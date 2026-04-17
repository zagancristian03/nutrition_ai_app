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
