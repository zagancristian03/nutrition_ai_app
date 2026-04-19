"""Coaching orchestration.

The router calls these; they own the SQL + OpenAI calls. Splitting the
"what" (service functions) from the "how" (HTTP) keeps the router small
and makes the services easy to call from tests or future background jobs.
"""
from __future__ import annotations

import json
import logging
from datetime import date, timedelta
from typing import Any

from psycopg2.extras import RealDictCursor

from db import get_conn

from . import context as ctx
from . import memory
from .openai_client import chat_completion
from .prompts import (
    COACH_SYSTEM_PROMPT,
    DAILY_REVIEW_INSTRUCTIONS,
    MEAL_RECOMMENDATION_INSTRUCTIONS,
    PROFILE_DERIVED_SUMMARY_INSTRUCTIONS,
    WEEKLY_REVIEW_INSTRUCTIONS,
)

log = logging.getLogger("ai.services")


# ---------------------------------------------------------------------------
# Onboarding profile
# ---------------------------------------------------------------------------

_PROFILE_WRITABLE: tuple[str, ...] = (
    # Goals
    "main_goals", "main_goal_note", "approach_style",
    # Diet
    "dietary_pattern", "dietary_pattern_note",
    "allergies", "disliked_foods", "favorite_foods",
    "cuisines_enjoyed", "eating_out_frequency",
    "budget_sensitivity", "cooking_preference", "meal_frequency",
    # Training / activity
    "training_frequency_per_week", "training_types", "training_intensity",
    "training_notes", "job_activity", "steps_per_day_band",
    # Lifestyle / recovery
    "sleep_hours_band", "stress_level", "water_intake", "alcohol_frequency",
    # Behavioral
    "biggest_struggles", "biggest_struggle_note", "struggle_timing",
    "motivation_level", "structure_preference",
    # Tone
    "coach_tone",
)


def get_profile(user_id: str) -> dict[str, Any]:
    """Return the AI profile, or a skeleton row with `onboarding_completed=false`."""
    row = ctx.fetch_ai_profile(user_id)
    if row:
        return row
    # Skeleton with the same keys the SELECT returns, so the pydantic model
    # serializes cleanly for a never-onboarded user.
    return {
        "user_id": user_id,
        "onboarding_completed": False,
        "main_goals": [], "main_goal_note": None, "approach_style": None,
        "dietary_pattern": None, "dietary_pattern_note": None,
        "allergies": None, "disliked_foods": None, "favorite_foods": None,
        "cuisines_enjoyed": None, "eating_out_frequency": None,
        "budget_sensitivity": None, "cooking_preference": None,
        "meal_frequency": None,
        "training_frequency_per_week": None, "training_types": [],
        "training_intensity": None, "training_notes": None,
        "job_activity": None, "steps_per_day_band": None,
        "sleep_hours_band": None, "stress_level": None,
        "water_intake": None, "alcohol_frequency": None,
        "biggest_struggles": [], "biggest_struggle_note": None,
        "struggle_timing": None, "motivation_level": None,
        "structure_preference": None,
        "coach_tone": "balanced",
        "extras": {},
        "derived_summary": None,
        "created_at": None, "updated_at": None,
    }


def save_onboarding(
    user_id: str,
    *,
    payload: dict[str, Any],
    extras: dict[str, Any] | None = None,
    mark_completed: bool = True,
) -> dict[str, Any]:
    """Upsert onboarding answers, regenerate the derived summary, return row."""
    provided = {k: v for k, v in payload.items() if k in _PROFILE_WRITABLE}

    # Build the derived summary BEFORE the DB write so it's always in sync.
    derived = _build_derived_summary({**provided, "extras": extras or {}})

    cols = ["user_id", *_PROFILE_WRITABLE, "extras", "derived_summary",
            "onboarding_completed"]
    values: list[Any] = [user_id]
    for c in _PROFILE_WRITABLE:
        values.append(provided.get(c))
    values.append(json.dumps(extras or {}))
    values.append(derived)
    values.append(bool(mark_completed))

    update_parts = [f"{c} = excluded.{c}" for c in _PROFILE_WRITABLE if c in provided]
    update_parts.append("extras = excluded.extras")
    update_parts.append("derived_summary = excluded.derived_summary")
    if mark_completed:
        update_parts.append("onboarding_completed = true")
    update_parts.append("updated_at = now()")

    placeholders = ", ".join(["%s"] * len(cols))
    sql = f"""
        INSERT INTO user_ai_profiles ({', '.join(cols)})
        VALUES ({placeholders})
        ON CONFLICT (user_id) DO UPDATE SET {', '.join(update_parts)}
        RETURNING
            user_id, onboarding_completed, main_goal, approach_style,
            dietary_pattern, allergies, disliked_foods, favorite_foods,
            budget_sensitivity, cooking_preference, meal_frequency,
            biggest_struggle, struggle_timing, motivation_level,
            structure_preference, coach_tone, extras, derived_summary,
            created_at, updated_at
    """

    with get_conn() as conn:
        conn.autocommit = False
        try:
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(sql, values)
                row = cur.fetchone()
                conn.commit()
        except Exception:
            conn.rollback()
            raise

    assert row is not None
    return dict(row)


def _build_derived_summary(payload: dict[str, Any]) -> str:
    """Ask the model to compress raw answers into a compact coaching profile.

    Falls back to a deterministic string if OpenAI is unavailable — we never
    want onboarding to fail just because the summary couldn't be built.
    """
    try:
        return chat_completion(
            messages=[
                {"role": "system", "content": PROFILE_DERIVED_SUMMARY_INSTRUCTIONS},
                {"role": "user",   "content": json.dumps(payload, default=str)},
            ],
            temperature=0.2,
            max_tokens=220,
        )
    except Exception as e:  # noqa: BLE001
        log.warning("derived summary fallback: %s", e)
        parts: list[str] = []
        goals = payload.get("main_goals") or []
        if goals:
            parts.append(f"Main goals: {', '.join(goals)}.")
        if payload.get("main_goal_note"):
            parts.append(f"Goal note: {payload['main_goal_note']}.")
        if payload.get("approach_style"):
            parts.append(f"Approach: {payload['approach_style']}.")
        if payload.get("dietary_pattern"):
            parts.append(f"Diet pattern: {payload['dietary_pattern']}.")
        freq = payload.get("training_frequency_per_week")
        if freq is not None:
            parts.append(f"Trains {freq}x/week.")
        t_types = payload.get("training_types") or []
        if t_types:
            parts.append(f"Training: {', '.join(t_types)}.")
        if payload.get("training_intensity"):
            parts.append(f"Intensity: {payload['training_intensity']}.")
        if payload.get("job_activity"):
            parts.append(f"Job activity: {payload['job_activity']}.")
        struggles = payload.get("biggest_struggles") or []
        if struggles:
            parts.append(f"Struggles with: {', '.join(struggles)}.")
        parts.append(f"Coach tone: {payload.get('coach_tone') or 'balanced'}.")
        return " ".join(parts)


# ---------------------------------------------------------------------------
# Chat
# ---------------------------------------------------------------------------

def chat_reply(
    *,
    user_id: str,
    message: str,
    thread_id: int | None,
    today: date,
) -> dict[str, Any]:
    """Run one chat turn and persist both sides."""
    # 1. Ensure a thread.
    if thread_id is None:
        thread = memory.create_thread(user_id)
        thread_id = thread["id"]
    else:
        thread = memory.load_thread(thread_id, user_id)
        if thread is None:
            raise LookupError("thread not found")

    # 2. Save the user message first so it's durable even if the model fails.
    memory.save_message(
        thread_id=thread_id, user_id=user_id, role="user", content=message,
    )

    # 3. Build the context block + message history.
    coach_ctx = ctx.build_coaching_context(user_id, today)
    system_prompt = ctx.compose_system_prompt(COACH_SYSTEM_PROMPT, coach_ctx)

    thread_summary = (thread.get("summary") or "").strip()
    if thread_summary:
        system_prompt += (
            "\n\n[THREAD SUMMARY — summarized older turns]\n"
            f"{thread_summary}\n[END THREAD SUMMARY]"
        )

    recent = memory.list_recent_messages(thread_id, limit=memory.RECENT_WINDOW)
    history = [{"role": m["role"], "content": m["content"]} for m in recent]

    messages = [{"role": "system", "content": system_prompt}, *history]

    # 4. Call the model.
    try:
        reply = chat_completion(
            messages=messages, temperature=0.6, max_tokens=600,
        )
    except Exception as e:  # noqa: BLE001
        log.exception("chat_completion failed")
        raise RuntimeError(str(e)) from e

    reply = reply.strip() or "Sorry — I didn't catch that. Could you rephrase?"

    # 5. Persist the reply.
    memory.save_message(
        thread_id=thread_id, user_id=user_id, role="assistant", content=reply,
    )

    # Auto-title a new thread from the user's first prompt.
    if not (thread.get("title") or "").strip():
        memory.set_thread_title_if_empty(thread_id, message)

    # 6. Summarize older turns if the thread has grown long.
    try:
        memory.maybe_summarize(thread_id, user_id)
    except Exception as e:  # noqa: BLE001
        log.warning("summarize failed: %s", e)

    return {"thread_id": thread_id, "reply": reply}


def list_chat_history(
    user_id: str,
    thread_id: int | None = None,
    limit: int = 100,
) -> dict[str, Any]:
    """Return the messages for a given thread (or the latest thread)."""
    if thread_id is None:
        threads = memory.list_threads(user_id, limit=1)
        if not threads:
            return {"thread_id": None, "messages": []}
        thread_id = threads[0]["id"]

    thread = memory.load_thread(thread_id, user_id)
    if thread is None:
        return {"thread_id": None, "messages": []}

    msgs = memory.list_recent_messages(thread_id, limit=limit)
    return {
        "thread_id": thread_id,
        "title":     thread.get("title"),
        "summary":   thread.get("summary"),
        "messages":  [
            {"role": m["role"], "content": m["content"],
             "created_at": m["created_at"]} for m in msgs
        ],
    }


# ---------------------------------------------------------------------------
# Reviews
# ---------------------------------------------------------------------------

def daily_review(user_id: str, on_date: date) -> dict[str, Any]:
    coach_ctx = ctx.build_coaching_context(user_id, on_date)
    system = ctx.compose_system_prompt(COACH_SYSTEM_PROMPT, coach_ctx)

    text = chat_completion(
        messages=[
            {"role": "system", "content": system},
            {"role": "user",   "content": DAILY_REVIEW_INSTRUCTIONS},
        ],
        temperature=0.4,
        max_tokens=500,
    )

    _log_recommendation(user_id, "review_day", {"on_date": on_date.isoformat()}, text)
    _upsert_summary(user_id, "daily", on_date, on_date, text)
    return {"on_date": on_date.isoformat(), "review": text}


def weekly_review(user_id: str, today: date) -> dict[str, Any]:
    coach_ctx = ctx.build_coaching_context(user_id, today)
    system = ctx.compose_system_prompt(COACH_SYSTEM_PROMPT, coach_ctx)

    text = chat_completion(
        messages=[
            {"role": "system", "content": system},
            {"role": "user",   "content": WEEKLY_REVIEW_INSTRUCTIONS},
        ],
        temperature=0.4,
        max_tokens=600,
    )

    start = today - timedelta(days=6)
    _log_recommendation(user_id, "review_week",
                        {"start": start.isoformat(), "end": today.isoformat()},
                        text)
    _upsert_summary(user_id, "weekly", start, today, text)
    return {"start": start.isoformat(), "end": today.isoformat(), "review": text}


# ---------------------------------------------------------------------------
# Meal recommendations
# ---------------------------------------------------------------------------

def recommend_meal(user_id: str, today: date) -> dict[str, Any]:
    coach_ctx = ctx.build_coaching_context(user_id, today)
    system = ctx.compose_system_prompt(COACH_SYSTEM_PROMPT, coach_ctx)

    goals   = coach_ctx["goals"]
    totals  = coach_ctx["day_totals"]
    remaining = {
        "calories": max(0.0, float(goals["calorie_goal"]) - float(totals["calories"])),
        "protein":  max(0.0, float(goals["protein_goal"]) - float(totals["protein"])),
        "carbs":    max(0.0, float(goals["carbs_goal"])   - float(totals["carbs"])),
        "fat":      max(0.0, float(goals["fat_goal"])     - float(totals["fat"])),
    }

    user_msg = (
        f"{MEAL_RECOMMENDATION_INSTRUCTIONS}\n\n"
        f"Remaining for today: "
        f"{int(remaining['calories'])} kcal, "
        f"protein {int(remaining['protein'])}g, "
        f"carbs {int(remaining['carbs'])}g, "
        f"fat {int(remaining['fat'])}g."
    )

    raw = chat_completion(
        messages=[
            {"role": "system", "content": system},
            {"role": "user",   "content": user_msg},
        ],
        temperature=0.5,
        max_tokens=700,
        json_mode=True,
    )

    parsed = _safe_json(raw) or {"suggestions": []}
    _log_recommendation(user_id, "meal",
                        {"remaining": remaining, "on_date": today.isoformat()},
                        raw)
    return {"remaining": remaining, **parsed}


# ---------------------------------------------------------------------------
# Internals
# ---------------------------------------------------------------------------

def _safe_json(raw: str) -> dict[str, Any] | None:
    raw = (raw or "").strip()
    if not raw:
        return None
    try:
        parsed = json.loads(raw)
    except json.JSONDecodeError:
        return None
    return parsed if isinstance(parsed, dict) else None


def _log_recommendation(
    user_id: str, kind: str, snapshot: dict[str, Any], response_text: str
) -> None:
    try:
        with get_conn() as conn:
            conn.autocommit = True
            with conn.cursor() as cur:
                cur.execute(
                    """
                    INSERT INTO ai_recommendations_log
                        (user_id, kind, prompt_snapshot, response_text)
                    VALUES (%s, %s, %s::jsonb, %s)
                    """,
                    (user_id, kind, json.dumps(snapshot, default=str), response_text),
                )
    except Exception as e:  # noqa: BLE001
        log.warning("recommendation log write failed: %s", e)


def _upsert_summary(
    user_id: str, kind: str, start: date, end: date, text: str,
) -> None:
    try:
        with get_conn() as conn:
            conn.autocommit = True
            with conn.cursor() as cur:
                cur.execute(
                    """
                    INSERT INTO ai_coaching_summaries
                        (user_id, kind, period_start, period_end, summary_text)
                    VALUES (%s, %s, %s, %s, %s)
                    """,
                    (user_id, kind, start, end, text),
                )
    except Exception as e:  # noqa: BLE001
        log.warning("coaching summary write failed: %s", e)
