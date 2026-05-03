"""Chat memory: recent window + rolling summary.

Strategy (cheap + stable):
  * Keep the last `RECENT_WINDOW` messages raw in every prompt.
  * Once a thread exceeds `SUMMARIZE_AT` messages, summarize everything
    OLDER than the recent window into `ai_chat_threads.summary` and keep
    the recent window raw. The summary is then injected as a prefix in the
    system prompt on subsequent turns.
"""
from __future__ import annotations

import logging
import threading
from typing import Any

from psycopg2 import errors as pg_errors
from psycopg2.extras import RealDictCursor

from db import get_conn

from .openai_client import SUMMARY_MODEL, chat_completion
from .prompts import THREAD_SUMMARY_INSTRUCTIONS

log = logging.getLogger("ai.memory")

RECENT_WINDOW: int = 10   # messages kept raw in the prompt
SUMMARIZE_AT:  int = 30   # total messages that triggers summarization


_folder_schema_lock = threading.Lock()
_folder_schema_ready = False


def _ensure_folder_schema() -> None:
    """Create ai_chat_folders + folder_id if missing (same as 009_ai_chat_folders.sql).

    Avoids 'Could not create folder' when the SQL migration was not applied on the DB.
    """
    global _folder_schema_ready
    if _folder_schema_ready:
        return
    with _folder_schema_lock:
        if _folder_schema_ready:
            return
        with get_conn() as conn:
            conn.autocommit = True
            with conn.cursor() as cur:
                cur.execute(
                    """
                    CREATE TABLE IF NOT EXISTS ai_chat_folders (
                        id          bigserial PRIMARY KEY,
                        user_id     text NOT NULL,
                        name        text NOT NULL,
                        sort_order  integer NOT NULL DEFAULT 0,
                        created_at  timestamptz NOT NULL DEFAULT now(),
                        updated_at  timestamptz NOT NULL DEFAULT now(),
                        CONSTRAINT ai_chat_folders_name_nonempty
                            CHECK (char_length(trim(name)) > 0),
                        CONSTRAINT ai_chat_folders_name_maxlen
                            CHECK (char_length(name) <= 120)
                    );
                    """
                )
                cur.execute(
                    """
                    CREATE INDEX IF NOT EXISTS idx_ai_chat_folders_user
                        ON ai_chat_folders (user_id, sort_order ASC, name ASC, id ASC);
                    """
                )
                cur.execute(
                    """
                    ALTER TABLE ai_chat_threads
                        ADD COLUMN IF NOT EXISTS folder_id bigint
                        REFERENCES ai_chat_folders(id) ON DELETE SET NULL;
                    """
                )
                cur.execute(
                    """
                    CREATE INDEX IF NOT EXISTS idx_ai_chat_threads_user_folder
                        ON ai_chat_threads (user_id, folder_id, updated_at DESC);
                    """
                )
        _folder_schema_ready = True
        log.info("ai_chat_folders schema ensured (auto-migrated)")


def _thread_row(d: dict[str, Any]) -> dict[str, Any]:
    row = dict(d)
    row.setdefault("folder_id", None)
    return row


def load_thread(thread_id: int, user_id: str) -> dict[str, Any] | None:
    with get_conn() as conn, conn.cursor(cursor_factory=RealDictCursor) as cur:
        try:
            cur.execute(
                """
                SELECT id, user_id, title, summary, message_count, folder_id,
                       created_at, updated_at
                FROM ai_chat_threads
                WHERE id = %s AND user_id = %s
                """,
                (thread_id, user_id),
            )
        except pg_errors.UndefinedColumn:
            conn.rollback()
            log.warning(
                "ai_chat_threads.folder_id missing — run database/schema/009_ai_chat_folders.sql"
            )
            cur.execute(
                """
                SELECT id, user_id, title, summary, message_count,
                       created_at, updated_at
                FROM ai_chat_threads
                WHERE id = %s AND user_id = %s
                """,
                (thread_id, user_id),
            )
        row = cur.fetchone()
    return _thread_row(dict(row)) if row else None


def _folder_belongs(user_id: str, folder_id: int) -> bool:
    _ensure_folder_schema()
    try:
        with get_conn() as conn, conn.cursor() as cur:
            cur.execute(
                """
                SELECT 1 FROM ai_chat_folders
                WHERE id = %s AND user_id = %s
                """,
                (folder_id, user_id),
            )
            return cur.fetchone() is not None
    except pg_errors.UndefinedTable:
        log.warning("ai_chat_folders missing — run database/schema/009_ai_chat_folders.sql")
        return False


def create_thread(
    user_id: str,
    title: str | None = None,
    folder_id: int | None = None,
) -> dict[str, Any]:
    if folder_id is not None and not _folder_belongs(user_id, folder_id):
        raise LookupError("folder not found")
    with get_conn() as conn:
        conn.autocommit = False
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            try:
                cur.execute(
                    """
                    INSERT INTO ai_chat_threads (user_id, title, folder_id)
                    VALUES (%s, %s, %s)
                    RETURNING id, user_id, title, summary, message_count, folder_id,
                              created_at, updated_at
                    """,
                    (user_id, title, folder_id),
                )
            except pg_errors.UndefinedColumn:
                conn.rollback()
                log.warning(
                    "ai_chat_threads.folder_id missing — inserting without folder_id "
                    "(run database/schema/009_ai_chat_folders.sql for folders)."
                )
                cur.execute(
                    """
                    INSERT INTO ai_chat_threads (user_id, title)
                    VALUES (%s, %s)
                    RETURNING id, user_id, title, summary, message_count,
                              created_at, updated_at
                    """,
                    (user_id, title),
                )
            row = cur.fetchone()
            conn.commit()
    assert row is not None
    return _thread_row(dict(row))


def _reset_folder_schema_cache() -> None:
    """Clear one-shot flag so the next call re-runs DDL (e.g. after a failed ALTER)."""
    global _folder_schema_ready
    with _folder_schema_lock:
        _folder_schema_ready = False


def patch_thread(user_id: str, thread_id: int, updates: dict[str, Any]) -> dict[str, Any] | None:
    """Apply partial updates. Keys: title (str|None), folder_id (int|None)."""
    _ensure_folder_schema()
    if not updates:
        return load_thread(thread_id, user_id)
    if "folder_id" in updates:
        fid = updates["folder_id"]
        if fid is not None:
            fid = int(fid)
            if not _folder_belongs(user_id, fid):
                raise LookupError("folder not found")
            updates = {**updates, "folder_id": fid}
    sets: list[str] = ["updated_at = now()"]
    args: list[Any] = []

    if "title" in updates:
        t = updates["title"]
        if t is not None:
            t = str(t).strip()
            if not t:
                t = None
            else:
                t = t[:120]
        sets.append("title = %s")
        args.append(t)

    if "folder_id" in updates:
        sets.append("folder_id = %s")
        args.append(updates["folder_id"])

    args.extend([thread_id, user_id])
    sql = (
        f"UPDATE ai_chat_threads SET {', '.join(sets)} "
        "WHERE id = %s AND user_id = %s "
        "RETURNING id, user_id, title, summary, message_count, folder_id, "
        "created_at, updated_at"
    )
    with get_conn() as conn, conn.cursor(cursor_factory=RealDictCursor) as cur:
        try:
            cur.execute(sql, args)
        except pg_errors.UndefinedColumn:
            conn.rollback()
            log.warning(
                "patch_thread: folder_id column missing on UPDATE — resetting schema cache and retrying"
            )
            _reset_folder_schema_cache()
            _ensure_folder_schema()
            cur.execute(sql, args)
        out = cur.fetchone()
    return _thread_row(dict(out)) if out else None


def list_threads(user_id: str, limit: int = 20) -> list[dict[str, Any]]:
    with get_conn() as conn, conn.cursor(cursor_factory=RealDictCursor) as cur:
        try:
            cur.execute(
                """
                SELECT id, user_id, title, summary, message_count, folder_id,
                       created_at, updated_at
                FROM ai_chat_threads
                WHERE user_id = %s
                ORDER BY updated_at DESC
                LIMIT %s
                """,
                (user_id, limit),
            )
        except pg_errors.UndefinedColumn:
            conn.rollback()
            log.warning(
                "ai_chat_threads.folder_id missing — listing threads without it "
                "(run database/schema/009_ai_chat_folders.sql)."
            )
            cur.execute(
                """
                SELECT id, user_id, title, summary, message_count,
                       created_at, updated_at
                FROM ai_chat_threads
                WHERE user_id = %s
                ORDER BY updated_at DESC
                LIMIT %s
                """,
                (user_id, limit),
            )
        return [_thread_row(dict(r)) for r in cur.fetchall()]


def list_folders(user_id: str) -> list[dict[str, Any]]:
    _ensure_folder_schema()
    try:
        with get_conn() as conn, conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                """
                SELECT id, user_id, name, sort_order, created_at, updated_at
                FROM ai_chat_folders
                WHERE user_id = %s
                ORDER BY sort_order ASC, name ASC, id ASC
                """,
                (user_id,),
            )
            return [dict(r) for r in cur.fetchall()]
    except pg_errors.UndefinedTable:
        log.warning("ai_chat_folders missing — run database/schema/009_ai_chat_folders.sql")
        return []


def create_folder(user_id: str, name: str) -> dict[str, Any]:
    _ensure_folder_schema()
    name = name.strip()
    if not name:
        raise ValueError("folder name is empty")
    name = name[:120]
    with get_conn() as conn:
        conn.autocommit = False
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                """
                INSERT INTO ai_chat_folders (user_id, name)
                VALUES (%s, %s)
                RETURNING id, user_id, name, sort_order, created_at, updated_at
                """,
                (user_id, name),
            )
            row = cur.fetchone()
            conn.commit()
    assert row is not None
    return dict(row)


def rename_folder(user_id: str, folder_id: int, name: str) -> dict[str, Any] | None:
    _ensure_folder_schema()
    name = name.strip()
    if not name:
        raise ValueError("folder name is empty")
    name = name[:120]
    with get_conn() as conn, conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            """
            UPDATE ai_chat_folders
            SET name = %s, updated_at = now()
            WHERE id = %s AND user_id = %s
            RETURNING id, user_id, name, sort_order, created_at, updated_at
            """,
            (name, folder_id, user_id),
        )
        row = cur.fetchone()
    return dict(row) if row else None


def delete_folder(user_id: str, folder_id: int) -> bool:
    """Delete folder; threads keep folder_id = NULL (FK on delete set null)."""
    _ensure_folder_schema()
    try:
        with get_conn() as conn, conn.cursor() as cur:
            cur.execute(
                "DELETE FROM ai_chat_folders WHERE id = %s AND user_id = %s",
                (folder_id, user_id),
            )
            return cur.rowcount > 0
    except pg_errors.UndefinedTable:
        log.warning("ai_chat_folders missing — delete_folder is a no-op")
        return False


def list_recent_messages(thread_id: int, limit: int = RECENT_WINDOW) -> list[dict[str, Any]]:
    """Return the last `limit` messages in chronological order."""
    with get_conn() as conn, conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            """
            SELECT id, role, content, created_at
            FROM (
                SELECT id, role, content, created_at
                FROM ai_chat_messages
                WHERE thread_id = %s
                ORDER BY created_at DESC
                LIMIT %s
            ) t
            ORDER BY created_at ASC
            """,
            (thread_id, limit),
        )
        return [dict(r) for r in cur.fetchall()]


def list_all_messages(thread_id: int) -> list[dict[str, Any]]:
    with get_conn() as conn, conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            """
            SELECT id, role, content, created_at
            FROM ai_chat_messages
            WHERE thread_id = %s
            ORDER BY created_at ASC
            """,
            (thread_id,),
        )
        return [dict(r) for r in cur.fetchall()]


def save_message(
    *, thread_id: int, user_id: str, role: str, content: str,
    metadata: dict[str, Any] | None = None,
) -> int:
    """Insert a message, bump thread counters, return the new id."""
    with get_conn() as conn:
        conn.autocommit = False
        try:
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(
                    """
                    INSERT INTO ai_chat_messages
                        (thread_id, user_id, role, content, metadata)
                    VALUES (%s, %s, %s, %s, %s::jsonb)
                    RETURNING id
                    """,
                    (thread_id, user_id, role, content, _as_jsonb(metadata)),
                )
                new_id: int = cur.fetchone()["id"]

                cur.execute(
                    """
                    UPDATE ai_chat_threads
                    SET message_count = message_count + 1,
                        updated_at    = now()
                    WHERE id = %s
                    """,
                    (thread_id,),
                )
                conn.commit()
        except Exception:
            conn.rollback()
            raise
    return new_id


def set_thread_title_if_empty(thread_id: int, title: str) -> None:
    title = title.strip()
    if not title:
        return
    title = title[:80]
    with get_conn() as conn:
        conn.autocommit = True
        with conn.cursor() as cur:
            cur.execute(
                """
                UPDATE ai_chat_threads
                SET title = %s
                WHERE id = %s AND (title IS NULL OR title = '')
                """,
                (title, thread_id),
            )


# ---------------------------------------------------------------------------
# Summarization
# ---------------------------------------------------------------------------

def maybe_summarize(thread_id: int, user_id: str) -> None:
    """Trigger a rolling summary if the thread crossed the threshold.

    Non-fatal: if OpenAI fails here we swallow the error — the chat flow
    already completed, and we'll try again on the next turn.
    """
    thread = load_thread(thread_id, user_id)
    if thread is None:
        return

    total = int(thread.get("message_count") or 0)
    if total < SUMMARIZE_AT:
        return

    all_msgs = list_all_messages(thread_id)
    # Older = everything NOT in the recent window.
    older = all_msgs[:-RECENT_WINDOW] if len(all_msgs) > RECENT_WINDOW else []
    if not older:
        return

    transcript_lines = [f"{m['role'].upper()}: {m['content']}" for m in older]
    transcript = "\n".join(transcript_lines)

    prior = (thread.get("summary") or "").strip()
    seed = (
        f"Existing summary (may be empty):\n{prior or '(none)'}\n\n"
        f"New older messages to fold in:\n{transcript}"
    )

    try:
        new_summary = chat_completion(
            messages=[
                {"role": "system", "content": THREAD_SUMMARY_INSTRUCTIONS},
                {"role": "user",   "content": seed},
            ],
            model=SUMMARY_MODEL,
            temperature=0.2,
            max_tokens=350,
        )
    except Exception as e:  # noqa: BLE001
        log.warning("thread summary failed for thread %s: %s", thread_id, e)
        return

    if not new_summary.strip():
        return

    with get_conn() as conn:
        conn.autocommit = True
        with conn.cursor() as cur:
            cur.execute(
                "UPDATE ai_chat_threads SET summary = %s, updated_at = now() WHERE id = %s",
                (new_summary.strip(), thread_id),
            )


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _as_jsonb(v: dict[str, Any] | None) -> str:
    """psycopg2 needs JSON as a string when using `::jsonb`."""
    import json
    return json.dumps(v or {})
