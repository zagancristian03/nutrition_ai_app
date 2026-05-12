"""
Multilingual ranked search over `foods` + `food_aliases` (curated seed rows).

- source = 'seed': name + aliases + primary display alias per locale
- all sources: legacy `search_text` matching (manual / third-party unchanged)
"""
from __future__ import annotations

import logging
import time
from typing import Any

from psycopg2.extras import RealDictCursor

from food_search_text import locale_search_chain, normalize_food_search_text

log = logging.getLogger("foods.search")

_RESULT_LIMIT = 20

_LEGACY_SQL = """
SELECT
    f.id::text                        AS id,
    f.name,
    f.brand,
    f.calories_per_100g::float8       AS calories_per_100g,
    f.protein_per_100g::float8        AS protein_per_100g,
    f.carbs_per_100g::float8          AS carbs_per_100g,
    f.fat_per_100g::float8            AS fat_per_100g,
    f.serving_size_g::float8          AS serving_size_g,
    f.source                          AS source,
    f.search_text                     AS search_text,
    pd.alias                           AS _primary_alias
FROM foods f
LEFT JOIN food_aliases pd
       ON pd.food_id = f.id
      AND pd.locale = %s
      AND pd.is_primary = true
WHERE
    (
            f.search_text %% %s
        OR  f.search_text LIKE %s
        OR  f.search_text LIKE %s
    )
    AND coalesce(f.calories_per_100g, 0) between 1 and 900
    AND (
            coalesce(f.protein_per_100g, 0) > 0
         OR coalesce(f.carbs_per_100g,   0) > 0
         OR coalesce(f.fat_per_100g,     0) > 0
    )
ORDER BY
    CASE
        WHEN f.search_text LIKE %s THEN 1
        WHEN f.search_text LIKE %s THEN 2
        ELSE 3
    END,
    similarity(f.search_text, %s) DESC,
    length(f.search_text) ASC
LIMIT %s;
"""

_ALIAS_SQL = """
SELECT
    f.id::text                        AS id,
    f.name,
    f.brand,
    f.calories_per_100g::float8       AS calories_per_100g,
    f.protein_per_100g::float8        AS protein_per_100g,
    f.carbs_per_100g::float8          AS carbs_per_100g,
    f.fat_per_100g::float8            AS fat_per_100g,
    f.serving_size_g::float8          AS serving_size_g,
    f.source                          AS source,
    fa.alias                           AS matched_alias,
    fa.locale                          AS matched_locale,
    fa.normalized_alias                AS _match_nalias,
    pd.alias                           AS _primary_alias
FROM foods f
JOIN food_aliases fa ON fa.food_id = f.id
LEFT JOIN food_aliases pd
       ON pd.food_id = f.id
      AND pd.locale = %s
      AND pd.is_primary = true
WHERE f.source = 'seed'
  AND fa.locale = ANY(%s)
  AND (
        fa.normalized_alias = %s
     OR fa.normalized_alias LIKE %s
     OR fa.normalized_alias LIKE %s
     OR fa.normalized_alias %% %s
  )
  AND coalesce(f.calories_per_100g, 0) between 1 and 900
  AND (
        coalesce(f.protein_per_100g, 0) > 0
     OR coalesce(f.carbs_per_100g,   0) > 0
     OR coalesce(f.fat_per_100g,     0) > 0
  )
ORDER BY
  CASE WHEN fa.locale = %s THEN 0 ELSE 1 END,
  CASE
    WHEN fa.normalized_alias = %s THEN 1
    WHEN fa.normalized_alias LIKE %s THEN 2
    WHEN fa.normalized_alias LIKE %s THEN 3
    ELSE 4
  END,
  similarity(fa.normalized_alias, %s) DESC,
  length(fa.normalized_alias) ASC
LIMIT %s;
"""


def _tier_from_alias(preferred_locale: str, row: dict, q: str) -> int:
    nl = str(row.get("matched_locale") or "")
    na = str(row.get("_match_nalias") or normalize_food_search_text(
        str(row.get("matched_alias") or "")
    ))
    locale_bonus = 0 if nl == preferred_locale else 20
    if na == q:
        kind = 0
    elif q and na.startswith(q):
        kind = 4
    elif q and q in na:
        kind = 8
    else:
        kind = 12
    return 10 + locale_bonus + kind


def _tier_from_legacy(row: dict, q: str) -> int:
    st = str(row.get("search_text") or "")
    if st == q:
        kind = 0
    elif q and st.startswith(q):
        kind = 4
    elif q and q in st:
        kind = 8
    else:
        kind = 12
    return 50 + kind


def _shape_out(row: dict, *, display_locale: str) -> dict:
    src = row.get("source") or ""
    name = row.get("name") or ""
    primary = row.get("_primary_alias")
    if src == "seed" and primary:
        display_name = primary
    else:
        display_name = name

    out: dict[str, Any] = {
        "id": row["id"],
        "name": name,
        "brand": row.get("brand"),
        "calories_per_100g": row.get("calories_per_100g"),
        "protein_per_100g": row.get("protein_per_100g"),
        "carbs_per_100g": row.get("carbs_per_100g"),
        "fat_per_100g": row.get("fat_per_100g"),
        "serving_size_g": row.get("serving_size_g"),
        "canonical_name": name,
        "display_name": display_name,
    }
    ma = row.get("matched_alias")
    ml = row.get("matched_locale")
    if ma:
        out["matched_alias"] = ma
    if ml:
        out["matched_locale"] = ml
    return out


def run_food_search(
    conn: Any,
    *,
    raw_query: str,
    locale: str | None,
    limit: int = _RESULT_LIMIT,
) -> list[dict]:
    q = normalize_food_search_text(raw_query)
    if not q:
        return []

    locales = locale_search_chain(locale)
    display_locale = locales[0]
    preferred_locale = locales[0]
    prefix = f"{q}%"
    substr = f"%{q}%"
    alias_limit = min(max(limit * 25, 80), 400)

    started = time.perf_counter()
    rows_by_id: dict[str, tuple[dict, int]] = {}

    def consider(row: dict, tier: int) -> None:
        fid = str(row["id"])
        prev = rows_by_id.get(fid)
        if prev is None or tier < prev[1]:
            rows_by_id[fid] = (row, tier)

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            _ALIAS_SQL,
            (
                display_locale,
                locales,
                q,
                prefix,
                substr,
                q,
                preferred_locale,
                q,
                prefix,
                substr,
                q,
                alias_limit,
            ),
        )
        for row in cur.fetchall():
            r = dict(row)
            tier = _tier_from_alias(preferred_locale, r, q)
            consider(r, tier)

        cur.execute(
            _LEGACY_SQL,
            (
                display_locale,
                q,
                prefix,
                substr,
                prefix,
                substr,
                q,
                limit * 3,
            ),
        )
        for row in cur.fetchall():
            r = dict(row)
            tier = _tier_from_legacy(r, q)
            consider(r, tier)

    merged = sorted(rows_by_id.values(), key=lambda t: (t[1], len(str(t[0].get("name") or ""))))
    out = [_shape_out(dict(t[0]), display_locale=display_locale) for t in merged[:limit]]

    elapsed_ms = (time.perf_counter() - started) * 1000.0
    log.debug(
        "run_food_search q=%r locale=%r rows=%d ms=%.1f",
        q, locale, len(out), elapsed_ms,
    )
    return out
