import '../models/food_item.dart';
import 'food_api_service.dart';

/// Food search backed by the FastAPI `/foods/search` endpoint.
class FoodSearchService {
  final FoodApiService _apiService = FoodApiService();

  /// Returns foods matching [query], or an empty list if the query is blank.
  Future<List<FoodItem>> search(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }
    return _apiService.searchFood(query);
  }
}
