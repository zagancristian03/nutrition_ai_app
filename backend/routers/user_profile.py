"""
Per-user body-stats / goal profile.

    GET  /user-profile/{user_id}    -> UserProfile (empty row returned for new users)
    PUT  /user-profile/{user_id}    -> upsert (partial update allowed)

Every column is nullable — the client fills them in progressively on the
"Edit Profile" screen. Only provided fields are written on PUT.
"""
from __future__ import annotations

import logging
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Path
from psycopg2.extras import RealDictCursor

from auth_firebase import get_current_uid, require_same_user
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
    updated_at,
    coalesce(locale_mode, 'system')       AS locale_mode,
    preferred_locale,
    timezone,
    locale_updated_at,
    measurement_system
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
    "locale_mode",
    "preferred_locale",
    "timezone",
    "measurement_system",
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
        "locale_mode":       "system",
        "preferred_locale":  None,
        "timezone":          None,
        "locale_updated_at": None,
        "measurement_system": None,
    }


@router.get("/{user_id}", response_model=UserProfile)
def get_user_profile(
    user_id: str = Path(..., min_length=1, max_length=128),
    uid: Annotated[str, Depends(get_current_uid)] = ...,
) -> dict:
    require_same_user(uid, user_id)
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
    uid: Annotated[str, Depends(get_current_uid)] = ...,
) -> dict:
    """Upsert. Missing fields in the payload are *not* overwritten on an existing
    row — we only write the fields the client explicitly sent. On first call
    (insert) any unset field just defaults to NULL."""
    require_same_user(uid, user_id)
    provided = payload.model_dump(exclude_unset=True)

    # Always use INSERT ... ON CONFLICT. For missing columns we pass NULL and
    # skip updating them in the UPDATE branch.
    def _coerce_insert_val(col: str) -> object:
        v = provided.get(col)
        if col == "locale_mode" and v is None:
            return "system"
        return v

    insert_cols  = ["user_id", *_WRITABLE]
    insert_vals  = [user_id] + [_coerce_insert_val(c) for c in _WRITABLE]
    update_parts = [f"{c} = excluded.{c}" for c in _WRITABLE if c in provided]
    locale_touch = {"locale_mode", "preferred_locale", "timezone", "measurement_system"}
    if locale_touch & set(provided.keys()):
        update_parts.append("locale_updated_at = now()")
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
