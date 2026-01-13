class FoodEntry {
  final String foodId;
  final String foodName;
  final String mealType; // Breakfast, Lunch, Dinner, Snack
  final double servingSize; // in grams
  final double servings; // number of servings
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final DateTime timestamp;

  FoodEntry({
    required this.foodId,
    required this.foodName,
    required this.mealType,
    required this.servingSize,
    required this.servings,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Get total grams consumed
  double get totalGrams => servingSize * servings;

  /// Create FoodEntry from JSON
  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      foodId: json['foodId'] as String? ?? '',
      foodName: json['foodName'] as String? ?? '',
      mealType: json['mealType'] as String? ?? '',
      servingSize: (json['servingSize'] as num?)?.toDouble() ?? 0.0,
      servings: (json['servings'] as num?)?.toDouble() ?? 1.0,
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0.0,
      totalProtein: (json['totalProtein'] as num?)?.toDouble() ?? 0.0,
      totalCarbs: (json['totalCarbs'] as num?)?.toDouble() ?? 0.0,
      totalFat: (json['totalFat'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  /// Convert FoodEntry to JSON
  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'foodName': foodName,
      'mealType': mealType,
      'servingSize': servingSize,
      'servings': servings,
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
