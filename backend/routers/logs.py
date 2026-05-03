"""
Food diary endpoints.

Critical invariant: every row inserted into `food_logs` carries a SNAPSHOT of
the macros AND the food name at that moment. A later update to `foods` does
not retroactively rewrite history — the diary always shows what the user
actually ate, even if the food is later renamed or removed from the catalog.
"""
from __future__ import annotations

import logging
from datetime import date

from fastapi import APIRouter, HTTPException, Query, Response
from psycopg2.extras import RealDictCursor

from db import get_conn
from schemas import FoodLogCreate, FoodLogOut, FoodLogUpdate

router = APIRouter(prefix="/food-logs", tags=["food-logs"])
log = logging.getLogger("food_logs")


# Canonical SELECT list for every /food-logs endpoint.
#
# Casts to float8 for the same reason as /foods/search: Supabase stores these
# as `numeric`, which psycopg2 returns as Python Decimal, which FastAPI then
# serializes as JSON *strings* — breaking the Flutter client.
_LOG_COLUMNS = """
    id,
    user_id,
    food_id::text               AS food_id,
    food_name,
    logged_date,
    meal_type,
    grams::float8               AS grams,
    servings::float8            AS servings,
    calories::float8            AS calories,
    protein::float8             AS protein,
    carbs::float8               AS carbs,
    fat::float8                 AS fat,
    created_at
"""


def _snapshot_macros(
    *,
    calories_per_100g: float | None,
    protein_per_100g: float | None,
    carbs_per_100g: float | None,
    fat_per_100g: float | None,
    serving_size_g: float | None,
    grams: float | None,
    servings: float | None,
) -> tuple[float, float, float, float, float]:
    """
    Resolve the portion to grams, then derive (calories, protein, carbs, fat).

    Rules:
      - `grams` wins if provided.
      - Otherwise `servings * serving_size_g` is used (both required).
      - Macros default to 0.0 when the source row is missing a value
        (better than failing the insert on partial OFF data).
    """
    # Normalize every number to `float` up front. Supabase `numeric` columns
    # come back as Decimal through psycopg2 — mixing them with float raises
    # TypeError later.
    def _f(v: object) -> float:
        return float(v) if v is not None else 0.0

    kcal = _f(calories_per_100g)
    prot = _f(protein_per_100g)
    carb = _f(carbs_per_100g)
    fat  = _f(fat_per_100g)
    size = _f(serving_size_g)
    g    = _f(grams) if grams is not None else None
    s    = _f(servings) if servings is not None else None

    if g is None:
        if s is None or size <= 0:
            raise HTTPException(
                status_code=400,
                detail=(
                    "Cannot resolve portion. Provide `grams`, or `servings` "
                    "together with a known `serving_size_g` on the food row."
                ),
            )
        g = s * size

    factor = g / 100.0
    return (
        g,
        kcal * factor,
        prot * factor,
        carb * factor,
        fat  * factor,
    )


# --------------------------------------------------------------------------- #
# POST /food-logs                                                             #
# --------------------------------------------------------------------------- #
@router.post("", response_model=FoodLogOut, status_code=201)
def create_food_log(payload: FoodLogCreate) -> dict:
    with get_conn() as conn:
        conn.autocommit = False
        try:
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                # Cast the macro columns to float8 at the DB boundary.
                # Supabase stores these as `numeric`, which psycopg2 maps to
                # Python Decimal — and `Decimal * float` raises TypeError in
                # `_snapshot_macros`. float8 rounds through as native float.
                cur.execute(
                    """
                    SELECT name,
                           calories_per_100g::float8   AS calories_per_100g,
                           protein_per_100g::float8    AS protein_per_100g,
                           carbs_per_100g::float8      AS carbs_per_100g,
                           fat_per_100g::float8        AS fat_per_100g,
                           serving_size_g::float8      AS serving_size_g
                    FROM foods
                    WHERE id = %s
                    """,
                    (str(payload.food_id),),
                )
                food = cur.fetchone()
                if food is None:
                    raise HTTPException(status_code=404, detail="food not found")

                grams, cals, protein, carbs, fat = _snapshot_macros(
                    calories_per_100g=food["calories_per_100g"],
                    protein_per_100g=food["protein_per_100g"],
                    carbs_per_100g=food["carbs_per_100g"],
                    fat_per_100g=food["fat_per_100g"],
                    serving_size_g=food["serving_size_g"],
                    grams=payload.grams,
                    servings=payload.servings,
                )

                cur.execute(
                    f"""
                    INSERT INTO food_logs (
                        user_id, food_id, food_name, logged_date, meal_type,
                        grams, servings,
                        calories, protein, carbs, fat
                    )
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    RETURNING {_LOG_COLUMNS}
                    """,
                    (
                        payload.user_id,
                        str(payload.food_id),
                        food["name"] or "",
                        payload.logged_date,
                        payload.meal_type,
                        grams,
                        payload.servings,
                        round(cals,    2),
                        round(protein, 3),
                        round(carbs,   3),
                        round(fat,     3),
                    ),
                )
                row = cur.fetchone()
                conn.commit()
        except HTTPException:
            conn.rollback()
            raise
        except Exception as e:  # noqa: BLE001
            conn.rollback()
            log.exception("create_food_log failed")
            raise HTTPException(
                status_code=500,
                detail=f"create_food_log failed: {type(e).__name__}: {str(e)[:200]}",
            ) from e

    assert row is not None
    return dict(row)


# --------------------------------------------------------------------------- #
# GET /food-logs/recent-foods — one row per food_id, latest activity first    #
# --------------------------------------------------------------------------- #
_RECENT_FOODS_SQL = f"""
    SELECT * FROM (
        SELECT DISTINCT ON (food_id)
            id,
            user_id,
            food_id::text               AS food_id,
            food_name,
            logged_date,
            meal_type,
            grams::float8               AS grams,
            servings::float8            AS servings,
            calories::float8            AS calories,
            protein::float8             AS protein,
            carbs::float8               AS carbs,
            fat::float8                 AS fat,
            created_at
        FROM food_logs
        WHERE user_id = %s
        ORDER BY food_id, created_at DESC
    ) AS t
    ORDER BY t.created_at DESC
    LIMIT %s
"""


@router.get("/recent-foods", response_model=list[FoodLogOut])
def list_recent_distinct_foods(
    user_id: str = Query(..., min_length=1, max_length=128),
    limit: int = Query(default=30, ge=1, le=100),
) -> list[dict]:
    """
    Foods the user has logged before, ordered by most recently logged instance
    (any meal). Each `food_id` appears once — the row is the latest diary
    entry for that catalog item (includes snapshot grams/servings for quick re-log).
    """
    with get_conn() as conn, conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(_RECENT_FOODS_SQL, (user_id, limit))
        return [dict(r) for r in cur.fetchall()]


# --------------------------------------------------------------------------- #
# GET /food-logs                                                              #
# --------------------------------------------------------------------------- #
@router.get("", response_model=list[FoodLogOut])
def list_food_logs(
    user_id: str = Query(..., min_length=1, max_length=128),
    logged_date: date | None = Query(default=None, description="Filter by date (YYYY-MM-DD)"),
    limit: int = Query(default=200, ge=1, le=500),
) -> list[dict]:
    clauses = ["user_id = %s"]
    params: list = [user_id]
    if logged_date is not None:
        clauses.append("logged_date = %s")
        params.append(logged_date)
    params.append(limit)

    sql = f"""
        SELECT {_LOG_COLUMNS}
        FROM food_logs
        WHERE {' AND '.join(clauses)}
        ORDER BY logged_date DESC, created_at ASC
        LIMIT %s
    """

    with get_conn() as conn, conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(sql, tuple(params))
        return [dict(r) for r in cur.fetchall()]


# --------------------------------------------------------------------------- #
# PUT /food-logs/{log_id}                                                     #
# --------------------------------------------------------------------------- #
@router.put("/{log_id}", response_model=FoodLogOut)
def update_food_log(
    log_id: int,
    payload: FoodLogUpdate,
    user_id: str = Query(..., min_length=1, max_length=128),
) -> dict:
    """
    Partial update. Only the fields present in the payload are written; all
    others are preserved. The user_id from the query string must match the
    row — prevents a user from editing another user's diary.
    """
    updates: dict = payload.model_dump(exclude_none=True)

    if not updates:
        raise HTTPException(status_code=400, detail="no fields to update")

    set_clauses = [f"{col} = %({col})s" for col in updates.keys()]
    sql = f"""
        UPDATE food_logs
        SET {', '.join(set_clauses)}
        WHERE id = %(log_id)s AND user_id = %(user_id)s
        RETURNING {_LOG_COLUMNS}
    """

    params = {**updates, "log_id": log_id, "user_id": user_id}

    with get_conn() as conn:
        conn.autocommit = False
        try:
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(sql, params)
                row = cur.fetchone()
                if row is None:
                    raise HTTPException(status_code=404, detail="food log not found")
                conn.commit()
        except HTTPException:
            conn.rollback()
            raise
        except Exception as e:  # noqa: BLE001
            conn.rollback()
            log.exception("update_food_log failed")
            raise HTTPException(
                status_code=500,
                detail=f"update_food_log failed: {type(e).__name__}: {str(e)[:200]}",
            ) from e

    return dict(row)


# --------------------------------------------------------------------------- #
# DELETE /food-logs/{log_id}                                                  #
# --------------------------------------------------------------------------- #
@router.delete("/{log_id}", status_code=204, response_class=Response)
def delete_food_log(
    log_id: int,
    user_id: str = Query(..., min_length=1, max_length=128),
) -> Response:
    with get_conn() as conn:
        conn.autocommit = True
        with conn.cursor() as cur:
            cur.execute(
                "DELETE FROM food_logs WHERE id = %s AND user_id = %s",
                (log_id, user_id),
            )
            if cur.rowcount == 0:
                raise HTTPException(status_code=404, detail="food log not found")
    return Response(status_code=204)
