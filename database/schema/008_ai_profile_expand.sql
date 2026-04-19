-- =============================================================================
-- 008_ai_profile_expand.sql
-- Expand user_ai_profiles with multi-select goals/struggles, training, and
-- lifestyle columns. Additive and idempotent.
--
-- Safe to paste into Supabase SQL Editor and re-run at any time.
-- Existing data in `main_goal` / `biggest_struggle` is back-filled into the
-- new array columns so users don't lose their onboarding.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Add new columns (all nullable — onboarding still saves partially)
-- -----------------------------------------------------------------------------
alter table user_ai_profiles
    add column if not exists main_goals                  text[],
    add column if not exists main_goal_note              text,

    add column if not exists dietary_pattern_note        text,
    add column if not exists cuisines_enjoyed            text,
    add column if not exists eating_out_frequency        text,

    add column if not exists biggest_struggles           text[],
    add column if not exists biggest_struggle_note       text,

    -- Training / activity
    add column if not exists training_frequency_per_week integer,
    add column if not exists training_types              text[],
    add column if not exists training_intensity          text,
    add column if not exists training_notes              text,
    add column if not exists job_activity                text,
    add column if not exists steps_per_day_band          text,

    -- Lifestyle / recovery
    add column if not exists sleep_hours_band            text,
    add column if not exists stress_level                text,
    add column if not exists water_intake                text,
    add column if not exists alcohol_frequency           text;


-- -----------------------------------------------------------------------------
-- 2. Gentle range checks (attached via DO block so they stay idempotent)
-- -----------------------------------------------------------------------------
do $$
begin
    if not exists (
        select 1 from pg_constraint
         where conname = 'user_ai_profiles_training_freq_range'
    ) then
        alter table user_ai_profiles
            add constraint user_ai_profiles_training_freq_range
            check (training_frequency_per_week is null
                   or (training_frequency_per_week between 0 and 14));
    end if;
end $$;


-- -----------------------------------------------------------------------------
-- 3. Back-fill new arrays from the old single-value columns so existing
--    rows keep their onboarding intact.
-- -----------------------------------------------------------------------------
update user_ai_profiles
   set main_goals = array[main_goal]
 where main_goal is not null
   and (main_goals is null or cardinality(main_goals) = 0);

update user_ai_profiles
   set biggest_struggles = array[biggest_struggle]
 where biggest_struggle is not null
   and (biggest_struggles is null or cardinality(biggest_struggles) = 0);


-- -----------------------------------------------------------------------------
-- 4. Diagnostics
-- -----------------------------------------------------------------------------
select count(*)                                        as ai_profiles_total,
       count(*) filter (where main_goals is not null)  as with_main_goals,
       count(*) filter (where training_types is not null) as with_training_types
from user_ai_profiles;
