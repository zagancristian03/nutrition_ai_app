// Rule-based coaching copy for the dashboard and diary (no network calls).
import 'package:app/l10n/app_localizations.dart';

class NutritionInsights {
  NutritionInsights._();

  static bool _sameCalendarDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Short tips (0–3) based on the selected day and logged totals vs goals.
  static List<String> build({
    required AppLocalizations loc,
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
      tips.add(loc.nutritionInsightViewingOtherDay);
    }

    if (entryCount == 0) {
      if (_sameCalendarDay(day, today)) {
        tips.add(loc.nutritionInsightNoFoodsToday);
      }
      return tips.take(3).toList();
    }

    final safeCalGoal = calorieGoal <= 0 ? 1.0 : calorieGoal;
    final calRatio = calories / safeCalGoal;

    if (calRatio < 0.4 && _sameCalendarDay(day, today)) {
      tips.add(loc.nutritionInsightUnderCalories);
    } else if (calRatio > 1.15) {
      tips.add(loc.nutritionInsightOverCalories);
    }

    final safeP = proteinGoal <= 0 ? 1.0 : proteinGoal;
    final safeC = carbsGoal <= 0 ? 1.0 : carbsGoal;
    final safeF = fatGoal <= 0 ? 1.0 : fatGoal;
    if (protein / safeP < 0.7 && carbs / safeC > 0.85) {
      tips.add(loc.nutritionInsightProteinLowCarbsHigh);
    } else if (protein / safeP >= 0.85 && fat / safeF < 0.6) {
      tips.add(loc.nutritionInsightProteinHighFatLow);
    }

    return tips.take(3).toList();
  }
}
