-- =============================================================================
-- 006_profile.sql
-- Per-user profile (body stats, goal type, activity) + weight-tracking history.
--
-- Idempotent. Safe to run multiple times. Produces everything the Flutter app
-- needs for the Progress and Edit-Profile screens.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. user_profiles — one row per user, PK = Firebase UID
-- -----------------------------------------------------------------------------
create table if not exists user_profiles (
    user_id             text              primary key,
    display_name        text,
    sex                 text,
    date_of_birth       date,
    height_cm           double precision,
    current_weight_kg   double precision,
    target_weight_kg    double precision,
    goal_type           text,   -- 'lose' | 'maintain' | 'gain'
    activity_level      text,   -- 'sedentary' | 'light' | 'moderate' | 'active' | 'very_active'
    weekly_rate_kg      double precision,
    updated_at          timestamptz       not null default now(),

    constraint user_profiles_sex_valid
        check (sex is null or sex in ('male', 'female', 'other')),
    constraint user_profiles_goal_valid
        check (goal_type is null or goal_type in ('lose', 'maintain', 'gain')),
    constraint user_profiles_activity_valid
        check (activity_level is null or activity_level in (
            'sedentary', 'light', 'moderate', 'active', 'very_active')),
    constraint user_profiles_height_pos
        check (height_cm is null or (height_cm > 0 and height_cm < 300)),
    constraint user_profiles_weight_pos
        check (current_weight_kg is null or (current_weight_kg > 0 and current_weight_kg < 500)),
    constraint user_profiles_target_pos
        check (target_weight_kg is null or (target_weight_kg > 0 and target_weight_kg < 500)),
    constraint user_profiles_rate_range
        check (weekly_rate_kg is null or (weekly_rate_kg >= 0 and weekly_rate_kg <= 2))
);


-- -----------------------------------------------------------------------------
-- 2. weight_logs — time series of weight measurements
-- -----------------------------------------------------------------------------
create table if not exists weight_logs (
    id             bigserial primary key,
    user_id        text              not null,
    weight_kg      double precision  not null,
    logged_on      date              not null default current_date,
    note           text,
    created_at     timestamptz       not null default now(),

    constraint weight_logs_weight_pos
        check (weight_kg > 0 and weight_kg < 500)
);

-- Only one weight per day per user (the later write wins — handled at app
-- level via ON CONFLICT DO UPDATE).
create unique index if not exists weight_logs_user_date_unique
    on weight_logs (user_id, logged_on);

create index if not exists idx_weight_logs_user_date
    on weight_logs (user_id, logged_on desc);


-- -----------------------------------------------------------------------------
-- 3. Diagnostics
-- -----------------------------------------------------------------------------
select count(*) as user_profiles_total from user_profiles;
select count(*) as weight_logs_total   from weight_logs;
