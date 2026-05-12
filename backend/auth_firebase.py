"""Firebase ID token verification (Firebase Admin SDK).

Clients send: ``Authorization: Bearer <Firebase ID token>``.

Configure with either:
  - ``FIREBASE_CREDENTIALS_JSON`` — full service-account JSON as a single-line
    string (typical for Docker / PaaS secrets), or
  - ``GOOGLE_APPLICATION_CREDENTIALS`` — path to a service-account JSON file.

When ``ENVIRONMENT=production``, missing credentials fail application startup.
"""
from __future__ import annotations

import json
import logging
import os
from typing import Annotated

import firebase_admin
from firebase_admin import auth as firebase_auth
from firebase_admin import credentials
from fastapi import Header, HTTPException

log = logging.getLogger(__name__)

_firebase_ready: bool = False


def firebase_auth_configured() -> bool:
    return _firebase_ready


def try_init_firebase_admin(*, require_credentials: bool) -> None:
    global _firebase_ready
    _firebase_ready = False

    try:
        firebase_admin.get_app()
        _firebase_ready = True
        log.info("Firebase Admin already initialized")
        return
    except ValueError:
        pass

    cred_json = (os.getenv("FIREBASE_CREDENTIALS_JSON") or "").strip()
    cred_path = (os.getenv("GOOGLE_APPLICATION_CREDENTIALS") or "").strip()

    if not cred_json and not cred_path:
        if require_credentials:
            raise RuntimeError(
                "Firebase Admin is required in production. Set "
                "FIREBASE_CREDENTIALS_JSON or GOOGLE_APPLICATION_CREDENTIALS "
                "(service account JSON from Firebase console → Project settings → Service accounts)."
            )
        log.warning(
            "Firebase Admin credentials not set — authenticated routes will return 503. "
            "Set FIREBASE_CREDENTIALS_JSON or GOOGLE_APPLICATION_CREDENTIALS for local API testing."
        )
        return

    try:
        if cred_json:
            info = json.loads(cred_json)
            cred = credentials.Certificate(info)
        else:
            cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
    except Exception:
        log.exception("Firebase Admin initialization failed")
        if require_credentials:
            raise
        return

    _firebase_ready = True
    log.info("Firebase Admin SDK initialized")


def require_same_user(authenticated_uid: str, claimed_uid: str) -> None:
    if claimed_uid != authenticated_uid:
        raise HTTPException(
            status_code=403,
            detail="user_id does not match authenticated user",
        )


def get_current_uid(authorization: Annotated[str | None, Header()] = None) -> str:
    if not _firebase_ready:
        raise HTTPException(
            status_code=503,
            detail="Authentication not configured on server",
        )
    if authorization is None or not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=401,
            detail="Authorization: Bearer <Firebase ID token> required",
        )
    token = authorization[7:].strip()
    if not token:
        raise HTTPException(status_code=401, detail="Empty bearer token")
    try:
        decoded = firebase_auth.verify_id_token(token, check_revoked=False)
    except firebase_auth.ExpiredIdTokenError as e:
        raise HTTPException(status_code=401, detail="Expired ID token") from e
    except firebase_auth.RevokedIdTokenError as e:
        raise HTTPException(status_code=401, detail="Revoked ID token") from e
    except firebase_auth.InvalidIdTokenError as e:
        raise HTTPException(status_code=401, detail="Invalid ID token") from e
    except Exception as e:  # noqa: BLE001
        log.warning("verify_id_token failed: %s", e)
        raise HTTPException(status_code=401, detail="Could not verify ID token") from e

    uid = decoded.get("uid")
    if not uid or not isinstance(uid, str):
        raise HTTPException(status_code=401, detail="Token missing uid")
    return uid
