"""Unit tests for food search normalization and locale chain helpers."""
from __future__ import annotations

import sys
from pathlib import Path

# Run `pytest` from `backend/` so sibling imports match the app layout.
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from food_search_text import (  # noqa: E402
    locale_search_chain,
    normalize_food_search_text,
    primary_locale_tag,
)


def test_normalize_romanian_diacritics() -> None:
    assert normalize_food_search_text("Brânză") == "branza"
    assert normalize_food_search_text("pește") == "peste"
    assert normalize_food_search_text("pâine") == "paine"
    assert normalize_food_search_text("ouă") == "oua"
    assert normalize_food_search_text("Roșii") == "rosii"


def test_normalize_whitespace() -> None:
    assert normalize_food_search_text("  a   b  ") == "a b"
    assert normalize_food_search_text("a\t\tb") == "a b"


def test_primary_locale_tag() -> None:
    assert primary_locale_tag(None) == "en"
    assert primary_locale_tag("") == "en"
    assert primary_locale_tag("ro-RO") == "ro"
    assert primary_locale_tag("en_US") == "en"


def test_locale_search_chain() -> None:
    assert locale_search_chain("ro") == ["ro", "en"]
    assert locale_search_chain("en") == ["en"]
    assert locale_search_chain(None) == ["en"]
