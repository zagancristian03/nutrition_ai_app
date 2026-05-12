#!/usr/bin/env python3
"""
Verify ARB key parity and placeholder consistency between template (app_en.arb)
and translations (e.g. app_ro.arb).

Exit 1 on mismatch. Run from repo root:
  python tools/check_arb_parity.py
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

_PLACEHOLDER_RE = re.compile(r"\{([^{}]+)\}")


def _arb_message_keys(data: dict) -> set[str]:
    return {k for k in data if not k.startswith("@") and k != "@@locale"}


def _placeholders(value: str) -> set[str]:
    # ICU plurals embed `{count}` inside branch literals; naïve extraction
    # compares unrelated fragments (e.g. "1 chat" vs "1 mesaj").
    if re.search(r"\{\s*\w+\s*,\s*plural\s*,", value):
        return set()
    return set(_PLACEHOLDER_RE.findall(value))


def _meta_placeholders(data: dict, base_key: str) -> set[str] | None:
    meta = data.get(f"@{base_key}")
    if not isinstance(meta, dict):
        return None
    ph = meta.get("placeholders")
    if not isinstance(ph, dict):
        return set()
    return set(ph.keys())


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    en_path = root / "app" / "lib" / "l10n" / "app_en.arb"
    ro_path = root / "app" / "lib" / "l10n" / "app_ro.arb"
    if not en_path.is_file() or not ro_path.is_file():
        print("Missing app_en.arb or app_ro.arb", file=sys.stderr)
        return 1

    en = json.loads(en_path.read_text(encoding="utf-8"))
    ro = json.loads(ro_path.read_text(encoding="utf-8"))
    k_en = _arb_message_keys(en)
    k_ro = _arb_message_keys(ro)

    missing_in_ro = sorted(k_en - k_ro)
    extra_in_ro = sorted(k_ro - k_en)
    ok = True
    if missing_in_ro:
        ok = False
        print("Romanian missing keys:", ", ".join(missing_in_ro), file=sys.stderr)
    if extra_in_ro:
        ok = False
        print("Romanian extra keys:", ", ".join(extra_in_ro), file=sys.stderr)

    for key in sorted(k_en & k_ro):
        en_val = en[key]
        ro_val = ro[key]
        if not isinstance(en_val, str) or not isinstance(ro_val, str):
            continue
        en_ph = _placeholders(en_val)
        ro_ph = _placeholders(ro_val)
        if en_ph != ro_ph:
            ok = False
            print(
                f"Placeholder mismatch for {key!r}: en={sorted(en_ph)} ro={sorted(ro_ph)}",
                file=sys.stderr,
            )
        en_meta = _meta_placeholders(en, key)
        ro_meta = _meta_placeholders(ro, key)
        if en_meta is not None and ro_meta is not None and en_meta != ro_meta:
            ok = False
            print(
                f"@ placeholder keys mismatch for {key!r}: "
                f"en={sorted(en_meta)} ro={sorted(ro_meta)}",
                file=sys.stderr,
            )

    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
