-- =============================================================================
-- 007_ai.sql
-- Tables powering the AI coaching layer.
--
-- Idempotent. Safe to paste into Supabase SQL Editor and re-run.
--
-- Entities:
--   user_ai_profiles        per-user onboarding answers + coach tone
--   ai_chat_threads         one or more conversations per user, with a rolling summary
--   ai_chat_messages        raw chat turns belonging to a thread
--   ai_coaching_summaries   derived daily/weekly/behavioral summaries
--   ai_recommendations_log  audit of every structured recommendation
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. user_ai_profiles — structured onboarding answers
-- -----------------------------------------------------------------------------
create table if not exists user_ai_profiles (
    user_id                 text              primary key,
    onboarding_completed    boolean           not null default false,

    -- Goals
    main_goal               text,             -- lose_weight | gain_muscle | maintain | eat_healthier | improve_energy | consistency | other
    approach_style          text,             -- aggressive | balanced | flexible | sustainable

    -- Dietary
    dietary_pattern         text,             -- omnivore | vegetarian | vegan | pescatarian | other
    allergies               text,
    disliked_foods          text,
    favorite_foods          text,
    budget_sensitivity      text,             -- low | medium | high
    cooking_preference      text,             -- none | simple | enjoys
    meal_frequency          integer,          -- 2..6

    -- Behavioral
    biggest_struggle        text,             -- cravings | consistency | late_night | emotional | time | social | other
    struggle_timing         text,             -- morning | afternoon | evening | night | weekends | stress
    motivation_level        text,             -- low | medium | high
    structure_preference    text,             -- low | medium | high

    -- Coach tone
    coach_tone              text              not null default 'balanced',  -- direct | balanced | gentler

    -- Anything extra from the onboarding form that doesn't deserve a column
    extras                  jsonb             not null default '{}'::jsonb,

    -- A compact natural-language summary built by the backend at save time.
    -- Injected into every chat prompt so the model has cheap, stable context.
    derived_summary         text,

    created_at              timestamptz       not null default now(),
    updated_at              timestamptz       not null default now(),

    constraint user_ai_profiles_coach_tone_valid
        check (coach_tone in ('direct', 'balanced', 'gentler')),
    constraint user_ai_profiles_meal_frequency_range
        check (meal_frequency is null or (meal_frequency between 1 and 10))
);


-- -----------------------------------------------------------------------------
-- 2. ai_chat_threads — conversations with rolling summary
-- -----------------------------------------------------------------------------
create table if not exists ai_chat_threads (
    id              bigserial         primary key,
    user_id         text              not null,
    title           text,                                         -- optional, set from first user message
    summary         text,                                         -- rolling summary of older messages
    message_count   integer           not null default 0,
    created_at      timestamptz       not null default now(),
    updated_at      timestamptz       not null default now()
);

create index if not exists idx_ai_chat_threads_user
    on ai_chat_threads (user_id, updated_at desc);


-- -----------------------------------------------------------------------------
-- 3. ai_chat_messages — raw transcript
-- -----------------------------------------------------------------------------
create table if not exists ai_chat_messages (
    id              bigserial         primary key,
    thread_id       bigint            not null
                                      references ai_chat_threads(id) on delete cascade,
    user_id         text              not null,
    role            text              not null
        check (role in ('system', 'user', 'assistant')),
    content         text              not null,
    token_count     integer,
    metadata        jsonb             not null default '{}'::jsonb,
    created_at      timestamptz       not null default now()
);

create index if not exists idx_ai_chat_messages_thread
    on ai_chat_messages (thread_id, created_at asc);

create index if not exists idx_ai_chat_messages_user
    on ai_chat_messages (user_id, created_at desc);


-- -----------------------------------------------------------------------------
-- 4. ai_coaching_summaries — daily / weekly / behavioral memory
-- -----------------------------------------------------------------------------
create table if not exists ai_coaching_summaries (
    id              bigserial         primary key,
    user_id         text              not null,
    kind            text              not null
        check (kind in ('daily', 'weekly', 'behavioral')),
    period_start    date,
    period_end      date,
    summary_text    text              not null,
    data            jsonb             not null default '{}'::jsonb,
    created_at      timestamptz       not null default now()
);

create index if not exists idx_ai_coaching_summaries_user
    on ai_coaching_summaries (user_id, kind, period_end desc);


-- -----------------------------------------------------------------------------
-- 5. ai_recommendations_log — audit trail of structured recs
-- -----------------------------------------------------------------------------
create table if not exists ai_recommendations_log (
    id              bigserial         primary key,
    user_id         text              not null,
    kind            text              not null,     -- 'meal' | 'review_day' | 'review_week' | 'chat'
    prompt_snapshot jsonb             not null default '{}'::jsonb,
    response_text   text              not null,
    created_at      timestamptz       not null default now()
);

create index if not exists idx_ai_recommendations_log_user
    on ai_recommendations_log (user_id, kind, created_at desc);


-- -----------------------------------------------------------------------------
-- 6. Diagnostics
-- -----------------------------------------------------------------------------
select count(*) as ai_profiles_total   from user_ai_profiles;
select count(*) as ai_threads_total    from ai_chat_threads;
select count(*) as ai_messages_total   from ai_chat_messages;
