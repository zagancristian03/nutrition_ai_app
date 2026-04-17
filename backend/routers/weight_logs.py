"""
Time-series weight tracking.

    POST   /weight-logs                            -> insert-or-update (one row per user per day)
    GET    /weight-logs?user_id=&days=             -> most recent N days, chronological
    DELETE /weight-logs/{id}?user_id=              -> delete own row
"""
from __future__ import annotations

import logging
from datetime import date, timedelta

from fastapi import APIRouter, HTTPException, Query, Response
from psycopg2.extras import RealDictCursor

from db import get_conn
from schemas import WeightLogCreate, WeightLogOut

router = APIRouter(prefix="/weight-logs", tags=["weight-logs"])
log = logging.getLogger("weight_logs")


_SELECT_COLUMNS = """
    id,
    user_id,
    weight_kg::float8   AS weight_kg,
    logged_on,
    note,
    created_at
"""


@router.post("", response_model=WeightLogOut, status_code=201)
def create_weight_log(payload: WeightLogCreate) -> dict:
    """
    Upsert on (user_id, logged_on) — a user editing their weight for the same
    day replaces the previous entry rather than creating duplicates. This
    matches the UX: the chart shows one point per day.
    """
    logged_on = payload.logged_on or date.today()
    try:
        with get_conn() as conn:
            conn.autocommit = False
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(
                    f"""
                    INSERT INTO weight_logs (user_id, weight_kg, logged_on, note)
                    VALUES (%s, %s, %s, %s)
                    ON CONFLICT (user_id, logged_on) DO UPDATE SET
                        weight_kg  = excluded.weight_kg,
                        note       = excluded.note,
                        created_at = now()
                    RETURNING {_SELECT_COLUMNS}
                    """,
                    (payload.user_id, payload.weight_kg, logged_on, payload.note),
                )
                row = cur.fetchone()

                # Also reflect the new weight on the user's profile so
                # Progress / Dashboard stay in sync without an extra PUT.
                cur.execute(
                    """
                    INSERT INTO user_profiles (user_id, current_weight_kg)
                    VALUES (%s, %s)
                    ON CONFLICT (user_id) DO UPDATE SET
                        current_weight_kg = excluded.current_weight_kg,
                        updated_at        = now()
                    """,
                    (payload.user_id, payload.weight_kg),
                )
                conn.commit()
    except Exception as e:  # noqa: BLE001
        log.exception("create_weight_log failed for %s", payload.user_id)
        raise HTTPException(
            status_code=500,
            detail=f"create_weight_log failed: {type(e).__name__}: {str(e)[:200]}",
        ) from e

    assert row is not None
    return dict(row)


@router.get("", response_model=list[WeightLogOut])
def list_weight_logs(
    user_id: str = Query(..., min_length=1, max_length=128),
    days:    int = Query(default=180, ge=1, le=3650),
) -> list[dict]:
    """Chronological list (oldest first) — ready to feed straight into a chart."""
    since = date.today() - timedelta(days=days)
    try:
        with get_conn() as conn, conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                f"""
                SELECT {_SELECT_COLUMNS}
                FROM weight_logs
                WHERE user_id = %s AND logged_on >= %s
                ORDER BY logged_on ASC
                """,
                (user_id, since),
            )
            rows = cur.fetchall() or []
    except Exception as e:  # noqa: BLE001
        log.exception("list_weight_logs failed for %s", user_id)
        raise HTTPException(
            status_code=500,
            detail=f"list_weight_logs failed: {type(e).__name__}: {str(e)[:200]}",
        ) from e

    return [dict(r) for r in rows]


@router.delete("/{log_id}", response_class=Response)
def delete_weight_log(
    log_id:  int,
    user_id: str = Query(..., min_length=1, max_length=128),
) -> Response:
    try:
        with get_conn() as conn:
            conn.autocommit = False
            with conn.cursor() as cur:
                cur.execute(
                    "DELETE FROM weight_logs WHERE id = %s AND user_id = %s",
                    (log_id, user_id),
                )
                affected = cur.rowcount
                conn.commit()
    except Exception as e:  # noqa: BLE001
        log.exception("delete_weight_log failed for %s", user_id)
        raise HTTPException(
            status_code=500,
            detail=f"delete_weight_log failed: {type(e).__name__}: {str(e)[:200]}",
        ) from e

    if affected == 0:
        raise HTTPException(status_code=404, detail="weight log not found")
    return Response(status_code=204)
