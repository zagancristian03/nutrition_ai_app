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
from typing import Any

from psycopg2.extras import RealDictCursor

from db import get_conn

from .openai_client import SUMMARY_MODEL, chat_completion
from .prompts import THREAD_SUMMARY_INSTRUCTIONS

log = logging.getLogger("ai.memory")

RECENT_WINDOW: int = 10   # messages kept raw in the prompt
SUMMARIZE_AT:  int = 30   # total messages that triggers summarization


def load_thread(thread_id: int, user_id: str) -> dict[str, Any] | None:
    with get_conn() as conn, conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            """
            SELECT id, user_id, title, summary, message_count, created_at, updated_at
            FROM ai_chat_threads
            WHERE id = %s AND user_id = %s
            """,
            (thread_id, user_id),
        )
        row = cur.fetchone()
    return dict(row) if row else None


def create_thread(user_id: str, title: str | None = None) -> dict[str, Any]:
    with get_conn() as conn:
        conn.autocommit = False
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                """
                INSERT INTO ai_chat_threads (user_id, title)
                VALUES (%s, %s)
                RETURNING id, user_id, title, summary, message_count, created_at, updated_at
                """,
                (user_id, title),
            )
            row = cur.fetchone()
            conn.commit()
    assert row is not None
    return dict(row)


def list_threads(user_id: str, limit: int = 20) -> list[dict[str, Any]]:
    with get_conn() as conn, conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            """
            SELECT id, user_id, title, summary, message_count, created_at, updated_at
            FROM ai_chat_threads
            WHERE user_id = %s
            ORDER BY updated_at DESC
            LIMIT %s
            """,
            (user_id, limit),
        )
        return [dict(r) for r in cur.fetchall()]


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
