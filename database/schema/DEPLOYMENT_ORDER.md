# Production database migration order

Apply these in **Supabase SQL Editor** (or `psql`) on a new project, **in order**.
All scripts under `database/schema/` are written to be **idempotent** where possible (`IF NOT EXISTS`, additive `ALTER`).

| Step | File | Purpose |
|------|------|--------|
| 1 | `001_foods.sql` | Extensions, `foods` with UUID `id`, `search_text`, indexes |
| 2 | `002_food_logs.sql` | `food_logs` (FK to `foods.id` UUID) |
| 3 | `003_cleanup_junk.sql` | Optional cleanup |
| 4 | `004_fix_constraints.sql` | Legacy constraint fixes |
| 5 | `005_persistence.sql` | `food_logs.food_name`, `user_goals` |
| 6 | `006_profile.sql` | `user_profiles`, `weight_logs` |
| 7 | `007_ai.sql` | AI tables |
| 8 | `008_ai_profile_expand.sql` | AI profile columns |
| 9 | `009_ai_chat_folders.sql` | Chat folders |
| 10 | `010_seed_common_foods.sql` | Seed catalog rows (**before** aliases) |
| 11 | `011_locale_timezone.sql` | Locale / timezone columns |
| 12 | `012_food_aliases.sql` | Multilingual aliases (requires **010** seeds) |

## `000_migrate_all.sql`

- **Status:** convenience partial rollup (foods + basic food_logs only), **not** a full app schema.
- **Use** only if you understand it omits profile, goals, AI, locale, seeds, and aliases.
- **Prefer** the numbered sequence above for production.

## Type consistency

- **`foods.id`** and **`food_logs.food_id`** are **UUID** in current migrations (aligned with backend `POST /foods` and `012_food_aliases.sql`).
- If you have a legacy database with **`bigint`** `foods.id`, do **not** blindly re-run `001_foods.sql` `CREATE TABLE`; plan a deliberate migration or continue matching `012`’s documented bigint workaround.
