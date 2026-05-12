# Food search internationalization

## UI vs food data language

- **UI strings** (screens, buttons, errors) come from Flutter **ARB** / `AppLocalizations`. This document does not change that.
- **Food names in search results** come from the **API response** (`display_name` for curated catalog rows, or the stored `name` for manual and third‑party rows). They are **not** translated via ARB.

## Curated catalog model

- Each nutritional row in `foods` is **canonical** (one row per food, one set of macros).
- Multilingual **search and display** for seed rows (`source = 'seed'`) use table `food_aliases`:
  - `locale` — e.g. `ro`, `en`
  - `alias` — human-readable text (can include diacritics)
  - `normalized_alias` — same normalization as server-side search (lowercase, collapsed whitespace, diacritics stripped for matching)
  - `is_primary` — at most one per (`food_id`, `locale`); used as the **display title** when present

We **do not**:

- Duplicate `foods` rows per language
- Store separate nutrition per translation
- Auto-translate user-entered foods or Open Food Facts names

## User custom foods (`source = 'manual'`)

- Search continues to use `foods.search_text` (name + brand, lowercased, as stored).
- No alias rows are added by the app; **display stays exactly what the user typed** (after the usual lowercase storage in POST `/foods`).

## Third-party products

- Behavior is unchanged: match and show **names from the source**. No DB translation layer in this pass.

## Romanian aliases (v1)

- Seeded in `database/schema/012_food_aliases.sql` only for rows that already exist from `010_seed_common_foods.sql` (matched by `source = 'seed'` and `source_food_id`).
- This is a **small** starter set, not a full RO dictionary.

## Applying the migration

1. Run `database/schema/012_food_aliases.sql` in the Supabase SQL editor (or your Postgres client) **after** `foods` and seed data exist.
2. Restart the API if needed so caches pick up schema changes.

Re-running the file is safe: `CREATE IF NOT EXISTS` for the table/indexes; seed uses `ON CONFLICT (food_id, locale, normalized_alias) DO NOTHING`.

### `foods.id` type

- The migration defines `food_aliases.food_id` as **uuid** to match `food_logs.food_id` and the backend’s `POST /foods` UUID inserts.
- If your `foods.id` is still `bigserial`, change the `food_id` column type in `012_food_aliases.sql` to **bigint** before applying, and adjust the FK to match.

## Diary snapshot (`food_logs.food_name`)

When logging from the app, the client may send optional **`food_display_name`** on `POST /food-logs`. If set, that string is stored as the row’s **`food_name`** snapshot (what appears in the diary). If omitted, the server uses **`foods.name`** (English seed label) for backward compatibility.

Use the same label the user saw in search results (e.g. `primaryLabel` / `display_name`).

## API

- `POST /food-logs` — optional body field **`food_display_name`** (stored as `food_name` on the log row).
- `GET /foods/search?q=...&locale=ro` — optional `locale` (BCP‑47 tag; primary subtag is used, e.g. `ro-RO` → `ro`).
- Responses include optional:
  - `canonical_name` — stable stored name (English/lowercase seed label)
  - `display_name` — what the client should show for curated foods when a primary alias exists for that locale
  - `matched_alias`, `matched_locale` — optional debugging fields when the hit came from an alias row

## Future work

- Admin tooling to edit aliases without raw SQL
- Larger curated alias sets / more locales
- Stronger ranking (e.g. dedicated English canonical tier vs alias tier tuning)
- Optional `pg_trgm` tuning for very fuzzy alias matching
- Multilingual third-party catalogs only if product ownership accepts data/licensing implications
