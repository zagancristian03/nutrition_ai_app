import '../models/user_profile.dart';

/// Pure functions used across the Progress and Edit-Profile screens.
///
/// All formulas use the Mifflin–St Jeor equation for BMR — the most accurate
/// widely-used estimator for adults with normal body composition:
///
///     BMR(kcal) = 10·kg + 6.25·cm − 5·age + s
///         s = +5 for male, −161 for female, avg for "other"
///
/// TDEE = BMR × activity factor (see [ActivityLevel.factor]).
///
/// Adjustment from TDEE to daily calorie target uses ≈7700 kcal/kg body mass
/// (the commonly-cited figure for human adipose tissue):
///
///     daily_adjustment = (weekly_rate_kg · 7700) / 7
class NutritionMath {
  NutritionMath._();

  /// Estimated Basal Metabolic Rate in kcal/day, or null if we can't compute it.
  static double? bmr(UserProfile p) {
    final w = p.currentWeightKg;
    final h = p.heightCm;
    final age = p.ageYears;
    final sex = p.sex;
    if (w == null || h == null || age == null || sex == null) return null;

    final base = 10 * w + 6.25 * h - 5 * age;
    switch (sex) {
      case Sex.male:   return base + 5;
      case Sex.female: return base - 161;
      case Sex.other:  return base + (5 + -161) / 2; // midpoint
    }
  }

  /// Total Daily Energy Expenditure (kcal/day). Null if BMR or activity
  /// level are unknown.
  static double? tdee(UserProfile p) {
    final b = bmr(p);
    final act = p.activityLevel;
    if (b == null || act == null) return null;
    return b * act.factor;
  }

  /// Recommended daily calorie target given the goal + weekly rate.
  /// Clamped to a safe floor (1200 for females / other, 1500 for males).
  static double? recommendedCalories(UserProfile p) {
    final t = tdee(p);
    final goal = p.goalType;
    if (t == null || goal == null) return null;

    final rateKg = p.weeklyRateKg ?? _defaultRateFor(goal);
    final adjust = (rateKg * 7700) / 7; // kcal/day

    double kcal;
    switch (goal) {
      case GoalType.lose:     kcal = t - adjust; break;
      case GoalType.maintain: kcal = t;          break;
      case GoalType.gain:     kcal = t + adjust; break;
    }

    final floor = (p.sex == Sex.male) ? 1500.0 : 1200.0;
    if (kcal < floor) kcal = floor;
    return kcal;
  }

  /// Macro targets (grams/day), distributed as:
  ///
  ///   * Protein: 1.8 g/kg body weight (lose: 2.0 g/kg, gain: 1.8 g/kg)
  ///   * Fat    : 25 % of calories        (≈0.8 g/kg minimum)
  ///   * Carbs  : remainder from calories
  ///
  /// Returns null if the profile doesn't have enough info.
  static MacroTargets? recommendedMacros(UserProfile p) {
    final kcal = recommendedCalories(p);
    final weight = p.currentWeightKg;
    if (kcal == null || weight == null) return null;

    final proteinPerKg = (p.goalType == GoalType.lose) ? 2.0 : 1.8;
    final proteinG = proteinPerKg * weight;

    var fatG = (0.25 * kcal) / 9.0;
    final minFatG = 0.8 * weight;
    if (fatG < minFatG) fatG = minFatG;

    final remainingKcal = kcal - (proteinG * 4) - (fatG * 9);
    var carbsG = remainingKcal / 4.0;
    if (carbsG < 0) carbsG = 0;

    return MacroTargets(
      calories: kcal,
      protein:  proteinG,
      carbs:    carbsG,
      fat:      fatG,
    );
  }

  /// Body mass index (kg/m²) — or null if height/weight are unknown.
  static double? bmi(UserProfile p) {
    final w = p.currentWeightKg;
    final h = p.heightCm;
    if (w == null || h == null || h <= 0) return null;
    final m = h / 100.0;
    return w / (m * m);
  }

  /// Textual classification of [bmi] per WHO.
  static String bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25)   return 'Healthy';
    if (bmi < 30)   return 'Overweight';
    return 'Obese';
  }

  static double _defaultRateFor(GoalType goal) {
    switch (goal) {
      case GoalType.lose:     return 0.5;
      case GoalType.maintain: return 0.0;
      case GoalType.gain:     return 0.25;
    }
  }
}

/// Calorie + macro targets (grams/day for macros, kcal/day for calories).
class MacroTargets {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  const MacroTargets({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}
