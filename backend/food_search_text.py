"""
Shared normalization for food search and food_aliases.normalized_alias.

Rules (match DB seed + search):
  * lowercase
  * trim
  * collapse repeated whitespace
  * strip Unicode combining marks (NFKD) so Romanian diacritics match ASCII

Examples:
  "Brânză" -> "branza"
  "pește" / "peşte" -> "peste"
  "ouă" -> "oua"
"""
from __future__ import annotations

import re
import unicodedata

_WS_RE = re.compile(r"\s+")


def normalize_food_search_text(raw: str) -> str:
    if not raw:
        return ""
    s = raw.strip().lower()
    s = unicodedata.normalize("NFKD", s)
    s = "".join(c for c in s if not unicodedata.combining(c))
    return _WS_RE.sub(" ", s).strip()


def primary_locale_tag(locale: str | None) -> str:
    """
    BCP-47 or simple tag -> primary subtag for DB locale column ('ro', 'en').
    """
    if not locale or not str(locale).strip():
        return "en"
    tag = str(locale).strip().replace("_", "-").split("-", 1)[0].lower()
    return tag if tag in ("ro", "en") else tag[:2] if len(tag) >= 2 else "en"


def locale_search_chain(locale: str | None) -> list[str]:
    """
    Preferred locale first, then English fallback for alias matching.
    Dedupes while preserving order.
    """
    prim = primary_locale_tag(locale)
    out: list[str] = []
    for x in (prim, "en"):
        if x not in out:
            out.append(x)
    return out
