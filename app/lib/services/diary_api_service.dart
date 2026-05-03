import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/food_entry.dart';
import 'food_api_service.dart';

/// HTTP client for the diary endpoints:
///
///   * `/food-logs`   — per-user food diary (CRUD)
///   * `/user-goals`  — per-user calorie + macro targets (GET/PUT)
///
/// Everything is keyed by [userId] — pass in the Firebase UID.
class DiaryApiService {
  static String get _baseUrl => FoodApiService.baseUrl;
  static const Duration _timeout = Duration(seconds: 10);

  /// Convert any incoming JSON value (num OR numeric-string) to double.
  /// Supabase `numeric` columns are serialized as strings through
  /// psycopg2 → FastAPI. See [FoodItem.fromJson] for the same pattern.
  static double _asDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  static double? _asDoubleOrNull(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static String _dateToIso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// SQL/JSON `date` values are calendar days — always interpret in the local
  /// timezone so diary grouping matches [DateTime(year, month, day)].
  static DateTime _parseLoggedDate(Object? raw) {
    if (raw == null) return DateTime.now();
    final s = raw.toString().trim();
    if (s.isEmpty) return DateTime.now();
    final head = s.split('T').first;
    final parts = head.split('-');
    if (parts.length == 3) {
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y != null && m != null && d != null) {
        return DateTime(y, m, d);
      }
    }
    return DateTime.tryParse(s) ?? DateTime.now();
  }

  static const Map<String, String> _clientMealToServer = {
    'Breakfast': 'breakfast',
    'Lunch':     'lunch',
    'Dinner':    'dinner',
    'Snack':     'snack',
  };
  static const Map<String, String> _serverMealToClient = {
    'breakfast': 'Breakfast',
    'lunch':     'Lunch',
    'dinner':    'Dinner',
    'snack':     'Snack',
  };

  static String _normaliseMeal(String m) =>
      _clientMealToServer[m] ?? m.toLowerCase();

  static String _prettifyMeal(String m) =>
      _serverMealToClient[m.toLowerCase()] ??
      (m.isEmpty ? m : m[0].toUpperCase() + m.substring(1).toLowerCase());

  // ----------------------------------------------------------------------- //
  // Food logs                                                               //
  // ----------------------------------------------------------------------- //

  /// GET /food-logs?user_id=...&logged_date=YYYY-MM-DD
  ///
  /// Returns `null` if the request failed (network or non-200). An empty
  /// list means the day was loaded successfully but has no entries.
  Future<List<FoodEntry>?> listFoodLogs({
    required String userId,
    required DateTime date,
  }) async {
    final uri = Uri.parse('$_baseUrl/food-logs').replace(queryParameters: {
      'user_id':     userId,
      'logged_date': _dateToIso(date),
      'limit':       '500',
    });

    try {
      final response = await http
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(_timeout);

      if (response.statusCode != 200) {
        debugPrint(
          '[DiaryApiService] listFoodLogs HTTP ${response.statusCode} '
          'body=${response.body}',
        );
        return null;
      }

      final decoded = json.decode(response.body);
      if (decoded is! List) return const [];

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_entryFromLogJson)
          .toList();
    } catch (e, st) {
      debugPrint('[DiaryApiService] listFoodLogs error: $e\n$st');
      return null;
    }
  }

  /// GET /food-logs/recent-foods?user_id=... — latest logged instance per food_id.
  Future<List<Map<String, dynamic>>> listRecentDistinctFoodsRaw({
    required String userId,
    int limit = 40,
  }) async {
    final uri =
        Uri.parse('$_baseUrl/food-logs/recent-foods').replace(queryParameters: {
      'user_id': userId,
      'limit':   '$limit',
    });

    try {
      final response = await http
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(_timeout);

      if (response.statusCode != 200) {
        debugPrint(
          '[DiaryApiService] listRecentDistinctFoodsRaw HTTP '
          '${response.statusCode} body=${response.body}',
        );
        return const [];
      }

      final decoded = json.decode(response.body);
      if (decoded is! List) return const [];

      return decoded
          .whereType<Map<String, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (e, st) {
      debugPrint('[DiaryApiService] listRecentDistinctFoodsRaw error: $e\n$st');
      return const [];
    }
  }

  /// POST /food-logs — create a new diary entry and return the persisted row.
  Future<FoodEntry?> createFoodLog({
    required String userId,
    required String foodId,
    required DateTime loggedDate,
    required String mealType,
    double? grams,
    double? servings,
  }) async {
    final uri = Uri.parse('$_baseUrl/food-logs');
    final body = <String, dynamic>{
      'user_id':     userId,
      'food_id':     foodId,
      'logged_date': _dateToIso(loggedDate),
      'meal_type':   _normaliseMeal(mealType),
      if (grams    != null) 'grams':    grams,
      if (servings != null) 'servings': servings,
    };

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(_timeout);

      if (response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) return _entryFromLogJson(decoded);
        return null;
      }

      debugPrint(
        '[DiaryApiService] createFoodLog HTTP ${response.statusCode} '
        'body=${response.body}',
      );
      return null;
    } catch (e, st) {
      debugPrint('[DiaryApiService] createFoodLog error: $e\n$st');
      return null;
    }
  }

  /// PUT /food-logs/{logId}?user_id=...
  ///
  /// Pass only the fields you want to change — everything else is preserved.
  Future<FoodEntry?> updateFoodLog({
    required int logId,
    required String userId,
    String? mealType,
    double? grams,
    double? servings,
    DateTime? loggedDate,
    String? foodName,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
  }) async {
    final uri = Uri.parse('$_baseUrl/food-logs/$logId')
        .replace(queryParameters: {'user_id': userId});

    final body = <String, dynamic>{
      if (mealType   != null) 'meal_type':   _normaliseMeal(mealType),
      if (grams      != null) 'grams':       grams,
      if (servings   != null) 'servings':    servings,
      if (loggedDate != null) 'logged_date': _dateToIso(loggedDate),
      if (foodName   != null) 'food_name':   foodName,
      if (calories   != null) 'calories':    calories,
      if (protein    != null) 'protein':     protein,
      if (carbs      != null) 'carbs':       carbs,
      if (fat        != null) 'fat':         fat,
    };

    if (body.isEmpty) return null;

    try {
      final response = await http
          .put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) return _entryFromLogJson(decoded);
        return null;
      }

      debugPrint(
        '[DiaryApiService] updateFoodLog HTTP ${response.statusCode} '
        'body=${response.body}',
      );
      return null;
    } catch (e, st) {
      debugPrint('[DiaryApiService] updateFoodLog error: $e\n$st');
      return null;
    }
  }

  /// DELETE /food-logs/{logId}?user_id=...
  Future<bool> deleteFoodLog({required int logId, required String userId}) async {
    final uri = Uri.parse('$_baseUrl/food-logs/$logId')
        .replace(queryParameters: {'user_id': userId});

    try {
      final response = await http.delete(uri).timeout(_timeout);
      return response.statusCode == 204;
    } catch (e) {
      debugPrint('[DiaryApiService] deleteFoodLog error: $e');
      return false;
    }
  }

  static FoodEntry _entryFromLogJson(Map<String, dynamic> j) {
    final mealRaw = j['meal_type'] as String? ?? '';
    final loggedDate = _parseLoggedDate(j['logged_date']);
    final createdAt = DateTime.tryParse(j['created_at']?.toString() ?? '') ??
        DateTime.now();

    return FoodEntry(
      logId:         (j['id'] as num?)?.toInt(),
      foodId:        j['food_id']?.toString() ?? '',
      foodName:      j['food_name']?.toString() ?? '',
      mealType:      _prettifyMeal(mealRaw),
      servingSize:   _asDoubleOrNull(j['grams']) ?? 0.0,
      servings:      _asDoubleOrNull(j['servings']) ?? 1.0,
      totalCalories: _asDouble(j['calories']),
      totalProtein:  _asDouble(j['protein']),
      totalCarbs:    _asDouble(j['carbs']),
      totalFat:      _asDouble(j['fat']),
      loggedDate:    loggedDate,
      timestamp:     createdAt,
    );
  }

  // ----------------------------------------------------------------------- //
  // User goals                                                              //
  // ----------------------------------------------------------------------- //

  /// GET /user-goals/{userId}
  ///
  /// Never fails: if the user has no stored goals yet, the backend returns
  /// the default targets. On network/server error, returns [UserGoalsDto.defaults].
  Future<UserGoalsDto> getGoals(String userId) async {
    final uri = Uri.parse('$_baseUrl/user-goals/$userId');
    try {
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return UserGoalsDto._fromJson(decoded);
        }
      }
      debugPrint(
        '[DiaryApiService] getGoals HTTP ${response.statusCode} body=${response.body}',
      );
    } catch (e) {
      debugPrint('[DiaryApiService] getGoals error: $e');
    }
    return UserGoalsDto.defaults;
  }

  /// PUT /user-goals/{userId}
  Future<UserGoalsDto?> putGoals({
    required String userId,
    required double calorieGoal,
    required double proteinGoal,
    required double carbsGoal,
    required double fatGoal,
  }) async {
    final uri = Uri.parse('$_baseUrl/user-goals/$userId');
    final body = {
      'calorie_goal': calorieGoal,
      'protein_goal': proteinGoal,
      'carbs_goal':   carbsGoal,
      'fat_goal':     fatGoal,
    };

    try {
      final response = await http
          .put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return UserGoalsDto._fromJson(decoded);
        }
      }
      debugPrint(
        '[DiaryApiService] putGoals HTTP ${response.statusCode} body=${response.body}',
      );
    } catch (e) {
      debugPrint('[DiaryApiService] putGoals error: $e');
    }
    return null;
  }
}


/// Plain data holder for user goals returned by the backend.
class UserGoalsDto {
  final double calorieGoal;
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;

  const UserGoalsDto({
    required this.calorieGoal,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
  });

  static const UserGoalsDto defaults = UserGoalsDto(
    calorieGoal: 2000,
    proteinGoal: 150,
    carbsGoal:   250,
    fatGoal:     65,
  );

  factory UserGoalsDto._fromJson(Map<String, dynamic> j) {
    double pick(String a, String b, double fallback) {
      final v = j[a] ?? j[b];
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? fallback;
      return fallback;
    }

    return UserGoalsDto(
      calorieGoal: pick('calorie_goal', 'calorieGoal', 2000),
      proteinGoal: pick('protein_goal', 'proteinGoal', 150),
      carbsGoal:   pick('carbs_goal',   'carbsGoal',   250),
      fatGoal:     pick('fat_goal',     'fatGoal',     65),
    );
  }
}
