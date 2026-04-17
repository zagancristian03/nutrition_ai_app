-- =============================================================================
-- 000_migrate_all.sql
-- One-shot migration for the Nutrition AI backend. Idempotent: safe to paste
-- into Supabase SQL Editor and re-run any time.
--
-- What it does, in order:
--   1. Enables pg_trgm.
--   2. Creates `foods` (or patches an existing table with any missing columns).
--   3. Adds `search_text` as a STORED generated column (lowercased, trimmed,
--      single-spaced concatenation of name + brand).
--   4. Creates the unique source constraint + GIN trigram index.
--   5. Creates `food_logs` (diary) with a snapshot of macros at log time.
--   6. Prints counts so you can verify everything actually landed.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Extensions
-- -----------------------------------------------------------------------------
create extension if not exists pg_trgm;


-- -----------------------------------------------------------------------------
-- 2. foods (base + additive migrations for older installs)
-- -----------------------------------------------------------------------------
create table if not exists foods (
    id                  bigserial primary key,
    name                text              not null,
    brand               text,
    calories_per_100g   double precision,
    protein_per_100g    double precision,
    carbs_per_100g      double precision,
    fat_per_100g        double precision,
    serving_size_g      double precision,
    source              text,
    source_food_id      text,
    created_at          timestamptz       not null default now()
);

alter table foods add column if not exists brand            text;
alter table foods add column if not exists serving_size_g   double precision;
alter table foods add column if not exists source           text;
alter table foods add column if not exists source_food_id   text;
alter table foods add column if not exists created_at       timestamptz not null default now();


-- -----------------------------------------------------------------------------
-- 3. search_text generated column
-- -----------------------------------------------------------------------------
alter table foods
    add column if not exists search_text text
    generated always as (
        trim(
            regexp_replace(
                lower(coalesce(name, '') || ' ' || coalesce(brand, '')),
                '\s+', ' ', 'g'
            )
        )
    ) stored;


-- -----------------------------------------------------------------------------
-- 4. Indexes on foods
-- -----------------------------------------------------------------------------
create unique index if not exists foods_source_key
    on foods (source, source_food_id)
    where source is not null and source_food_id is not null;

create index if not exists idx_foods_search_text_trgm
    on foods using gin (search_text gin_trgm_ops);

create index if not exists idx_foods_source
    on foods (source);


-- -----------------------------------------------------------------------------
-- 5. food_logs (diary with nutritional snapshot)
-- -----------------------------------------------------------------------------
-- NOTE: `foods.id` in Supabase is UUID, so `food_logs.food_id` must match.
create table if not exists food_logs (
    id              bigserial primary key,
    user_id         text              not null,
    food_id         uuid              not null
                                      references foods(id) on delete restrict,
    logged_date     date              not null,
    meal_type       text              not null
        check (meal_type in ('breakfast', 'lunch', 'dinner', 'snack')),
    grams           double precision,
    servings        double precision,

    -- -------- Nutritional SNAPSHOT (DO NOT compute dynamically later) --------
    calories        double precision  not null,
    protein         double precision  not null,
    carbs           double precision  not null,
    fat             double precision  not null,

    created_at      timestamptz       not null default now(),

    constraint food_logs_portion_present
        check (grams is not null or servings is not null),
    constraint food_logs_portion_nonneg
        check ((grams    is null or grams    >= 0)
           and (servings is null or servings >= 0))
);

create index if not exists idx_food_logs_user_date
    on food_logs (user_id, logged_date desc, created_at desc);

create index if not exists idx_food_logs_food_id
    on food_logs (food_id);


-- =============================================================================
-- 6. Diagnostics — read the output of these to confirm the migration worked
-- =============================================================================

-- (a) total rows and how many already have a searchable text
select
    count(*)                                    as foods_total,
    count(*) filter (where search_text <> '')   as foods_with_search_text,
    count(*) filter (where search_text = '')    as foods_with_empty_search_text
from foods;

-- (b) sample 5 rows to eyeball the generated column
select id, name, brand, search_text
from foods
order by id
limit 5;

-- (c) confirm the trigram index is present
select indexname
from pg_indexes
where tablename = 'foods'
  and indexname = 'idx_foods_search_text_trgm';

-- (d) quick smoke test of the ranked search used by the API (edit 'apple')
select id, name, brand,
       similarity(search_text, 'apple') as sim
from foods
where search_text % 'apple'
   or search_text like 'apple%'
   or search_text like '%apple%'
order by
    case
        when search_text like 'apple%'  then 1
        when search_text like '%apple%' then 2
        else 3
    end,
    similarity(search_text, 'apple') desc,
    length(search_text) asc
limit 10;
