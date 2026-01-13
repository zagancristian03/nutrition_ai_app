import '../models/food_item.dart';
import 'food_api_service.dart';

class FoodSearchService {
  final FoodApiService _apiService = FoodApiService();

  // Mock foods for testing when backend is not available
  final List<FoodItem> _mockFoods = [
    FoodItem(
      id: 'food_001',
      name: 'Chicken Breast',
      caloriesPer100g: 165.0,
      proteinPer100g: 31.0,
      carbsPer100g: 0.0,
      fatPer100g: 3.6,
    ),
    FoodItem(
      id: 'food_002',
      name: 'Brown Rice',
      caloriesPer100g: 111.0,
      proteinPer100g: 2.6,
      carbsPer100g: 23.0,
      fatPer100g: 0.9,
    ),
    FoodItem(
      id: 'food_003',
      name: 'Salmon',
      caloriesPer100g: 206.0,
      proteinPer100g: 22.0,
      carbsPer100g: 0.0,
      fatPer100g: 12.0,
    ),
    FoodItem(
      id: 'food_004',
      name: 'Apple',
      caloriesPer100g: 52.0,
      proteinPer100g: 0.3,
      carbsPer100g: 14.0,
      fatPer100g: 0.2,
    ),
    FoodItem(
      id: 'food_005',
      name: 'Banana',
      caloriesPer100g: 89.0,
      proteinPer100g: 1.1,
      carbsPer100g: 23.0,
      fatPer100g: 0.3,
    ),
    FoodItem(
      id: 'food_006',
      name: 'Oatmeal',
      caloriesPer100g: 68.0,
      proteinPer100g: 2.4,
      carbsPer100g: 12.0,
      fatPer100g: 1.4,
    ),
    FoodItem(
      id: 'food_007',
      name: 'Eggs',
      caloriesPer100g: 155.0,
      proteinPer100g: 13.0,
      carbsPer100g: 1.1,
      fatPer100g: 11.0,
    ),
    FoodItem(
      id: 'food_008',
      name: 'Broccoli',
      caloriesPer100g: 34.0,
      proteinPer100g: 2.8,
      carbsPer100g: 7.0,
      fatPer100g: 0.4,
    ),
    FoodItem(
      id: 'food_009',
      name: 'Sweet Potato',
      caloriesPer100g: 86.0,
      proteinPer100g: 1.6,
      carbsPer100g: 20.0,
      fatPer100g: 0.1,
    ),
    FoodItem(
      id: 'food_010',
      name: 'Greek Yogurt',
      caloriesPer100g: 59.0,
      proteinPer100g: 10.0,
      carbsPer100g: 3.6,
      fatPer100g: 0.4,
    ),
  ];

  /// Search for food items
  /// 
  /// [query] - Food search query
  /// [useBackend] - Whether to use backend API (default: true)
  /// 
  /// Returns a list of FoodItem objects matching the query
  Future<List<FoodItem>> search(String query, {bool useBackend = true}) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final queryLower = query.trim().toLowerCase();

    // Try backend first if enabled
    if (useBackend) {
      try {
        final results = await _apiService.searchFood(query);
        if (results.isNotEmpty) {
          return results;
        }
      } catch (e) {
        print('Backend search failed, using mock data: $e');
      }
    }

    // Fallback to mock data
    return _mockFoods
        .where((food) => food.name.toLowerCase().contains(queryLower))
        .toList();
  }
}
