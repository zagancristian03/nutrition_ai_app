import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_item.dart';

class FoodApiService {
  // Backend API base URL
  // Change this to your backend URL:
  // - 'http://localhost:8000' for iOS simulator / web / desktop
  // - 'http://10.0.2.2:8000' for Android emulator (10.0.2.2 is the emulator's alias for localhost)
  // - Your deployed backend URL for production
  static const String baseUrl = 'http://localhost:8000';

  /// Search for food items using the backend API
  /// 
  /// [query] - Food search query (e.g., "rice", "chicken", "apple")
  /// 
  /// Returns a list of FoodItem objects, or empty list on error
  Future<List<FoodItem>> searchFood(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final uri = Uri.parse('$baseUrl/search-food').replace(
        queryParameters: {'query': query.trim()},
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((item) => FoodItem.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        // Handle error response
        print('Error searching food: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception searching food: $e');
      return [];
    }
  }
}
