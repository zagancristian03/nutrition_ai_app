# Nutrition AI Backend API

FastAPI backend service for the Nutrition AI Flutter app.

## Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Set environment variables:
```bash
export EDAMAM_APP_ID=your_app_id
export EDAMAM_APP_KEY=your_app_key
```

Or create a `.env` file (not included in git):
```
EDAMAM_APP_ID=your_app_id
EDAMAM_APP_KEY=your_app_key
```

3. Run the server:
```bash
python main.py
```

Or with uvicorn:
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## API Endpoints

### GET /search-food?query=string

Search for food items using Edamam Food Database.

**Query Parameters:**
- `query` (required): Food search query (e.g., "rice", "chicken", "apple")

**Response:**
```json
[
  {
    "id": "food_xxx",
    "name": "Chicken breast",
    "calories": 165.0,
    "protein": 31.0,
    "carbs": 0.0,
    "fat": 3.6
  }
]
```

## Getting Edamam API Credentials

1. Go to https://developer.edamam.com/
2. Sign up for a free account
3. Create a new application
4. Get your App ID and App Key
5. Set them as environment variables
