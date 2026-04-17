-- =============================================================================
-- 004_fix_constraints.sql
-- Relax a couple of legacy NOT NULL constraints that block manual food inserts.
-- Safe to re-run.
--
-- Why:
--   An older version of the schema made `source_food_id` NOT NULL. That worked
--   for Open Food Facts imports (the OFF `code` is always present) but breaks
--   manual inserts from the mobile app, which have no external source id.
--
--   The backend now inserts `source_food_id = 'manual:<uuid>'`, so this
--   migration isn't strictly required for the app to work, but it's still the
--   correct shape for the table and unblocks any future data source that has
--   no canonical external id.
-- =============================================================================

-- Make `source_food_id` nullable.
do $$
begin
    if exists (
        select 1
        from information_schema.columns
        where table_schema = 'public'
          and table_name   = 'foods'
          and column_name  = 'source_food_id'
          and is_nullable  = 'NO'
    ) then
        execute 'alter table foods alter column source_food_id drop not null';
        raise notice 'dropped NOT NULL from foods.source_food_id';
    else
        raise notice 'foods.source_food_id is already nullable — no change';
    end if;
end$$;


-- Quick sanity check: show which columns are NOT NULL on `foods`.
select column_name, data_type, is_nullable, column_default
from information_schema.columns
where table_schema = 'public' and table_name = 'foods'
order by ordinal_position;
