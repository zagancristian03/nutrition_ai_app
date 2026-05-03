"""Pydantic request/response models."""
from __future__ import annotations

from datetime import date, datetime
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, model_validator

MealType = Literal["breakfast", "lunch", "dinner", "snack"]

Sex            = Literal["male", "female", "other"]
GoalType       = Literal["lose", "maintain", "gain"]
ActivityLevel  = Literal["sedentary", "light", "moderate", "active", "very_active"]


# =============================================================================
# /foods/search
# =============================================================================
class FoodOut(BaseModel):
    """Row returned by GET /foods/search (per-100 g values)."""

    model_config = ConfigDict(from_attributes=True)

    id: UUID
    name: str
    brand: str | None = None
    calories: float
    protein: float
    carbs: float
    fat: float


# =============================================================================
# POST /foods
# =============================================================================
class FoodCreate(BaseModel):
    """
    Minimal payload to insert a new food row (used by the Flutter "add food
    manually" screen). All macros are per 100 g — the client converts from
    its per-serving form before sending.
    """

    name: str = Field(..., min_length=1, max_length=256)
    brand: str | None = Field(default=None, max_length=256)
    calories_per_100g: float = Field(..., ge=0, le=1000)
    protein_per_100g: float = Field(default=0.0, ge=0, le=200)
    carbs_per_100g:   float = Field(default=0.0, ge=0, le=200)
    fat_per_100g:     float = Field(default=0.0, ge=0, le=200)
    serving_size_g:   float | None = Field(default=None, gt=0, le=5000)


# =============================================================================
# /food-logs
# =============================================================================
class FoodLogCreate(BaseModel):
    user_id: str = Field(..., min_length=1, max_length=128)
    food_id: UUID
    logged_date: date
    meal_type: MealType
    grams: float | None = Field(default=None, ge=0, le=10_000)
    servings: float | None = Field(default=None, ge=0, le=100)

    @model_validator(mode="after")
    def _portion_present(self) -> "FoodLogCreate":
        if self.grams is None and self.servings is None:
            raise ValueError("Either `grams` or `servings` must be provided")
        return self


class FoodLogUpdate(BaseModel):
    """
    Update an existing food_log. The user_id is supplied via query param on
    the endpoint (so it can be verified against the row). Every field here is
    optional — only provided fields are written.
    """

    meal_type:   MealType | None = None
    grams:       float    | None = Field(default=None, ge=0, le=10_000)
    servings:    float    | None = Field(default=None, ge=0, le=100)
    logged_date: date     | None = None
    food_name:   str      | None = Field(default=None, min_length=1, max_length=256)

    # Allow direct macro overrides (used by the "Edit entry" screen which lets
    # the user tweak the exact numbers rather than the portion).
    calories:    float | None = Field(default=None, ge=0, le=20_000)
    protein:     float | None = Field(default=None, ge=0, le=2_000)
    carbs:       float | None = Field(default=None, ge=0, le=2_000)
    fat:         float | None = Field(default=None, ge=0, le=2_000)


class FoodLogOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: str
    food_id: UUID
    food_name: str
    logged_date: date
    meal_type: str
    grams: float | None
    servings: float | None
    calories: float
    protein: float
    carbs: float
    fat: float
    created_at: datetime


# =============================================================================
# /user-goals
# =============================================================================
class UserGoals(BaseModel):
    """Per-user nutrition targets."""

    model_config = ConfigDict(from_attributes=True)

    user_id:      str   = Field(..., min_length=1, max_length=128)
    calorie_goal: float = Field(..., ge=0, le=20_000)
    protein_goal: float = Field(..., ge=0, le=2_000)
    carbs_goal:   float = Field(..., ge=0, le=2_000)
    fat_goal:     float = Field(..., ge=0, le=2_000)


class UserGoalsUpdate(BaseModel):
    """Upsert payload — user_id comes from the URL, so it's not repeated here."""

    calorie_goal: float = Field(..., ge=0, le=20_000)
    protein_goal: float = Field(..., ge=0, le=2_000)
    carbs_goal:   float = Field(..., ge=0, le=2_000)
    fat_goal:     float = Field(..., ge=0, le=2_000)


# =============================================================================
# /user-profile
# =============================================================================
class UserProfile(BaseModel):
    """Per-user body-stats + goal profile. All fields nullable — the row is
    created lazily and the user fills it in over time."""

    model_config = ConfigDict(from_attributes=True)

    user_id:           str
    display_name:      str           | None = None
    sex:               Sex           | None = None
    date_of_birth:     date          | None = None
    height_cm:         float         | None = None
    current_weight_kg: float         | None = None
    target_weight_kg:  float         | None = None
    goal_type:         GoalType      | None = None
    activity_level:    ActivityLevel | None = None
    weekly_rate_kg:    float         | None = None
    updated_at:        datetime      | None = None


class UserProfileUpdate(BaseModel):
    """Upsert payload. user_id comes from URL."""

    display_name:      str           | None = Field(default=None, max_length=128)
    sex:               Sex           | None = None
    date_of_birth:     date          | None = None
    height_cm:         float         | None = Field(default=None, gt=0, le=300)
    current_weight_kg: float         | None = Field(default=None, gt=0, le=500)
    target_weight_kg:  float         | None = Field(default=None, gt=0, le=500)
    goal_type:         GoalType      | None = None
    activity_level:    ActivityLevel | None = None
    weekly_rate_kg:    float         | None = Field(default=None, ge=0, le=2)


# =============================================================================
# /weight-logs
# =============================================================================
class WeightLogCreate(BaseModel):
    user_id:   str   = Field(..., min_length=1, max_length=128)
    weight_kg: float = Field(..., gt=0, le=500)
    logged_on: date  | None = None
    note:      str   | None = Field(default=None, max_length=256)


class WeightLogOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id:         int
    user_id:    str
    weight_kg:  float
    logged_on:  date
    note:       str | None
    created_at: datetime


# =============================================================================
# /ai — coaching layer
# =============================================================================
# Enumerations below are Literal-typed only where the value is truly closed.
# Open-ended sets (goals, struggles, training types) use free `str` values +
# a dedicated `*_note` free-text column, so the UI can evolve without
# requiring a DB or backend change.
ApproachStyle     = Literal["aggressive", "balanced", "flexible", "sustainable"]
DietaryPattern    = Literal["omnivore", "vegetarian", "vegan", "pescatarian", "other"]
BudgetSensitivity = Literal["low", "medium", "high"]
CookingPreference = Literal["none", "simple", "enjoys"]
StruggleTiming    = Literal["morning", "afternoon", "evening", "night", "weekends", "stress"]
LowMedHigh        = Literal["low", "medium", "high"]
CoachTone         = Literal["direct", "balanced", "gentler"]

TrainingIntensity = Literal["light", "moderate", "hard", "very_hard"]
JobActivity       = Literal["desk", "mostly_seated", "on_feet", "physical_labor"]
StepsBand         = Literal["under_5k", "5k_7k", "7k_10k", "10k_15k", "over_15k"]
SleepBand         = Literal["under_5", "5_6", "6_7", "7_8", "over_8"]
AlcoholFrequency  = Literal["none", "occasional", "weekly", "frequent"]
EatingOutFreq     = Literal["rarely", "weekly", "often", "daily"]


class AiOnboardingPayload(BaseModel):
    """All fields optional — the client may save partial progress with
    `mark_completed=false`. Arrays default to null when omitted."""

    # ---------------------------------------------------------------- Goals
    main_goals:                  list[str] | None = Field(default=None, max_length=10)
    main_goal_note:              str | None = Field(default=None, max_length=1000)
    approach_style:              ApproachStyle | None = None

    # --------------------------------------------------------------- Diet
    dietary_pattern:             DietaryPattern | None = None
    dietary_pattern_note:        str | None = Field(default=None, max_length=512)
    allergies:                   str | None = Field(default=None, max_length=512)
    disliked_foods:              str | None = Field(default=None, max_length=512)
    favorite_foods:              str | None = Field(default=None, max_length=512)
    cuisines_enjoyed:            str | None = Field(default=None, max_length=512)
    eating_out_frequency:        EatingOutFreq | None = None
    budget_sensitivity:          BudgetSensitivity | None = None
    cooking_preference:          CookingPreference | None = None
    meal_frequency:              int | None = Field(default=None, ge=1, le=10)

    # --------------------------------------------------------- Training / activity
    training_frequency_per_week: int | None = Field(default=None, ge=0, le=14)
    training_types:              list[str] | None = Field(default=None, max_length=15)
    training_intensity:          TrainingIntensity | None = None
    training_notes:              str | None = Field(default=None, max_length=512)
    job_activity:                JobActivity | None = None
    steps_per_day_band:          StepsBand | None = None

    # -------------------------------------------------------- Lifestyle / recovery
    sleep_hours_band:            SleepBand | None = None
    stress_level:                LowMedHigh | None = None
    water_intake:                LowMedHigh | None = None
    alcohol_frequency:           AlcoholFrequency | None = None

    # ---------------------------------------------------------- Behavioral
    biggest_struggles:           list[str] | None = Field(default=None, max_length=10)
    biggest_struggle_note:       str | None = Field(default=None, max_length=1000)
    struggle_timing:             StruggleTiming | None = None
    motivation_level:            LowMedHigh | None = None
    structure_preference:        LowMedHigh | None = None

    # ---------------------------------------------------------------- Tone
    coach_tone:                  CoachTone | None = None

    extras:                      dict | None = None


class AiProfileOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    user_id:                     str
    onboarding_completed:        bool

    main_goals:                  list[str] = Field(default_factory=list)
    main_goal_note:              str | None = None
    approach_style:              str | None = None

    dietary_pattern:             str | None = None
    dietary_pattern_note:        str | None = None
    allergies:                   str | None = None
    disliked_foods:              str | None = None
    favorite_foods:              str | None = None
    cuisines_enjoyed:            str | None = None
    eating_out_frequency:        str | None = None
    budget_sensitivity:          str | None = None
    cooking_preference:          str | None = None
    meal_frequency:              int | None = None

    training_frequency_per_week: int | None = None
    training_types:              list[str] = Field(default_factory=list)
    training_intensity:          str | None = None
    training_notes:              str | None = None
    job_activity:                str | None = None
    steps_per_day_band:          str | None = None

    sleep_hours_band:            str | None = None
    stress_level:                str | None = None
    water_intake:                str | None = None
    alcohol_frequency:           str | None = None

    biggest_struggles:           list[str] = Field(default_factory=list)
    biggest_struggle_note:       str | None = None
    struggle_timing:             str | None = None
    motivation_level:            str | None = None
    structure_preference:        str | None = None

    coach_tone:                  str  = "balanced"
    extras:                      dict = Field(default_factory=dict)
    derived_summary:             str | None = None

    created_at:                  datetime | None = None
    updated_at:                  datetime | None = None


class AiChatRequest(BaseModel):
    user_id:   str  = Field(..., min_length=1, max_length=128)
    message:   str  = Field(..., min_length=1, max_length=4000)
    thread_id: int  | None = None


class AiChatResponse(BaseModel):
    thread_id: int
    reply:     str


class AiChatMessage(BaseModel):
    role:       Literal["user", "assistant", "system"]
    content:    str
    created_at: datetime | None = None


class AiChatHistory(BaseModel):
    thread_id: int   | None
    title:     str   | None = None
    summary:   str   | None = None
    messages:  list[AiChatMessage] = Field(default_factory=list)


class AiThreadOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id:            int
    user_id:       str
    title:         str | None = None
    summary:       str | None = None
    message_count: int = 0
    folder_id:     int | None = None
    created_at:    datetime | None = None
    updated_at:    datetime | None = None


class AiThreadCreate(BaseModel):
    """Create an empty conversation; the user can send the first message next."""

    user_id:   str  = Field(..., min_length=1, max_length=128)
    title:     str | None = Field(default=None, max_length=120)
    folder_id: int  | None = Field(default=None, ge=1)


class AiThreadUpdate(BaseModel):
    """Partial update: only fields present in the JSON body are applied."""

    title:     str | None = Field(default=None, max_length=120)
    folder_id: int | None = None

    @model_validator(mode="after")
    def _folder_id_positive(self) -> AiThreadUpdate:
        fid = self.folder_id
        if fid is not None and fid < 1:
            raise ValueError("folder_id must be a positive integer")
        return self


class AiFolderOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id:          int
    user_id:     str
    name:           str
    sort_order:     int = 0
    created_at:  datetime | None = None
    updated_at:  datetime | None = None


class AiFolderCreate(BaseModel):
    user_id: str = Field(..., min_length=1, max_length=128)
    name:    str = Field(..., min_length=1, max_length=120)


class AiFolderRename(BaseModel):
    name: str = Field(..., min_length=1, max_length=120)


class AiReviewOut(BaseModel):
    review: str
    on_date: str | None = None
    start:   str | None = None
    end:     str | None = None


class AiMealSuggestion(BaseModel):
    name:                 str
    why:                  str | None = None
    estimated_calories:   int | float | None = None
    estimated_protein:    int | float | None = None
    estimated_carbs:      int | float | None = None
    estimated_fat:        int | float | None = None


class AiMealRecommendations(BaseModel):
    remaining:   dict[str, float]
    suggestions: list[AiMealSuggestion] = Field(default_factory=list)
