import 'app_localizations.dart';

/// Localized WHO-style BMI category for display (numeric thresholds unchanged).
String bmiCategoryLabel(AppLocalizations loc, double bmi) {
  if (bmi < 18.5) return loc.progressBmiCategoryUnderweight;
  if (bmi < 25) return loc.progressBmiCategoryHealthy;
  if (bmi < 30) return loc.progressBmiCategoryOverweight;
  return loc.progressBmiCategoryObese;
}
