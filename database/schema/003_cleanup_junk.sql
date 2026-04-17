-- =============================================================================
-- 003_cleanup_junk.sql
-- Remove useless rows from `foods` and inspect what's left.
--
-- Run this in Supabase SQL Editor AFTER 000_migrate_all.sql. Safe to re-run.
--
-- A row is considered "junk" and deleted when ALL of these are true:
--   * calories_per_100g is null/zero, OR
--   * every macro (protein, carbs, fat) is null/zero
--
-- We preserve `food_logs` integrity by only deleting foods that are not
-- currently referenced by a diary entry (the FK would block anyway, but
-- the WHERE NOT EXISTS makes the intent explicit).
-- =============================================================================

-- --------- (a) BEFORE: how does the catalogue look right now? ---------------
select
    count(*)                                                    as foods_total,
    count(*) filter (where coalesce(calories_per_100g, 0) = 0)  as zero_kcal,
    count(*) filter (where coalesce(protein_per_100g,  0) = 0
                       and coalesce(carbs_per_100g,    0) = 0
                       and coalesce(fat_per_100g,      0) = 0)  as zero_macros,
    count(*) filter (where coalesce(calories_per_100g, 0) = 0
                        or (coalesce(protein_per_100g, 0) = 0
                        and coalesce(carbs_per_100g,   0) = 0
                        and coalesce(fat_per_100g,     0) = 0)) as will_be_deleted
from foods;


-- --------- (b) DELETE the junk -----------------------------------------------
-- Definition of junk = 0 kcal  OR  all three macros are 0/null.
delete from foods f
where (
        coalesce(f.calories_per_100g, 0) = 0
     OR (
            coalesce(f.protein_per_100g, 0) = 0
        and coalesce(f.carbs_per_100g,   0) = 0
        and coalesce(f.fat_per_100g,     0) = 0
     )
)
and not exists (
    select 1 from food_logs l where l.food_id = f.id
);


-- --------- (c) AFTER: what remains? ------------------------------------------
select
    count(*)                                                   as foods_total_after,
    round(avg(calories_per_100g)::numeric, 1)                  as avg_kcal,
    round(avg(protein_per_100g)::numeric,  2)                  as avg_protein,
    round(avg(carbs_per_100g)::numeric,    2)                  as avg_carbs,
    round(avg(fat_per_100g)::numeric,      2)                  as avg_fat
from foods;


-- --------- (d) peek at 10 surviving rows -------------------------------------
select name, brand,
       calories_per_100g as kcal,
       protein_per_100g  as p,
       carbs_per_100g    as c,
       fat_per_100g      as f,
       source
from foods
where calories_per_100g > 0
order by calories_per_100g desc
limit 10;
