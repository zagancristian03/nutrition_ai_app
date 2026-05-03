class FoodItem {
  final String id;
  final String name;
  final String? brand;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double? servingSizeG;
  final String unit; // 'g', 'ml', or 'unit'

  FoodItem({
    required this.id,
    required this.name,
    this.brand,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.servingSizeG,
    this.unit = 'g',
  });

  /// Human-readable label: "Name · Brand" when brand is set, else just name.
  String get displayTitle {
    final b = brand?.trim();
    if (b == null || b.isEmpty) return name;
    return '$name · $b';
  }

  /// Does the row have any useful macro information at all?
  bool get hasAnyMacros =>
      caloriesPer100g > 0 ||
      proteinPer100g > 0 ||
      carbsPer100g > 0 ||
      fatPer100g > 0;

  double caloriesFor(double grams) => (caloriesPer100g * grams) / 100.0;
  double proteinFor(double grams)  => (proteinPer100g  * grams) / 100.0;
  double carbsFor(double grams)    => (carbsPer100g    * grams) / 100.0;
  double fatFor(double grams)      => (fatPer100g      * grams) / 100.0;

  /// Create FoodItem from JSON (FastAPI: `*_per_100g`; legacy: short keys).
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    // Postgres `numeric` columns round-trip through psycopg2/FastAPI as JSON
    // *strings* (e.g. "50.0") to preserve precision. Accept both forms.
    double asDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    double? asDoubleOrNull(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    double per100(String snake, String shortKey) {
      return asDouble(json[snake] ?? json[shortKey]);
    }

    double? optNum(String key) => asDoubleOrNull(json[key]);

    String? optStr(String key) {
      final v = json[key];
      if (v is String && v.trim().isNotEmpty) return v;
      return null;
    }

    final idRaw = json['id'];
    final id = idRaw == null ? '' : idRaw.toString();

    return FoodItem(
      id: id,
      name: json['name'] as String? ?? '',
      brand: optStr('brand'),
      caloriesPer100g: per100('calories_per_100g', 'calories'),
      proteinPer100g:  per100('protein_per_100g',  'protein'),
      carbsPer100g:    per100('carbs_per_100g',    'carbs'),
      fatPer100g:      per100('fat_per_100g',      'fat'),
      servingSizeG:    optNum('serving_size_g'),
      unit: json['unit'] as String? ?? 'g',
    );
  }

  static FoodItem fromRecentFoodLog(Map<String, dynamic> j) {
    double asDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    double? asDoubleOrNull(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    final grams = asDoubleOrNull(j['grams']);
    final calories = asDouble(j['calories']);
    final protein = asDouble(j['protein']);
    final carbs = asDouble(j['carbs']);
    final fat =  asDouble(j['fat']);
    final g = (grams != null && grams > 0) ? grams : 100.0;
    final factor = g > 0 ? 100.0 / g : 0.0;

    return FoodItem(
      id: j['food_id']?.toString() ?? '',
      name: j['food_name'] as String? ?? '',
      brand: null,
      caloriesPer100g: calories * factor,
      proteinPer100g:  protein * factor,
      carbsPer100g:    carbs * factor,
      fatPer100g:      fat * factor,
      servingSizeG: grams ?? 100.0,
      unit: 'g',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatPer100g': fatPer100g,
      'servingSizeG': servingSizeG,
      'unit': unit,
    };
  }
}