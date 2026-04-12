"""
FastAPI backend: search foods in Supabase Postgres.
"""
import os
from contextlib import asynccontextmanager
from pathlib import Path

import psycopg2
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, Query
from fastapi.encoders import jsonable_encoder
from fastapi.middleware.cors import CORSMiddleware
from psycopg2 import OperationalError, ProgrammingError
from psycopg2.extras import RealDictCursor

_BACKEND_DIR = Path(__file__).resolve().parent
load_dotenv(_BACKEND_DIR / ".env")

DATABASE_URL = (os.getenv("DATABASE_URL") or "").strip()


@asynccontextmanager
async def lifespan(app: FastAPI):
    if not DATABASE_URL:
        raise RuntimeError(
            "DATABASE_URL is not set. Add it to backend/.env "
            "(Project Settings → Database → Connection string → URI)."
        )
    yield


app = FastAPI(title="Nutrition AI Backend", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root():
    return {"message": "Nutrition AI Backend API"}


@app.get("/foods/search")
def search_foods(
    q: str = Query(..., min_length=1, max_length=500, description="Food name search"),
):
    """Search foods by name (ILIKE), up to 20 rows."""
    term = q.strip()
    if not term:
        raise HTTPException(
            status_code=422,
            detail="Query parameter q cannot be empty or whitespace only",
        )

    try:
        conn = psycopg2.connect(DATABASE_URL)
    except OperationalError as e:
        raise HTTPException(
            status_code=503,
            detail=f"Could not connect to database: {e!s}",
        ) from e

    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                """
                SELECT id, name, calories_per_100g, protein_per_100g,
                       carbs_per_100g, fat_per_100g
                FROM foods
                WHERE name ILIKE %s
                LIMIT 20
                """,
                (f"%{term}%",),
            )
            rows = cur.fetchall()
    except ProgrammingError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Database query error: {e!s}",
        ) from e
    except psycopg2.Error as e:
        raise HTTPException(
            status_code=503,
            detail=f"Database error: {e!s}",
        ) from e
    finally:
        conn.close()

    return jsonable_encoder([dict(r) for r in rows])


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
