"""
Database connection pool.

A single ThreadedConnectionPool is created at FastAPI startup and reused for
the life of the process. Sync endpoints run in FastAPI's threadpool, so a
threaded pool is the right match and keeps the stack minimal.
"""
from __future__ import annotations

import os
from contextlib import contextmanager
from pathlib import Path
from typing import Iterator

import psycopg2
from dotenv import load_dotenv
from psycopg2.extensions import connection as PgConnection
from psycopg2.pool import ThreadedConnectionPool

_BACKEND_DIR = Path(__file__).resolve().parent
load_dotenv(_BACKEND_DIR / ".env")

DATABASE_URL: str = (os.getenv("DATABASE_URL") or "").strip()

_pool: ThreadedConnectionPool | None = None


def init_pool(minconn: int = 1, maxconn: int = 10) -> None:
    global _pool
    if _pool is not None:
        return
    if not DATABASE_URL:
        raise RuntimeError(
            "DATABASE_URL is not set. Add it to backend/.env "
            "(Supabase → Project Settings → Database → Connection string → URI)."
        )
    _pool = ThreadedConnectionPool(minconn, maxconn, dsn=DATABASE_URL)


def close_pool() -> None:
    global _pool
    if _pool is not None:
        _pool.closeall()
        _pool = None


@contextmanager
def get_conn() -> Iterator[PgConnection]:
    """Borrow a connection from the pool; always return it, even on error."""
    if _pool is None:
        raise RuntimeError("DB pool not initialized")
    conn = _pool.getconn()
    try:
        yield conn
    except psycopg2.Error:
        try:
            conn.rollback()
        except psycopg2.Error:
            pass
        raise
    finally:
        _pool.putconn(conn)
