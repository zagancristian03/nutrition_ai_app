# Nutrition AI Backend

FastAPI backend for the Nutrition AI Flutter app. All search and logging runs
directly against Supabase Postgres — no external search engine.

## Layout

```
backend/
├── main.py                  # FastAPI app, CORS, lifespan (pool init/close)
├── db.py                    # psycopg2 threaded connection pool
├── cache.py                 # in-memory TTL+LRU cache
├── schemas.py               # Pydantic models
├── routers/
│   ├── foods.py             # GET /foods/search
│   └── logs.py              # POST/GET/DELETE /food-logs
├── import_openfoodfacts.py  # OFF ingestion script
└── requirements.txt
```

SQL lives under `database/schema/`:
- `001_foods.sql` — `foods` table, `pg_trgm`, `search_text` generated column, GIN index
- `002_food_logs.sql` — `food_logs` (diary) with macro snapshots

## Setup

1. Install deps:
   ```bash
   pip install -r requirements.txt
   ```

2. Create `backend/.env`:
   ```
   DATABASE_URL=postgresql://postgres:PASSWORD@HOST:5432/postgres
   ```

3. Apply the schema to Supabase (SQL editor or `psql`):
   ```bash
   psql "$DATABASE_URL" -f ../database/schema/001_foods.sql
   psql "$DATABASE_URL" -f ../database/schema/002_food_logs.sql
   ```

4. Import a slice of Open Food Facts:
   ```bash
   python import_openfoodfacts.py --file data/openfoodfacts_products.tsv --max-rows 10000
   ```

5. Run the API:
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000
   # or: python main.py
   ```

## Endpoints

### `GET /foods/search?q=<term>[&seq=<int>]`

Trigram-ranked fuzzy + substring + prefix search, capped at 20 rows.
Queries shorter than 2 characters return `[]`.

Response headers:
- `X-Cache`: `HIT` / `MISS` / `BYPASS`
- `X-Elapsed-Ms`: server-side query time (MISS only)
- `X-Seq`: echo of the `seq` query param — use client-side to discard
  out-of-order responses

Response body (per-100 g values):
```json
[
  { "id": 1, "name": "chicken breast", "brand": null,
    "calories": 165, "protein": 31.0, "carbs": 0.0, "fat": 3.6 }
]
```

### `POST /food-logs`

Creates a diary entry. Macros are computed **once** from the referenced food
and persisted as a snapshot.

Request:
```json
{
  "user_id": "uid-123",
  "food_id": 42,
  "logged_date": "2026-04-17",
  "meal_type": "lunch",
  "grams": 150
}
```

(`servings` may be used instead of `grams` if the food row has
`serving_size_g`.)

Response `201`: full `food_logs` row (incl. `calories/protein/carbs/fat`
snapshot and `created_at`).

### `GET /food-logs?user_id=<uid>[&logged_date=YYYY-MM-DD][&limit=100]`

Lists logs for a user, newest first (limit ≤ 500).

### `DELETE /food-logs/{id}?user_id=<uid>`

Deletes a single log. Returns `204` on success, `404` if the log doesn't
belong to the user.

### `GET /health`, `GET /`

Meta / uptime probes.

## Design notes

- `search_text` is a `STORED` generated column; it can never drift from
  `name` + `brand`, and lookups don't have to call `lower()` on the fly.
- The GIN(`gin_trgm_ops`) index serves all three operators used by the
  search query (`%`, `LIKE 'q%'`, `LIKE '%q%'`), so there's only one index
  to maintain.
- Connection pool size = 10 is sized for a single Uvicorn worker; scale
  horizontally by increasing workers, not the pool.
- Search results are cached for 60 s keyed by normalized query. The cache
  lives inside the process — after a new import, restart the API (or wait 60 s)
  to see fresh rows for previously-cached queries.
- Stale-response protection: clients pass a monotonic `seq` with every
  request and ignore any response whose `X-Seq` header is older than the
  latest one they've dispatched.
