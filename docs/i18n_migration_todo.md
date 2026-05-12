# i18n migration tracker

Template: `app/lib/l10n/app_en.arb` · Romanian: `app/lib/l10n/app_ro.arb` · Run `flutter gen-l10n` after ARB edits · `python tools/check_arb_parity.py`

## Migrated in this pass (high-visibility surfaces)

| Area | Files |
|------|--------|
| App shell | `lib/screens/main/main_shell.dart` — exit dialog, bottom nav labels, AI FAB tooltip |
| Dashboard | `lib/screens/dashboard/dashboard_screen.dart` — tooltips, coach/macros labels, calorie card date, `NutritionInsights` |
| Diary | `lib/screens/diary/diary_screen.dart`, `lib/widgets/meal_section.dart` — delete dialog, insights/empty/summary, localized meal headers, add-food / cal units |
| Food search | `lib/screens/food/food_search_screen.dart` — app bar, hints, recent block, search empty/error, portions, meal picker + snackbars (meal label localized) |
| More | `lib/screens/more/more_screen.dart` — title, tiles, no-email fallback |
| Progress | `lib/screens/progress/progress_screen.dart` — app bar, refresh, profile card, weight section/chart/history/delete dialog, log-weight sheet, today intake + TDEE/BMI (`bmiCategoryLabel`), `lib/l10n/bmi_labels.dart` |
| AI coach | `lib/screens/ai/ai_coach_screen.dart` — app bar title logic, errors via mapper, drawer/inbox/folders, dialogs, onboarding CTA, composer, quick chips, relative time |
| AI onboarding | `lib/screens/ai/ai_onboarding_screen.dart`, `lib/l10n/ai_onboarding_options.dart` |
| Auth | `lib/screens/auth/login_screen.dart`, `lib/screens/auth/register_screen.dart` |
| Food detail / manual / edit | `lib/screens/food/food_detail_screen.dart`, `manual_food_entry_screen.dart`, `edit_food_entry_screen.dart` |
| Meals / recipes (saved) | `lib/screens/meals/create_meal_screen.dart`, `lib/screens/meals/my_meals_screen.dart`, `lib/screens/recipes/create_recipe_screen.dart`, `lib/screens/recipes/my_recipes_screen.dart` |
| Add meal (search form) | `lib/screens/add_meal/add_meal_screen.dart` |
| Profile edit (BMI chip) | `lib/screens/profile/edit_profile_screen.dart` — BMI category via `bmiCategoryLabel` |
| Insights service | `lib/services/ai_service.dart` — `NutritionInsights.build` uses ARB |
| AI errors | `lib/providers/ai_provider.dart` — `lastErrorCode`; `lib/l10n/api_error_mapper.dart` maps to localized copy |
| Meal keys → labels | `lib/l10n/meal_labels.dart` (Breakfast/Lunch/… API keys → `AppLocalizations`; `Snacks` → snack label) |

## Remaining hardcoded English (examples)

- **Food picker / result tiles**: `lib/screens/food/food_picker_screen.dart`, `lib/screens/food/food_result_tile.dart` — labels, units, empty states if any.
- **Edit profile** (beyond BMI chip): e.g. “Suggested plan” card and other English section copy in `lib/screens/profile/edit_profile_screen.dart`.
- **Settings**: review any tile titles/subtitles still passed as raw English in `settings_screen.dart` outside the language/theme/units blocks.
- **Other flows**: any screen under `lib/` not listed above that still uses literal `Text('...')` for user-visible app copy.
- **Tests / dev-only**: placeholder `print` in `add_meal_screen.dart` (not user-facing).

## Intentionally not translated (dynamic or third-party)

- User-entered food names, notes, custom meals/recipes, chat message bodies.
- OpenFoodFacts / external product names (search results show untranslated product titles; only template strings like “cal/100g” use ARB).
- AI thread **titles** when set by the user or defaulted as free text from the backend (shown as-is); only **fallback** chat titles use `aiCoachThreadTitle`.
- Folder names from the user.
- Profile enum **values** in subtitles (`sex`, `goalType` `.label` from models) — still English tokens from the app model until mapped to ARB.
- Route names, analytics events, logs, raw API error bodies / `FoodApiService` diagnostics when surfaced in SnackBars (shown as-is when non-empty).
- Numeric formatting and unit suffixes embedded in ARB strings (e.g. `g`, `kcal`, `cal`) where they duplicate metric symbols.

## Tooling

- `tools/check_arb_parity.py` skips naïve `{…}` extraction inside ICU `plural` messages to avoid false placeholder mismatches.
