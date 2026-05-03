-- =============================================================================
-- 009_ai_chat_folders.sql
-- Folders for AI chat threads + optional folder_id on threads.
-- Idempotent. Safe to re-run in Supabase SQL Editor.
-- =============================================================================

-- Folders per user (manual organization; threads may have folder_id NULL = unfiled).
create table if not exists ai_chat_folders (
    id          bigserial         primary key,
    user_id     text              not null,
    name        text              not null,
    sort_order  integer           not null default 0,
    created_at  timestamptz       not null default now(),
    updated_at  timestamptz       not null default now(),
    constraint ai_chat_folders_name_nonempty
        check (char_length(trim(name)) > 0),
    constraint ai_chat_folders_name_maxlen
        check (char_length(name) <= 120)
);

create index if not exists idx_ai_chat_folders_user
    on ai_chat_folders (user_id, sort_order asc, name asc, id asc);

alter table ai_chat_threads
    add column if not exists folder_id bigint
    references ai_chat_folders (id) on delete set null;

create index if not exists idx_ai_chat_threads_user_folder
    on ai_chat_threads (user_id, folder_id, updated_at desc);
