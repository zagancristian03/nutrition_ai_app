class FoodItem {
  final String id;
  final String name;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final String unit; // 'g', 'ml', or 'unit'

  FoodItem({
    required this.id,
    required this.name,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.unit = 'g',
  });

  /// Calculate calories for a given amount in grams
  double caloriesFor(double grams) {
    return (caloriesPer100g * grams) / 100.0;
  }

  /// Calculate protein for a given amount in grams
  double proteinFor(double grams) {
    return (proteinPer100g * grams) / 100.0;
  }

  /// Calculate carbs for a given amount in grams
  double carbsFor(double grams) {
    return (carbsPer100g * grams) / 100.0;
  }

  /// Calculate fat for a given amount in grams
  double fatFor(double grams) {
    return (fatPer100g * grams) / 100.0;
  }

  /// Create FoodItem from JSON (from backend API)
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    // Backend returns per 100g values
    return FoodItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      caloriesPer100g: (json['calories'] as num?)?.toDouble() ?? 0.0,
      proteinPer100g: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbsPer100g: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fatPer100g: (json['fat'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'g',
    );
  }

  /// Convert FoodItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatPer100g': fatPer100g,
      'unit': unit,
    };
  }
}
