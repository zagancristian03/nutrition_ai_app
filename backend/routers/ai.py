"""AI coaching endpoints.

    POST  /ai/onboarding?user_id=...&mark_completed=true   -> upsert + summary
    GET   /ai/profile/{user_id}                            -> AiProfileOut
    POST  /ai/chat                                         -> AiChatResponse
    GET   /ai/chat/history                                 -> AiChatHistory
    GET   /ai/chat/threads                                 -> list[AiThreadOut]
    POST  /ai/review/day                                   -> AiReviewOut
    POST  /ai/review/week                                  -> AiReviewOut
    POST  /ai/recommend/meal                               -> AiMealRecommendations

Errors:
  * 502  when OpenAI is unreachable / misconfigured
  * 404  when a thread doesn't belong to the user
"""
from __future__ import annotations

import logging
from datetime import date

from fastapi import APIRouter, HTTPException, Path, Query

from ai import services
from schemas import (
    AiChatHistory,
    AiChatRequest,
    AiChatResponse,
    AiMealRecommendations,
    AiOnboardingPayload,
    AiProfileOut,
    AiReviewOut,
    AiThreadOut,
)

router = APIRouter(prefix="/ai", tags=["ai"])
log = logging.getLogger("ai.router")


def _bad_gateway(e: Exception) -> HTTPException:
    return HTTPException(status_code=502, detail=f"AI service error: {e}")


# --------------------------------------------------------------------------- #
# Onboarding                                                                  #
# --------------------------------------------------------------------------- #
@router.post("/onboarding", response_model=AiProfileOut)
def post_onboarding(
    payload: AiOnboardingPayload,
    user_id: str = Query(..., min_length=1, max_length=128),
    mark_completed: bool = Query(default=True),
) -> dict:
    data = payload.model_dump(exclude_none=True)
    extras = data.pop("extras", None)

    try:
        row = services.save_onboarding(
            user_id,
            payload=data,
            extras=extras,
            mark_completed=mark_completed,
        )
    except Exception as e:  # noqa: BLE001
        log.exception("onboarding save failed")
        raise HTTPException(
            status_code=500,
            detail=f"onboarding save failed: {type(e).__name__}",
        ) from e

    return row


@router.get("/profile/{user_id}", response_model=AiProfileOut)
def get_profile(
    user_id: str = Path(..., min_length=1, max_length=128),
) -> dict:
    return services.get_profile(user_id)


# --------------------------------------------------------------------------- #
# Chat                                                                        #
# --------------------------------------------------------------------------- #
@router.post("/chat", response_model=AiChatResponse)
def post_chat(payload: AiChatRequest) -> dict:
    try:
        result = services.chat_reply(
            user_id=payload.user_id,
            message=payload.message.strip(),
            thread_id=payload.thread_id,
            today=date.today(),
        )
    except LookupError as e:
        raise HTTPException(status_code=404, detail=str(e)) from e
    except RuntimeError as e:
        raise _bad_gateway(e) from e
    except Exception as e:  # noqa: BLE001
        log.exception("chat failed")
        raise HTTPException(
            status_code=500,
            detail=f"chat failed: {type(e).__name__}",
        ) from e

    return result


@router.get("/chat/history", response_model=AiChatHistory)
def get_chat_history(
    user_id: str = Query(..., min_length=1, max_length=128),
    thread_id: int | None = Query(default=None),
    limit: int = Query(default=100, ge=1, le=200),
) -> dict:
    return services.list_chat_history(user_id, thread_id=thread_id, limit=limit)


@router.get("/chat/threads", response_model=list[AiThreadOut])
def list_threads(
    user_id: str = Query(..., min_length=1, max_length=128),
    limit: int = Query(default=20, ge=1, le=50),
) -> list[dict]:
    # Late import to keep the router file tiny.
    from ai import memory
    return memory.list_threads(user_id, limit=limit)


# --------------------------------------------------------------------------- #
# Reviews                                                                     #
# --------------------------------------------------------------------------- #
@router.post("/review/day", response_model=AiReviewOut)
def post_review_day(
    user_id: str = Query(..., min_length=1, max_length=128),
    on_date: date | None = Query(default=None),
) -> dict:
    try:
        return services.daily_review(user_id, on_date or date.today())
    except RuntimeError as e:
        raise _bad_gateway(e) from e


@router.post("/review/week", response_model=AiReviewOut)
def post_review_week(
    user_id: str = Query(..., min_length=1, max_length=128),
    today: date | None = Query(default=None),
) -> dict:
    try:
        return services.weekly_review(user_id, today or date.today())
    except RuntimeError as e:
        raise _bad_gateway(e) from e


# --------------------------------------------------------------------------- #
# Meal recommendations                                                        #
# --------------------------------------------------------------------------- #
@router.post("/recommend/meal", response_model=AiMealRecommendations)
def post_recommend_meal(
    user_id: str = Query(..., min_length=1, max_length=128),
    today: date | None = Query(default=None),
) -> dict:
    try:
        return services.recommend_meal(user_id, today or date.today())
    except RuntimeError as e:
        raise _bad_gateway(e) from e
