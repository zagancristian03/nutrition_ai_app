import 'food_entry.dart';

class DailyLog {
  final DateTime date;
  double calorieGoal;
  double proteinGoal;
  double carbsGoal;
  double fatGoal;
  final List<FoodEntry> entries;

  DailyLog({
    DateTime? date,
    this.calorieGoal = 2000.0,
    this.proteinGoal = 150.0,
    this.carbsGoal = 250.0,
    this.fatGoal = 65.0,
    List<FoodEntry>? entries,
  })  : date = date ?? DateTime.now(),
        entries = entries ?? [];

  /// Get total calories consumed from all entries
  double get totalCalories {
    return entries.fold(0.0, (sum, entry) => sum + entry.totalCalories);
  }

  /// Get total protein consumed from all entries
  double get totalProtein {
    return entries.fold(0.0, (sum, entry) => sum + entry.totalProtein);
  }

  /// Get total carbs consumed from all entries
  double get totalCarbs {
    return entries.fold(0.0, (sum, entry) => sum + entry.totalCarbs);
  }

  /// Get total fat consumed from all entries
  double get totalFat {
    return entries.fold(0.0, (sum, entry) => sum + entry.totalFat);
  }

  /// Get entries grouped by meal type
  Map<String, List<FoodEntry>> get entriesByMealType {
    final Map<String, List<FoodEntry>> grouped = {};
    for (final entry in entries) {
      grouped.putIfAbsent(entry.mealType, () => []).add(entry);
    }
    return grouped;
  }

  /// Get total calories for a specific meal type
  double caloriesForMealType(String mealType) {
    return entries
        .where((entry) => entry.mealType == mealType)
        .fold(0.0, (sum, entry) => sum + entry.totalCalories);
  }

  /// Create DailyLog from JSON
  factory DailyLog.fromJson(Map<String, dynamic> json) {
    return DailyLog(
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      calorieGoal: (json['calorieGoal'] as num?)?.toDouble() ?? 2000.0,
      proteinGoal: (json['proteinGoal'] as num?)?.toDouble() ?? 150.0,
      carbsGoal: (json['carbsGoal'] as num?)?.toDouble() ?? 250.0,
      fatGoal: (json['fatGoal'] as num?)?.toDouble() ?? 65.0,
      entries: (json['entries'] as List<dynamic>?)
              ?.map((e) => FoodEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Convert DailyLog to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'calorieGoal': calorieGoal,
      'proteinGoal': proteinGoal,
      'carbsGoal': carbsGoal,
      'fatGoal': fatGoal,
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }
}
