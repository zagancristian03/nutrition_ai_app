// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Nutrition AI';

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get settingsSectionProfileGoals => 'Profile & goals';

  @override
  String get settingsSectionPreferences => 'Preferences';

  @override
  String get settingsSectionAccount => 'Account';

  @override
  String get settingsSectionHelp => 'Help';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsLanguageTitle => 'App language';

  @override
  String get settingsLanguageSubtitle =>
      'Controls menus and buttons in the app (not food names from external databases).';

  @override
  String get settingsLanguageSystemDefault => 'System default';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageRomanian => 'Romanian';

  @override
  String get settingsThemeTitle => 'Theme';

  @override
  String get settingsThemeSubtitle => 'Light, dark, or match your device';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsWeightUnitTitle => 'Weight unit';

  @override
  String get settingsWeightUnitSubtitle =>
      'Used on the Progress and weight log screens';

  @override
  String get settingsWeightUnitKg => 'Kilograms (kg)';

  @override
  String get settingsWeightUnitLb => 'Pounds (lb)';

  @override
  String get settingsCoachTipsTitle => 'Show coach tips';

  @override
  String get settingsCoachTipsSubtitle =>
      'Friendly insights on Dashboard and Diary';

  @override
  String get settingsConfirmDeleteTitle => 'Confirm before deleting';

  @override
  String get settingsConfirmDeleteSubtitle =>
      'Ask before removing a logged food';

  @override
  String get settingsHapticsTitle => 'Haptic feedback';

  @override
  String get settingsHapticsSubtitle => 'Subtle vibration on actions';

  @override
  String get settingsEditProfileTitle => 'Edit profile';

  @override
  String get settingsEditProfileSubtitle => 'Body stats, goal, activity level';

  @override
  String get settingsDailyTargetsTitle => 'Daily targets';

  @override
  String get settingsDailyTargetsSubtitle => 'Calorie + macro goals';

  @override
  String get settingsEmailTitle => 'Email';

  @override
  String get settingsEmailNotSignedIn => 'Not signed in';

  @override
  String get settingsChangePasswordTitle => 'Change password';

  @override
  String get settingsChangePasswordSubtitleSignIn => 'Sign in first';

  @override
  String get settingsChangePasswordSubtitle =>
      'Send a reset link to your email';

  @override
  String get settingsSnackResetEmailSent => 'Reset email sent';

  @override
  String settingsSnackResetFailed(String detail) {
    return 'Failed to send: $detail';
  }

  @override
  String get settingsSignOutTitle => 'Sign out';

  @override
  String get settingsSignOutSubtitle => 'Return to the login screen';

  @override
  String get authSignOutConfirmTitle => 'Sign out?';

  @override
  String get authSignOutConfirmBody => 'You can sign back in any time.';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSignOut => 'Sign out';

  @override
  String get commonDismiss => 'Dismiss';

  @override
  String get commonRetry => 'Retry';

  @override
  String get settingsFeedbackTitle => 'Send feedback';

  @override
  String get settingsFeedbackSubtitle => 'Tell us what you\'d like to see next';

  @override
  String get settingsFeedbackSnack => 'Thanks! Email feedback coming soon.';

  @override
  String get settingsRateTitle => 'Rate this app';

  @override
  String get settingsRateSubtitle => 'A quick rating helps a lot';

  @override
  String get settingsRateSnack => 'Thanks for your support!';

  @override
  String get settingsAboutAppTitle => 'Nutrition AI';

  @override
  String get settingsAboutVersionSubtitle => 'Version 1.0.0';

  @override
  String get settingsPrivacyTitle => 'Privacy';

  @override
  String get settingsPrivacySubtitle =>
      'Your foods, goals and weights are stored securely.';

  @override
  String get errorNetworkTimeout =>
      'The connection timed out. Check your network and try again.';

  @override
  String get errorServerGeneric =>
      'Something went wrong on our side. Please try again.';

  @override
  String get errorValidationRequiredField =>
      'A required field is missing. Please check your input.';

  @override
  String errorUnknownWithDetail(String detail) {
    return 'Something went wrong: $detail';
  }

  @override
  String get diaryLoadFailedGeneric =>
      'Could not load your diary. Check your connection and try again.';

  @override
  String welcomeUser(String name) {
    return 'Welcome, $name';
  }

  @override
  String get diaryTodayTitle => 'Today';

  @override
  String get diaryRelativeYesterday => 'Yesterday';

  @override
  String get diaryRelativeTomorrow => 'Tomorrow';

  @override
  String get diaryDayPreviousTooltip => 'Previous day';

  @override
  String get diaryDayNextTooltip => 'Next day';

  @override
  String diaryLastUpdated(String time) {
    return 'Last updated $time';
  }

  @override
  String get shellExitTitle => 'Exit app?';

  @override
  String get shellExitBody => 'Are you sure you want to close the app?';

  @override
  String get shellExitConfirm => 'Exit';

  @override
  String get shellNavDashboard => 'Dashboard';

  @override
  String get shellNavDiary => 'Diary';

  @override
  String get shellNavAdd => 'Add';

  @override
  String get shellNavProgress => 'Progress';

  @override
  String get shellNavMore => 'More';

  @override
  String get shellAiCoachFabTooltip => 'AI Coach';

  @override
  String get mealBreakfast => 'Breakfast';

  @override
  String get mealLunch => 'Lunch';

  @override
  String get mealDinner => 'Dinner';

  @override
  String get mealSnack => 'Snack';

  @override
  String get dashboardReloadTooltip => 'Reload this day';

  @override
  String get dashboardEditGoalsTooltip => 'Edit goals';

  @override
  String get goalsEditCalorieLabel => 'Calorie goal';

  @override
  String get goalsEditSaveButton => 'Save goals';

  @override
  String get goalsUpdatedSnack => 'Goals updated successfully!';

  @override
  String get goalsSavedLocalSnack =>
      'Saved locally — check your connection to sync.';

  @override
  String get dashboardCoachTitle => 'Coach';

  @override
  String get dashboardMacrosTitle => 'Macros';

  @override
  String get dashboardMacroProtein => 'Protein';

  @override
  String get dashboardMacroCarbs => 'Carbs';

  @override
  String get dashboardMacroFats => 'Fats';

  @override
  String get dashboardCaloriesToday => 'Calories (today)';

  @override
  String dashboardCaloriesForDate(String date) {
    return 'Calories ($date)';
  }

  @override
  String get nutritionInsightViewingOtherDay =>
      'You are viewing a past or future day. Use ← → or the calendar to move between days.';

  @override
  String get nutritionInsightNoFoodsToday =>
      'No foods logged yet today. Tap Add or pick a meal below to get started.';

  @override
  String get nutritionInsightUnderCalories =>
      'You are under your calorie goal so far. Add a balanced meal or snack if you are still hungry.';

  @override
  String get nutritionInsightOverCalories =>
      'Calories are above today’s goal. Consider lighter options tomorrow or adjust goals in settings if this is intentional.';

  @override
  String get nutritionInsightProteinLowCarbsHigh =>
      'Carbs are on track but protein is low. Lean meat, dairy, legumes, or tofu can help balance this day.';

  @override
  String get nutritionInsightProteinHighFatLow =>
      'Protein looks solid. If energy dips later, a small portion of healthy fats (nuts, olive oil) can help.';

  @override
  String get diaryInsightsTitle => 'Insights';

  @override
  String get diaryDeleteEntryTitle => 'Remove from diary?';

  @override
  String diaryDeleteEntryMessage(String foodName) {
    return '“$foodName” will be removed from this day.';
  }

  @override
  String get diaryDeleteEntryConfirm => 'Remove';

  @override
  String get diaryEmptyStateBody =>
      'Nothing logged for this day yet. Scroll down and tap Add food under any meal.';

  @override
  String get diaryDaySummaryTitle => 'This day';

  @override
  String diaryKcalFraction(String goal) {
    return ' / $goal kcal';
  }

  @override
  String diaryMacroMiniLine(
    String letter,
    String value,
    String goal,
    String percent,
  ) {
    return '$letter $value / $goal g ($percent%)';
  }

  @override
  String get diaryMacroLetterProtein => 'P';

  @override
  String get diaryMacroLetterCarbs => 'C';

  @override
  String get diaryMacroLetterFat => 'F';

  @override
  String get diaryMealSectionEmpty =>
      'No foods yet — tap Add food below to search and log.';

  @override
  String get diaryMealAddFood => 'Add food';

  @override
  String diaryCaloriesUnit(String n) {
    return '$n cal';
  }

  @override
  String get foodAddTitle => 'Add food';

  @override
  String get foodAddManualTooltip => 'Add manually';

  @override
  String get foodMyMeals => 'My meals';

  @override
  String get foodMyRecipes => 'My recipes';

  @override
  String get foodSearchHint => 'Search foods (try: rice, egg, milk)…';

  @override
  String get foodRecentTitle => 'Recently logged';

  @override
  String get foodRecentRefreshTooltip => 'Refresh';

  @override
  String get foodRecentEmpty =>
      'Foods you log will appear here — newest first — use + to log again and pick a meal.';

  @override
  String get foodSearchLoadErrorTitle => 'Could not load foods';

  @override
  String get foodSearchNoResults => 'No results found';

  @override
  String get foodSearchNoResultsHint =>
      'If the database is new, import or seed foods, or add a food with +.';

  @override
  String foodLogTargetMealTitle(String foodName) {
    return 'Log “$foodName” to';
  }

  @override
  String get foodLogNoPortionSnack =>
      'No portion saved for this item — tap the row to set amount.';

  @override
  String foodLogAddedSnack(String meal) {
    return 'Added to $meal';
  }

  @override
  String get foodLogFailedSnack =>
      'Could not log — check connection and try again.';

  @override
  String get foodLogAgainTooltip => 'Log again';

  @override
  String foodPortionGrams(String grams) {
    return '$grams g';
  }

  @override
  String foodPortionServings(String count) {
    return '$count × serving';
  }

  @override
  String get foodPortionDash => '—';

  @override
  String get moreScreenTitle => 'More';

  @override
  String get moreNoEmail => 'No email';

  @override
  String get moreAiCoachTitle => 'AI Coach';

  @override
  String get moreAiCoachSubtitle => 'Chat, meal ideas, daily & weekly reviews';

  @override
  String get moreSettingsSubtitle => 'Theme, profile, goals, account, about';

  @override
  String get progressTitle => 'Progress';

  @override
  String get progressRefreshTooltip => 'Refresh';

  @override
  String get commonRemove => 'Remove';

  @override
  String get aiCoachTitle => 'AI Coach';

  @override
  String aiCoachThreadTitle(String id) {
    return 'Chat #$id';
  }

  @override
  String get aiCoachNewChatTooltip => 'New chat';

  @override
  String get aiCoachEditOnboardingTooltip => 'Edit onboarding';

  @override
  String get aiCoachSnackWaitReply =>
      'Wait for the reply to finish before switching chats.';

  @override
  String get aiCoachSnackOpenChatFailed => 'Could not open that chat.';

  @override
  String get aiCoachOnboardingHeadline => 'Meet your nutrition coach';

  @override
  String get aiCoachOnboardingBody =>
      'Answer a few quick questions so the coach can tailor advice to your goal, food preferences, and habits.';

  @override
  String get aiCoachOnboardingStart => 'Start onboarding';

  @override
  String get aiCoachInputHint => 'Ask your coach…';

  @override
  String get aiCoachSendTooltip => 'Send';

  @override
  String get aiCoachQuick1Label => 'How is my day?';

  @override
  String get aiCoachQuick1Prompt => 'How is today going for my goal?';

  @override
  String get aiCoachQuick2Label => 'Suggest food';

  @override
  String get aiCoachQuick2Prompt => 'What should I eat next to stay on track?';

  @override
  String get aiCoachQuick3Label => 'Review my week';

  @override
  String get aiCoachQuick3Prompt => 'Give me a quick review of my last 7 days.';

  @override
  String get aiCoachQuick4Label => 'Craving sweet';

  @override
  String get aiCoachQuick4Prompt =>
      'I\'m craving something sweet — what\'s a smart option?';

  @override
  String get aiCoachDrawerTitle => 'Coach chats';

  @override
  String get aiCoachDrawerSubtitle =>
      'Folders keep chats out of the inbox until you expand them.';

  @override
  String get aiCoachDrawerNewChat => 'New chat';

  @override
  String get aiCoachDrawerNewFolderTooltip => 'New folder';

  @override
  String get aiCoachInboxTitle => 'Inbox';

  @override
  String get aiCoachInboxSubtitle =>
      'Only chats that are not in a folder. Move one into a folder to remove it from here.';

  @override
  String get aiCoachInboxEmptyNoFolders =>
      'No chats yet. Start a new one above.';

  @override
  String get aiCoachInboxEmptyWithFolders =>
      'No unfiled chats — open a folder above to see the rest.';

  @override
  String get aiCoachFoldersHeading => 'Folders';

  @override
  String get aiCoachNoChatsYet =>
      'No chats yet.\nTap “New chat” or create a folder.';

  @override
  String get aiCoachUnfiled => 'Unfiled';

  @override
  String get aiCoachDrawerRename => 'Rename';

  @override
  String get aiCoachDrawerMoveToFolder => 'Move to folder…';

  @override
  String get aiCoachFolderOptions => 'Folder options';

  @override
  String get aiCoachNewChatInFolder => 'New chat in this folder';

  @override
  String get aiCoachRenameChatTitle => 'Rename chat';

  @override
  String get aiCoachRenameChatNameLabel => 'Name';

  @override
  String get aiCoachRenameChatNameHint => 'e.g. Meal planning';

  @override
  String get aiCoachRenameFolderTitle => 'Rename folder';

  @override
  String get aiCoachNewFolderTitle => 'New folder';

  @override
  String get aiCoachFolderNameLabel => 'Folder name';

  @override
  String get aiCoachDeleteFolderTitle => 'Delete folder?';

  @override
  String aiCoachDeleteFolderBody(String name) {
    return '“$name” will be removed. Chats inside move to Unfiled.';
  }

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonSave => 'Save';

  @override
  String get aiCoachSnackRenameChatFailed => 'Could not rename chat.';

  @override
  String get aiCoachSnackCreateFolderFailed => 'Could not create folder.';

  @override
  String get aiCoachSnackRenameFolderFailed => 'Could not rename folder.';

  @override
  String get aiCoachSnackDeleteFolderFailed => 'Could not delete folder.';

  @override
  String aiCoachThreadMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages',
      one: '1 message',
      zero: 'No messages',
    );
    return '$_temp0';
  }

  @override
  String get aiCoachTimeJustNow => 'just now';

  @override
  String aiCoachTimeMinutesAgo(String minutes) {
    return '${minutes}m ago';
  }

  @override
  String aiCoachTimeHoursAgo(String hours) {
    return '${hours}h ago';
  }

  @override
  String aiCoachTimeDaysAgo(String days) {
    return '${days}d ago';
  }

  @override
  String get aiCoachSnackMoveChatFailed =>
      'Could not move chat. Check your connection and try again.';

  @override
  String get aiCoachSnackWaitReplyFirst =>
      'Wait for the reply to finish first.';

  @override
  String aiCoachMoveChatSheetTitle(String chatTitle) {
    return 'Move \"$chatTitle\"';
  }

  @override
  String get aiCoachDeleteFolderMenuItem => 'Delete folder';

  @override
  String get aiCoachFolderEmptyInboxHint =>
      'Move a chat here from the inbox, or start a new one above.';

  @override
  String aiCoachFolderSubtitleThreads(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chats',
      one: '1 chat',
      zero: 'Empty — tap to open',
    );
    return '$_temp0';
  }

  @override
  String get authLoginTitle => 'Log in';

  @override
  String get authSignInButton => 'Log in';

  @override
  String get authRegisterPrompt => 'Don\'t have an account? Register';

  @override
  String get authLoginFailedSnack =>
      'Log in failed. Check your email and password.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authValidationEmailRequired => 'Enter your email';

  @override
  String get authValidationEmailInvalid => 'Enter a valid email';

  @override
  String get authValidationPasswordRequired => 'Enter your password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authForgotPasswordEnterEmail => 'Enter an email address first';

  @override
  String get authForgotPasswordSnackSent => 'Password reset email sent';

  @override
  String get authForgotPasswordSnackFailed =>
      'Could not send reset email — try again later';

  @override
  String get authRegisterTitle => 'Create account';

  @override
  String get authRegisterSubtitle => 'Sign up to get started';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authRegisterButton => 'Register';

  @override
  String get authRegisterFailedSnack => 'Registration failed. Try again.';

  @override
  String get authValidationPasswordMin6 =>
      'Password must be at least 6 characters';

  @override
  String get authValidationConfirmRequired => 'Confirm your password';

  @override
  String get authValidationPasswordsMismatch => 'Passwords don\'t match';

  @override
  String get authLoginPrompt => 'Already have an account? Log in';

  @override
  String get progressProfileYourProfile => 'Your profile';

  @override
  String get progressProfileSubtitleEmpty =>
      'Add a few details to unlock personalised targets.';

  @override
  String get progressCommonEdit => 'Edit';

  @override
  String progressProfileAgeYears(String years) {
    return '$years yr';
  }

  @override
  String get progressWeightSectionTitle => 'Weight';

  @override
  String get progressWeightLogButton => 'Log';

  @override
  String get progressWeightCurrent => 'Current';

  @override
  String get progressWeightTarget => 'Target';

  @override
  String get progressWeightChange => 'Change';

  @override
  String get progressWeightToGo => 'To go';

  @override
  String get progressWeightOnTarget => 'On target';

  @override
  String get progressWeightEmpty =>
      'No weight logged yet.\nTap \"Log\" to add your first measurement.';

  @override
  String get progressIntakeToday => 'Intake · today';

  @override
  String progressIntakeDate(String date) {
    return 'Intake · $date';
  }

  @override
  String get progressEstimatedTdee => 'Estimated TDEE';

  @override
  String progressBmiStatLabel(String category) {
    return 'BMI · $category';
  }

  @override
  String get progressBmiCategoryUnderweight => 'Underweight';

  @override
  String get progressBmiCategoryHealthy => 'Healthy range';

  @override
  String get progressBmiCategoryOverweight => 'Overweight';

  @override
  String get progressBmiCategoryObese => 'Obese';

  @override
  String get progressHistoryTitle => 'History';

  @override
  String get progressDeleteWeightTitle => 'Delete entry?';

  @override
  String progressDeleteWeightMessage(String date) {
    return 'Remove the weight log for $date?';
  }

  @override
  String get progressWeightLogSheetTitle => 'Log weight';

  @override
  String get progressWeightFieldLabel => 'Weight';

  @override
  String get progressWeightSuffixKg => 'kg';

  @override
  String get progressWeightDateLabel => 'Date';

  @override
  String get progressWeightNoteLabel => 'Note (optional)';

  @override
  String get progressWeightSave => 'Save';

  @override
  String get progressWeightSaving => 'Saving…';

  @override
  String get progressWeightInvalid => 'Enter a valid weight (0–500 kg)';

  @override
  String get progressWeightLoggedSnack => 'Weight logged';

  @override
  String get progressWeightSaveFailedSnack => 'Could not save. Try again.';

  @override
  String get progressChartTargetLabel => 'target';

  @override
  String progressBmiChipPrefix(String value) {
    return 'BMI $value';
  }

  @override
  String get mealServingDialogTitle => 'Serving size';

  @override
  String get mealServingAmountG => 'Amount (g)';

  @override
  String get mealRecipeDialogAdd => 'Add';

  @override
  String get mealDialogCancel => 'Cancel';

  @override
  String get createMealTitle => 'Create meal';

  @override
  String get createMealNameLabel => 'Meal name';

  @override
  String get createMealFoodItemsHeader => 'Food items';

  @override
  String get createMealAddFoodButton => 'Add food';

  @override
  String get createMealEmptyItems => 'No items added yet';

  @override
  String get createMealTotalNutrition => 'Total nutrition';

  @override
  String get createMealSaveButton => 'Save meal';

  @override
  String get createMealSnackNameRequired => 'Enter a meal name';

  @override
  String get createMealSnackItemsRequired => 'Add at least one food';

  @override
  String get createMealSnackSaved => 'Meal saved';

  @override
  String createMealItemSubtitle(String grams, String cal) {
    return '$grams g • $cal cal';
  }

  @override
  String get createRecipeTitle => 'Create recipe';

  @override
  String get recipeNameLabel => 'Recipe name';

  @override
  String get recipeDescriptionLabel => 'Description (optional)';

  @override
  String get recipeServingsLabel => 'Number of servings';

  @override
  String get recipeIngredientsHeader => 'Ingredients';

  @override
  String get recipeAddIngredient => 'Add ingredient';

  @override
  String get recipeEmptyIngredients => 'No ingredients added yet';

  @override
  String recipeTotalNutritionServings(String count) {
    return 'Total nutrition ($count servings)';
  }

  @override
  String recipeTotalCaloriesLine(String n) {
    return 'Total calories: $n';
  }

  @override
  String recipeTotalProteinLine(String n) {
    return 'Total protein: $n g';
  }

  @override
  String recipeTotalCarbsLine(String n) {
    return 'Total carbs: $n g';
  }

  @override
  String recipeTotalFatLine(String n) {
    return 'Total fat: $n g';
  }

  @override
  String get recipePerServingHeader => 'Per serving';

  @override
  String recipePerServingCalories(String n) {
    return 'Calories: $n';
  }

  @override
  String recipePerServingProtein(String n) {
    return 'Protein: $n g';
  }

  @override
  String recipePerServingCarbs(String n) {
    return 'Carbs: $n g';
  }

  @override
  String recipePerServingFat(String n) {
    return 'Fat: $n g';
  }

  @override
  String get recipeSaveButton => 'Save recipe';

  @override
  String get recipeSnackNameRequired => 'Enter a recipe name';

  @override
  String get recipeSnackIngredientsRequired => 'Add at least one ingredient';

  @override
  String get recipeSnackServingsInvalid => 'Enter a valid number of servings';

  @override
  String get recipeSnackSaved => 'Recipe saved';

  @override
  String recipeIngredientSubtitle(String grams, String cal) {
    return '$grams g • $cal cal';
  }

  @override
  String get myMealsScreenTitle => 'My meals';

  @override
  String get myMealsCreateTooltip => 'Create meal';

  @override
  String get myMealsEmpty => 'No saved meals yet';

  @override
  String get myMealsCreateFirst => 'Create your first meal';

  @override
  String myMealsCardSubtitle(String cal, String p, String c, String f) {
    return '$cal cal • P: $p g • C: $c g • F: $f g';
  }

  @override
  String get myMealsAddToDiaryTooltip => 'Add to diary';

  @override
  String get myMealsDeleteTooltip => 'Delete';

  @override
  String get myMealsDeleteTitle => 'Delete meal?';

  @override
  String myMealsDeleteConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String myMealsAddedSnack(String name) {
    return '$name added to diary!';
  }

  @override
  String myMealsPartialSnack(String added, String total, String failed) {
    return 'Added $added / $total items ($failed failed — foods may be missing).';
  }

  @override
  String get myRecipesScreenTitle => 'My recipes';

  @override
  String get myRecipesCreateTooltip => 'Create recipe';

  @override
  String get myRecipesEmpty => 'No saved recipes yet';

  @override
  String get myRecipesCreateFirst => 'Create your first recipe';

  @override
  String myRecipesCardSubtitle(String cal, String servings, String p) {
    return '$cal cal/serving • $servings servings • P: $p g';
  }

  @override
  String myRecipesAddedSnack(String name) {
    return '$name (1 serving) added to diary!';
  }

  @override
  String myRecipesPartialSnack(String added, String total, String failed) {
    return '$added / $total ingredients logged ($failed failed — foods may be missing).';
  }

  @override
  String get myRecipesDeleteTitle => 'Delete recipe?';

  @override
  String myRecipesDeleteConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get addMealTitle => 'Add meal';

  @override
  String get addMealSearchLabel => 'Search for food';

  @override
  String get addMealSearchHint => 'e.g. rice, chicken, apple';

  @override
  String get addMealNoResults => 'No results';

  @override
  String addMealSearchResultLine(String cal, String p, String c, String f) {
    return '$cal cal/100g • P: $p g • C: $c g • F: $f g';
  }

  @override
  String get addMealMealTypeLabel => 'Meal type';

  @override
  String get addMealSelectMealType => 'Select a meal type';

  @override
  String get addMealFoodNameLabel => 'Food name';

  @override
  String get addMealFoodNameRequired => 'Enter a food name';

  @override
  String get addMealCaloriesLabel => 'Calories';

  @override
  String get addMealCaloriesRequired => 'Enter calories';

  @override
  String get addMealCaloriesInvalid => 'Enter a valid number';

  @override
  String get addMealProteinLabel => 'Protein (g)';

  @override
  String get addMealProteinRequired => 'Enter protein';

  @override
  String get addMealProteinInvalid => 'Enter a valid number';

  @override
  String get addMealCarbsLabel => 'Carbs (g)';

  @override
  String get addMealCarbsRequired => 'Enter carbs';

  @override
  String get addMealCarbsInvalid => 'Enter a valid number';

  @override
  String get addMealFatsLabel => 'Fat (g)';

  @override
  String get addMealFatsRequired => 'Enter fat';

  @override
  String get addMealFatsInvalid => 'Enter a valid number';

  @override
  String get addMealSubmitButton => 'Add meal';

  @override
  String get addMealSuccessSnack => 'Meal logged locally';

  @override
  String get foodDetailTitle => 'Food details';

  @override
  String get foodDetailPer100 => 'Per 100 g';

  @override
  String get foodDetailPortionTitle => 'Portion';

  @override
  String get foodDetailMealTypeLabel => 'Meal type';

  @override
  String foodDetailServingSizeLabel(String unit) {
    return 'Serving size ($unit)';
  }

  @override
  String get foodDetailServingsLabel => 'Servings';

  @override
  String get foodDetailTotalsTitle => 'Totals';

  @override
  String get foodDetailValidationPortions =>
      'Enter a valid serving size and servings';

  @override
  String get foodDetailSaveFailedSnack =>
      'Could not save to diary. Check your connection.';

  @override
  String get foodDetailAddedSnack => 'Added to diary';

  @override
  String get foodDetailAddToDiary => 'Add to diary';

  @override
  String get foodDetailSaving => 'Saving…';

  @override
  String get foodManualTitle => 'Add food manually';

  @override
  String get foodManualSectionBasics => 'Basics';

  @override
  String get foodManualSectionPortion => 'Portion';

  @override
  String get foodManualSectionNutrition => 'Nutrition (per serving)';

  @override
  String get foodManualFoodNameLabel => 'Food name';

  @override
  String get foodManualBrandLabel => 'Brand (optional)';

  @override
  String get foodManualServingSizeG => 'Serving size (g)';

  @override
  String get foodManualValidationName => 'Enter a food name';

  @override
  String get foodManualValidationCalories => 'Enter calories';

  @override
  String get foodManualSaveFailedGeneric => 'Could not save food. Try again.';

  @override
  String get foodManualSavedAndLoggedSnack => 'Food saved and added to diary!';

  @override
  String get foodManualSavedLogFailedSnack => 'Food saved — diary log failed.';

  @override
  String get foodManualAddToDiary => 'Add to diary';

  @override
  String get foodManualSaving => 'Saving…';

  @override
  String get foodEditTitle => 'Edit food entry';

  @override
  String get foodEditMealTypeLabel => 'Meal type';

  @override
  String get foodEditFoodNameLabel => 'Food name';

  @override
  String get foodEditServingSizeG => 'Serving size (g)';

  @override
  String get foodEditServingsLabel => 'Number of servings';

  @override
  String get foodEditCaloriesLabel => 'Calories';

  @override
  String get foodEditProteinLabel => 'Protein (g)';

  @override
  String get foodEditCarbsLabel => 'Carbs (g)';

  @override
  String get foodEditFatLabel => 'Fat (g)';

  @override
  String get foodEditSaveButton => 'Save changes';

  @override
  String get foodEditSaving => 'Saving…';

  @override
  String get foodEditMealTypeRequired => 'Select a meal type';

  @override
  String get foodEditNameRequired => 'Enter a food name';

  @override
  String get foodEditCaloriesRequired => 'Enter calories';

  @override
  String get foodEditUpdatedSnack => 'Entry updated';

  @override
  String get foodEditSaveFailedSnack => 'Could not save changes';

  @override
  String get aiOnboardingIntro =>
      'Answer what applies. You can combine goals (for example lose weight + gain muscle), and use the text boxes when the options don\'t cover everything.';

  @override
  String get aiOnboardingAppBarTitle => 'Coach setup';

  @override
  String get aiOnboardingSaveDraft => 'Save draft';

  @override
  String get aiOnboardingFinishButton => 'Finish & start chatting';

  @override
  String get aiOnboardingSnackRequiredFields =>
      'Pick at least one goal, approach, and diet pattern to finish.';

  @override
  String get aiOnboardingSnackSaveFailed =>
      'Couldn\'t save. Check your connection and try again.';

  @override
  String get aiOnboardingSnackDraftSaved => 'Draft saved.';

  @override
  String get aiOnboardingSectionGoalsTitle => 'Your goals';

  @override
  String get aiOnboardingSectionGoalsSubtitle => 'Pick one or more';

  @override
  String get aiOnboardingNoteMainGoalLabel => 'Any other goal or context?';

  @override
  String get aiOnboardingNoteMainGoalHint => 'e.g. half-marathon in 12 weeks';

  @override
  String get aiOnboardingSectionApproachTitle =>
      'How do you want to approach it?';

  @override
  String get aiOnboardingSectionTrainingTitle => 'Training & activity';

  @override
  String get aiOnboardingSectionTrainingSubtitle =>
      'Shapes calorie and protein targets';

  @override
  String get aiOnboardingLabelTrainingSessionsPerWeek =>
      'Training sessions per week';

  @override
  String get aiOnboardingLabelTrainingTypes =>
      'Types of training (pick all that apply)';

  @override
  String get aiOnboardingLabelSessionIntensity => 'Typical session intensity';

  @override
  String get aiOnboardingLabelJobActivity => 'Daytime / job activity';

  @override
  String get aiOnboardingLabelDailySteps => 'Average daily steps';

  @override
  String get aiOnboardingNoteTrainingLabel => 'Training notes';

  @override
  String get aiOnboardingNoteTrainingHint => 'e.g. push/pull/legs split';

  @override
  String get aiOnboardingSectionDietTitle => 'Diet pattern';

  @override
  String get aiOnboardingNoteDietaryLabel => 'Dietary notes / restrictions';

  @override
  String get aiOnboardingNoteDietaryHint =>
      'e.g. low-FODMAP, halal, fasting schedule';

  @override
  String get aiOnboardingLabelAllergies => 'Allergies or intolerances';

  @override
  String get aiOnboardingHintAllergies => 'e.g. peanuts, lactose';

  @override
  String get aiOnboardingLabelDisliked => 'Disliked foods';

  @override
  String get aiOnboardingHintDisliked => 'e.g. mushrooms, liver';

  @override
  String get aiOnboardingLabelFavorites => 'Favorite foods';

  @override
  String get aiOnboardingHintFavorites => 'e.g. chicken, rice, yogurt';

  @override
  String get aiOnboardingLabelCuisines => 'Cuisines you enjoy';

  @override
  String get aiOnboardingHintCuisines => 'e.g. Italian, Japanese';

  @override
  String get aiOnboardingLabelEatingOut => 'Eating out frequency';

  @override
  String get aiOnboardingSectionCookingTitle => 'Cooking & budget';

  @override
  String get aiOnboardingLabelCookingPreference => 'Cooking preference';

  @override
  String get aiOnboardingLabelBudget => 'Budget sensitivity';

  @override
  String get aiOnboardingLabelMealsPerDay => 'Meals per day';

  @override
  String get aiOnboardingSectionLifestyleTitle => 'Lifestyle & recovery';

  @override
  String get aiOnboardingSectionLifestyleSubtitle =>
      'Energy, cravings, adherence';

  @override
  String get aiOnboardingLabelSleep => 'Average sleep';

  @override
  String get aiOnboardingLabelStress => 'Typical stress level';

  @override
  String get aiOnboardingLabelWater => 'Water intake';

  @override
  String get aiOnboardingLabelAlcohol => 'Alcohol frequency';

  @override
  String get aiOnboardingSectionStrugglesTitle =>
      'What tends to get in the way?';

  @override
  String get aiOnboardingLabelBiggestStruggles =>
      'Biggest struggles (pick any)';

  @override
  String get aiOnboardingNoteStruggleLabel =>
      'Anything else that holds you back?';

  @override
  String get aiOnboardingNoteStruggleHint => 'e.g. shift work, weekends';

  @override
  String get aiOnboardingLabelStruggleWhen => 'When is it hardest?';

  @override
  String get aiOnboardingSectionMotivationTitle => 'Motivation & structure';

  @override
  String get aiOnboardingLabelMotivation => 'Motivation level';

  @override
  String get aiOnboardingLabelStructure => 'How much structure do you want?';

  @override
  String get aiOnboardingSectionCoachToneTitle => 'Coach tone';

  @override
  String get aiOnboardingGoalLoseWeight => 'Lose weight';

  @override
  String get aiOnboardingGoalGainMuscle => 'Gain muscle';

  @override
  String get aiOnboardingGoalMaintain => 'Maintain weight';

  @override
  String get aiOnboardingGoalEatHealthier => 'Eat healthier';

  @override
  String get aiOnboardingGoalImproveEnergy => 'More energy';

  @override
  String get aiOnboardingGoalImprovePerformance => 'Athletic performance';

  @override
  String get aiOnboardingGoalImproveConsistency => 'Be consistent';

  @override
  String get aiOnboardingApproachAggressive => 'Aggressive';

  @override
  String get aiOnboardingApproachBalanced => 'Balanced';

  @override
  String get aiOnboardingApproachFlexible => 'Flexible';

  @override
  String get aiOnboardingApproachSustainable => 'Slow & sustainable';

  @override
  String get aiOnboardingTrainingSessions7Plus => '7+';

  @override
  String get aiOnboardingTrainingLifting => 'Weight lifting';

  @override
  String get aiOnboardingTrainingCardio => 'Cardio';

  @override
  String get aiOnboardingTrainingHiit => 'HIIT / intervals';

  @override
  String get aiOnboardingTrainingSports => 'Team sports';

  @override
  String get aiOnboardingTrainingRunning => 'Running';

  @override
  String get aiOnboardingTrainingCycling => 'Cycling';

  @override
  String get aiOnboardingTrainingSwimming => 'Swimming';

  @override
  String get aiOnboardingTrainingYoga => 'Yoga / mobility';

  @override
  String get aiOnboardingTrainingWalking => 'Walking';

  @override
  String get aiOnboardingTrainingNone => 'None currently';

  @override
  String get aiOnboardingIntensityLight => 'Light';

  @override
  String get aiOnboardingIntensityModerate => 'Moderate';

  @override
  String get aiOnboardingIntensityHard => 'Hard';

  @override
  String get aiOnboardingIntensityVeryHard => 'Very hard';

  @override
  String get aiOnboardingJobDesk => 'Mostly at a desk';

  @override
  String get aiOnboardingJobMostlySeated => 'Seated with some movement';

  @override
  String get aiOnboardingJobOnFeet => 'On my feet a lot';

  @override
  String get aiOnboardingJobPhysicalLabor => 'Physical labor';

  @override
  String get aiOnboardingStepsUnder5k => '< 5k steps';

  @override
  String get aiOnboardingSteps5k7k => '5–7k';

  @override
  String get aiOnboardingSteps7k10k => '7–10k';

  @override
  String get aiOnboardingSteps10k15k => '10–15k';

  @override
  String get aiOnboardingStepsOver15k => '15k+';

  @override
  String get aiOnboardingDietOmnivore => 'Omnivore';

  @override
  String get aiOnboardingDietVegetarian => 'Vegetarian';

  @override
  String get aiOnboardingDietVegan => 'Vegan';

  @override
  String get aiOnboardingDietPescatarian => 'Pescatarian';

  @override
  String get aiOnboardingDietOther => 'Other';

  @override
  String get aiOnboardingEatingOutRarely => 'Rarely';

  @override
  String get aiOnboardingEatingOutWeekly => '1–2× / week';

  @override
  String get aiOnboardingEatingOutOften => '3–5× / week';

  @override
  String get aiOnboardingEatingOutDaily => 'Daily';

  @override
  String get aiOnboardingCookingNone => 'I don\'t cook';

  @override
  String get aiOnboardingCookingSimple => 'Simple meals only';

  @override
  String get aiOnboardingCookingEnjoys => 'I enjoy cooking';

  @override
  String get aiOnboardingBudgetLow => 'Not a concern';

  @override
  String get aiOnboardingBudgetMedium => 'Somewhat';

  @override
  String get aiOnboardingBudgetHigh => 'Very tight';

  @override
  String get aiOnboardingSleepUnder5 => '< 5 h';

  @override
  String get aiOnboardingSleep5to6 => '5–6 h';

  @override
  String get aiOnboardingSleep6to7 => '6–7 h';

  @override
  String get aiOnboardingSleep7to8 => '7–8 h';

  @override
  String get aiOnboardingSleepOver8 => '8+ h';

  @override
  String get aiOnboardingStressLow => 'Low';

  @override
  String get aiOnboardingStressMedium => 'Medium';

  @override
  String get aiOnboardingStressHigh => 'High';

  @override
  String get aiOnboardingWaterLow => 'Low';

  @override
  String get aiOnboardingWaterMedium => 'Medium';

  @override
  String get aiOnboardingWaterHigh => 'High';

  @override
  String get aiOnboardingAlcoholNone => 'None';

  @override
  String get aiOnboardingAlcoholOccasional => 'Occasional';

  @override
  String get aiOnboardingAlcoholWeekly => '1–2× / week';

  @override
  String get aiOnboardingAlcoholFrequent => '3+ / week';

  @override
  String get aiOnboardingStruggleCravings => 'Cravings';

  @override
  String get aiOnboardingStruggleConsistency => 'Staying consistent';

  @override
  String get aiOnboardingStruggleLateNight => 'Late-night eating';

  @override
  String get aiOnboardingStruggleEmotional => 'Emotional eating';

  @override
  String get aiOnboardingStruggleBoredom => 'Boredom eating';

  @override
  String get aiOnboardingStruggleTime => 'Lack of time';

  @override
  String get aiOnboardingStruggleSocial => 'Social / eating out';

  @override
  String get aiOnboardingStruggleTravel => 'Travel';

  @override
  String get aiOnboardingStrugglePortions => 'Portion control';

  @override
  String get aiOnboardingStrugglePlanning => 'Meal planning';

  @override
  String get aiOnboardingTimingMorning => 'Morning';

  @override
  String get aiOnboardingTimingAfternoon => 'Afternoon';

  @override
  String get aiOnboardingTimingEvening => 'Evening';

  @override
  String get aiOnboardingTimingNight => 'Late night';

  @override
  String get aiOnboardingTimingWeekends => 'Weekends';

  @override
  String get aiOnboardingTimingStress => 'When stressed';

  @override
  String get aiOnboardingMotivationLow => 'Low';

  @override
  String get aiOnboardingMotivationMedium => 'Medium';

  @override
  String get aiOnboardingMotivationHigh => 'High';

  @override
  String get aiOnboardingStructureLow => 'Loose guidance';

  @override
  String get aiOnboardingStructureMedium => 'Balanced plan';

  @override
  String get aiOnboardingStructureHigh => 'Detailed plan';

  @override
  String get aiOnboardingToneDirect => 'Direct';

  @override
  String get aiOnboardingToneBalanced => 'Balanced';

  @override
  String get aiOnboardingToneGentler => 'Gentler';

  @override
  String get createRecipeEnterAmountTitle => 'Ingredient amount';

  @override
  String nutritionTotalCalories(String n) {
    return 'Calories: $n';
  }

  @override
  String nutritionTotalProtein(String n) {
    return 'Protein: $n g';
  }

  @override
  String nutritionTotalCarbs(String n) {
    return 'Carbs: $n g';
  }

  @override
  String nutritionTotalFat(String n) {
    return 'Fat: $n g';
  }

  @override
  String get aiCoachErrorReplyFailed =>
      'The coach couldn\'t reply right now. Check your connection and try again.';

  @override
  String get aiCoachErrorNewChatFailed =>
      'Couldn\'t start a new chat. Check your connection and try again.';
}
