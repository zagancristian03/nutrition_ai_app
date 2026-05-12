# Nutrition AI — FastAPI (production)
# Build from this directory:  docker build -t app-backend .
# Run:                       docker run --env-file .env -p 8000:8000 app-backend
#
# Required env vars (see .env.example): at minimum DATABASE_URL.
# Do not bake secrets into the image; pass them at runtime.

FROM python:3.12-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends libpq5 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

# Single worker default; scale replicas at orchestration layer.
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
