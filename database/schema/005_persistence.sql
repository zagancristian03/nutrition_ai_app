-- =============================================================================
-- 005_persistence.sql
-- Adds the pieces needed for per-user diary + goals persistence.
-- Idempotent: safe to run multiple times.
--
--   (1) food_logs.food_name  — snapshot of the food name at log time, so the
--                              diary still reads correctly even if the food
--                              row is later renamed or deleted.
--   (2) user_goals           — per-user calorie/macro targets, keyed by the
--                              Firebase UID. One row per user.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. food_logs.food_name
-- -----------------------------------------------------------------------------
alter table food_logs
    add column if not exists food_name text;

-- Backfill any pre-existing rows (nullable during the backfill).
update food_logs fl
set    food_name = f.name
from   foods f
where  fl.food_id   = f.id
   and fl.food_name is null;

-- Tighten constraint, now that everything is populated.
do $$
begin
    if exists (
        select 1
        from information_schema.columns
        where table_schema = 'public'
          and table_name   = 'food_logs'
          and column_name  = 'food_name'
          and is_nullable  = 'YES'
    ) then
        update food_logs set food_name = '' where food_name is null;
        execute 'alter table food_logs alter column food_name set not null';
    end if;
end$$;


-- -----------------------------------------------------------------------------
-- 2. user_goals
-- -----------------------------------------------------------------------------
create table if not exists user_goals (
    user_id         text              primary key,
    calorie_goal    double precision  not null default 2000,
    protein_goal    double precision  not null default 150,
    carbs_goal      double precision  not null default 250,
    fat_goal        double precision  not null default 65,
    updated_at      timestamptz       not null default now(),

    constraint user_goals_nonneg
        check (calorie_goal >= 0
           and protein_goal >= 0
           and carbs_goal   >= 0
           and fat_goal     >= 0)
);


-- -----------------------------------------------------------------------------
-- 3. Diagnostics
-- -----------------------------------------------------------------------------
select count(*) as food_logs_total,
       count(*) filter (where food_name is null or food_name = '') as food_logs_without_name
from food_logs;

select count(*) as user_goals_total from user_goals;
