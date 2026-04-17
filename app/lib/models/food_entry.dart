/// A single row in the user's diary.
///
/// When the entry has been persisted to the backend, [logId] is the server's
/// `food_logs.id`. For an ephemeral (not-yet-synced) entry, [logId] is null.
class FoodEntry {
  /// Server-assigned id from the `food_logs` table. `null` means the entry
  /// lives only in memory (sync failed or still in-flight).
  final int? logId;

  final String foodId;
  final String foodName;
  final String mealType; // Breakfast, Lunch, Dinner, Snack
  final double servingSize; // in grams
  final double servings; // number of servings
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  /// The diary date this entry belongs to (day granularity).
  final DateTime loggedDate;

  /// When the entry was logged (server `created_at`, or `DateTime.now()` for
  /// offline entries).
  final DateTime timestamp;

  FoodEntry({
    this.logId,
    required this.foodId,
    required this.foodName,
    required this.mealType,
    required this.servingSize,
    required this.servings,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    DateTime? loggedDate,
    DateTime? timestamp,
  })  : loggedDate = loggedDate ?? DateTime.now(),
        timestamp = timestamp ?? DateTime.now();

  /// Get total grams consumed.
  double get totalGrams => servingSize * servings;

  /// Return a copy with the given fields replaced. `logId` uses a sentinel
  /// flag so callers can explicitly clear it when needed.
  FoodEntry copyWith({
    int? logId,
    bool clearLogId = false,
    String? foodId,
    String? foodName,
    String? mealType,
    double? servingSize,
    double? servings,
    double? totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
    DateTime? loggedDate,
    DateTime? timestamp,
  }) {
    return FoodEntry(
      logId:          clearLogId ? null : (logId ?? this.logId),
      foodId:         foodId         ?? this.foodId,
      foodName:       foodName       ?? this.foodName,
      mealType:       mealType       ?? this.mealType,
      servingSize:    servingSize    ?? this.servingSize,
      servings:       servings       ?? this.servings,
      totalCalories:  totalCalories  ?? this.totalCalories,
      totalProtein:   totalProtein   ?? this.totalProtein,
      totalCarbs:     totalCarbs     ?? this.totalCarbs,
      totalFat:       totalFat       ?? this.totalFat,
      loggedDate:     loggedDate     ?? this.loggedDate,
      timestamp:      timestamp      ?? this.timestamp,
    );
  }

  /// Parse from the local JSON shape (not the server's /food-logs shape —
  /// use `DiaryApiService` for that).
  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      logId: (json['logId'] as num?)?.toInt(),
      foodId: json['foodId'] as String? ?? '',
      foodName: json['foodName'] as String? ?? '',
      mealType: json['mealType'] as String? ?? '',
      servingSize: (json['servingSize'] as num?)?.toDouble() ?? 0.0,
      servings: (json['servings'] as num?)?.toDouble() ?? 1.0,
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0.0,
      totalProtein: (json['totalProtein'] as num?)?.toDouble() ?? 0.0,
      totalCarbs: (json['totalCarbs'] as num?)?.toDouble() ?? 0.0,
      totalFat: (json['totalFat'] as num?)?.toDouble() ?? 0.0,
      loggedDate: json['loggedDate'] != null
          ? DateTime.parse(json['loggedDate'] as String)
          : DateTime.now(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logId': logId,
      'foodId': foodId,
      'foodName': foodName,
      'mealType': mealType,
      'servingSize': servingSize,
      'servings': servings,
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'loggedDate': loggedDate.toIso8601String(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
