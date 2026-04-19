"""Build compact, prompt-ready context blocks from the database.

Goal: stuff enough signal into the system prompt that the model can reason
about the user — goals, profile, today's intake, weekly trend — WITHOUT
dumping hundreds of raw rows. Everything returned here is already summarized.
"""
from __future__ import annotations

from datetime import date, timedelta
from typing import Any

from psycopg2.extras import RealDictCursor

from db import get_conn


# ---------------------------------------------------------------------------
# Individual fetchers — each keeps its own SQL so they stay small/readable.
# ---------------------------------------------------------------------------

def fetch_ai_profile(user_id: str) -> dict[str, Any] | None:
    with get_conn() as conn, conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            """
            SELECT user_id, onboarding_completed,
                   coalesce(main_goals, '{}')::text[]        AS main_goals,
                   main_goal_note, approach_style,
                   dietary_pattern, dietary_pattern_note,
                   allergies, disliked_foods, favorite_foods,
                   cuisines_enjoyed, eating_out_frequency,
                   budget_sensitivity, cooking_preference, meal_frequency,
                   training_frequency_per_week,
                   coalesce(training_types, '{}')::text[]    AS training_types,
                   training_intensity, training_notes,
                   job_activity, steps_per_day_band,
                   sleep_hours_band, stress_level, water_intake,
                   alcohol_frequency,
                   coalesce(biggest_struggles, '{}')::text[] AS biggest_struggles,
                   biggest_struggle_note, struggle_timing,
                   motivation_level, structure_preference,
                   coach_tone, extras, derived_summary,
                   created_at, updated_at
            FROM user_ai_profiles
            WHERE user_id = %s
            """,
            (user_id,),
        )
        row = cur.fetchone()
    return dict(row) if row else None


def fetch_goals(user_id: str) -> dict[str, float]:
    with get_conn() as conn, conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            """
            SELECT calorie_goal::float8 AS calorie_goal,
                   protein_goal::float8 AS protein_goal,
                   carbs_goal::float8   AS carbs_goal,
                   fat_goal::float8     AS fat_goal
            FROM user_goals WHERE user_id = %s
            """,
            (user_id,),
        )
        row = cur.fetchone()
    # Defaults match /user-goals fallback — keeps prompts consistent for new users.
    return dict(row) if row else {
        "calorie_goal": 2000.0,
        "protein_goal": 150.0,
        "carbs_goal":   250.0,
        "fat_goal":     65.0,
    }


def fetch_physical_profile(user_id: str) -> dict[str, Any] | None:
    """Body stats — optional, used only when relevant (e.g. weekly review)."""
    with get_conn() as conn, conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            """
            SELECT sex, date_of_birth, height_cm::float8 AS height_cm,
                   current_weight_kg::float8 AS current_weight_kg,
                   target_weight_kg::float8  AS target_weight_kg,
                   goal_type, activity_level,
                   weekly_rate_kg::float8 AS weekly_rate_kg
            FROM user_profiles WHERE user_id = %s
            """,
            (user_id,),
        )
        row = cur.fetchone()
    return dict(row) if row else None


def fetch_day_logs(user_id: str, on_date: date) -> list[dict[str, Any]]:
    with get_conn() as conn, conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            """
            SELECT food_name, meal_type,
                   grams::float8    AS grams,
                   calories::float8 AS calories,
                   protein::float8  AS protein,
                   carbs::float8    AS carbs,
                   fat::float8      AS fat
            FROM food_logs
            WHERE user_id = %s AND logged_date = %s
            ORDER BY created_at ASC
            """,
            (user_id, on_date),
        )
        return [dict(r) for r in cur.fetchall()]


def fetch_daily_totals(
    user_id: str, start: date, end: date
) -> list[dict[str, Any]]:
    """Per-day totals for the inclusive range [start, end]."""
    with get_conn() as conn, conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            """
            SELECT logged_date,
                   sum(calories)::float8 AS calories,
                   sum(protein)::float8  AS protein,
                   sum(carbs)::float8    AS carbs,
                   sum(fat)::float8      AS fat,
                   count(*)::int         AS entry_count
            FROM food_logs
            WHERE user_id = %s AND logged_date BETWEEN %s AND %s
            GROUP BY logged_date
            ORDER BY logged_date ASC
            """,
            (user_id, start, end),
        )
        return [dict(r) for r in cur.fetchall()]


# ---------------------------------------------------------------------------
# Formatters — turn DB rows into short human-readable blocks for the prompt.
# ---------------------------------------------------------------------------

def _round(v: Any, n: int = 0) -> Any:
    if v is None:
        return None
    try:
        return round(float(v), n) if n else int(round(float(v)))
    except (TypeError, ValueError):
        return v


def format_profile_block(profile: dict[str, Any] | None) -> str:
    if not profile:
        return "User has NOT completed onboarding yet. Ask them to finish onboarding before deep coaching."

    # Prefer the cached derived_summary — it's what the prompt is designed for.
    if (profile.get("derived_summary") or "").strip():
        extra_tone = profile.get("coach_tone") or "balanced"
        return f"{profile['derived_summary'].strip()}\nCoach tone preference: {extra_tone}."

    # Fallback: synthesize a compact block from raw fields, covering goals,
    # training, diet and lifestyle so the coach has enough to work with even
    # before the derived_summary finishes building.
    parts: list[str] = []

    goals = profile.get("main_goals") or []
    if goals:
        parts.append(f"Main goals: {', '.join(goals)}.")
    if profile.get("main_goal_note"):
        parts.append(f"Goal notes: {profile['main_goal_note']}.")
    if profile.get("approach_style"):
        parts.append(f"Approach: {profile['approach_style']}.")

    if profile.get("dietary_pattern"):
        parts.append(f"Diet: {profile['dietary_pattern']}.")
    if profile.get("dietary_pattern_note"):
        parts.append(f"Diet notes: {profile['dietary_pattern_note']}.")
    if profile.get("allergies"):
        parts.append(f"Allergies/intolerances: {profile['allergies']}.")
    if profile.get("disliked_foods"):
        parts.append(f"Disliked: {profile['disliked_foods']}.")
    if profile.get("favorite_foods"):
        parts.append(f"Favorites: {profile['favorite_foods']}.")
    if profile.get("cuisines_enjoyed"):
        parts.append(f"Cuisines: {profile['cuisines_enjoyed']}.")
    if profile.get("eating_out_frequency"):
        parts.append(f"Eats out: {profile['eating_out_frequency']}.")

    # Training / activity — big driver of caloric need and macro targets.
    freq = profile.get("training_frequency_per_week")
    if freq is not None:
        parts.append(f"Trains {freq}x/week.")
    t_types = profile.get("training_types") or []
    if t_types:
        parts.append(f"Training: {', '.join(t_types)}.")
    if profile.get("training_intensity"):
        parts.append(f"Intensity: {profile['training_intensity']}.")
    if profile.get("training_notes"):
        parts.append(f"Training notes: {profile['training_notes']}.")
    if profile.get("job_activity"):
        parts.append(f"Job activity: {profile['job_activity']}.")
    if profile.get("steps_per_day_band"):
        parts.append(f"Daily steps: {profile['steps_per_day_band']}.")

    # Lifestyle / recovery.
    if profile.get("sleep_hours_band"):
        parts.append(f"Sleep band: {profile['sleep_hours_band']}.")
    if profile.get("stress_level"):
        parts.append(f"Stress: {profile['stress_level']}.")
    if profile.get("water_intake"):
        parts.append(f"Water: {profile['water_intake']}.")
    if profile.get("alcohol_frequency"):
        parts.append(f"Alcohol: {profile['alcohol_frequency']}.")

    # Behavior.
    struggles = profile.get("biggest_struggles") or []
    if struggles:
        parts.append(f"Biggest struggles: {', '.join(struggles)}.")
    if profile.get("biggest_struggle_note"):
        parts.append(f"Struggle notes: {profile['biggest_struggle_note']}.")
    if profile.get("struggle_timing"):
        parts.append(f"Struggles most at: {profile['struggle_timing']}.")
    if profile.get("motivation_level"):
        parts.append(f"Motivation: {profile['motivation_level']}.")
    if profile.get("structure_preference"):
        parts.append(f"Wants structure: {profile['structure_preference']}.")

    parts.append(f"Coach tone: {profile.get('coach_tone') or 'balanced'}.")
    return " ".join(parts)


def format_today_block(
    totals: dict[str, float],
    goals: dict[str, float],
    day_logs: list[dict[str, Any]],
    on_date: date,
) -> str:
    if not day_logs:
        return f"Today ({on_date.isoformat()}): no foods logged yet."

    cals = _round(totals.get("calories"))
    prot = _round(totals.get("protein"))
    carb = _round(totals.get("carbs"))
    fat = _round(totals.get("fat"))

    cal_goal = _round(goals.get("calorie_goal"))
    prot_goal = _round(goals.get("protein_goal"))
    carb_goal = _round(goals.get("carbs_goal"))
    fat_goal = _round(goals.get("fat_goal"))

    header = (
        f"Today ({on_date.isoformat()}) totals: "
        f"{cals} / {cal_goal} kcal, "
        f"protein {prot}/{prot_goal} g, "
        f"carbs {carb}/{carb_goal} g, "
        f"fat {fat}/{fat_goal} g."
    )

    # Group by meal so the model sees the day structure without per-row bloat.
    by_meal: dict[str, list[str]] = {}
    for row in day_logs:
        meal = (row.get("meal_type") or "other").title()
        name = row.get("food_name") or "Food"
        grams = _round(row.get("grams"))
        cals_r = _round(row.get("calories"))
        line = f"{name} ({grams} g, {cals_r} kcal)"
        by_meal.setdefault(meal, []).append(line)

    meal_lines = [f"- {meal}: " + "; ".join(items) for meal, items in by_meal.items()]
    return header + "\nLogged items:\n" + "\n".join(meal_lines)


def format_week_block(
    daily_totals: list[dict[str, Any]],
    goals: dict[str, float],
    today: date,
) -> str:
    if not daily_totals:
        return "Last 7 days: nothing logged."

    lines: list[str] = []
    total_cal = total_prot = total_carb = total_fat = 0.0
    logged_days = 0
    for row in daily_totals:
        d = row["logged_date"]
        lines.append(
            f"- {d.isoformat()}: {_round(row['calories'])} kcal, "
            f"P {_round(row['protein'])}g, C {_round(row['carbs'])}g, "
            f"F {_round(row['fat'])}g ({row['entry_count']} items)"
        )
        total_cal += float(row["calories"] or 0)
        total_prot += float(row["protein"] or 0)
        total_carb += float(row["carbs"] or 0)
        total_fat += float(row["fat"] or 0)
        logged_days += 1

    window = 7
    span_start = today - timedelta(days=window - 1)
    missed_days = window - logged_days
    avg_cal = _round(total_cal / logged_days) if logged_days else 0

    header = (
        f"Last {window} days ({span_start.isoformat()} → {today.isoformat()}): "
        f"{logged_days} days logged, {missed_days} days missed. "
        f"Avg calories on logged days: {avg_cal} (goal {_round(goals['calorie_goal'])})."
    )
    return header + "\n" + "\n".join(lines)


# ---------------------------------------------------------------------------
# High-level bundles used by services.
# ---------------------------------------------------------------------------

def build_coaching_context(user_id: str, today: date) -> dict[str, Any]:
    """Fetch + format the blocks every coach call needs.

    Returns a dict with both the raw rows (for structured endpoints) and the
    pre-formatted text blocks (for the chat system prompt).
    """
    profile   = fetch_ai_profile(user_id)
    goals     = fetch_goals(user_id)
    day_logs  = fetch_day_logs(user_id, today)
    week_rows = fetch_daily_totals(user_id, today - timedelta(days=6), today)

    day_totals = {
        "calories": sum(float(r["calories"] or 0) for r in day_logs),
        "protein":  sum(float(r["protein"]  or 0) for r in day_logs),
        "carbs":    sum(float(r["carbs"]    or 0) for r in day_logs),
        "fat":      sum(float(r["fat"]      or 0) for r in day_logs),
    }

    return {
        "profile":       profile,
        "goals":         goals,
        "day_logs":      day_logs,
        "day_totals":    day_totals,
        "week_rows":     week_rows,
        "blocks": {
            "profile": format_profile_block(profile),
            "today":   format_today_block(day_totals, goals, day_logs, today),
            "week":    format_week_block(week_rows, goals, today),
        },
    }


def compose_system_prompt(base_prompt: str, context: dict[str, Any]) -> str:
    """Inject the formatted blocks under a clearly-labeled `[CONTEXT]` section."""
    blocks = context["blocks"]
    return (
        f"{base_prompt}\n\n"
        "[CONTEXT — read before every reply]\n"
        f"Profile: {blocks['profile']}\n\n"
        f"{blocks['today']}\n\n"
        f"{blocks['week']}\n"
        "[END CONTEXT]"
    )
