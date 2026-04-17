-- =============================================================================
-- 002_food_logs.sql
-- Per-user diary entries. Stores a SNAPSHOT of macros at logging time so a
-- later edit of the source `foods` row never retroactively changes history.
-- =============================================================================

create table if not exists food_logs (
    id              bigserial primary key,

    -- External user identifier (Supabase auth uid / Firebase uid). Kept TEXT
    -- on purpose so the backend is not coupled to a single auth provider.
    user_id         text              not null,

    food_id         uuid              not null
                                      references foods(id) on delete restrict,

    logged_date     date              not null,
    meal_type       text              not null
        check (meal_type in ('breakfast', 'lunch', 'dinner', 'snack')),

    -- Portion the user actually ate. At least one of the two must be set;
    -- the backend enforces this (and computes grams from servings when needed).
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

-- Diary lookups are always "give me <user>'s logs on <date>", optionally
-- ordered by creation time.
create index if not exists idx_food_logs_user_date
    on food_logs (user_id, logged_date desc, created_at desc);

create index if not exists idx_food_logs_food_id
    on food_logs (food_id);
