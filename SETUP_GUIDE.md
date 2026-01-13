# Food Database Integration Setup Guide

This guide will help you set up the Edamam Food Database API integration for the Nutrition AI app.

## Part 1: Backend Setup (FastAPI)

### 1. Install Python Dependencies

Navigate to the `backend` directory and install dependencies:

```bash
cd backend
pip install -r requirements.txt
```

### 2. Get Edamam API Credentials

1. Go to https://developer.edamam.com/
2. Sign up for a free account
3. Navigate to "Applications" and create a new application
4. Select "Food Database API"
5. Copy your **Application ID** and **Application Key**

### 3. Set Environment Variables

**Option A: Set in terminal (temporary)**
```bash
export EDAMAM_APP_ID=your_app_id_here
export EDAMAM_APP_KEY=your_app_key_here
```

**Option B: Create a `.env` file (recommended)**
Create a `.env` file in the `backend` directory:
```
EDAMAM_APP_ID=your_app_id_here
EDAMAM_APP_KEY=your_app_key_here
```

Then install `python-dotenv` and update `main.py` to load from `.env`:
```bash
pip install python-dotenv
```

### 4. Run the Backend Server

```bash
python main.py
```

Or with uvicorn:
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000`

### 5. Test the Backend

Open your browser and visit:
```
http://localhost:8000/search-food?query=rice
```

You should see a JSON response with food items.

## Part 2: Flutter Setup

### 1. Install Dependencies

Navigate to the `app` directory and install Flutter dependencies:

```bash
cd app
flutter pub get
```

### 2. Configure Backend URL

Edit `app/lib/services/food_api_service.dart`:

- **For iOS Simulator / Web / Desktop**: Use `http://localhost:8000`
- **For Android Emulator**: Use `http://10.0.2.2:8000` (10.0.2.2 is the emulator's alias for localhost)
- **For Physical Device**: Use your computer's IP address (e.g., `http://192.168.1.100:8000`)

### 3. Run the Flutter App

```bash
flutter run
```

## Testing

1. Open the app and navigate to the "Add Meal" screen
2. Type a food name in the search field (e.g., "rice", "chicken", "apple")
3. Press Enter or submit
4. You should see a list of food items with nutrition data
5. Tap on a food item to auto-fill the form
6. You can still manually edit the values if needed

## Troubleshooting

### Backend Issues

- **"Edamam API credentials not configured"**: Make sure you've set the environment variables correctly
- **Connection errors**: Ensure the backend server is running on port 8000
- **Empty results**: Check that your Edamam API credentials are valid and you haven't exceeded rate limits

### Flutter Issues

- **Connection refused**: 
  - For Android emulator: Change `localhost` to `10.0.2.2` in `food_api_service.dart`
  - For physical device: Use your computer's IP address instead of localhost
- **No results showing**: Check the console for error messages
- **Timeout errors**: Ensure the backend is running and accessible

### Network Configuration

If testing on a physical device:
1. Find your computer's IP address:
   - Windows: `ipconfig` (look for IPv4 Address)
   - Mac/Linux: `ifconfig` or `ip addr`
2. Update `baseUrl` in `food_api_service.dart` to use your IP: `http://YOUR_IP:8000`
3. Ensure your device and computer are on the same network
4. Make sure your firewall allows connections on port 8000

## API Endpoints

### GET /search-food

Search for food items.

**Query Parameters:**
- `query` (required): Food search query

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

## Next Steps

- The food search is now integrated and working
- You can extend this to save meals to Firestore
- Add quantity/portion size calculations
- Implement meal history and tracking
