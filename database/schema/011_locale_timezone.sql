-- =============================================================================
-- 011_locale_timezone.sql
-- UI/AI locale + IANA timezone on user_profiles; diary instant + zone on food_logs.
-- Idempotent additions. Safe to re-run.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. user_profiles — locale for AI/sync; timezone for diary interpretation
-- -----------------------------------------------------------------------------
alter table user_profiles
    add column if not exists locale_mode text not null default 'system';

alter table user_profiles
    add column if not exists preferred_locale text;

alter table user_profiles
    add column if not exists timezone text;

alter table user_profiles
    add column if not exists locale_updated_at timestamptz not null default now();

alter table user_profiles
    add column if not exists measurement_system text;

do $$
begin
    if not exists (
        select 1 from pg_constraint
        where conname = 'user_profiles_locale_mode_valid'
    ) then
        alter table user_profiles
            add constraint user_profiles_locale_mode_valid
            check (locale_mode in ('system', 'manual'));
    end if;
end $$;

do $$
begin
    if not exists (
        select 1 from pg_constraint
        where conname = 'user_profiles_measurement_system_valid'
    ) then
        alter table user_profiles
            add constraint user_profiles_measurement_system_valid
            check (
                measurement_system is null
                or measurement_system in ('metric', 'imperial')
            );
    end if;
end $$;

-- -----------------------------------------------------------------------------
-- 2. food_logs — instant + zone used to interpret diary_date (logged_date)
-- -----------------------------------------------------------------------------
alter table food_logs
    add column if not exists consumed_at timestamptz;

alter table food_logs
    add column if not exists diary_timezone text;

update food_logs
   set consumed_at = coalesce(consumed_at, created_at);

-- -----------------------------------------------------------------------------
-- 3. Diagnostics
-- -----------------------------------------------------------------------------
select count(*) as user_profiles_with_locale_cols from user_profiles;
select count(*) as food_logs_with_consumed_at from food_logs where consumed_at is not null;
