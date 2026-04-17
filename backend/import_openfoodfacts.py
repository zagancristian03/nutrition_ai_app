#!/usr/bin/env python3
"""
Import a batch from an Open Food Facts CSV/TSV export into Supabase `foods`.

The export may be UTF-8 or UTF-16 (common when saving from Excel on Windows),
tab- or comma-separated.

Cleaning pipeline per row:
  * lowercase + strip every text field
  * collapse internal whitespace
  * drop rows with no name / no code / no resolvable energy value
  * convert kJ → kcal (4.184) when kcal is missing
  * parse serving_size_g from free-form "30 g" / "1.5 oz" strings
  * in-run deduplication on (name, brand) AFTER normalization

The DB layer still enforces uniqueness on (source, source_food_id) via a
partial unique index, which protects against cross-run duplicates.

Requires:
  - backend/.env with DATABASE_URL (same as FastAPI).
  - Table `foods` populated by database/schema/001_foods.sql.

Run:
  cd backend
  python import_openfoodfacts.py --file data/off_slice.tsv
  python import_openfoodfacts.py --file data/off_slice.tsv --max-rows 8000
"""
from __future__ import annotations

import argparse
import csv
import gzip
import os
import re
import sys
from pathlib import Path

import psycopg2
from dotenv import load_dotenv

SOURCE = "open_food_facts"

_BACKEND_DIR = Path(__file__).resolve().parent
load_dotenv(_BACKEND_DIR / ".env")

# search_text is a generated column — we never insert it directly.
INSERT_SQL = """
INSERT INTO foods (
    source, source_food_id, name, brand,
    calories_per_100g, protein_per_100g, carbs_per_100g, fat_per_100g,
    serving_size_g
) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
ON CONFLICT (source, source_food_id) DO NOTHING
"""

# OFF column aliases — first match wins for text fields.
NAME_KEYS         = ("product_name", "generic_name")
CODE_KEYS         = ("code",)
BRAND_KEYS        = ("brands", "brands_en", "brand_owner")
KCAL_KEYS         = ("energy-kcal_100g",)
KJ_KEYS           = ("energy-kj_100g",)
ENERGY_100G_KEYS  = ("energy_100g",)  # typically kJ per 100 g in OFF
PROTEIN_KEYS      = ("proteins_100g", "protein_100g")
CARB_KEYS         = ("carbohydrates_100g", "carbohydrate_100g", "carbs_100g")
FAT_KEYS          = ("fat_100g",)
SERVING_SIZE_KEYS = ("serving_size",)
SERVING_QTY_KEYS  = ("serving_quantity",)  # OFF often fills this with grams

_MAX_ROWS_CAP = 500_000
_WS_RE = re.compile(r"\s+")

# "30 g", "1.5 oz", "250ml", "3,5 g" etc.
_SERVING_RE = re.compile(
    r"""
    ^\s*
    (?P<num>[0-9]+(?:[.,][0-9]+)?)
    \s*
    (?P<unit>g|gram|grams|kg|mg|ml|cl|l|oz|lb)?
    \b
    """,
    re.IGNORECASE | re.VERBOSE,
)

_UNIT_TO_GRAMS = {
    "g": 1.0, "gram": 1.0, "grams": 1.0,
    "kg": 1000.0,
    "mg": 0.001,
    "ml": 1.0,       # assume density ~= 1 for ml/cl/l (good enough for UI defaults)
    "cl": 10.0,
    "l":  1000.0,
    "oz": 28.3495,
    "lb": 453.592,
}


# --------------------------------------------------------------------------- #
# File handling                                                               #
# --------------------------------------------------------------------------- #
def _encoding_from_bom(start: bytes) -> str:
    if len(start) >= 2 and start[:2] in (b"\xff\xfe", b"\xfe\xff"):
        return "utf-16"
    if start.startswith(b"\xef\xbb\xbf"):
        return "utf-8-sig"
    return "utf-8-sig"


def _peek_start_bytes(path: Path, n: int = 4096) -> bytes:
    if path.suffix.lower() == ".gz":
        with gzip.open(path, "rb") as gf:
            return gf.read(n)
    with path.open("rb") as bf:
        return bf.read(n)


def open_text(path: Path):
    enc = _encoding_from_bom(_peek_start_bytes(path))
    if path.suffix.lower() == ".gz":
        return gzip.open(path, "rt", encoding=enc, newline="", errors="replace")
    return path.open("r", encoding=enc, newline="", errors="replace")


def sniff_delimiter(sample_line: str) -> str:
    return "\t" if sample_line.count("\t") > sample_line.count(",") else ","


def build_column_map(fieldnames: list[str] | None) -> dict[str, str]:
    if not fieldnames:
        return {}
    mapping: dict[str, str] = {}
    for raw in fieldnames:
        if raw is None:
            continue
        logical = raw.lstrip("\ufeff").strip()
        mapping[logical] = raw
    return mapping


# --------------------------------------------------------------------------- #
# Cell extraction / parsing                                                   #
# --------------------------------------------------------------------------- #
def _clean_text(raw: str | None) -> str | None:
    """Lowercase, strip, collapse whitespace. Returns None for empty/whitespace."""
    if raw is None:
        return None
    s = _WS_RE.sub(" ", str(raw).strip()).lower()
    return s or None


def cell(row: dict[str, str], col_map: dict[str, str], *logical_names: str) -> str | None:
    """First non-empty raw value among logical column names (not lowercased)."""
    for name in logical_names:
        key = col_map.get(name)
        if not key:
            continue
        val = row.get(key)
        if val is None:
            continue
        s = str(val).strip()
        if s:
            return s
    return None


def cell_clean(row: dict[str, str], col_map: dict[str, str], *logical_names: str) -> str | None:
    return _clean_text(cell(row, col_map, *logical_names))


def parse_float(raw: str | None) -> float | None:
    if raw is None:
        return None
    s = str(raw).strip()
    if not s:
        return None
    try:
        return float(s.replace(",", "."))
    except ValueError:
        return None


def resolve_kcal_per_100g(row: dict[str, str], col_map: dict[str, str]) -> float | None:
    """Prefer explicit kcal, fall back to kJ / 4.184."""
    kcal = parse_float(cell(row, col_map, *KCAL_KEYS))
    if kcal is not None and kcal >= 0:
        return kcal

    kj = parse_float(cell(row, col_map, *KJ_KEYS))
    if kj is not None and kj >= 0:
        return kj / 4.184

    e100 = parse_float(cell(row, col_map, *ENERGY_100G_KEYS))
    if e100 is not None and e100 >= 0:
        return e100 / 4.184

    return None


def macro_or_none(row: dict[str, str], col_map: dict[str, str], keys: tuple[str, ...]) -> float | None:
    """Parsed macro if present and non-negative, else None (NOT 0.0)."""
    v = parse_float(cell(row, col_map, *keys))
    if v is None or v < 0:
        return None
    return v


def parse_serving_size_g(row: dict[str, str], col_map: dict[str, str]) -> float | None:
    """Best-effort parse: prefer serving_quantity (already grams), else parse free text."""
    qty = parse_float(cell(row, col_map, *SERVING_QTY_KEYS))
    if qty is not None and 0 < qty <= 5000:
        return round(qty, 2)

    raw = cell(row, col_map, *SERVING_SIZE_KEYS)
    if not raw:
        return None
    m = _SERVING_RE.match(raw)
    if not m:
        return None
    num = parse_float(m.group("num"))
    if num is None or num <= 0:
        return None
    unit = (m.group("unit") or "g").lower()
    factor = _UNIT_TO_GRAMS.get(unit)
    if factor is None:
        return None
    grams = num * factor
    if grams <= 0 or grams > 5000:
        return None
    return round(grams, 2)


# --------------------------------------------------------------------------- #
# Row normalization                                                           #
# --------------------------------------------------------------------------- #
def normalize_row(
    row: dict[str, str],
    col_map: dict[str, str],
) -> tuple[tuple | None, str | None]:
    """Returns (insert_tuple, None) on success, or (None, skip_reason)."""
    name = cell_clean(row, col_map, *NAME_KEYS)
    if not name:
        return (None, "no_name")

    code = cell(row, col_map, *CODE_KEYS)
    if not code:
        return (None, "no_code")
    code = code.strip()

    kcal = resolve_kcal_per_100g(row, col_map)
    if kcal is None:
        return (None, "no_energy")
    # plausibility guard: 0..1000 kcal/100 g covers every real food
    if kcal < 0 or kcal > 1000:
        return (None, "implausible_energy")

    brand = cell_clean(row, col_map, *BRAND_KEYS)

    protein = macro_or_none(row, col_map, PROTEIN_KEYS)
    carbs   = macro_or_none(row, col_map, CARB_KEYS)
    fat     = macro_or_none(row, col_map, FAT_KEYS)

    # Skip rows where the source has absolutely no macro info — they show up
    # in the app as "food with 0 protein, 0 carbs, 0 fat" which is useless.
    if protein is None and carbs is None and fat is None:
        return (None, "no_macros")

    serving_size_g = parse_serving_size_g(row, col_map)

    rec = (
        SOURCE,
        code,
        name,
        brand,
        round(kcal, 2),
        round(protein, 3) if protein is not None else 0.0,
        round(carbs,   3) if carbs   is not None else 0.0,
        round(fat,     3) if fat     is not None else 0.0,
        serving_size_g,
    )
    return (rec, None)


# --------------------------------------------------------------------------- #
# CLI                                                                         #
# --------------------------------------------------------------------------- #
def main() -> int:
    default_file = _BACKEND_DIR / "data" / "openfoodfacts_products.tsv"

    p = argparse.ArgumentParser(description="Import Open Food Facts slice into foods.")
    p.add_argument("--file", "-f", type=Path, default=default_file,
                   help=f"Path to TSV/CSV (or .gz). Default: {default_file}")
    p.add_argument("--max-rows", type=int, default=5000,
                   help=f"Max data rows after header. Default: 5000 (cap {_MAX_ROWS_CAP}).")
    p.add_argument("--skip-samples", type=int, default=12,
                   help="Max skipped rows to print with reasons. Default: 12")
    p.add_argument("--batch-size", type=int, default=500,
                   help="Rows per DB batch. Default: 500")
    args = p.parse_args()

    data_file: Path = args.file
    max_rows: int = args.max_rows
    skip_samples_limit: int = max(0, args.skip_samples)
    batch_size: int = max(1, args.batch_size)

    if max_rows < 1:
        print("max-rows must be >= 1", file=sys.stderr)
        return 1
    if max_rows > _MAX_ROWS_CAP:
        print(f"max-rows capped at {_MAX_ROWS_CAP} (got {max_rows})", file=sys.stderr)
        max_rows = _MAX_ROWS_CAP

    if not data_file.is_file():
        print(f"File not found: {data_file}", file=sys.stderr)
        return 1

    database_url = (os.getenv("DATABASE_URL") or "").strip()
    if not database_url:
        print("DATABASE_URL missing. Set it in backend/.env", file=sys.stderr)
        return 1

    inserted = 0
    skipped_invalid = 0
    skipped_duplicate = 0        # on-conflict (source, source_food_id)
    skipped_dupe_in_batch = 0    # same (name, brand) earlier in this run
    failed = 0
    skip_reason_counts: dict[str, int] = {}
    skip_samples: list[str] = []
    rows_scanned = 0
    seen_keys: set[tuple[str, str]] = set()

    with open_text(data_file) as f:
        first_line = f.readline()
        if not first_line:
            print("Empty file.", file=sys.stderr)
            return 1

        delim = sniff_delimiter(first_line)
        f.seek(0)
        reader = csv.DictReader(f, delimiter=delim)

        fieldnames = reader.fieldnames or []
        col_map = build_column_map(list(fieldnames))

        print(f"[import] file={data_file}")
        print(f"[import] max_rows={max_rows} batch_size={batch_size} delim={delim!r}")
        print(f"[import] columns={len(fieldnames)}")

        conn = psycopg2.connect(database_url)
        conn.autocommit = False
        try:
            with conn.cursor() as cur:
                batch: list[tuple] = []

                def flush() -> None:
                    nonlocal inserted, skipped_duplicate, failed
                    if not batch:
                        return
                    try:
                        cur.executemany(INSERT_SQL, batch)
                        # executemany can't easily distinguish inserted vs
                        # conflicted rows; use rowcount as a best-effort sum.
                        # Fallback: assume all non-failing rows are inserted
                        # unless conflict stats are required. We approximate
                        # duplicates using a post-insert count query per batch,
                        # but keep it simple here: treat rowcount as inserts.
                        affected = cur.rowcount if cur.rowcount >= 0 else len(batch)
                        inserted += affected
                        skipped_duplicate += max(0, len(batch) - affected)
                        conn.commit()
                    except psycopg2.Error as e:
                        conn.rollback()
                        # Fallback to per-row to localize the bad record(s).
                        for rec in batch:
                            try:
                                cur.execute(INSERT_SQL, rec)
                                if cur.rowcount == 1:
                                    inserted += 1
                                else:
                                    skipped_duplicate += 1
                                conn.commit()
                            except psycopg2.Error as e2:
                                conn.rollback()
                                failed += 1
                                print(f"Row failed (code={rec[1]!r}): {e2}", file=sys.stderr)
                    batch.clear()

                for i, row in enumerate(reader):
                    if i >= max_rows:
                        break
                    rows_scanned = i + 1

                    try:
                        rec, skip_reason = normalize_row(row, col_map)
                    except Exception as e:  # noqa: BLE001
                        failed += 1
                        if len(skip_samples) < skip_samples_limit:
                            skip_samples.append(f"  row_index={i} -> parse_error: {e!r}")
                        continue

                    if rec is None:
                        skipped_invalid += 1
                        assert skip_reason is not None
                        skip_reason_counts[skip_reason] = skip_reason_counts.get(skip_reason, 0) + 1
                        if len(skip_samples) < skip_samples_limit:
                            c = cell(row, col_map, *CODE_KEYS) or "?"
                            n = (cell(row, col_map, *NAME_KEYS) or "")[:40]
                            skip_samples.append(f"  code={c!r} name={n!r} -> {skip_reason}")
                        continue

                    dedupe_key = (rec[2], rec[3] or "")  # (name, brand)
                    if dedupe_key in seen_keys:
                        skipped_dupe_in_batch += 1
                        continue
                    seen_keys.add(dedupe_key)

                    batch.append(rec)
                    if len(batch) >= batch_size:
                        flush()

                flush()
        finally:
            conn.close()

    if skip_samples:
        print("[import] sample skipped rows:")
        for line in skip_samples:
            print(line)
    if skip_reason_counts:
        print(f"[import] skip reasons: {skip_reason_counts}")

    print(
        f"Done. inserted={inserted} "
        f"skipped_invalid={skipped_invalid} "
        f"skipped_dupe_in_batch={skipped_dupe_in_batch} "
        f"skipped_duplicate_in_db={skipped_duplicate} "
        f"failed={failed} "
        f"(scanned {rows_scanned} data rows, limit was {max_rows}, file={data_file})"
    )
    return 0 if failed == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())
