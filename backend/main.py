"""
Nutrition AI backend — FastAPI entrypoint.

Run from the `backend/` directory:

    uvicorn main:app --reload --host 0.0.0.0 --port 8000

or simply:

    python main.py
"""
from __future__ import annotations

import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from db import close_pool, init_pool
from routers import foods as foods_router
from routers import logs as logs_router
from routers import user_goals as user_goals_router
from routers import user_profile as user_profile_router
from routers import weight_logs as weight_logs_router

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)-5s %(name)s :: %(message)s",
)


@asynccontextmanager
async def lifespan(app: FastAPI):
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

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["X-Cache", "X-Elapsed-Ms", "X-Seq"],
)

app.include_router(foods_router.router)
app.include_router(logs_router.router)
app.include_router(user_goals_router.router)
app.include_router(user_profile_router.router)
app.include_router(weight_logs_router.router)


@app.get("/", tags=["meta"])
def root() -> dict:
    return {"service": "nutrition-ai-backend", "version": "2.0.0", "status": "ok"}


@app.get("/health", tags=["meta"])
def health() -> dict:
    return {"status": "ok"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=False)
