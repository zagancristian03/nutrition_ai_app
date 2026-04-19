"""Tiny OpenAI wrapper.

Keeps a single lazily-created `OpenAI()` client. The API key is read from
`backend/.env` (loaded by `db.py` on import). All callers go through
`chat_completion` so timeouts, retries, and response_format handling live in
one place.
"""
from __future__ import annotations

import logging
import os
from typing import Any, Iterable

from openai import APIError, OpenAI, RateLimitError

log = logging.getLogger("ai.openai")

# Balanced default: capable enough for coaching reasoning, cheapest tier that
# handles JSON formatting and multi-turn context reliably.
DEFAULT_MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini").strip() or "gpt-4o-mini"

# Allow an explicit env override for the lightweight summarization calls —
# falls back to the same default model if unset.
SUMMARY_MODEL = os.getenv("OPENAI_SUMMARY_MODEL", DEFAULT_MODEL).strip() or DEFAULT_MODEL

_client: OpenAI | None = None


def get_client() -> OpenAI:
    global _client
    if _client is None:
        key = (os.getenv("OPENAI_API_KEY") or "").strip()
        if not key:
            raise RuntimeError(
                "OPENAI_API_KEY is not set. Add it to backend/.env (never "
                "commit it)."
            )
        _client = OpenAI(api_key=key, timeout=30.0, max_retries=2)
    return _client


def chat_completion(
    *,
    messages: Iterable[dict[str, Any]],
    model: str | None = None,
    temperature: float = 0.6,
    max_tokens: int = 700,
    json_mode: bool = False,
) -> str:
    """Run a chat completion and return the assistant text.

    * `json_mode=True` asks the model for a JSON object response (enforced
      server-side by OpenAI; useful for structured endpoints).
    * Raises `RuntimeError` with a clean message on network/billing failures
      so the FastAPI router can map them to a 502.
    """
    client = get_client()
    kwargs: dict[str, Any] = {
        "model": model or DEFAULT_MODEL,
        "messages": list(messages),
        "temperature": temperature,
        "max_tokens": max_tokens,
    }
    if json_mode:
        kwargs["response_format"] = {"type": "json_object"}

    try:
        resp = client.chat.completions.create(**kwargs)
    except RateLimitError as e:
        log.warning("OpenAI rate-limited: %s", e)
        raise RuntimeError("AI service is rate-limited. Try again in a moment.") from e
    except APIError as e:
        log.exception("OpenAI API error")
        raise RuntimeError(f"AI service error: {type(e).__name__}") from e
    except Exception as e:  # noqa: BLE001
        log.exception("OpenAI unexpected error")
        raise RuntimeError(f"AI service unavailable: {type(e).__name__}") from e

    choice = resp.choices[0]
    content = choice.message.content or ""
    return content.strip()
