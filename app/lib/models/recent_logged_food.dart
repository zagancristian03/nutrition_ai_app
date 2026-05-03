import 'food_item.dart';

/// One row from GET `/food-logs/recent-foods` (latest diary entry per food).
class RecentLoggedFood {
  final Map<String, dynamic> _j;

  RecentLoggedFood._(this._j);

  factory RecentLoggedFood.fromLogJson(Map<String, dynamic> j) =>
      RecentLoggedFood._(Map<String, dynamic>.from(j));

  String get foodId => _j['food_id']?.toString() ?? '';

  String get foodName => _j['food_name'] as String? ?? '';

  double? get grams {
    final v = _j['grams'];
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  double? get servings {
    final v = _j['servings'];
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  DateTime get lastLoggedAt {
    final s = _j['created_at']?.toString();
    return DateTime.tryParse(s ?? '') ?? DateTime.now();
  }

  /// Synthetic catalog row for [FoodDetailScreen] (macros derived from snapshot).
  FoodItem get asFoodItem => FoodItem.fromRecentFoodLog(_j);
}
