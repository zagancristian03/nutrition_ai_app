"""
Nutrition AI backend — FastAPI entrypoint.

Run from the `backend/` directory:

    uvicorn main:app --reload --host 0.0.0.0 --port 8000

or simply:

    python main.py
"""
from __future__ import annotations

import logging
import os
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from auth_firebase import try_init_firebase_admin
from db import close_pool, get_conn, init_pool
from routers import ai as ai_router
from routers import foods as foods_router
from routers import logs as logs_router
from routers import user_goals as user_goals_router
from routers import user_profile as user_profile_router
from routers import weight_logs as weight_logs_router

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)-5s %(name)s :: %(message)s",
)

log = logging.getLogger("main")


def _cors_settings() -> tuple[list[str], bool]:
    """
    CORS for browser clients. Mobile/native apps do not use CORS.

    * ``CORS_ALLOWED_ORIGINS`` — comma-separated list (required for explicit
      browser access in production).
    * Development: if unset, defaults to ``*`` with credentials disabled.
    * Production: if unset, no origins (empty list) — browsers cannot call the
      API cross-origin until you set ``CORS_ALLOWED_ORIGINS``.
    """
    raw = (os.getenv("CORS_ALLOWED_ORIGINS") or "").strip()
    env = (os.getenv("ENVIRONMENT") or "development").strip().lower()
    cred_flag = (os.getenv("CORS_ALLOW_CREDENTIALS") or "").strip().lower() in (
        "1",
        "true",
        "yes",
    )
    if raw:
        origins = [o.strip() for o in raw.split(",") if o.strip()]
        allow_cred = cred_flag
    elif env == "development":
        origins = ["*"]
        allow_cred = False
    else:
        origins = []
        allow_cred = False
    if "*" in origins:
        allow_cred = False
    return origins, allow_cred


@asynccontextmanager
async def lifespan(app: FastAPI):
    env = (os.getenv("ENVIRONMENT") or "development").strip().lower()
    try_init_firebase_admin(require_credentials=(env == "production"))
    init_pool(minconn=1, maxconn=10)
    try:
        yield
    finally:
        close_pool()


app = FastAPI(
    title="Nutrition AI Backend",
    version="2.0.0",
    lifespan=lifespan,
)

_origins, _cred = _cors_settings()
if (os.getenv("ENVIRONMENT") or "development").strip().lower() == "production":
    log.info("CORS allow_origins count=%s allow_credentials=%s", len(_origins), _cred)
else:
    log.info("CORS allow_origins=%s allow_credentials=%s", _origins, _cred)

app.add_middleware(
    CORSMiddleware,
    allow_origins=_origins,
    allow_credentials=_cred,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["X-Cache", "X-Elapsed-Ms", "X-Seq"],
)

app.include_router(foods_router.router)
app.include_router(logs_router.router)
app.include_router(user_goals_router.router)
app.include_router(user_profile_router.router)
app.include_router(weight_logs_router.router)
app.include_router(ai_router.router)


@app.get("/", tags=["meta"])
def root() -> dict:
    return {"service": "nutrition-ai-backend", "version": "2.0.0", "status": "ok"}


@app.get("/health", tags=["meta"])
def health() -> dict:
    """Process is running (no dependency checks)."""
    return {"status": "ok"}


@app.get("/ready", tags=["meta"])
def ready() -> JSONResponse:
    """Database connectivity (for orchestrators / load balancers)."""
    try:
        with get_conn() as conn, conn.cursor() as cur:
            cur.execute("SELECT 1")
    except Exception:
        return JSONResponse(
            status_code=503,
            content={"status": "not_ready", "database": "unavailable"},
        )
    return JSONResponse(content={"status": "ready", "database": "ok"})


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=False)
