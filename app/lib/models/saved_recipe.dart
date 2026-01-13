import 'food_item.dart';

class SavedRecipe {
  final String id;
  final String name;
  final String? description;
  final List<SavedRecipeItem> items;
  final int servings; // Number of servings the recipe makes
  final DateTime createdAt;

  SavedRecipe({
    required this.id,
    required this.name,
    this.description,
    required this.items,
    this.servings = 1,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Get total nutrition for the entire recipe
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

  /// Get nutrition per serving
  double get caloriesPerServing => totalCalories / servings;
  double get proteinPerServing => totalProtein / servings;
  double get carbsPerServing => totalCarbs / servings;
  double get fatPerServing => totalFat / servings;

  factory SavedRecipe.fromJson(Map<String, dynamic> json) {
    return SavedRecipe(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => SavedRecipeItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      servings: (json['servings'] as num?)?.toInt() ?? 1,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'items': items.map((e) => e.toJson()).toList(),
      'servings': servings,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class SavedRecipeItem {
  final String foodId;
  final String foodName;
  final double servingSize; // in grams
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;

  SavedRecipeItem({
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

  factory SavedRecipeItem.fromJson(Map<String, dynamic> json) {
    return SavedRecipeItem(
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
