"""
FastAPI backend for Nutrition AI App
Handles food database searches via Edamam API
"""
import os
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
import httpx
from typing import List, Optional
from pydantic import BaseModel

app = FastAPI(title="Nutrition AI Backend")

# CORS middleware to allow Flutter app to call the API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your Flutter app's origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Edamam API configuration
EDAMAM_APP_ID = os.getenv("EDAMAM_APP_ID")
EDAMAM_APP_KEY = os.getenv("EDAMAM_APP_KEY")
EDAMAM_BASE_URL = "https://api.edamam.com/api/food-database/v2/parser"

# Response model
class FoodItem(BaseModel):
    id: str
    name: str
    calories: float
    protein: float
    carbs: float
    fat: float


@app.get("/")
async def root():
    return {"message": "Nutrition AI Backend API"}


@app.get("/search-food", response_model=List[FoodItem])
async def search_food(query: str = Query(..., min_length=1)):
    """
    Search for food items using Edamam Food Database API.
    
    Args:
        query: Food search query (e.g., "rice", "chicken", "apple")
    
    Returns:
        List of FoodItem objects with nutrition data
    """
    if not EDAMAM_APP_ID or not EDAMAM_APP_KEY:
        raise HTTPException(
            status_code=500,
            detail="Edamam API credentials not configured. Please set EDAMAM_APP_ID and EDAMAM_APP_KEY environment variables."
        )
    
    try:
        # Call Edamam API
        async with httpx.AsyncClient() as client:
            response = await client.get(
                EDAMAM_BASE_URL,
                params={
                    "app_id": EDAMAM_APP_ID,
                    "app_key": EDAMAM_APP_KEY,
                    "ingr": query,
                    "nutrition-type": "cooking",
                },
                timeout=10.0,
            )
            response.raise_for_status()
            data = response.json()
        
        # Extract and normalize food items
        food_items = []
        
        if "hints" in data and data["hints"]:
            for hint in data["hints"][:20]:  # Limit to 20 results
                food = hint.get("food", {})
                nutrients = food.get("nutrients", {})
                
                # Extract nutrition data (per 100g)
                food_id = food.get("foodId", "")
                label = food.get("label", "")
                calories = nutrients.get("ENERC_KCAL", 0.0)
                protein = nutrients.get("PROCNT", 0.0)  # Protein in grams
                carbs = nutrients.get("CHOCDF", 0.0)  # Carbs in grams
                fat = nutrients.get("FAT", 0.0)  # Fat in grams
                
                if label:  # Only add items with a valid name
                    food_items.append(
                        FoodItem(
                            id=food_id,
                            name=label,
                            calories=round(calories, 1),
                            protein=round(protein, 1),
                            carbs=round(carbs, 1),
                            fat=round(fat, 1),
                        )
                    )
        
        if not food_items:
            return []  # Return empty list if no results
        
        return food_items
    
    except httpx.HTTPStatusError as e:
        raise HTTPException(
            status_code=e.response.status_code,
            detail=f"Edamam API error: {e.response.text}"
        )
    except httpx.RequestError as e:
        raise HTTPException(
            status_code=503,
            detail=f"Failed to connect to Edamam API: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Internal server error: {str(e)}"
        )


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
