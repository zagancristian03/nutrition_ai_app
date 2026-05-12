"""
Food catalog endpoints.

GET  /foods/search  — curated `food_aliases` + legacy `search_text` merge.

POST /foods         — insert a user-provided food (from the "add manually" UI)
                      and return the row so the client can diary it.

Seed foods (`source = 'seed'`) use multilingual aliases; manual and third-party
rows continue to match `foods.search_text` only (no auto-translation).
"""
from __future__ import annotations

import logging
import time
from uuid import uuid4

from fastapi import APIRouter, HTTPException, Query, Response
from psycopg2.extras import RealDictCursor

from cache import TTLCache
from db import get_conn
from food_search import run_food_search
from food_search_text import normalize_food_search_text, primary_locale_tag
from schemas import FoodCreate

router = APIRouter(prefix="/foods", tags=["foods"])
log = logging.getLogger("foods")

# Cache the final JSON payload keyed by normalized query + locale.
_SEARCH_CACHE: TTLCache[list[dict]] = TTLCache(maxsize=512, ttl_seconds=60.0)

# Single-character queries are allowed so short searches still hit the DB
# (still capped by LIMIT). Empty string is rejected by FastAPI min_length=1.
_MIN_QUERY_LEN = 1
_RESULT_LIMIT = 20


def _compact(row: dict | None) -> str:
    """Short representation of a search row, for uvicorn log lines."""
    if row is None:
        return "none"
    return (
        f"name={row.get('name')!r} "
        f"kcal={row.get('calories_per_100g')} "
        f"p={row.get('protein_per_100g')} "
        f"c={row.get('carbs_per_100g')} "
        f"f={row.get('fat_per_100g')}"
    )


# --------------------------------------------------------------------------- #
# GET /foods/_debug/stats — unfiltered ground-truth counts                    #
# --------------------------------------------------------------------------- #
_DEBUG_STATS_SQL = """
select
    count(*)                                                   as total,
    count(*) filter (where coalesce(calories_per_100g, 0) > 0) as with_kcal,
    count(*) filter (where coalesce(protein_per_100g, 0) > 0
                        or coalesce(carbs_per_100g,   0) > 0
                        or coalesce(fat_per_100g,     0) > 0) as with_any_macro,
    count(*) filter (where coalesce(calories_per_100g, 0) > 0
                       and (coalesce(protein_per_100g, 0) > 0
                         or coalesce(carbs_per_100g,   0) > 0
                         or coalesce(fat_per_100g,     0) > 0)) as passes_search_filter
from foods;
"""

_DEBUG_SAMPLE_SQL = """
select
    id::text                    as id,
    name, brand,
    calories_per_100g::float8   as calories_per_100g,
    protein_per_100g::float8    as protein_per_100g,
    carbs_per_100g::float8      as carbs_per_100g,
    fat_per_100g::float8        as fat_per_100g,
    serving_size_g::float8      as serving_size_g,
    source
from foods
order by calories_per_100g desc nulls last
limit 5;
"""


@router.get("/_debug/stats")
def debug_stats() -> dict:
    """
    Return a snapshot of what's actually in the `foods` table.

    Fields:
      * total                — all rows
      * with_kcal            — rows where calories_per_100g > 0
      * with_any_macro       — rows with at least one macro > 0
      * passes_search_filter — rows that the /foods/search WHERE clause accepts
      * top_by_kcal          — 5 sample rows, highest calories first
    """
    try:
        with get_conn() as conn, conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(_DEBUG_STATS_SQL)
            counts = dict(cur.fetchone() or {})
            cur.execute(_DEBUG_SAMPLE_SQL)
            sample = [dict(r) for r in cur.fetchall()]
    except Exception as e:  # noqa: BLE001
        log.exception("debug_stats failed")
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}") from e

    return {"counts": counts, "top_by_kcal": sample}


@router.get("/search")
def search_foods(
    response: Response,
    q: str = Query(..., min_length=1, max_length=100, description="Search term"),
    locale: str | None = Query(
        default=None,
        max_length=32,
        description="BCP-47 language tag for alias/display preference (e.g. ro, en).",
    ),
    seq: int | None = Query(
        default=None,
        ge=0,
        description=(
            "Optional client-side monotonic request id. Echoed back as the "
            "`X-Seq` header so the client can discard stale responses."
        ),
    ),
) -> list[dict]:
    term = normalize_food_search_text(q)
    locale_key = primary_locale_tag(locale)

    if len(term) < _MIN_QUERY_LEN:
        response.headers["X-Cache"] = "BYPASS"
        if seq is not None:
            response.headers["X-Seq"] = str(seq)
        return []

    cache_key = f"{term}\x1f{locale_key}"
    cached = _SEARCH_CACHE.get(cache_key)
    if cached is not None:
        response.headers["X-Cache"] = "HIT"
        if seq is not None:
            response.headers["X-Seq"] = str(seq)
        return cached

    started = time.perf_counter()
    try:
        with get_conn() as conn:
            rows = run_food_search(
                conn,
                raw_query=q,
                locale=locale,
                limit=_RESULT_LIMIT,
            )
    except Exception as e:  # noqa: BLE001
        log.exception("search failed q=%r locale=%r", term, locale_key)
        raise HTTPException(status_code=503, detail="search failed") from e

    elapsed_ms = (time.perf_counter() - started) * 1000.0
    sample = rows[0] if rows else None
    log.info(
        "search q=%r locale=%r rows=%d took=%.1fms sample=%s",
        term, locale_key, len(rows), elapsed_ms,
        _compact(sample),
    )

    _SEARCH_CACHE.set(cache_key, rows)

    response.headers["X-Cache"] = "MISS"
    response.headers["X-Elapsed-Ms"] = f"{elapsed_ms:.1f}"
    if seq is not None:
        response.headers["X-Seq"] = str(seq)

    return rows


# --------------------------------------------------------------------------- #
# POST /foods — user-authored (manual) entries                                #
# --------------------------------------------------------------------------- #
_INSERT_SQL = """
INSERT INTO foods (
    id,
    name, brand,
    calories_per_100g, protein_per_100g, carbs_per_100g, fat_per_100g,
    serving_size_g,
    source, source_food_id
)
VALUES (%s, %s, %s, %s, %s, %s, %s, %s, 'manual', %s)
RETURNING
    id::text                    AS id,
    name,
    brand,
    calories_per_100g::float8   AS calories_per_100g,
    protein_per_100g::float8    AS protein_per_100g,
    carbs_per_100g::float8      AS carbs_per_100g,
    fat_per_100g::float8        AS fat_per_100g,
    serving_size_g::float8      AS serving_size_g,
    name                        AS canonical_name,
    name                        AS display_name
"""


@router.post("", status_code=201)
def create_food(payload: FoodCreate) -> dict:
    name  = payload.name.strip().lower()
    brand = payload.brand.strip().lower() if payload.brand else None
    if not name:
        raise HTTPException(status_code=422, detail="name cannot be empty")

    # Generate the UUID server-side so this works regardless of whether the
    # `foods.id` column has a `DEFAULT gen_random_uuid()` in Supabase.
    new_id = uuid4()

    # Some Supabase installs enforce NOT NULL on `source_food_id` via legacy
    # migrations. We just mirror the UUID — it's guaranteed unique and keeps
    # the (source, source_food_id) partial unique index honest.
    source_food_id = f"manual:{new_id}"

    try:
        with get_conn() as conn:
            conn.autocommit = False
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(
                    _INSERT_SQL,
                    (
                        str(new_id),
                        name,
                        brand,
                        round(payload.calories_per_100g, 2),
                        round(payload.protein_per_100g, 3),
                        round(payload.carbs_per_100g,   3),
                        round(payload.fat_per_100g,     3),
                        payload.serving_size_g,
                        source_food_id,
                    ),
                )
                row = cur.fetchone()
                conn.commit()
    except Exception as e:  # noqa: BLE001
        log.exception("create_food failed")
        # Expose the real DB error in the response — massively helpful while
        # we're still wiring this up. Trim to keep the payload reasonable.
        detail = f"create food failed: {type(e).__name__}: {str(e)[:400]}"
        raise HTTPException(status_code=500, detail=detail) from e

    # New row is now searchable — clear cached (possibly empty) results.
    _SEARCH_CACHE.clear()

    assert row is not None
    out = dict(row)
    # Manual entries: stable canonical + UI display = user-entered name.
    out.setdefault("canonical_name", out.get("name"))
    out.setdefault("display_name", out.get("name"))
    return out
