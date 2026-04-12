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

  /// Create FoodItem from JSON (FastAPI: `*_per_100g`; legacy: short keys).
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    double per100(String snake, String shortKey) {
      final v = json[snake] ?? json[shortKey];
      if (v is num) return v.toDouble();
      return 0.0;
    }

    final idRaw = json['id'];
    final id = idRaw == null ? '' : idRaw.toString();

    return FoodItem(
      id: id,
      name: json['name'] as String? ?? '',
      caloriesPer100g: per100('calories_per_100g', 'calories'),
      proteinPer100g: per100('protein_per_100g', 'protein'),
      carbsPer100g: per100('carbs_per_100g', 'carbs'),
      fatPer100g: per100('fat_per_100g', 'fat'),
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
