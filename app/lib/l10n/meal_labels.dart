import 'app_localizations.dart';

/// Diary/API meal keys are English (`Breakfast`, …). Maps to localized labels.
String mealTypeLabel(AppLocalizations loc, String mealKey) {
  switch (mealKey) {
    case 'Breakfast':
      return loc.mealBreakfast;
    case 'Lunch':
      return loc.mealLunch;
    case 'Dinner':
      return loc.mealDinner;
    case 'Snack':
      return loc.mealSnack;
    case 'Snacks':
      return loc.mealSnack;
    default:
      return mealKey;
  }
}
