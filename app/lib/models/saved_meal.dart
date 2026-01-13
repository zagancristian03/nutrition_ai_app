import 'food_item.dart';

class SavedMeal {
  final String id;
  final String name;
  final List<SavedMealItem> items;
  final DateTime createdAt;

  SavedMeal({
    required this.id,
    required this.name,
    required this.items,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Get total nutrition for the meal (per serving)
  double get totalCalories {
    return items.fold(0.0, (sum, item) => sum + item.totalCalories);
  }

  double get totalProtein {
    return items.fold(0.0, (sum, item) => sum + item.totalProtein);
  }

  double get totalCarbs {
    return items.fold(0.0, (sum, item) => sum + item.totalCarbs);
  }

  double get totalFat {
    return items.fold(0.0, (sum, item) => sum + item.totalFat);
  }

  factory SavedMeal.fromJson(Map<String, dynamic> json) {
    return SavedMeal(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => SavedMealItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class SavedMealItem {
  final String foodId;
  final String foodName;
  final double servingSize; // in grams
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;

  SavedMealItem({
    required this.foodId,
    required this.foodName,
    required this.servingSize,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
  });

  double get totalCalories => (caloriesPer100g * servingSize) / 100.0;
  double get totalProtein => (proteinPer100g * servingSize) / 100.0;
  double get totalCarbs => (carbsPer100g * servingSize) / 100.0;
  double get totalFat => (fatPer100g * servingSize) / 100.0;

  factory SavedMealItem.fromJson(Map<String, dynamic> json) {
    return SavedMealItem(
      foodId: json['foodId'] as String? ?? '',
      foodName: json['foodName'] as String? ?? '',
      servingSize: (json['servingSize'] as num?)?.toDouble() ?? 0.0,
      caloriesPer100g: (json['caloriesPer100g'] as num?)?.toDouble() ?? 0.0,
      proteinPer100g: (json['proteinPer100g'] as num?)?.toDouble() ?? 0.0,
      carbsPer100g: (json['carbsPer100g'] as num?)?.toDouble() ?? 0.0,
      fatPer100g: (json['fatPer100g'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'foodName': foodName,
      'servingSize': servingSize,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatPer100g': fatPer100g,
    };
  }
}
