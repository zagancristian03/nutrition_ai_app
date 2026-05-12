import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ro.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ro'),
  ];

  /// Application title used in task switcher and about
  ///
  /// In en, this message translates to:
  /// **'Nutrition AI'**
  String get appTitle;

  /// No description provided for @settingsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenTitle;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsSectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsSectionLanguage;

  /// No description provided for @settingsSectionProfileGoals.
  ///
  /// In en, this message translates to:
  /// **'Profile & goals'**
  String get settingsSectionProfileGoals;

  /// No description provided for @settingsSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsSectionPreferences;

  /// No description provided for @settingsSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsSectionAccount;

  /// No description provided for @settingsSectionHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get settingsSectionHelp;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Controls menus and buttons in the app (not food names from external databases).'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsLanguageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystemDefault;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageRomanian.
  ///
  /// In en, this message translates to:
  /// **'Romanian'**
  String get settingsLanguageRomanian;

  /// No description provided for @settingsThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeTitle;

  /// No description provided for @settingsThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Light, dark, or match your device'**
  String get settingsThemeSubtitle;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsWeightUnitTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight unit'**
  String get settingsWeightUnitTitle;

  /// No description provided for @settingsWeightUnitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Used on the Progress and weight log screens'**
  String get settingsWeightUnitSubtitle;

  /// No description provided for @settingsWeightUnitKg.
  ///
  /// In en, this message translates to:
  /// **'Kilograms (kg)'**
  String get settingsWeightUnitKg;

  /// No description provided for @settingsWeightUnitLb.
  ///
  /// In en, this message translates to:
  /// **'Pounds (lb)'**
  String get settingsWeightUnitLb;

  /// No description provided for @settingsCoachTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Show coach tips'**
  String get settingsCoachTipsTitle;

  /// No description provided for @settingsCoachTipsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Friendly insights on Dashboard and Diary'**
  String get settingsCoachTipsSubtitle;

  /// No description provided for @settingsConfirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm before deleting'**
  String get settingsConfirmDeleteTitle;

  /// No description provided for @settingsConfirmDeleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask before removing a logged food'**
  String get settingsConfirmDeleteSubtitle;

  /// No description provided for @settingsHapticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get settingsHapticsTitle;

  /// No description provided for @settingsHapticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Subtle vibration on actions'**
  String get settingsHapticsSubtitle;

  /// No description provided for @settingsEditProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get settingsEditProfileTitle;

  /// No description provided for @settingsEditProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Body stats, goal, activity level'**
  String get settingsEditProfileSubtitle;

  /// No description provided for @settingsDailyTargetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily targets'**
  String get settingsDailyTargetsTitle;

  /// No description provided for @settingsDailyTargetsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Calorie + macro goals'**
  String get settingsDailyTargetsSubtitle;

  /// No description provided for @settingsEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get settingsEmailTitle;

  /// No description provided for @settingsEmailNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get settingsEmailNotSignedIn;

  /// No description provided for @settingsChangePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get settingsChangePasswordTitle;

  /// No description provided for @settingsChangePasswordSubtitleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in first'**
  String get settingsChangePasswordSubtitleSignIn;

  /// No description provided for @settingsChangePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send a reset link to your email'**
  String get settingsChangePasswordSubtitle;

  /// No description provided for @settingsSnackResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Reset email sent'**
  String get settingsSnackResetEmailSent;

  /// Password reset error snackbar
  ///
  /// In en, this message translates to:
  /// **'Failed to send: {detail}'**
  String settingsSnackResetFailed(String detail);

  /// No description provided for @settingsSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOutTitle;

  /// No description provided for @settingsSignOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Return to the login screen'**
  String get settingsSignOutSubtitle;

  /// No description provided for @authSignOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get authSignOutConfirmTitle;

  /// No description provided for @authSignOutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You can sign back in any time.'**
  String get authSignOutConfirmBody;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get commonSignOut;

  /// No description provided for @commonDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get commonDismiss;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @settingsFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get settingsFeedbackTitle;

  /// No description provided for @settingsFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you\'d like to see next'**
  String get settingsFeedbackSubtitle;

  /// No description provided for @settingsFeedbackSnack.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Email feedback coming soon.'**
  String get settingsFeedbackSnack;

  /// No description provided for @settingsRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate this app'**
  String get settingsRateTitle;

  /// No description provided for @settingsRateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A quick rating helps a lot'**
  String get settingsRateSubtitle;

  /// No description provided for @settingsRateSnack.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your support!'**
  String get settingsRateSnack;

  /// No description provided for @settingsAboutAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition AI'**
  String get settingsAboutAppTitle;

  /// No description provided for @settingsAboutVersionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get settingsAboutVersionSubtitle;

  /// No description provided for @settingsPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacyTitle;

  /// No description provided for @settingsPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your foods, goals and weights are stored securely.'**
  String get settingsPrivacySubtitle;

  /// No description provided for @errorNetworkTimeout.
  ///
  /// In en, this message translates to:
  /// **'The connection timed out. Check your network and try again.'**
  String get errorNetworkTimeout;

  /// No description provided for @errorServerGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Please try again.'**
  String get errorServerGeneric;

  /// No description provided for @errorValidationRequiredField.
  ///
  /// In en, this message translates to:
  /// **'A required field is missing. Please check your input.'**
  String get errorValidationRequiredField;

  /// Fallback when the server returns an error code we do not map yet
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {detail}'**
  String errorUnknownWithDetail(String detail);

  /// No description provided for @diaryLoadFailedGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not load your diary. Check your connection and try again.'**
  String get diaryLoadFailedGeneric;

  /// Greeting example with placeholder for Phase 0
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String welcomeUser(String name);

  /// No description provided for @diaryTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get diaryTodayTitle;

  /// No description provided for @diaryRelativeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get diaryRelativeYesterday;

  /// No description provided for @diaryRelativeTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get diaryRelativeTomorrow;

  /// No description provided for @diaryDayPreviousTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get diaryDayPreviousTooltip;

  /// No description provided for @diaryDayNextTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get diaryDayNextTooltip;

  /// Relative or absolute time label for diary refresh
  ///
  /// In en, this message translates to:
  /// **'Last updated {time}'**
  String diaryLastUpdated(String time);

  /// No description provided for @shellExitTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit app?'**
  String get shellExitTitle;

  /// No description provided for @shellExitBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the app?'**
  String get shellExitBody;

  /// No description provided for @shellExitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get shellExitConfirm;

  /// No description provided for @shellNavDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get shellNavDashboard;

  /// No description provided for @shellNavDiary.
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get shellNavDiary;

  /// No description provided for @shellNavAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get shellNavAdd;

  /// No description provided for @shellNavProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get shellNavProgress;

  /// No description provided for @shellNavMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get shellNavMore;

  /// No description provided for @shellAiCoachFabTooltip.
  ///
  /// In en, this message translates to:
  /// **'AI Coach'**
  String get shellAiCoachFabTooltip;

  /// No description provided for @mealBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealBreakfast;

  /// No description provided for @mealLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealLunch;

  /// No description provided for @mealDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealDinner;

  /// No description provided for @mealSnack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get mealSnack;

  /// No description provided for @dashboardReloadTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reload this day'**
  String get dashboardReloadTooltip;

  /// No description provided for @dashboardEditGoalsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit goals'**
  String get dashboardEditGoalsTooltip;

  /// No description provided for @goalsEditCalorieLabel.
  ///
  /// In en, this message translates to:
  /// **'Calorie goal'**
  String get goalsEditCalorieLabel;

  /// No description provided for @goalsEditSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save goals'**
  String get goalsEditSaveButton;

  /// No description provided for @goalsUpdatedSnack.
  ///
  /// In en, this message translates to:
  /// **'Goals updated successfully!'**
  String get goalsUpdatedSnack;

  /// No description provided for @goalsSavedLocalSnack.
  ///
  /// In en, this message translates to:
  /// **'Saved locally — check your connection to sync.'**
  String get goalsSavedLocalSnack;

  /// No description provided for @dashboardCoachTitle.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get dashboardCoachTitle;

  /// No description provided for @dashboardMacrosTitle.
  ///
  /// In en, this message translates to:
  /// **'Macros'**
  String get dashboardMacrosTitle;

  /// No description provided for @dashboardMacroProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get dashboardMacroProtein;

  /// No description provided for @dashboardMacroCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get dashboardMacroCarbs;

  /// No description provided for @dashboardMacroFats.
  ///
  /// In en, this message translates to:
  /// **'Fats'**
  String get dashboardMacroFats;

  /// No description provided for @dashboardCaloriesToday.
  ///
  /// In en, this message translates to:
  /// **'Calories (today)'**
  String get dashboardCaloriesToday;

  /// No description provided for @dashboardCaloriesForDate.
  ///
  /// In en, this message translates to:
  /// **'Calories ({date})'**
  String dashboardCaloriesForDate(String date);

  /// No description provided for @nutritionInsightViewingOtherDay.
  ///
  /// In en, this message translates to:
  /// **'You are viewing a past or future day. Use ← → or the calendar to move between days.'**
  String get nutritionInsightViewingOtherDay;

  /// No description provided for @nutritionInsightNoFoodsToday.
  ///
  /// In en, this message translates to:
  /// **'No foods logged yet today. Tap Add or pick a meal below to get started.'**
  String get nutritionInsightNoFoodsToday;

  /// No description provided for @nutritionInsightUnderCalories.
  ///
  /// In en, this message translates to:
  /// **'You are under your calorie goal so far. Add a balanced meal or snack if you are still hungry.'**
  String get nutritionInsightUnderCalories;

  /// No description provided for @nutritionInsightOverCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories are above today’s goal. Consider lighter options tomorrow or adjust goals in settings if this is intentional.'**
  String get nutritionInsightOverCalories;

  /// No description provided for @nutritionInsightProteinLowCarbsHigh.
  ///
  /// In en, this message translates to:
  /// **'Carbs are on track but protein is low. Lean meat, dairy, legumes, or tofu can help balance this day.'**
  String get nutritionInsightProteinLowCarbsHigh;

  /// No description provided for @nutritionInsightProteinHighFatLow.
  ///
  /// In en, this message translates to:
  /// **'Protein looks solid. If energy dips later, a small portion of healthy fats (nuts, olive oil) can help.'**
  String get nutritionInsightProteinHighFatLow;

  /// No description provided for @diaryInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get diaryInsightsTitle;

  /// No description provided for @diaryDeleteEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from diary?'**
  String get diaryDeleteEntryTitle;

  /// No description provided for @diaryDeleteEntryMessage.
  ///
  /// In en, this message translates to:
  /// **'“{foodName}” will be removed from this day.'**
  String diaryDeleteEntryMessage(String foodName);

  /// No description provided for @diaryDeleteEntryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get diaryDeleteEntryConfirm;

  /// No description provided for @diaryEmptyStateBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged for this day yet. Scroll down and tap Add food under any meal.'**
  String get diaryEmptyStateBody;

  /// No description provided for @diaryDaySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'This day'**
  String get diaryDaySummaryTitle;

  /// No description provided for @diaryKcalFraction.
  ///
  /// In en, this message translates to:
  /// **' / {goal} kcal'**
  String diaryKcalFraction(String goal);

  /// No description provided for @diaryMacroMiniLine.
  ///
  /// In en, this message translates to:
  /// **'{letter} {value} / {goal} g ({percent}%)'**
  String diaryMacroMiniLine(
    String letter,
    String value,
    String goal,
    String percent,
  );

  /// No description provided for @diaryMacroLetterProtein.
  ///
  /// In en, this message translates to:
  /// **'P'**
  String get diaryMacroLetterProtein;

  /// No description provided for @diaryMacroLetterCarbs.
  ///
  /// In en, this message translates to:
  /// **'C'**
  String get diaryMacroLetterCarbs;

  /// No description provided for @diaryMacroLetterFat.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get diaryMacroLetterFat;

  /// No description provided for @diaryMealSectionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No foods yet — tap Add food below to search and log.'**
  String get diaryMealSectionEmpty;

  /// No description provided for @diaryMealAddFood.
  ///
  /// In en, this message translates to:
  /// **'Add food'**
  String get diaryMealAddFood;

  /// No description provided for @diaryCaloriesUnit.
  ///
  /// In en, this message translates to:
  /// **'{n} cal'**
  String diaryCaloriesUnit(String n);

  /// No description provided for @foodAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add food'**
  String get foodAddTitle;

  /// No description provided for @foodAddManualTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add manually'**
  String get foodAddManualTooltip;

  /// No description provided for @foodMyMeals.
  ///
  /// In en, this message translates to:
  /// **'My meals'**
  String get foodMyMeals;

  /// No description provided for @foodMyRecipes.
  ///
  /// In en, this message translates to:
  /// **'My recipes'**
  String get foodMyRecipes;

  /// No description provided for @foodSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search foods (try: rice, egg, milk)…'**
  String get foodSearchHint;

  /// No description provided for @foodRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recently logged'**
  String get foodRecentTitle;

  /// No description provided for @foodRecentRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get foodRecentRefreshTooltip;

  /// No description provided for @foodRecentEmpty.
  ///
  /// In en, this message translates to:
  /// **'Foods you log will appear here — newest first — use + to log again and pick a meal.'**
  String get foodRecentEmpty;

  /// No description provided for @foodSearchLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load foods'**
  String get foodSearchLoadErrorTitle;

  /// No description provided for @foodSearchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get foodSearchNoResults;

  /// No description provided for @foodSearchNoResultsHint.
  ///
  /// In en, this message translates to:
  /// **'If the database is new, import or seed foods, or add a food with +.'**
  String get foodSearchNoResultsHint;

  /// No description provided for @foodLogTargetMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Log “{foodName}” to'**
  String foodLogTargetMealTitle(String foodName);

  /// No description provided for @foodLogNoPortionSnack.
  ///
  /// In en, this message translates to:
  /// **'No portion saved for this item — tap the row to set amount.'**
  String get foodLogNoPortionSnack;

  /// No description provided for @foodLogAddedSnack.
  ///
  /// In en, this message translates to:
  /// **'Added to {meal}'**
  String foodLogAddedSnack(String meal);

  /// No description provided for @foodLogFailedSnack.
  ///
  /// In en, this message translates to:
  /// **'Could not log — check connection and try again.'**
  String get foodLogFailedSnack;

  /// No description provided for @foodLogAgainTooltip.
  ///
  /// In en, this message translates to:
  /// **'Log again'**
  String get foodLogAgainTooltip;

  /// No description provided for @foodPortionGrams.
  ///
  /// In en, this message translates to:
  /// **'{grams} g'**
  String foodPortionGrams(String grams);

  /// No description provided for @foodPortionServings.
  ///
  /// In en, this message translates to:
  /// **'{count} × serving'**
  String foodPortionServings(String count);

  /// No description provided for @foodPortionDash.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get foodPortionDash;

  /// No description provided for @moreScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreScreenTitle;

  /// No description provided for @moreNoEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get moreNoEmail;

  /// No description provided for @moreAiCoachTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Coach'**
  String get moreAiCoachTitle;

  /// No description provided for @moreAiCoachSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Chat, meal ideas, daily & weekly reviews'**
  String get moreAiCoachSubtitle;

  /// No description provided for @moreSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Theme, profile, goals, account, about'**
  String get moreSettingsSubtitle;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @progressRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get progressRefreshTooltip;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @aiCoachTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Coach'**
  String get aiCoachTitle;

  /// No description provided for @aiCoachThreadTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat #{id}'**
  String aiCoachThreadTitle(String id);

  /// No description provided for @aiCoachNewChatTooltip.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get aiCoachNewChatTooltip;

  /// No description provided for @aiCoachEditOnboardingTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit onboarding'**
  String get aiCoachEditOnboardingTooltip;

  /// No description provided for @aiCoachSnackWaitReply.
  ///
  /// In en, this message translates to:
  /// **'Wait for the reply to finish before switching chats.'**
  String get aiCoachSnackWaitReply;

  /// No description provided for @aiCoachSnackOpenChatFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open that chat.'**
  String get aiCoachSnackOpenChatFailed;

  /// No description provided for @aiCoachOnboardingHeadline.
  ///
  /// In en, this message translates to:
  /// **'Meet your nutrition coach'**
  String get aiCoachOnboardingHeadline;

  /// No description provided for @aiCoachOnboardingBody.
  ///
  /// In en, this message translates to:
  /// **'Answer a few quick questions so the coach can tailor advice to your goal, food preferences, and habits.'**
  String get aiCoachOnboardingBody;

  /// No description provided for @aiCoachOnboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start onboarding'**
  String get aiCoachOnboardingStart;

  /// No description provided for @aiCoachInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask your coach…'**
  String get aiCoachInputHint;

  /// No description provided for @aiCoachSendTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get aiCoachSendTooltip;

  /// No description provided for @aiCoachQuick1Label.
  ///
  /// In en, this message translates to:
  /// **'How is my day?'**
  String get aiCoachQuick1Label;

  /// No description provided for @aiCoachQuick1Prompt.
  ///
  /// In en, this message translates to:
  /// **'How is today going for my goal?'**
  String get aiCoachQuick1Prompt;

  /// No description provided for @aiCoachQuick2Label.
  ///
  /// In en, this message translates to:
  /// **'Suggest food'**
  String get aiCoachQuick2Label;

  /// No description provided for @aiCoachQuick2Prompt.
  ///
  /// In en, this message translates to:
  /// **'What should I eat next to stay on track?'**
  String get aiCoachQuick2Prompt;

  /// No description provided for @aiCoachQuick3Label.
  ///
  /// In en, this message translates to:
  /// **'Review my week'**
  String get aiCoachQuick3Label;

  /// No description provided for @aiCoachQuick3Prompt.
  ///
  /// In en, this message translates to:
  /// **'Give me a quick review of my last 7 days.'**
  String get aiCoachQuick3Prompt;

  /// No description provided for @aiCoachQuick4Label.
  ///
  /// In en, this message translates to:
  /// **'Craving sweet'**
  String get aiCoachQuick4Label;

  /// No description provided for @aiCoachQuick4Prompt.
  ///
  /// In en, this message translates to:
  /// **'I\'m craving something sweet — what\'s a smart option?'**
  String get aiCoachQuick4Prompt;

  /// No description provided for @aiCoachDrawerTitle.
  ///
  /// In en, this message translates to:
  /// **'Coach chats'**
  String get aiCoachDrawerTitle;

  /// No description provided for @aiCoachDrawerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Folders keep chats out of the inbox until you expand them.'**
  String get aiCoachDrawerSubtitle;

  /// No description provided for @aiCoachDrawerNewChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get aiCoachDrawerNewChat;

  /// No description provided for @aiCoachDrawerNewFolderTooltip.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get aiCoachDrawerNewFolderTooltip;

  /// No description provided for @aiCoachInboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get aiCoachInboxTitle;

  /// No description provided for @aiCoachInboxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only chats that are not in a folder. Move one into a folder to remove it from here.'**
  String get aiCoachInboxSubtitle;

  /// No description provided for @aiCoachInboxEmptyNoFolders.
  ///
  /// In en, this message translates to:
  /// **'No chats yet. Start a new one above.'**
  String get aiCoachInboxEmptyNoFolders;

  /// No description provided for @aiCoachInboxEmptyWithFolders.
  ///
  /// In en, this message translates to:
  /// **'No unfiled chats — open a folder above to see the rest.'**
  String get aiCoachInboxEmptyWithFolders;

  /// No description provided for @aiCoachFoldersHeading.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get aiCoachFoldersHeading;

  /// No description provided for @aiCoachNoChatsYet.
  ///
  /// In en, this message translates to:
  /// **'No chats yet.\nTap “New chat” or create a folder.'**
  String get aiCoachNoChatsYet;

  /// No description provided for @aiCoachUnfiled.
  ///
  /// In en, this message translates to:
  /// **'Unfiled'**
  String get aiCoachUnfiled;

  /// No description provided for @aiCoachDrawerRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get aiCoachDrawerRename;

  /// No description provided for @aiCoachDrawerMoveToFolder.
  ///
  /// In en, this message translates to:
  /// **'Move to folder…'**
  String get aiCoachDrawerMoveToFolder;

  /// No description provided for @aiCoachFolderOptions.
  ///
  /// In en, this message translates to:
  /// **'Folder options'**
  String get aiCoachFolderOptions;

  /// No description provided for @aiCoachNewChatInFolder.
  ///
  /// In en, this message translates to:
  /// **'New chat in this folder'**
  String get aiCoachNewChatInFolder;

  /// No description provided for @aiCoachRenameChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename chat'**
  String get aiCoachRenameChatTitle;

  /// No description provided for @aiCoachRenameChatNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get aiCoachRenameChatNameLabel;

  /// No description provided for @aiCoachRenameChatNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Meal planning'**
  String get aiCoachRenameChatNameHint;

  /// No description provided for @aiCoachRenameFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename folder'**
  String get aiCoachRenameFolderTitle;

  /// No description provided for @aiCoachNewFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get aiCoachNewFolderTitle;

  /// No description provided for @aiCoachFolderNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get aiCoachFolderNameLabel;

  /// No description provided for @aiCoachDeleteFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete folder?'**
  String get aiCoachDeleteFolderTitle;

  /// No description provided for @aiCoachDeleteFolderBody.
  ///
  /// In en, this message translates to:
  /// **'“{name}” will be removed. Chats inside move to Unfiled.'**
  String aiCoachDeleteFolderBody(String name);

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @aiCoachSnackRenameChatFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not rename chat.'**
  String get aiCoachSnackRenameChatFailed;

  /// No description provided for @aiCoachSnackCreateFolderFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create folder.'**
  String get aiCoachSnackCreateFolderFailed;

  /// No description provided for @aiCoachSnackRenameFolderFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not rename folder.'**
  String get aiCoachSnackRenameFolderFailed;

  /// No description provided for @aiCoachSnackDeleteFolderFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete folder.'**
  String get aiCoachSnackDeleteFolderFailed;

  /// Subtitle under a thread in the AI coach drawer
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No messages} one{1 message} other{{count} messages}}'**
  String aiCoachThreadMessages(int count);

  /// No description provided for @aiCoachTimeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get aiCoachTimeJustNow;

  /// No description provided for @aiCoachTimeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String aiCoachTimeMinutesAgo(String minutes);

  /// No description provided for @aiCoachTimeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String aiCoachTimeHoursAgo(String hours);

  /// No description provided for @aiCoachTimeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String aiCoachTimeDaysAgo(String days);

  /// No description provided for @aiCoachSnackMoveChatFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not move chat. Check your connection and try again.'**
  String get aiCoachSnackMoveChatFailed;

  /// No description provided for @aiCoachSnackWaitReplyFirst.
  ///
  /// In en, this message translates to:
  /// **'Wait for the reply to finish first.'**
  String get aiCoachSnackWaitReplyFirst;

  /// No description provided for @aiCoachMoveChatSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Move \"{chatTitle}\"'**
  String aiCoachMoveChatSheetTitle(String chatTitle);

  /// No description provided for @aiCoachDeleteFolderMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Delete folder'**
  String get aiCoachDeleteFolderMenuItem;

  /// No description provided for @aiCoachFolderEmptyInboxHint.
  ///
  /// In en, this message translates to:
  /// **'Move a chat here from the inbox, or start a new one above.'**
  String get aiCoachFolderEmptyInboxHint;

  /// No description provided for @aiCoachFolderSubtitleThreads.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Empty — tap to open} one{1 chat} other{{count} chats}}'**
  String aiCoachFolderSubtitleThreads(int count);

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLoginTitle;

  /// No description provided for @authSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authSignInButton;

  /// No description provided for @authRegisterPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get authRegisterPrompt;

  /// No description provided for @authLoginFailedSnack.
  ///
  /// In en, this message translates to:
  /// **'Log in failed. Check your email and password.'**
  String get authLoginFailedSnack;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authValidationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authValidationEmailRequired;

  /// No description provided for @authValidationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get authValidationEmailInvalid;

  /// No description provided for @authValidationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authValidationPasswordRequired;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authForgotPasswordEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter an email address first'**
  String get authForgotPasswordEnterEmail;

  /// No description provided for @authForgotPasswordSnackSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent'**
  String get authForgotPasswordSnackSent;

  /// No description provided for @authForgotPasswordSnackFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send reset email — try again later'**
  String get authForgotPasswordSnackFailed;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started'**
  String get authRegisterSubtitle;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authRegisterButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegisterButton;

  /// No description provided for @authRegisterFailedSnack.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Try again.'**
  String get authRegisterFailedSnack;

  /// No description provided for @authValidationPasswordMin6.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get authValidationPasswordMin6;

  /// No description provided for @authValidationConfirmRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get authValidationConfirmRequired;

  /// No description provided for @authValidationPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get authValidationPasswordsMismatch;

  /// No description provided for @authLoginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get authLoginPrompt;

  /// No description provided for @progressProfileYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get progressProfileYourProfile;

  /// No description provided for @progressProfileSubtitleEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add a few details to unlock personalised targets.'**
  String get progressProfileSubtitleEmpty;

  /// No description provided for @progressCommonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get progressCommonEdit;

  /// No description provided for @progressProfileAgeYears.
  ///
  /// In en, this message translates to:
  /// **'{years} yr'**
  String progressProfileAgeYears(String years);

  /// No description provided for @progressWeightSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get progressWeightSectionTitle;

  /// No description provided for @progressWeightLogButton.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get progressWeightLogButton;

  /// No description provided for @progressWeightCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get progressWeightCurrent;

  /// No description provided for @progressWeightTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get progressWeightTarget;

  /// No description provided for @progressWeightChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get progressWeightChange;

  /// No description provided for @progressWeightToGo.
  ///
  /// In en, this message translates to:
  /// **'To go'**
  String get progressWeightToGo;

  /// No description provided for @progressWeightOnTarget.
  ///
  /// In en, this message translates to:
  /// **'On target'**
  String get progressWeightOnTarget;

  /// No description provided for @progressWeightEmpty.
  ///
  /// In en, this message translates to:
  /// **'No weight logged yet.\nTap \"Log\" to add your first measurement.'**
  String get progressWeightEmpty;

  /// No description provided for @progressIntakeToday.
  ///
  /// In en, this message translates to:
  /// **'Intake · today'**
  String get progressIntakeToday;

  /// No description provided for @progressIntakeDate.
  ///
  /// In en, this message translates to:
  /// **'Intake · {date}'**
  String progressIntakeDate(String date);

  /// No description provided for @progressEstimatedTdee.
  ///
  /// In en, this message translates to:
  /// **'Estimated TDEE'**
  String get progressEstimatedTdee;

  /// No description provided for @progressBmiStatLabel.
  ///
  /// In en, this message translates to:
  /// **'BMI · {category}'**
  String progressBmiStatLabel(String category);

  /// No description provided for @progressBmiCategoryUnderweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get progressBmiCategoryUnderweight;

  /// No description provided for @progressBmiCategoryHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy range'**
  String get progressBmiCategoryHealthy;

  /// No description provided for @progressBmiCategoryOverweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get progressBmiCategoryOverweight;

  /// No description provided for @progressBmiCategoryObese.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get progressBmiCategoryObese;

  /// No description provided for @progressHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get progressHistoryTitle;

  /// No description provided for @progressDeleteWeightTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get progressDeleteWeightTitle;

  /// No description provided for @progressDeleteWeightMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove the weight log for {date}?'**
  String progressDeleteWeightMessage(String date);

  /// No description provided for @progressWeightLogSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Log weight'**
  String get progressWeightLogSheetTitle;

  /// No description provided for @progressWeightFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get progressWeightFieldLabel;

  /// No description provided for @progressWeightSuffixKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get progressWeightSuffixKg;

  /// No description provided for @progressWeightDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get progressWeightDateLabel;

  /// No description provided for @progressWeightNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get progressWeightNoteLabel;

  /// No description provided for @progressWeightSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get progressWeightSave;

  /// No description provided for @progressWeightSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get progressWeightSaving;

  /// No description provided for @progressWeightInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid weight (0–500 kg)'**
  String get progressWeightInvalid;

  /// No description provided for @progressWeightLoggedSnack.
  ///
  /// In en, this message translates to:
  /// **'Weight logged'**
  String get progressWeightLoggedSnack;

  /// No description provided for @progressWeightSaveFailedSnack.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Try again.'**
  String get progressWeightSaveFailedSnack;

  /// No description provided for @progressChartTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'target'**
  String get progressChartTargetLabel;

  /// No description provided for @progressBmiChipPrefix.
  ///
  /// In en, this message translates to:
  /// **'BMI {value}'**
  String progressBmiChipPrefix(String value);

  /// No description provided for @mealServingDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Serving size'**
  String get mealServingDialogTitle;

  /// No description provided for @mealServingAmountG.
  ///
  /// In en, this message translates to:
  /// **'Amount (g)'**
  String get mealServingAmountG;

  /// No description provided for @mealRecipeDialogAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get mealRecipeDialogAdd;

  /// No description provided for @mealDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get mealDialogCancel;

  /// No description provided for @createMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Create meal'**
  String get createMealTitle;

  /// No description provided for @createMealNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal name'**
  String get createMealNameLabel;

  /// No description provided for @createMealFoodItemsHeader.
  ///
  /// In en, this message translates to:
  /// **'Food items'**
  String get createMealFoodItemsHeader;

  /// No description provided for @createMealAddFoodButton.
  ///
  /// In en, this message translates to:
  /// **'Add food'**
  String get createMealAddFoodButton;

  /// No description provided for @createMealEmptyItems.
  ///
  /// In en, this message translates to:
  /// **'No items added yet'**
  String get createMealEmptyItems;

  /// No description provided for @createMealTotalNutrition.
  ///
  /// In en, this message translates to:
  /// **'Total nutrition'**
  String get createMealTotalNutrition;

  /// No description provided for @createMealSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save meal'**
  String get createMealSaveButton;

  /// No description provided for @createMealSnackNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a meal name'**
  String get createMealSnackNameRequired;

  /// No description provided for @createMealSnackItemsRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least one food'**
  String get createMealSnackItemsRequired;

  /// No description provided for @createMealSnackSaved.
  ///
  /// In en, this message translates to:
  /// **'Meal saved'**
  String get createMealSnackSaved;

  /// No description provided for @createMealItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{grams} g • {cal} cal'**
  String createMealItemSubtitle(String grams, String cal);

  /// No description provided for @createRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Create recipe'**
  String get createRecipeTitle;

  /// No description provided for @recipeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipe name'**
  String get recipeNameLabel;

  /// No description provided for @recipeDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get recipeDescriptionLabel;

  /// No description provided for @recipeServingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of servings'**
  String get recipeServingsLabel;

  /// No description provided for @recipeIngredientsHeader.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get recipeIngredientsHeader;

  /// No description provided for @recipeAddIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient'**
  String get recipeAddIngredient;

  /// No description provided for @recipeEmptyIngredients.
  ///
  /// In en, this message translates to:
  /// **'No ingredients added yet'**
  String get recipeEmptyIngredients;

  /// No description provided for @recipeTotalNutritionServings.
  ///
  /// In en, this message translates to:
  /// **'Total nutrition ({count} servings)'**
  String recipeTotalNutritionServings(String count);

  /// No description provided for @recipeTotalCaloriesLine.
  ///
  /// In en, this message translates to:
  /// **'Total calories: {n}'**
  String recipeTotalCaloriesLine(String n);

  /// No description provided for @recipeTotalProteinLine.
  ///
  /// In en, this message translates to:
  /// **'Total protein: {n} g'**
  String recipeTotalProteinLine(String n);

  /// No description provided for @recipeTotalCarbsLine.
  ///
  /// In en, this message translates to:
  /// **'Total carbs: {n} g'**
  String recipeTotalCarbsLine(String n);

  /// No description provided for @recipeTotalFatLine.
  ///
  /// In en, this message translates to:
  /// **'Total fat: {n} g'**
  String recipeTotalFatLine(String n);

  /// No description provided for @recipePerServingHeader.
  ///
  /// In en, this message translates to:
  /// **'Per serving'**
  String get recipePerServingHeader;

  /// No description provided for @recipePerServingCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories: {n}'**
  String recipePerServingCalories(String n);

  /// No description provided for @recipePerServingProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein: {n} g'**
  String recipePerServingProtein(String n);

  /// No description provided for @recipePerServingCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs: {n} g'**
  String recipePerServingCarbs(String n);

  /// No description provided for @recipePerServingFat.
  ///
  /// In en, this message translates to:
  /// **'Fat: {n} g'**
  String recipePerServingFat(String n);

  /// No description provided for @recipeSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save recipe'**
  String get recipeSaveButton;

  /// No description provided for @recipeSnackNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a recipe name'**
  String get recipeSnackNameRequired;

  /// No description provided for @recipeSnackIngredientsRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least one ingredient'**
  String get recipeSnackIngredientsRequired;

  /// No description provided for @recipeSnackServingsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number of servings'**
  String get recipeSnackServingsInvalid;

  /// No description provided for @recipeSnackSaved.
  ///
  /// In en, this message translates to:
  /// **'Recipe saved'**
  String get recipeSnackSaved;

  /// No description provided for @recipeIngredientSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{grams} g • {cal} cal'**
  String recipeIngredientSubtitle(String grams, String cal);

  /// No description provided for @myMealsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'My meals'**
  String get myMealsScreenTitle;

  /// No description provided for @myMealsCreateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create meal'**
  String get myMealsCreateTooltip;

  /// No description provided for @myMealsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved meals yet'**
  String get myMealsEmpty;

  /// No description provided for @myMealsCreateFirst.
  ///
  /// In en, this message translates to:
  /// **'Create your first meal'**
  String get myMealsCreateFirst;

  /// No description provided for @myMealsCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{cal} cal • P: {p} g • C: {c} g • F: {f} g'**
  String myMealsCardSubtitle(String cal, String p, String c, String f);

  /// No description provided for @myMealsAddToDiaryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add to diary'**
  String get myMealsAddToDiaryTooltip;

  /// No description provided for @myMealsDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get myMealsDeleteTooltip;

  /// No description provided for @myMealsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete meal?'**
  String get myMealsDeleteTitle;

  /// No description provided for @myMealsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String myMealsDeleteConfirm(String name);

  /// No description provided for @myMealsAddedSnack.
  ///
  /// In en, this message translates to:
  /// **'{name} added to diary!'**
  String myMealsAddedSnack(String name);

  /// No description provided for @myMealsPartialSnack.
  ///
  /// In en, this message translates to:
  /// **'Added {added} / {total} items ({failed} failed — foods may be missing).'**
  String myMealsPartialSnack(String added, String total, String failed);

  /// No description provided for @myRecipesScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'My recipes'**
  String get myRecipesScreenTitle;

  /// No description provided for @myRecipesCreateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create recipe'**
  String get myRecipesCreateTooltip;

  /// No description provided for @myRecipesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved recipes yet'**
  String get myRecipesEmpty;

  /// No description provided for @myRecipesCreateFirst.
  ///
  /// In en, this message translates to:
  /// **'Create your first recipe'**
  String get myRecipesCreateFirst;

  /// No description provided for @myRecipesCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{cal} cal/serving • {servings} servings • P: {p} g'**
  String myRecipesCardSubtitle(String cal, String servings, String p);

  /// No description provided for @myRecipesAddedSnack.
  ///
  /// In en, this message translates to:
  /// **'{name} (1 serving) added to diary!'**
  String myRecipesAddedSnack(String name);

  /// No description provided for @myRecipesPartialSnack.
  ///
  /// In en, this message translates to:
  /// **'{added} / {total} ingredients logged ({failed} failed — foods may be missing).'**
  String myRecipesPartialSnack(String added, String total, String failed);

  /// No description provided for @myRecipesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete recipe?'**
  String get myRecipesDeleteTitle;

  /// No description provided for @myRecipesDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String myRecipesDeleteConfirm(String name);

  /// No description provided for @addMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Add meal'**
  String get addMealTitle;

  /// No description provided for @addMealSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search for food'**
  String get addMealSearchLabel;

  /// No description provided for @addMealSearchHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. rice, chicken, apple'**
  String get addMealSearchHint;

  /// No description provided for @addMealNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get addMealNoResults;

  /// No description provided for @addMealSearchResultLine.
  ///
  /// In en, this message translates to:
  /// **'{cal} cal/100g • P: {p} g • C: {c} g • F: {f} g'**
  String addMealSearchResultLine(String cal, String p, String c, String f);

  /// No description provided for @addMealMealTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal type'**
  String get addMealMealTypeLabel;

  /// No description provided for @addMealSelectMealType.
  ///
  /// In en, this message translates to:
  /// **'Select a meal type'**
  String get addMealSelectMealType;

  /// No description provided for @addMealFoodNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Food name'**
  String get addMealFoodNameLabel;

  /// No description provided for @addMealFoodNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a food name'**
  String get addMealFoodNameRequired;

  /// No description provided for @addMealCaloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get addMealCaloriesLabel;

  /// No description provided for @addMealCaloriesRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter calories'**
  String get addMealCaloriesRequired;

  /// No description provided for @addMealCaloriesInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get addMealCaloriesInvalid;

  /// No description provided for @addMealProteinLabel.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get addMealProteinLabel;

  /// No description provided for @addMealProteinRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter protein'**
  String get addMealProteinRequired;

  /// No description provided for @addMealProteinInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get addMealProteinInvalid;

  /// No description provided for @addMealCarbsLabel.
  ///
  /// In en, this message translates to:
  /// **'Carbs (g)'**
  String get addMealCarbsLabel;

  /// No description provided for @addMealCarbsRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter carbs'**
  String get addMealCarbsRequired;

  /// No description provided for @addMealCarbsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get addMealCarbsInvalid;

  /// No description provided for @addMealFatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Fat (g)'**
  String get addMealFatsLabel;

  /// No description provided for @addMealFatsRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter fat'**
  String get addMealFatsRequired;

  /// No description provided for @addMealFatsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get addMealFatsInvalid;

  /// No description provided for @addMealSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Add meal'**
  String get addMealSubmitButton;

  /// No description provided for @addMealSuccessSnack.
  ///
  /// In en, this message translates to:
  /// **'Meal logged locally'**
  String get addMealSuccessSnack;

  /// No description provided for @foodDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Food details'**
  String get foodDetailTitle;

  /// No description provided for @foodDetailPer100.
  ///
  /// In en, this message translates to:
  /// **'Per 100 g'**
  String get foodDetailPer100;

  /// No description provided for @foodDetailPortionTitle.
  ///
  /// In en, this message translates to:
  /// **'Portion'**
  String get foodDetailPortionTitle;

  /// No description provided for @foodDetailMealTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal type'**
  String get foodDetailMealTypeLabel;

  /// No description provided for @foodDetailServingSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Serving size ({unit})'**
  String foodDetailServingSizeLabel(String unit);

  /// No description provided for @foodDetailServingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get foodDetailServingsLabel;

  /// No description provided for @foodDetailTotalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Totals'**
  String get foodDetailTotalsTitle;

  /// No description provided for @foodDetailValidationPortions.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid serving size and servings'**
  String get foodDetailValidationPortions;

  /// No description provided for @foodDetailSaveFailedSnack.
  ///
  /// In en, this message translates to:
  /// **'Could not save to diary. Check your connection.'**
  String get foodDetailSaveFailedSnack;

  /// No description provided for @foodDetailAddedSnack.
  ///
  /// In en, this message translates to:
  /// **'Added to diary'**
  String get foodDetailAddedSnack;

  /// No description provided for @foodDetailAddToDiary.
  ///
  /// In en, this message translates to:
  /// **'Add to diary'**
  String get foodDetailAddToDiary;

  /// No description provided for @foodDetailSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get foodDetailSaving;

  /// No description provided for @foodManualTitle.
  ///
  /// In en, this message translates to:
  /// **'Add food manually'**
  String get foodManualTitle;

  /// No description provided for @foodManualSectionBasics.
  ///
  /// In en, this message translates to:
  /// **'Basics'**
  String get foodManualSectionBasics;

  /// No description provided for @foodManualSectionPortion.
  ///
  /// In en, this message translates to:
  /// **'Portion'**
  String get foodManualSectionPortion;

  /// No description provided for @foodManualSectionNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition (per serving)'**
  String get foodManualSectionNutrition;

  /// No description provided for @foodManualFoodNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Food name'**
  String get foodManualFoodNameLabel;

  /// No description provided for @foodManualBrandLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand (optional)'**
  String get foodManualBrandLabel;

  /// No description provided for @foodManualServingSizeG.
  ///
  /// In en, this message translates to:
  /// **'Serving size (g)'**
  String get foodManualServingSizeG;

  /// No description provided for @foodManualValidationName.
  ///
  /// In en, this message translates to:
  /// **'Enter a food name'**
  String get foodManualValidationName;

  /// No description provided for @foodManualValidationCalories.
  ///
  /// In en, this message translates to:
  /// **'Enter calories'**
  String get foodManualValidationCalories;

  /// No description provided for @foodManualSaveFailedGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not save food. Try again.'**
  String get foodManualSaveFailedGeneric;

  /// No description provided for @foodManualSavedAndLoggedSnack.
  ///
  /// In en, this message translates to:
  /// **'Food saved and added to diary!'**
  String get foodManualSavedAndLoggedSnack;

  /// No description provided for @foodManualSavedLogFailedSnack.
  ///
  /// In en, this message translates to:
  /// **'Food saved — diary log failed.'**
  String get foodManualSavedLogFailedSnack;

  /// No description provided for @foodManualAddToDiary.
  ///
  /// In en, this message translates to:
  /// **'Add to diary'**
  String get foodManualAddToDiary;

  /// No description provided for @foodManualSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get foodManualSaving;

  /// No description provided for @foodEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit food entry'**
  String get foodEditTitle;

  /// No description provided for @foodEditMealTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal type'**
  String get foodEditMealTypeLabel;

  /// No description provided for @foodEditFoodNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Food name'**
  String get foodEditFoodNameLabel;

  /// No description provided for @foodEditServingSizeG.
  ///
  /// In en, this message translates to:
  /// **'Serving size (g)'**
  String get foodEditServingSizeG;

  /// No description provided for @foodEditServingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of servings'**
  String get foodEditServingsLabel;

  /// No description provided for @foodEditCaloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get foodEditCaloriesLabel;

  /// No description provided for @foodEditProteinLabel.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get foodEditProteinLabel;

  /// No description provided for @foodEditCarbsLabel.
  ///
  /// In en, this message translates to:
  /// **'Carbs (g)'**
  String get foodEditCarbsLabel;

  /// No description provided for @foodEditFatLabel.
  ///
  /// In en, this message translates to:
  /// **'Fat (g)'**
  String get foodEditFatLabel;

  /// No description provided for @foodEditSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get foodEditSaveButton;

  /// No description provided for @foodEditSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get foodEditSaving;

  /// No description provided for @foodEditMealTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a meal type'**
  String get foodEditMealTypeRequired;

  /// No description provided for @foodEditNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a food name'**
  String get foodEditNameRequired;

  /// No description provided for @foodEditCaloriesRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter calories'**
  String get foodEditCaloriesRequired;

  /// No description provided for @foodEditUpdatedSnack.
  ///
  /// In en, this message translates to:
  /// **'Entry updated'**
  String get foodEditUpdatedSnack;

  /// No description provided for @foodEditSaveFailedSnack.
  ///
  /// In en, this message translates to:
  /// **'Could not save changes'**
  String get foodEditSaveFailedSnack;

  /// No description provided for @aiOnboardingIntro.
  ///
  /// In en, this message translates to:
  /// **'Answer what applies. You can combine goals (for example lose weight + gain muscle), and use the text boxes when the options don\'t cover everything.'**
  String get aiOnboardingIntro;

  /// No description provided for @aiOnboardingAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Coach setup'**
  String get aiOnboardingAppBarTitle;

  /// No description provided for @aiOnboardingSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get aiOnboardingSaveDraft;

  /// No description provided for @aiOnboardingFinishButton.
  ///
  /// In en, this message translates to:
  /// **'Finish & start chatting'**
  String get aiOnboardingFinishButton;

  /// No description provided for @aiOnboardingSnackRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one goal, approach, and diet pattern to finish.'**
  String get aiOnboardingSnackRequiredFields;

  /// No description provided for @aiOnboardingSnackSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Check your connection and try again.'**
  String get aiOnboardingSnackSaveFailed;

  /// No description provided for @aiOnboardingSnackDraftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved.'**
  String get aiOnboardingSnackDraftSaved;

  /// No description provided for @aiOnboardingSectionGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your goals'**
  String get aiOnboardingSectionGoalsTitle;

  /// No description provided for @aiOnboardingSectionGoalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick one or more'**
  String get aiOnboardingSectionGoalsSubtitle;

  /// No description provided for @aiOnboardingNoteMainGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Any other goal or context?'**
  String get aiOnboardingNoteMainGoalLabel;

  /// No description provided for @aiOnboardingNoteMainGoalHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. half-marathon in 12 weeks'**
  String get aiOnboardingNoteMainGoalHint;

  /// No description provided for @aiOnboardingSectionApproachTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you want to approach it?'**
  String get aiOnboardingSectionApproachTitle;

  /// No description provided for @aiOnboardingSectionTrainingTitle.
  ///
  /// In en, this message translates to:
  /// **'Training & activity'**
  String get aiOnboardingSectionTrainingTitle;

  /// No description provided for @aiOnboardingSectionTrainingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shapes calorie and protein targets'**
  String get aiOnboardingSectionTrainingSubtitle;

  /// No description provided for @aiOnboardingLabelTrainingSessionsPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Training sessions per week'**
  String get aiOnboardingLabelTrainingSessionsPerWeek;

  /// No description provided for @aiOnboardingLabelTrainingTypes.
  ///
  /// In en, this message translates to:
  /// **'Types of training (pick all that apply)'**
  String get aiOnboardingLabelTrainingTypes;

  /// No description provided for @aiOnboardingLabelSessionIntensity.
  ///
  /// In en, this message translates to:
  /// **'Typical session intensity'**
  String get aiOnboardingLabelSessionIntensity;

  /// No description provided for @aiOnboardingLabelJobActivity.
  ///
  /// In en, this message translates to:
  /// **'Daytime / job activity'**
  String get aiOnboardingLabelJobActivity;

  /// No description provided for @aiOnboardingLabelDailySteps.
  ///
  /// In en, this message translates to:
  /// **'Average daily steps'**
  String get aiOnboardingLabelDailySteps;

  /// No description provided for @aiOnboardingNoteTrainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Training notes'**
  String get aiOnboardingNoteTrainingLabel;

  /// No description provided for @aiOnboardingNoteTrainingHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. push/pull/legs split'**
  String get aiOnboardingNoteTrainingHint;

  /// No description provided for @aiOnboardingSectionDietTitle.
  ///
  /// In en, this message translates to:
  /// **'Diet pattern'**
  String get aiOnboardingSectionDietTitle;

  /// No description provided for @aiOnboardingNoteDietaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Dietary notes / restrictions'**
  String get aiOnboardingNoteDietaryLabel;

  /// No description provided for @aiOnboardingNoteDietaryHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. low-FODMAP, halal, fasting schedule'**
  String get aiOnboardingNoteDietaryHint;

  /// No description provided for @aiOnboardingLabelAllergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies or intolerances'**
  String get aiOnboardingLabelAllergies;

  /// No description provided for @aiOnboardingHintAllergies.
  ///
  /// In en, this message translates to:
  /// **'e.g. peanuts, lactose'**
  String get aiOnboardingHintAllergies;

  /// No description provided for @aiOnboardingLabelDisliked.
  ///
  /// In en, this message translates to:
  /// **'Disliked foods'**
  String get aiOnboardingLabelDisliked;

  /// No description provided for @aiOnboardingHintDisliked.
  ///
  /// In en, this message translates to:
  /// **'e.g. mushrooms, liver'**
  String get aiOnboardingHintDisliked;

  /// No description provided for @aiOnboardingLabelFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorite foods'**
  String get aiOnboardingLabelFavorites;

  /// No description provided for @aiOnboardingHintFavorites.
  ///
  /// In en, this message translates to:
  /// **'e.g. chicken, rice, yogurt'**
  String get aiOnboardingHintFavorites;

  /// No description provided for @aiOnboardingLabelCuisines.
  ///
  /// In en, this message translates to:
  /// **'Cuisines you enjoy'**
  String get aiOnboardingLabelCuisines;

  /// No description provided for @aiOnboardingHintCuisines.
  ///
  /// In en, this message translates to:
  /// **'e.g. Italian, Japanese'**
  String get aiOnboardingHintCuisines;

  /// No description provided for @aiOnboardingLabelEatingOut.
  ///
  /// In en, this message translates to:
  /// **'Eating out frequency'**
  String get aiOnboardingLabelEatingOut;

  /// No description provided for @aiOnboardingSectionCookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Cooking & budget'**
  String get aiOnboardingSectionCookingTitle;

  /// No description provided for @aiOnboardingLabelCookingPreference.
  ///
  /// In en, this message translates to:
  /// **'Cooking preference'**
  String get aiOnboardingLabelCookingPreference;

  /// No description provided for @aiOnboardingLabelBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget sensitivity'**
  String get aiOnboardingLabelBudget;

  /// No description provided for @aiOnboardingLabelMealsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Meals per day'**
  String get aiOnboardingLabelMealsPerDay;

  /// No description provided for @aiOnboardingSectionLifestyleTitle.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle & recovery'**
  String get aiOnboardingSectionLifestyleTitle;

  /// No description provided for @aiOnboardingSectionLifestyleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Energy, cravings, adherence'**
  String get aiOnboardingSectionLifestyleSubtitle;

  /// No description provided for @aiOnboardingLabelSleep.
  ///
  /// In en, this message translates to:
  /// **'Average sleep'**
  String get aiOnboardingLabelSleep;

  /// No description provided for @aiOnboardingLabelStress.
  ///
  /// In en, this message translates to:
  /// **'Typical stress level'**
  String get aiOnboardingLabelStress;

  /// No description provided for @aiOnboardingLabelWater.
  ///
  /// In en, this message translates to:
  /// **'Water intake'**
  String get aiOnboardingLabelWater;

  /// No description provided for @aiOnboardingLabelAlcohol.
  ///
  /// In en, this message translates to:
  /// **'Alcohol frequency'**
  String get aiOnboardingLabelAlcohol;

  /// No description provided for @aiOnboardingSectionStrugglesTitle.
  ///
  /// In en, this message translates to:
  /// **'What tends to get in the way?'**
  String get aiOnboardingSectionStrugglesTitle;

  /// No description provided for @aiOnboardingLabelBiggestStruggles.
  ///
  /// In en, this message translates to:
  /// **'Biggest struggles (pick any)'**
  String get aiOnboardingLabelBiggestStruggles;

  /// No description provided for @aiOnboardingNoteStruggleLabel.
  ///
  /// In en, this message translates to:
  /// **'Anything else that holds you back?'**
  String get aiOnboardingNoteStruggleLabel;

  /// No description provided for @aiOnboardingNoteStruggleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. shift work, weekends'**
  String get aiOnboardingNoteStruggleHint;

  /// No description provided for @aiOnboardingLabelStruggleWhen.
  ///
  /// In en, this message translates to:
  /// **'When is it hardest?'**
  String get aiOnboardingLabelStruggleWhen;

  /// No description provided for @aiOnboardingSectionMotivationTitle.
  ///
  /// In en, this message translates to:
  /// **'Motivation & structure'**
  String get aiOnboardingSectionMotivationTitle;

  /// No description provided for @aiOnboardingLabelMotivation.
  ///
  /// In en, this message translates to:
  /// **'Motivation level'**
  String get aiOnboardingLabelMotivation;

  /// No description provided for @aiOnboardingLabelStructure.
  ///
  /// In en, this message translates to:
  /// **'How much structure do you want?'**
  String get aiOnboardingLabelStructure;

  /// No description provided for @aiOnboardingSectionCoachToneTitle.
  ///
  /// In en, this message translates to:
  /// **'Coach tone'**
  String get aiOnboardingSectionCoachToneTitle;

  /// No description provided for @aiOnboardingGoalLoseWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose weight'**
  String get aiOnboardingGoalLoseWeight;

  /// No description provided for @aiOnboardingGoalGainMuscle.
  ///
  /// In en, this message translates to:
  /// **'Gain muscle'**
  String get aiOnboardingGoalGainMuscle;

  /// No description provided for @aiOnboardingGoalMaintain.
  ///
  /// In en, this message translates to:
  /// **'Maintain weight'**
  String get aiOnboardingGoalMaintain;

  /// No description provided for @aiOnboardingGoalEatHealthier.
  ///
  /// In en, this message translates to:
  /// **'Eat healthier'**
  String get aiOnboardingGoalEatHealthier;

  /// No description provided for @aiOnboardingGoalImproveEnergy.
  ///
  /// In en, this message translates to:
  /// **'More energy'**
  String get aiOnboardingGoalImproveEnergy;

  /// No description provided for @aiOnboardingGoalImprovePerformance.
  ///
  /// In en, this message translates to:
  /// **'Athletic performance'**
  String get aiOnboardingGoalImprovePerformance;

  /// No description provided for @aiOnboardingGoalImproveConsistency.
  ///
  /// In en, this message translates to:
  /// **'Be consistent'**
  String get aiOnboardingGoalImproveConsistency;

  /// No description provided for @aiOnboardingApproachAggressive.
  ///
  /// In en, this message translates to:
  /// **'Aggressive'**
  String get aiOnboardingApproachAggressive;

  /// No description provided for @aiOnboardingApproachBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get aiOnboardingApproachBalanced;

  /// No description provided for @aiOnboardingApproachFlexible.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get aiOnboardingApproachFlexible;

  /// No description provided for @aiOnboardingApproachSustainable.
  ///
  /// In en, this message translates to:
  /// **'Slow & sustainable'**
  String get aiOnboardingApproachSustainable;

  /// No description provided for @aiOnboardingTrainingSessions7Plus.
  ///
  /// In en, this message translates to:
  /// **'7+'**
  String get aiOnboardingTrainingSessions7Plus;

  /// No description provided for @aiOnboardingTrainingLifting.
  ///
  /// In en, this message translates to:
  /// **'Weight lifting'**
  String get aiOnboardingTrainingLifting;

  /// No description provided for @aiOnboardingTrainingCardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get aiOnboardingTrainingCardio;

  /// No description provided for @aiOnboardingTrainingHiit.
  ///
  /// In en, this message translates to:
  /// **'HIIT / intervals'**
  String get aiOnboardingTrainingHiit;

  /// No description provided for @aiOnboardingTrainingSports.
  ///
  /// In en, this message translates to:
  /// **'Team sports'**
  String get aiOnboardingTrainingSports;

  /// No description provided for @aiOnboardingTrainingRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get aiOnboardingTrainingRunning;

  /// No description provided for @aiOnboardingTrainingCycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get aiOnboardingTrainingCycling;

  /// No description provided for @aiOnboardingTrainingSwimming.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get aiOnboardingTrainingSwimming;

  /// No description provided for @aiOnboardingTrainingYoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga / mobility'**
  String get aiOnboardingTrainingYoga;

  /// No description provided for @aiOnboardingTrainingWalking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get aiOnboardingTrainingWalking;

  /// No description provided for @aiOnboardingTrainingNone.
  ///
  /// In en, this message translates to:
  /// **'None currently'**
  String get aiOnboardingTrainingNone;

  /// No description provided for @aiOnboardingIntensityLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get aiOnboardingIntensityLight;

  /// No description provided for @aiOnboardingIntensityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get aiOnboardingIntensityModerate;

  /// No description provided for @aiOnboardingIntensityHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get aiOnboardingIntensityHard;

  /// No description provided for @aiOnboardingIntensityVeryHard.
  ///
  /// In en, this message translates to:
  /// **'Very hard'**
  String get aiOnboardingIntensityVeryHard;

  /// No description provided for @aiOnboardingJobDesk.
  ///
  /// In en, this message translates to:
  /// **'Mostly at a desk'**
  String get aiOnboardingJobDesk;

  /// No description provided for @aiOnboardingJobMostlySeated.
  ///
  /// In en, this message translates to:
  /// **'Seated with some movement'**
  String get aiOnboardingJobMostlySeated;

  /// No description provided for @aiOnboardingJobOnFeet.
  ///
  /// In en, this message translates to:
  /// **'On my feet a lot'**
  String get aiOnboardingJobOnFeet;

  /// No description provided for @aiOnboardingJobPhysicalLabor.
  ///
  /// In en, this message translates to:
  /// **'Physical labor'**
  String get aiOnboardingJobPhysicalLabor;

  /// No description provided for @aiOnboardingStepsUnder5k.
  ///
  /// In en, this message translates to:
  /// **'< 5k steps'**
  String get aiOnboardingStepsUnder5k;

  /// No description provided for @aiOnboardingSteps5k7k.
  ///
  /// In en, this message translates to:
  /// **'5–7k'**
  String get aiOnboardingSteps5k7k;

  /// No description provided for @aiOnboardingSteps7k10k.
  ///
  /// In en, this message translates to:
  /// **'7–10k'**
  String get aiOnboardingSteps7k10k;

  /// No description provided for @aiOnboardingSteps10k15k.
  ///
  /// In en, this message translates to:
  /// **'10–15k'**
  String get aiOnboardingSteps10k15k;

  /// No description provided for @aiOnboardingStepsOver15k.
  ///
  /// In en, this message translates to:
  /// **'15k+'**
  String get aiOnboardingStepsOver15k;

  /// No description provided for @aiOnboardingDietOmnivore.
  ///
  /// In en, this message translates to:
  /// **'Omnivore'**
  String get aiOnboardingDietOmnivore;

  /// No description provided for @aiOnboardingDietVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get aiOnboardingDietVegetarian;

  /// No description provided for @aiOnboardingDietVegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get aiOnboardingDietVegan;

  /// No description provided for @aiOnboardingDietPescatarian.
  ///
  /// In en, this message translates to:
  /// **'Pescatarian'**
  String get aiOnboardingDietPescatarian;

  /// No description provided for @aiOnboardingDietOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get aiOnboardingDietOther;

  /// No description provided for @aiOnboardingEatingOutRarely.
  ///
  /// In en, this message translates to:
  /// **'Rarely'**
  String get aiOnboardingEatingOutRarely;

  /// No description provided for @aiOnboardingEatingOutWeekly.
  ///
  /// In en, this message translates to:
  /// **'1–2× / week'**
  String get aiOnboardingEatingOutWeekly;

  /// No description provided for @aiOnboardingEatingOutOften.
  ///
  /// In en, this message translates to:
  /// **'3–5× / week'**
  String get aiOnboardingEatingOutOften;

  /// No description provided for @aiOnboardingEatingOutDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get aiOnboardingEatingOutDaily;

  /// No description provided for @aiOnboardingCookingNone.
  ///
  /// In en, this message translates to:
  /// **'I don\'t cook'**
  String get aiOnboardingCookingNone;

  /// No description provided for @aiOnboardingCookingSimple.
  ///
  /// In en, this message translates to:
  /// **'Simple meals only'**
  String get aiOnboardingCookingSimple;

  /// No description provided for @aiOnboardingCookingEnjoys.
  ///
  /// In en, this message translates to:
  /// **'I enjoy cooking'**
  String get aiOnboardingCookingEnjoys;

  /// No description provided for @aiOnboardingBudgetLow.
  ///
  /// In en, this message translates to:
  /// **'Not a concern'**
  String get aiOnboardingBudgetLow;

  /// No description provided for @aiOnboardingBudgetMedium.
  ///
  /// In en, this message translates to:
  /// **'Somewhat'**
  String get aiOnboardingBudgetMedium;

  /// No description provided for @aiOnboardingBudgetHigh.
  ///
  /// In en, this message translates to:
  /// **'Very tight'**
  String get aiOnboardingBudgetHigh;

  /// No description provided for @aiOnboardingSleepUnder5.
  ///
  /// In en, this message translates to:
  /// **'< 5 h'**
  String get aiOnboardingSleepUnder5;

  /// No description provided for @aiOnboardingSleep5to6.
  ///
  /// In en, this message translates to:
  /// **'5–6 h'**
  String get aiOnboardingSleep5to6;

  /// No description provided for @aiOnboardingSleep6to7.
  ///
  /// In en, this message translates to:
  /// **'6–7 h'**
  String get aiOnboardingSleep6to7;

  /// No description provided for @aiOnboardingSleep7to8.
  ///
  /// In en, this message translates to:
  /// **'7–8 h'**
  String get aiOnboardingSleep7to8;

  /// No description provided for @aiOnboardingSleepOver8.
  ///
  /// In en, this message translates to:
  /// **'8+ h'**
  String get aiOnboardingSleepOver8;

  /// No description provided for @aiOnboardingStressLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get aiOnboardingStressLow;

  /// No description provided for @aiOnboardingStressMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get aiOnboardingStressMedium;

  /// No description provided for @aiOnboardingStressHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get aiOnboardingStressHigh;

  /// No description provided for @aiOnboardingWaterLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get aiOnboardingWaterLow;

  /// No description provided for @aiOnboardingWaterMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get aiOnboardingWaterMedium;

  /// No description provided for @aiOnboardingWaterHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get aiOnboardingWaterHigh;

  /// No description provided for @aiOnboardingAlcoholNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get aiOnboardingAlcoholNone;

  /// No description provided for @aiOnboardingAlcoholOccasional.
  ///
  /// In en, this message translates to:
  /// **'Occasional'**
  String get aiOnboardingAlcoholOccasional;

  /// No description provided for @aiOnboardingAlcoholWeekly.
  ///
  /// In en, this message translates to:
  /// **'1–2× / week'**
  String get aiOnboardingAlcoholWeekly;

  /// No description provided for @aiOnboardingAlcoholFrequent.
  ///
  /// In en, this message translates to:
  /// **'3+ / week'**
  String get aiOnboardingAlcoholFrequent;

  /// No description provided for @aiOnboardingStruggleCravings.
  ///
  /// In en, this message translates to:
  /// **'Cravings'**
  String get aiOnboardingStruggleCravings;

  /// No description provided for @aiOnboardingStruggleConsistency.
  ///
  /// In en, this message translates to:
  /// **'Staying consistent'**
  String get aiOnboardingStruggleConsistency;

  /// No description provided for @aiOnboardingStruggleLateNight.
  ///
  /// In en, this message translates to:
  /// **'Late-night eating'**
  String get aiOnboardingStruggleLateNight;

  /// No description provided for @aiOnboardingStruggleEmotional.
  ///
  /// In en, this message translates to:
  /// **'Emotional eating'**
  String get aiOnboardingStruggleEmotional;

  /// No description provided for @aiOnboardingStruggleBoredom.
  ///
  /// In en, this message translates to:
  /// **'Boredom eating'**
  String get aiOnboardingStruggleBoredom;

  /// No description provided for @aiOnboardingStruggleTime.
  ///
  /// In en, this message translates to:
  /// **'Lack of time'**
  String get aiOnboardingStruggleTime;

  /// No description provided for @aiOnboardingStruggleSocial.
  ///
  /// In en, this message translates to:
  /// **'Social / eating out'**
  String get aiOnboardingStruggleSocial;

  /// No description provided for @aiOnboardingStruggleTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get aiOnboardingStruggleTravel;

  /// No description provided for @aiOnboardingStrugglePortions.
  ///
  /// In en, this message translates to:
  /// **'Portion control'**
  String get aiOnboardingStrugglePortions;

  /// No description provided for @aiOnboardingStrugglePlanning.
  ///
  /// In en, this message translates to:
  /// **'Meal planning'**
  String get aiOnboardingStrugglePlanning;

  /// No description provided for @aiOnboardingTimingMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get aiOnboardingTimingMorning;

  /// No description provided for @aiOnboardingTimingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get aiOnboardingTimingAfternoon;

  /// No description provided for @aiOnboardingTimingEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get aiOnboardingTimingEvening;

  /// No description provided for @aiOnboardingTimingNight.
  ///
  /// In en, this message translates to:
  /// **'Late night'**
  String get aiOnboardingTimingNight;

  /// No description provided for @aiOnboardingTimingWeekends.
  ///
  /// In en, this message translates to:
  /// **'Weekends'**
  String get aiOnboardingTimingWeekends;

  /// No description provided for @aiOnboardingTimingStress.
  ///
  /// In en, this message translates to:
  /// **'When stressed'**
  String get aiOnboardingTimingStress;

  /// No description provided for @aiOnboardingMotivationLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get aiOnboardingMotivationLow;

  /// No description provided for @aiOnboardingMotivationMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get aiOnboardingMotivationMedium;

  /// No description provided for @aiOnboardingMotivationHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get aiOnboardingMotivationHigh;

  /// No description provided for @aiOnboardingStructureLow.
  ///
  /// In en, this message translates to:
  /// **'Loose guidance'**
  String get aiOnboardingStructureLow;

  /// No description provided for @aiOnboardingStructureMedium.
  ///
  /// In en, this message translates to:
  /// **'Balanced plan'**
  String get aiOnboardingStructureMedium;

  /// No description provided for @aiOnboardingStructureHigh.
  ///
  /// In en, this message translates to:
  /// **'Detailed plan'**
  String get aiOnboardingStructureHigh;

  /// No description provided for @aiOnboardingToneDirect.
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get aiOnboardingToneDirect;

  /// No description provided for @aiOnboardingToneBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get aiOnboardingToneBalanced;

  /// No description provided for @aiOnboardingToneGentler.
  ///
  /// In en, this message translates to:
  /// **'Gentler'**
  String get aiOnboardingToneGentler;

  /// No description provided for @createRecipeEnterAmountTitle.
  ///
  /// In en, this message translates to:
  /// **'Ingredient amount'**
  String get createRecipeEnterAmountTitle;

  /// No description provided for @nutritionTotalCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories: {n}'**
  String nutritionTotalCalories(String n);

  /// No description provided for @nutritionTotalProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein: {n} g'**
  String nutritionTotalProtein(String n);

  /// No description provided for @nutritionTotalCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs: {n} g'**
  String nutritionTotalCarbs(String n);

  /// No description provided for @nutritionTotalFat.
  ///
  /// In en, this message translates to:
  /// **'Fat: {n} g'**
  String nutritionTotalFat(String n);

  /// No description provided for @aiCoachErrorReplyFailed.
  ///
  /// In en, this message translates to:
  /// **'The coach couldn\'t reply right now. Check your connection and try again.'**
  String get aiCoachErrorReplyFailed;

  /// No description provided for @aiCoachErrorNewChatFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start a new chat. Check your connection and try again.'**
  String get aiCoachErrorNewChatFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ro'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ro':
      return AppLocalizationsRo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
