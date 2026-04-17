"""
Food catalog endpoints.

GET  /foods/search  — trigram-ranked fuzzy + substring + prefix search.
POST /foods         — insert a user-provided food (from the "add manually" UI)
                      and return the row so the client can diary it.

All three search operators share the single GIN(gin_trgm_ops) index on
`foods.search_text`.
"""
from __future__ import annotations

import logging
import re
import time
from uuid import uuid4

from fastapi import APIRouter, HTTPException, Query, Response
from psycopg2.extras import RealDictCursor

from cache import TTLCache
from db import get_conn
from schemas import FoodCreate

router = APIRouter(prefix="/foods", tags=["foods"])
log = logging.getLogger("foods")

# Cache the final JSON payload keyed by normalized query.
_SEARCH_CACHE: TTLCache[list[dict]] = TTLCache(maxsize=512, ttl_seconds=60.0)

_MIN_QUERY_LEN = 2
_RESULT_LIMIT = 20
_WS_RE = re.compile(r"\s+")


# NOTE: `%%` is psycopg2's literal-percent escape when using %(name)s params,
# so `search_text %% %(q)s` becomes `search_text % :q` — the pg_trgm operator.
#
# NOTE 2: macro columns are explicitly cast to `float8`. The Supabase tables
# use `numeric`, which psycopg2 maps to Python `Decimal`; FastAPI then
# serializes Decimals as JSON *strings* (to preserve precision), which the
# Flutter client can't read as numbers. Casting pins them to JSON numbers.
_SEARCH_SQL = """
SELECT
    id::text                        AS id,
    name,
    brand,
    calories_per_100g::float8       AS calories_per_100g,
    protein_per_100g::float8        AS protein_per_100g,
    carbs_per_100g::float8          AS carbs_per_100g,
    fat_per_100g::float8            AS fat_per_100g,
    serving_size_g::float8          AS serving_size_g
FROM foods
WHERE
    (
            search_text %% %(q)s
        OR  search_text LIKE %(prefix)s
        OR  search_text LIKE %(substr)s
    )
    -- Quality gate:
    --   * non-zero calories
    --   * implausibly high kcal (> 900 per 100 g) indicates bad source data
    --     (e.g. kJ values accidentally stored as kcal); hide those too
    --   * at least one macro must be present — a calorie-only row is useless
    AND coalesce(calories_per_100g, 0) between 1 and 900
    AND (
            coalesce(protein_per_100g, 0) > 0
         OR coalesce(carbs_per_100g,   0) > 0
         OR coalesce(fat_per_100g,     0) > 0
    )
ORDER BY
    CASE
        WHEN search_text LIKE %(prefix)s THEN 1
        WHEN search_text LIKE %(substr)s THEN 2
        ELSE 3
    END,
    similarity(search_text, %(q)s) DESC,
    length(search_text) ASC
LIMIT %(limit)s;
"""


def _normalize(raw: str) -> str:
    """lowercase, trim, collapse whitespace — matches `foods.search_text`."""
    return _WS_RE.sub(" ", raw.strip().lower())


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
    seq: int | None = Query(
        default=None,
        ge=0,
        description=(
            "Optional client-side monotonic request id. Echoed back as the "
            "`X-Seq` header so the client can discard stale responses."
        ),
    ),
) -> list[dict]:
    term = _normalize(q)

    if len(term) < _MIN_QUERY_LEN:
        response.headers["X-Cache"] = "BYPASS"
        if seq is not None:
            response.headers["X-Seq"] = str(seq)
        return []

    cached = _SEARCH_CACHE.get(term)
    if cached is not None:
        response.headers["X-Cache"] = "HIT"
        if seq is not None:
            response.headers["X-Seq"] = str(seq)
        return cached

    started = time.perf_counter()
    try:
        with get_conn() as conn, conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                _SEARCH_SQL,
                {
                    "q":      term,
                    "prefix": f"{term}%",
                    "substr": f"%{term}%",
                    "limit":  _RESULT_LIMIT,
                },
            )
            rows = [dict(r) for r in cur.fetchall()]
    except Exception as e:  # noqa: BLE001
        log.exception("search failed q=%r", term)
        raise HTTPException(status_code=503, detail="search failed") from e

    elapsed_ms = (time.perf_counter() - started) * 1000.0
    sample = rows[0] if rows else None
    log.info(
        "search q=%r rows=%d took=%.1fms sample=%s",
        term, len(rows), elapsed_ms,
        _compact(sample),
    )

    _SEARCH_CACHE.set(term, rows)

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
    serving_size_g::float8      AS serving_size_g
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
    return dict(row)
