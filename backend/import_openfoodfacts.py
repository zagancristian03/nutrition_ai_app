#!/usr/bin/env python3
"""
Import a batch from an Open Food Facts CSV/TSV export into Supabase `foods`.

The export may be UTF-8 or UTF-16 (common when saving from Excel on Windows),
tab- or comma-separated.

Requires:
  - backend/.env with DATABASE_URL (same as FastAPI).
  - Table `foods` with columns:
      source, source_food_id, name, brand,
      calories_per_100g, protein_per_100g, carbs_per_100g, fat_per_100g
  - UNIQUE (source, source_food_id) for ON CONFLICT below.

Default: read up to 5000 data rows (after header); use --max-rows to change.
Bad CSV rows or DB errors on a single row do not stop the import.

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
import sys
from pathlib import Path

import psycopg2
from dotenv import load_dotenv

SOURCE = "open_food_facts"

_BACKEND_DIR = Path(__file__).resolve().parent
load_dotenv(_BACKEND_DIR / ".env")

INSERT_SQL = """
INSERT INTO foods (
    source, source_food_id, name, brand,
    calories_per_100g, protein_per_100g, carbs_per_100g, fat_per_100g
) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
ON CONFLICT (source, source_food_id) DO NOTHING
"""

# Logical OFF column names -> aliases to try (first match wins for text fields)
NAME_KEYS = ("product_name", "generic_name")
CODE_KEYS = ("code",)
BRAND_KEYS = ("brands", "brands_en", "brand_owner")
KCAL_KEYS = ("energy-kcal_100g",)
KJ_KEYS = ("energy-kj_100g",)
ENERGY_100G_KEYS = ("energy_100g",)  # typically kJ per 100 g in OFF
PROTEIN_KEYS = ("proteins_100g", "protein_100g")
CARB_KEYS = ("carbohydrates_100g", "carbohydrate_100g", "carbs_100g")
FAT_KEYS = ("fat_100g",)

# Sane upper bound to avoid accidental huge --max-rows (override not required for normal use).
_MAX_ROWS_CAP = 500_000


def _encoding_from_bom(start: bytes) -> str:
    if len(start) >= 2 and start[:2] == b"\xff\xfe":
        return "utf-16"
    if len(start) >= 2 and start[:2] == b"\xfe\xff":
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
    """Open text for csv parsing; detects UTF-8 vs UTF-16 from BOM."""
    if path.suffix.lower() == ".gz":
        enc = _encoding_from_bom(_peek_start_bytes(path))
        return gzip.open(path, "rt", encoding=enc, newline="", errors="replace")
    enc = _encoding_from_bom(_peek_start_bytes(path))
    return path.open("r", encoding=enc, newline="", errors="replace")


def sniff_delimiter(sample_line: str) -> str:
    tab = sample_line.count("\t")
    comma = sample_line.count(",")
    return "\t" if tab > comma else ","


def build_column_map(fieldnames: list[str] | None) -> dict[str, str]:
    """
    Map logical column name -> actual DictReader key (handles \\ufeff on first header).
    """
    if not fieldnames:
        return {}
    mapping: dict[str, str] = {}
    for raw in fieldnames:
        if raw is None:
            continue
        logical = raw.lstrip("\ufeff").strip()
        mapping[logical] = raw
        # also allow lookup by cleaned name if duplicate raw (last wins — rare)
    return mapping


def cell(row: dict[str, str], col_map: dict[str, str], *logical_names: str) -> str | None:
    """First non-empty value among logical column names."""
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
    """energy-kcal_100g, else energy-kj_100g / 4.184, else energy_100g / 4.184 (kJ)."""
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


def macro_default(row: dict[str, str], col_map: dict[str, str], keys: tuple[str, ...]) -> float:
    v = parse_float(cell(row, col_map, *keys))
    if v is None or v < 0:
        return 0.0
    return v


def normalize_row(
    row: dict[str, str],
    col_map: dict[str, str],
) -> tuple[tuple, str | None]:
    """
    Returns (insert_tuple, None) or (None, skip_reason).
    Skip only for: no name, no code, no energy after fallbacks.
    """
    name = cell(row, col_map, *NAME_KEYS)
    if not name:
        return (None, "no_name")

    code = cell(row, col_map, *CODE_KEYS)
    if not code:
        return (None, "no_code")

    kcal = resolve_kcal_per_100g(row, col_map)
    if kcal is None:
        return (None, "no_energy")

    brand_raw = cell(row, col_map, *BRAND_KEYS)
    brand = brand_raw if brand_raw else None

    protein = macro_default(row, col_map, PROTEIN_KEYS)
    carbs = macro_default(row, col_map, CARB_KEYS)
    fat = macro_default(row, col_map, FAT_KEYS)

    rec = (
        SOURCE,
        code,
        name,
        brand,
        round(kcal, 2),
        round(protein, 3),
        round(carbs, 3),
        round(fat, 3),
    )
    return (rec, None)


def main() -> int:
    default_file = _BACKEND_DIR / "data" / "openfoodfacts_products.tsv"

    p = argparse.ArgumentParser(description="Import Open Food Facts slice into foods.")
    p.add_argument(
        "--file",
        "-f",
        type=Path,
        default=default_file,
        help=f"Path to TSV/CSV (or .gz). Default: {default_file}",
    )
    p.add_argument(
        "--max-rows",
        type=int,
        default=5000,
        help=(
            "Maximum data rows to read from the file (after header). "
            f"Default: 5000 (hard cap {_MAX_ROWS_CAP})."
        ),
    )
    p.add_argument(
        "--skip-samples",
        type=int,
        default=12,
        help="Max skipped rows to print with reasons. Default: 12",
    )
    args = p.parse_args()

    data_file: Path = args.file
    max_rows: int = args.max_rows
    skip_samples_limit: int = max(0, args.skip_samples)

    if max_rows < 1:
        print("max-rows must be >= 1", file=sys.stderr)
        return 1
    if max_rows > _MAX_ROWS_CAP:
        print(
            f"max-rows capped at {_MAX_ROWS_CAP} (got {max_rows})",
            file=sys.stderr,
        )
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
    skipped_duplicate = 0
    failed = 0
    skip_reason_counts: dict[str, int] = {}
    skip_samples: list[str] = []
    rows_scanned = 0

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
        print(f"[import] max_rows={max_rows} (stop after this many data rows)")
        print(f"[import] encoding from BOM / utf-8-sig, delimiter={delim!r}")
        print(f"[import] column count={len(fieldnames)}")
        print(f"[import] first row keys (first 12): {fieldnames[:12]!r}")
        if fieldnames:
            print(f"[import] first row keys (last 8): {fieldnames[-8:]!r}")

        conn = psycopg2.connect(database_url)
        conn.autocommit = True
        try:
            with conn.cursor() as cur:
                for i, row in enumerate(reader):
                    if i >= max_rows:
                        break
                    rows_scanned = i + 1

                    try:
                        rec, skip_reason = normalize_row(row, col_map)
                    except Exception as e:
                        failed += 1
                        print(f"Row parse error index={i}: {e}", file=sys.stderr)
                        if len(skip_samples) < skip_samples_limit:
                            skip_samples.append(f"  row_index={i} -> parse_error: {e!r}")
                        continue

                    if rec is None:
                        skipped_invalid += 1
                        assert skip_reason is not None
                        skip_reason_counts[skip_reason] = (
                            skip_reason_counts.get(skip_reason, 0) + 1
                        )
                        if len(skip_samples) < skip_samples_limit:
                            c = cell(row, col_map, *CODE_KEYS) or "?"
                            n = (cell(row, col_map, *NAME_KEYS) or "")[:40]
                            skip_samples.append(
                                f"  code={c!r} name={n!r} -> {skip_reason}"
                            )
                        continue

                    try:
                        cur.execute(INSERT_SQL, rec)
                        if cur.rowcount == 1:
                            inserted += 1
                        else:
                            skipped_duplicate += 1
                    except psycopg2.Error as e:
                        print(f"Row failed (code={rec[1]!r}): {e}", file=sys.stderr)
                        failed += 1
        finally:
            conn.close()

    if skip_samples:
        print("[import] sample skipped rows:")
        for line in skip_samples:
            print(line)
    if skip_reason_counts:
        print(f"[import] skip reasons: {skip_reason_counts}")

    print(
        f"Done. inserted={inserted} skipped_invalid={skipped_invalid} "
        f"skipped_duplicate={skipped_duplicate} failed={failed} "
        f"(scanned {rows_scanned} data rows, limit was {max_rows}, file={data_file})"
    )
    return 0 if failed == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())
