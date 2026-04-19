/// Rule-based coaching copy for the dashboard and diary (no network calls).
class NutritionInsights {
  NutritionInsights._();

  static bool _sameCalendarDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Short tips (0–3) based on the selected day and logged totals vs goals.
  static List<String> build({
    required DateTime selectedDate,
    required bool isLoading,
    required int entryCount,
    required double calorieGoal,
    required double calories,
    required double proteinGoal,
    required double protein,
    required double carbsGoal,
    required double carbs,
    required double fatGoal,
    required double fat,
  }) {
    if (isLoading) return const [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final tips = <String>[];

    if (!_sameCalendarDay(day, today)) {
      tips.add(
        'You are viewing a past or future day. Use ← → or the calendar to move between days.',
      );
    }

    if (entryCount == 0) {
      if (_sameCalendarDay(day, today)) {
        tips.add(
          'No foods logged yet today. Tap Add or pick a meal below to get started.',
        );
      }
      return tips.take(3).toList();
    }

    final safeCalGoal = calorieGoal <= 0 ? 1.0 : calorieGoal;
    final calRatio = calories / safeCalGoal;

    if (calRatio < 0.4 && _sameCalendarDay(day, today)) {
      tips.add(
        'You are under your calorie goal so far. Add a balanced meal or snack if you are still hungry.',
      );
    } else if (calRatio > 1.15) {
      tips.add(
        'Calories are above today’s goal. Consider lighter options tomorrow or adjust goals in settings if this is intentional.',
      );
    }

    final safeP = proteinGoal <= 0 ? 1.0 : proteinGoal;
    final safeC = carbsGoal <= 0 ? 1.0 : carbsGoal;
    final safeF = fatGoal <= 0 ? 1.0 : fatGoal;
    if (protein / safeP < 0.7 && carbs / safeC > 0.85) {
      tips.add(
        'Carbs are on track but protein is low. Lean meat, dairy, legumes, or tofu can help balance this day.',
      );
    } else if (protein / safeP >= 0.85 && fat / safeF < 0.6) {
      tips.add(
        'Protein looks solid. If energy dips later, a small portion of healthy fats (nuts, olive oil) can help.',
      );
    }

    return tips.take(3).toList();
  }
}
