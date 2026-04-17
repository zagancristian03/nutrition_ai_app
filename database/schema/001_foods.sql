-- =============================================================================
-- 001_foods.sql
-- Canonical food catalog, optimized for trigram search.
--
-- Idempotent: safe to run on a fresh DB or on an existing `foods` table that
-- was created by an earlier import. All additive changes use IF NOT EXISTS.
-- =============================================================================

create extension if not exists pg_trgm;

-- -----------------------------------------------------------------------------
-- Base table (new installs)
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

-- -----------------------------------------------------------------------------
-- Additive migrations for pre-existing installs
-- -----------------------------------------------------------------------------
alter table foods add column if not exists brand            text;
alter table foods add column if not exists serving_size_g   double precision;
alter table foods add column if not exists source           text;
alter table foods add column if not exists source_food_id   text;
alter table foods add column if not exists created_at       timestamptz not null default now();

-- -----------------------------------------------------------------------------
-- search_text : lowercased, trimmed, single-spaced "name brand".
-- Implemented as a STORED generated column so it is always in sync with the
-- source fields and cannot drift. Not null by construction (coalesce + trim).
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
-- Indexes
-- -----------------------------------------------------------------------------

-- Prevents duplicate imports of the same external product.
create unique index if not exists foods_source_key
    on foods (source, source_food_id)
    where source is not null and source_food_id is not null;

-- Primary search index. GIN + gin_trgm_ops accelerates:
--   search_text %   :q      (trigram similarity)
--   search_text LIKE :q || '%'
--   search_text LIKE '%' || :q || '%'
create index if not exists idx_foods_search_text_trgm
    on foods using gin (search_text gin_trgm_ops);

-- Useful secondary lookup when filtering by source.
create index if not exists idx_foods_source
    on foods (source);
