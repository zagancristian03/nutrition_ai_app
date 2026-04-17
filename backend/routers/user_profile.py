"""
Per-user body-stats / goal profile.

    GET  /user-profile/{user_id}    -> UserProfile (empty row returned for new users)
    PUT  /user-profile/{user_id}    -> upsert (partial update allowed)

Every column is nullable — the client fills them in progressively on the
"Edit Profile" screen. Only provided fields are written on PUT.
"""
from __future__ import annotations

import logging

from fastapi import APIRouter, HTTPException, Path
from psycopg2.extras import RealDictCursor

from db import get_conn
from schemas import UserProfile, UserProfileUpdate

router = APIRouter(prefix="/user-profile", tags=["user-profile"])
log = logging.getLogger("user_profile")


# Columns are cast so psycopg2's Decimal/None don't leak into the JSON payload.
_SELECT_COLUMNS = """
    user_id,
    display_name,
    sex,
    date_of_birth,
    height_cm::float8           AS height_cm,
    current_weight_kg::float8   AS current_weight_kg,
    target_weight_kg::float8    AS target_weight_kg,
    goal_type,
    activity_level,
    weekly_rate_kg::float8      AS weekly_rate_kg,
    updated_at
"""

# Fields that are writable via PUT — order matters for SQL generation.
_WRITABLE: tuple[str, ...] = (
    "display_name",
    "sex",
    "date_of_birth",
    "height_cm",
    "current_weight_kg",
    "target_weight_kg",
    "goal_type",
    "activity_level",
    "weekly_rate_kg",
)


def _empty_profile(user_id: str) -> dict:
    """Skeleton payload for users that have never saved a profile yet."""
    return {
        "user_id":           user_id,
        "display_name":      None,
        "sex":               None,
        "date_of_birth":     None,
        "height_cm":         None,
        "current_weight_kg": None,
        "target_weight_kg":  None,
        "goal_type":         None,
        "activity_level":    None,
        "weekly_rate_kg":    None,
        "updated_at":        None,
    }


@router.get("/{user_id}", response_model=UserProfile)
def get_user_profile(
    user_id: str = Path(..., min_length=1, max_length=128),
) -> dict:
    try:
        with get_conn() as conn, conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                f"SELECT {_SELECT_COLUMNS} FROM user_profiles WHERE user_id = %s",
                (user_id,),
            )
            row = cur.fetchone()
    except Exception as e:  # noqa: BLE001
        log.exception("get_user_profile failed for %s", user_id)
        raise HTTPException(
            status_code=500,
            detail=f"get_user_profile failed: {type(e).__name__}: {str(e)[:200]}",
        ) from e

    return dict(row) if row else _empty_profile(user_id)


@router.put("/{user_id}", response_model=UserProfile)
def put_user_profile(
    payload: UserProfileUpdate,
    user_id: str = Path(..., min_length=1, max_length=128),
) -> dict:
    """
    Upsert. Missing fields in the payload are *not* overwritten on an existing
    row — we only write the fields the client explicitly sent. On first call
    (insert) any unset field just defaults to NULL.
    """
    provided = payload.model_dump(exclude_unset=True)

    # Always use INSERT ... ON CONFLICT. For missing columns we pass NULL and
    # skip updating them in the UPDATE branch.
    insert_cols  = ["user_id", *_WRITABLE]
    insert_vals  = [user_id] + [provided.get(c) for c in _WRITABLE]
    update_parts = [f"{c} = excluded.{c}" for c in _WRITABLE if c in provided]
    # updated_at is always refreshed.
    update_parts.append("updated_at = now()")

    placeholders = ", ".join(["%s"] * len(insert_cols))
    update_sql   = ", ".join(update_parts) if update_parts else "updated_at = now()"

    sql = f"""
        INSERT INTO user_profiles ({', '.join(insert_cols)})
        VALUES ({placeholders})
        ON CONFLICT (user_id) DO UPDATE SET {update_sql}
        RETURNING {_SELECT_COLUMNS}
    """

    try:
        with get_conn() as conn:
            conn.autocommit = False
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(sql, insert_vals)
                row = cur.fetchone()
                conn.commit()
    except Exception as e:  # noqa: BLE001
        log.exception("put_user_profile failed for %s", user_id)
        raise HTTPException(
            status_code=500,
            detail=f"put_user_profile failed: {type(e).__name__}: {str(e)[:200]}",
        ) from e

    assert row is not None
    return dict(row)
