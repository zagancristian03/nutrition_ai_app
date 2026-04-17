"""
Per-user nutrition targets.

The Flutter client stores nothing locally — it calls:

    GET  /user-goals/{user_id}    on app start / login
    PUT  /user-goals/{user_id}    when the user edits their targets

`user_id` is the Firebase Auth UID.
"""
from __future__ import annotations

import logging

from fastapi import APIRouter, HTTPException, Path
from psycopg2.extras import RealDictCursor

from db import get_conn
from schemas import UserGoals, UserGoalsUpdate

router = APIRouter(prefix="/user-goals", tags=["user-goals"])
log = logging.getLogger("user_goals")


# Default targets returned for a user that has never saved anything yet.
_DEFAULTS = {
    "calorie_goal": 2000.0,
    "protein_goal": 150.0,
    "carbs_goal":   250.0,
    "fat_goal":     65.0,
}


_SELECT_COLUMNS = """
    user_id,
    calorie_goal::float8    AS calorie_goal,
    protein_goal::float8    AS protein_goal,
    carbs_goal::float8      AS carbs_goal,
    fat_goal::float8        AS fat_goal
"""


@router.get("/{user_id}", response_model=UserGoals)
def get_user_goals(
    user_id: str = Path(..., min_length=1, max_length=128),
) -> dict:
    """
    Never 404. If a row doesn't exist we return the defaults — the client
    never has to special-case "new user" and the row is created lazily on
    the first PUT.
    """
    try:
        with get_conn() as conn, conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                f"SELECT {_SELECT_COLUMNS} FROM user_goals WHERE user_id = %s",
                (user_id,),
            )
            row = cur.fetchone()
    except Exception as e:  # noqa: BLE001
        log.exception("get_user_goals failed for %s", user_id)
        raise HTTPException(
            status_code=500,
            detail=f"get_user_goals failed: {type(e).__name__}: {str(e)[:200]}",
        ) from e

    if row is None:
        return {"user_id": user_id, **_DEFAULTS}
    return dict(row)


@router.put("/{user_id}", response_model=UserGoals)
def put_user_goals(
    payload: UserGoalsUpdate,
    user_id: str = Path(..., min_length=1, max_length=128),
) -> dict:
    """Upsert — creates the row on first call, updates it afterwards."""
    try:
        with get_conn() as conn:
            conn.autocommit = False
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(
                    f"""
                    INSERT INTO user_goals (
                        user_id, calorie_goal, protein_goal, carbs_goal, fat_goal
                    )
                    VALUES (%s, %s, %s, %s, %s)
                    ON CONFLICT (user_id) DO UPDATE SET
                        calorie_goal = excluded.calorie_goal,
                        protein_goal = excluded.protein_goal,
                        carbs_goal   = excluded.carbs_goal,
                        fat_goal     = excluded.fat_goal,
                        updated_at   = now()
                    RETURNING {_SELECT_COLUMNS}
                    """,
                    (
                        user_id,
                        payload.calorie_goal,
                        payload.protein_goal,
                        payload.carbs_goal,
                        payload.fat_goal,
                    ),
                )
                row = cur.fetchone()
                conn.commit()
    except Exception as e:  # noqa: BLE001
        log.exception("put_user_goals failed for %s", user_id)
        raise HTTPException(
            status_code=500,
            detail=f"put_user_goals failed: {type(e).__name__}: {str(e)[:200]}",
        ) from e

    assert row is not None
    return dict(row)
