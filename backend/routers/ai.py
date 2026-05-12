"""AI coaching endpoints.

    POST  /ai/onboarding?user_id=...&mark_completed=true   -> upsert + summary
    GET   /ai/profile/{user_id}                            -> AiProfileOut
    POST  /ai/chat                                         -> AiChatResponse
    GET   /ai/chat/history                                 -> AiChatHistory
    GET   /ai/chat/threads                                 -> list[AiThreadOut]
    POST  /ai/chat/threads                                 -> AiThreadOut (empty thread)
    PATCH /ai/chat/threads/{id}?user_id=                   -> AiThreadOut (rename / move)
    GET   /ai/chat/folders                                 -> list[AiFolderOut]
    POST  /ai/chat/folders                                 -> AiFolderOut
    PATCH /ai/chat/folders/{id}                            -> AiFolderOut (rename)
    DELETE /ai/chat/folders/{id}                          -> {ok: true}
    POST  /ai/review/day                                   -> AiReviewOut
    POST  /ai/review/week                                  -> AiReviewOut
    POST  /ai/recommend/meal                               -> AiMealRecommendations

Errors:
  * 502  when OpenAI is unreachable / misconfigured
  * 404  when a thread doesn't belong to the user
"""
from __future__ import annotations

import logging
from datetime import date, datetime
from typing import Annotated

from fastapi import APIRouter, Body, Depends, HTTPException, Path, Query
from zoneinfo import ZoneInfo

from ai import services
from auth_firebase import get_current_uid, require_same_user
from schemas import (
    AiChatHistory,
    AiChatRequest,
    AiChatResponse,
    AiFolderCreate,
    AiFolderOut,
    AiFolderRename,
    AiMealRecommendations,
    AiOnboardingPayload,
    AiProfileOut,
    AiReviewOut,
    AiThreadCreate,
    AiThreadOut,
    AiThreadUpdate,
)

router = APIRouter(prefix="/ai", tags=["ai"])
log = logging.getLogger("ai.router")


def _bad_gateway(e: Exception) -> HTTPException:
    return HTTPException(status_code=502, detail=f"AI service error: {e}")


def _coaching_today(tz_name: str | None) -> date:
    if not tz_name or not str(tz_name).strip():
        return date.today()
    try:
        return datetime.now(ZoneInfo(str(tz_name).strip())).date()
    except Exception:
        return date.today()


# --------------------------------------------------------------------------- #
# Onboarding                                                                  #
# --------------------------------------------------------------------------- #
@router.post("/onboarding", response_model=AiProfileOut)
def post_onboarding(
    payload: AiOnboardingPayload,
    user_id: str = Query(..., min_length=1, max_length=128),
    mark_completed: bool = Query(default=True),
    uid: Annotated[str, Depends(get_current_uid)] = ...,
) -> dict:
    require_same_user(uid, user_id)
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
    uid: Annotated[str, Depends(get_current_uid)] = ...,
) -> dict:
    require_same_user(uid, user_id)
    return services.get_profile(user_id)


# --------------------------------------------------------------------------- #
# Chat                                                                        #
# --------------------------------------------------------------------------- #
@router.post("/chat", response_model=AiChatResponse)
def post_chat(
    payload: AiChatRequest,
    uid: Annotated[str, Depends(get_current_uid)] = ...,
) -> dict:
    require_same_user(uid, payload.user_id)
    try:
        result = services.chat_reply(
            user_id=uid,
            message=payload.message.strip(),
            thread_id=payload.thread_id,
            today=_coaching_today(payload.timezone),
            preferred_locale=(payload.preferred_locale or "en").strip() or "en",
            timezone=payload.timezone,
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
    uid: Annotated[str, Depends(get_current_uid)] = ...,
) -> dict:
    require_same_user(uid, user_id)
    return services.list_chat_history(user_id, thread_id=thread_id, limit=limit)


@router.get("/chat/threads", response_model=list[AiThreadOut])
def list_threads(
    user_id: str = Query(..., min_length=1, max_length=128),
    limit: int = Query(default=100, ge=1, le=250),
    uid: Annotated[str, Depends(get_current_uid)] = ...,
) -> list[dict]:
    require_same_user(uid, user_id)
    # Late import to keep the router file tiny.
    from ai import memory
    return memory.list_threads(user_id, limit=limit)


@router.post("/chat/threads", response_model=AiThreadOut)
def create_thread(
    payload: AiThreadCreate,
    uid: Annotated[str, Depends(get_current_uid)] = ...,
) -> dict:
    require_same_user(uid, payload.user_id)
    from ai import memory

    try:
        return memory.create_thread(
            uid,
            payload.title,
            folder_id=payload.folder_id,
        )
    except LookupError as e:
        raise HTTPException(status_code=404, detail=str(e)) from e


@router.patch("/chat/threads/{thread_id}", response_model=AiThreadOut)
def patch_thread(
    thread_id: int,
    user_id: str = Query(..., min_length=1, max_length=128),
    payload: AiThreadUpdate = Body(...),
    uid: Annotated[str, Depends(get_current_uid)] = ...,
) -> dict:
    require_same_user(uid, user_id)
    from ai import memory

    try:
        data = payload.model_dump(exclude_unset=True)
        row = memory.patch_thread(user_id, thread_id, data)
    except LookupError as e:
        raise HTTPException(status_code=404, detail=str(e)) from e
    if row is None:
        raise HTTPException(status_code=404, detail="thread not found")
    return row


@router.get("/chat/folders", response_model=list[AiFolderOut])
def list_chat_folders(
    user_id: str = Query(..., min_length=1, max_length=128),
    uid: Annotated[str, Depends(get_current_uid)] = ...,
) -> list[dict]:
    require_same_user(uid, user_id)
    from ai import memory
    return memory.list_folders(user_id)


@router.post("/chat/folders", response_model=AiFolderOut)
def create_chat_folder(
    payload: AiFolderCreate,
    uid: Annotated[str, Depends(get_current_uid)] = ...,
) -> dict:
    require_same_user(uid, payload.user_id)
    from ai import memory

    try:
        return memory.create_folder(uid, payload.name)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e)) from e
    except Exception as e:  # noqa: BLE001
        log.exception("create_chat_folder failed")
        raise HTTPException(
            status_code=500,
            detail=f"Could not create folder: {type(e).__name__}",
        ) from e


@router.patch("/chat/folders/{folder_id}", response_model=AiFolderOut)
def rename_chat_folder(
    folder_id: int,
    user_id: str = Query(..., min_length=1, max_length=128),
    payload: AiFolderRename = Body(...),
    uid: Annotated[str, Depends(get_current_uid)] = ...,
) -> dict:
    require_same_user(uid, user_id)
    from ai import memory

    try:
        row = memory.rename_folder(user_id, folder_id, payload.name)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e)) from e
    if row is None:
        raise HTTPException(status_code=404, detail="folder not found")
    return row


@router.delete("/chat/folders/{folder_id}")
def delete_chat_folder(
    folder_id: int,
    user_id: str = Query(..., min_length=1, max_length=128),
    uid: Annotated[str, Depends(get_current_uid)] = ...,
) -> dict:
    require_same_user(uid, user_id)
    from ai import memory

    if not memory.delete_folder(user_id, folder_id):
        raise HTTPException(status_code=404, detail="folder not found")
    return {"ok": True}


# --------------------------------------------------------------------------- #
# Reviews                                                                     #
# --------------------------------------------------------------------------- #
@router.post("/review/day", response_model=AiReviewOut)
def post_review_day(
    user_id: str = Query(..., min_length=1, max_length=128),
    on_date: date | None = Query(default=None),
    uid: Annotated[str, Depends(get_current_uid)] = ...,
) -> dict:
    require_same_user(uid, user_id)
    try:
        return services.daily_review(user_id, on_date or date.today())
    except RuntimeError as e:
        raise _bad_gateway(e) from e


@router.post("/review/week", response_model=AiReviewOut)
def post_review_week(
    user_id: str = Query(..., min_length=1, max_length=128),
    today: date | None = Query(default=None),
    uid: Annotated[str, Depends(get_current_uid)] = ...,
) -> dict:
    require_same_user(uid, user_id)
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
    uid: Annotated[str, Depends(get_current_uid)] = ...,
) -> dict:
    require_same_user(uid, user_id)
    try:
        return services.recommend_meal(user_id, today or date.today())
    except RuntimeError as e:
        raise _bad_gateway(e) from e
