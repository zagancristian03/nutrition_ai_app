// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appTitle => 'Nutrition AI';

  @override
  String get settingsScreenTitle => 'Setări';

  @override
  String get settingsSectionAppearance => 'Aspect';

  @override
  String get settingsSectionLanguage => 'Limbă';

  @override
  String get settingsSectionProfileGoals => 'Profil și obiective';

  @override
  String get settingsSectionPreferences => 'Preferințe';

  @override
  String get settingsSectionAccount => 'Cont';

  @override
  String get settingsSectionHelp => 'Ajutor';

  @override
  String get settingsSectionAbout => 'Despre';

  @override
  String get settingsLanguageTitle => 'Limba aplicației';

  @override
  String get settingsLanguageSubtitle =>
      'Controlează meniurile și butoanele din aplicație (nu numele alimentelor din baze externe).';

  @override
  String get settingsLanguageSystemDefault => 'Implicit sistem';

  @override
  String get settingsLanguageEnglish => 'Engleză';

  @override
  String get settingsLanguageRomanian => 'Română';

  @override
  String get settingsThemeTitle => 'Temă';

  @override
  String get settingsThemeSubtitle => 'Luminos, întunecat sau ca pe dispozitiv';

  @override
  String get settingsThemeLight => 'Luminos';

  @override
  String get settingsThemeDark => 'Întunecat';

  @override
  String get settingsThemeSystem => 'Sistem';

  @override
  String get settingsWeightUnitTitle => 'Unitate greutate';

  @override
  String get settingsWeightUnitSubtitle =>
      'Folosită la Progres și log greutate';

  @override
  String get settingsWeightUnitKg => 'Kilograme (kg)';

  @override
  String get settingsWeightUnitLb => 'Livre (lb)';

  @override
  String get settingsCoachTipsTitle => 'Afișează sfaturi coach';

  @override
  String get settingsCoachTipsSubtitle =>
      'Indicații pe tabloul de bord și Jurnal';

  @override
  String get settingsConfirmDeleteTitle => 'Confirmă înainte de ștergere';

  @override
  String get settingsConfirmDeleteSubtitle =>
      'Întreabă înainte de a elimina un aliment';

  @override
  String get settingsHapticsTitle => 'Feedback haptic';

  @override
  String get settingsHapticsSubtitle => 'Vibrație subtilă la acțiuni';

  @override
  String get settingsEditProfileTitle => 'Editează profilul';

  @override
  String get settingsEditProfileSubtitle =>
      'Statistici corporale, obiectiv, nivel activitate';

  @override
  String get settingsDailyTargetsTitle => 'Ținte zilnice';

  @override
  String get settingsDailyTargetsSubtitle =>
      'Obiectiv calorii + macronutrienți';

  @override
  String get settingsEmailTitle => 'E-mail';

  @override
  String get settingsEmailNotSignedIn => 'Nu ești autentificat';

  @override
  String get settingsChangePasswordTitle => 'Schimbă parola';

  @override
  String get settingsChangePasswordSubtitleSignIn => 'Autentifică-te mai întâi';

  @override
  String get settingsChangePasswordSubtitle =>
      'Trimite un link de reset pe e-mail';

  @override
  String get settingsSnackResetEmailSent => 'E-mail de reset trimis';

  @override
  String settingsSnackResetFailed(String detail) {
    return 'Trimitere eșuată: $detail';
  }

  @override
  String get settingsSignOutTitle => 'Deconectare';

  @override
  String get settingsSignOutSubtitle => 'Înapoi la ecranul de autentificare';

  @override
  String get authSignOutConfirmTitle => 'Te deconectezi?';

  @override
  String get authSignOutConfirmBody => 'Te poți autentifica din nou oricând.';

  @override
  String get commonCancel => 'Anulează';

  @override
  String get commonSignOut => 'Deconectare';

  @override
  String get commonDismiss => 'Închide';

  @override
  String get commonRetry => 'Reîncearcă';

  @override
  String get settingsFeedbackTitle => 'Trimite feedback';

  @override
  String get settingsFeedbackSubtitle =>
      'Spune-ne ce ai vrea să vezi mai departe';

  @override
  String get settingsFeedbackSnack =>
      'Mulțumim! E-mail pentru feedback în curând.';

  @override
  String get settingsRateTitle => 'Evaluează aplicația';

  @override
  String get settingsRateSubtitle => 'O evaluare rapidă ajută mult';

  @override
  String get settingsRateSnack => 'Mulțumim pentru susținere!';

  @override
  String get settingsAboutAppTitle => 'Nutrition AI';

  @override
  String get settingsAboutVersionSubtitle => 'Versiunea 1.0.0';

  @override
  String get settingsPrivacyTitle => 'Confidențialitate';

  @override
  String get settingsPrivacySubtitle =>
      'Alimentele, obiectivele și greutățile tale sunt stocate în siguranță.';

  @override
  String get errorNetworkTimeout =>
      'Conexiunea a expirat. Verifică rețeaua și încearcă din nou.';

  @override
  String get errorServerGeneric =>
      'Ceva nu a mers bine pe server. Te rugăm să încerci din nou.';

  @override
  String get errorValidationRequiredField =>
      'Lipsește un câmp obligatoriu. Verifică datele introduse.';

  @override
  String errorUnknownWithDetail(String detail) {
    return 'Ceva nu a mers bine: $detail';
  }

  @override
  String get diaryLoadFailedGeneric =>
      'Nu s-a putut încărca jurnalul. Verifică conexiunea și încearcă din nou.';

  @override
  String welcomeUser(String name) {
    return 'Bun venit, $name';
  }

  @override
  String get diaryTodayTitle => 'Astăzi';

  @override
  String get diaryRelativeYesterday => 'Ieri';

  @override
  String get diaryRelativeTomorrow => 'Mâine';

  @override
  String get diaryDayPreviousTooltip => 'Ziua anterioară';

  @override
  String get diaryDayNextTooltip => 'Ziua următoare';

  @override
  String diaryLastUpdated(String time) {
    return 'Ultima actualizare $time';
  }

  @override
  String get shellExitTitle => 'Ieși din aplicație?';

  @override
  String get shellExitBody => 'Sigur vrei să închizi aplicația?';

  @override
  String get shellExitConfirm => 'Ieșire';

  @override
  String get shellNavDashboard => 'Acasă';

  @override
  String get shellNavDiary => 'Jurnal';

  @override
  String get shellNavAdd => 'Adaugă';

  @override
  String get shellNavProgress => 'Progres';

  @override
  String get shellNavMore => 'Mai mult';

  @override
  String get shellAiCoachFabTooltip => 'Coach AI';

  @override
  String get mealBreakfast => 'Mic dejun';

  @override
  String get mealLunch => 'Prânz';

  @override
  String get mealDinner => 'Cină';

  @override
  String get mealSnack => 'Gustare';

  @override
  String get dashboardReloadTooltip => 'Reîncarcă ziua';

  @override
  String get dashboardEditGoalsTooltip => 'Editează obiective';

  @override
  String get goalsEditCalorieLabel => 'Obiectiv caloric';

  @override
  String get goalsEditSaveButton => 'Salvează obiectivele';

  @override
  String get goalsUpdatedSnack => 'Obiective actualizate cu succes!';

  @override
  String get goalsSavedLocalSnack =>
      'Salvat local — verifică conexiunea pentru sincronizare.';

  @override
  String get dashboardCoachTitle => 'Coach';

  @override
  String get dashboardMacrosTitle => 'Macronutrienți';

  @override
  String get dashboardMacroProtein => 'Proteine';

  @override
  String get dashboardMacroCarbs => 'Carbohidrați';

  @override
  String get dashboardMacroFats => 'Grăsimi';

  @override
  String get dashboardCaloriesToday => 'Calorii (astăzi)';

  @override
  String dashboardCaloriesForDate(String date) {
    return 'Calorii ($date)';
  }

  @override
  String get nutritionInsightViewingOtherDay =>
      'Vizualizezi o zi trecută sau viitoare. Folosește ← → sau calendarul pentru a schimba ziua.';

  @override
  String get nutritionInsightNoFoodsToday =>
      'Încă nu ai logat alimente astăzi. Atinge Adaugă sau alege o masă mai jos.';

  @override
  String get nutritionInsightUnderCalories =>
      'Sub obiectivul de calorii până acum. Adaugă o masă echilibrată sau o gustare dacă încă îți este foame.';

  @override
  String get nutritionInsightOverCalories =>
      'Caloriile depășesc obiectivul de astăzi. Mâine poți opta pentru variante mai ușoare sau ajustează obiectivele în setări dacă e intenționat.';

  @override
  String get nutritionInsightProteinLowCarbsHigh =>
      'Carbohidrații sunt ok, dar proteinele sunt scăzute. Carne slabă, lactate, leguminoase sau tofu pot echilibra ziua.';

  @override
  String get nutritionInsightProteinHighFatLow =>
      'Proteinele arată bine. Dacă energia scade mai târziu, o porție mică de grăsimi sănătoase (nuci, ulei de măsline) poate ajuta.';

  @override
  String get diaryInsightsTitle => 'Indicii';

  @override
  String get diaryDeleteEntryTitle => 'Elimini din jurnal?';

  @override
  String diaryDeleteEntryMessage(String foodName) {
    return '„$foodName” va fi eliminat din această zi.';
  }

  @override
  String get diaryDeleteEntryConfirm => 'Elimină';

  @override
  String get diaryEmptyStateBody =>
      'Încă nimic logat în această zi. Derulează în jos și atinge Adaugă aliment la orice masă.';

  @override
  String get diaryDaySummaryTitle => 'Ziua aceasta';

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
      'Încă fără alimente — atinge Adaugă aliment mai jos pentru căutare și logare.';

  @override
  String get diaryMealAddFood => 'Adaugă aliment';

  @override
  String diaryCaloriesUnit(String n) {
    return '$n kcal';
  }

  @override
  String get foodAddTitle => 'Adaugă aliment';

  @override
  String get foodAddManualTooltip => 'Adaugă manual';

  @override
  String get foodMyMeals => 'Mesele mele';

  @override
  String get foodMyRecipes => 'Rețetele mele';

  @override
  String get foodSearchHint => 'Caută alimente (ex.: orez, ou, lapte)…';

  @override
  String get foodRecentTitle => 'Recent logate';

  @override
  String get foodRecentRefreshTooltip => 'Reîmprospătează';

  @override
  String get foodRecentEmpty =>
      'Alimentele pe care le loghezi apar aici — cele mai noi prime — folosește + pentru a loga din nou și a alege masa.';

  @override
  String get foodSearchLoadErrorTitle => 'Nu s-au putut încărca alimentele';

  @override
  String get foodSearchNoResults => 'Niciun rezultat';

  @override
  String get foodSearchNoResultsHint =>
      'Dacă baza e nouă, importă sau adaugă alimente, sau creează unul cu +.';

  @override
  String foodLogTargetMealTitle(String foodName) {
    return 'Loghează „$foodName” la';
  }

  @override
  String get foodLogNoPortionSnack =>
      'Nu există porție salvată — atinge rândul pentru a seta cantitatea.';

  @override
  String foodLogAddedSnack(String meal) {
    return 'Adăugat la $meal';
  }

  @override
  String get foodLogFailedSnack =>
      'Nu s-a putut loga — verifică conexiunea și încearcă din nou.';

  @override
  String get foodLogAgainTooltip => 'Loghează din nou';

  @override
  String foodPortionGrams(String grams) {
    return '$grams g';
  }

  @override
  String foodPortionServings(String count) {
    return '$count × porție';
  }

  @override
  String get foodPortionDash => '—';

  @override
  String get moreScreenTitle => 'Mai mult';

  @override
  String get moreNoEmail => 'Fără e-mail';

  @override
  String get moreAiCoachTitle => 'Coach AI';

  @override
  String get moreAiCoachSubtitle =>
      'Chat, idei de mese, recenzii zilnice și săptămânale';

  @override
  String get moreSettingsSubtitle => 'Temă, profil, obiective, cont, despre';

  @override
  String get progressTitle => 'Progres';

  @override
  String get progressRefreshTooltip => 'Reîmprospătează';

  @override
  String get commonRemove => 'Elimină';

  @override
  String get aiCoachTitle => 'Coach AI';

  @override
  String aiCoachThreadTitle(String id) {
    return 'Chat #$id';
  }

  @override
  String get aiCoachNewChatTooltip => 'Chat nou';

  @override
  String get aiCoachEditOnboardingTooltip => 'Editează onboarding';

  @override
  String get aiCoachSnackWaitReply =>
      'Așteaptă să se termine răspunsul înainte de a schimba chatul.';

  @override
  String get aiCoachSnackOpenChatFailed => 'Nu s-a putut deschide acel chat.';

  @override
  String get aiCoachOnboardingHeadline => 'Cunoaște-ți coachul nutrițional';

  @override
  String get aiCoachOnboardingBody =>
      'Răspunde la câteva întrebări rapide ca sa îți personalizeze sfaturile după obiectiv, preferințe alimentare și obiceiuri.';

  @override
  String get aiCoachOnboardingStart => 'Începe onboarding';

  @override
  String get aiCoachInputHint => 'Întreabă coachul…';

  @override
  String get aiCoachSendTooltip => 'Trimite';

  @override
  String get aiCoachQuick1Label => 'Cum merge ziua?';

  @override
  String get aiCoachQuick1Prompt => 'Cum decurge astăzi pentru obiectivul meu?';

  @override
  String get aiCoachQuick2Label => 'Sugerează mâncare';

  @override
  String get aiCoachQuick2Prompt =>
      'Ce ar trebui să mănânc în continuare ca să rămân pe drumul bun?';

  @override
  String get aiCoachQuick3Label => 'Revizuire săptămână';

  @override
  String get aiCoachQuick3Prompt =>
      'Dă-mi o scurtă revizuire a ultimelor 7 zile.';

  @override
  String get aiCoachQuick4Label => 'Poftă dulce';

  @override
  String get aiCoachQuick4Prompt =>
      'Mi-e poftă de ceva dulce — ce variante sunt mai ok?';

  @override
  String get aiCoachDrawerTitle => 'Chaturi coach';

  @override
  String get aiCoachDrawerSubtitle =>
      'Dosarele țin chaturile în afara inboxului până le extinzi.';

  @override
  String get aiCoachDrawerNewChat => 'Chat nou';

  @override
  String get aiCoachDrawerNewFolderTooltip => 'Dosar nou';

  @override
  String get aiCoachInboxTitle => 'Inbox';

  @override
  String get aiCoachInboxSubtitle =>
      'Doar chaturile care nu sunt într-un dosar. Mută unul într-un dosar ca să dispară de aici.';

  @override
  String get aiCoachInboxEmptyNoFolders =>
      'Încă niciun chat. Începe unul mai sus.';

  @override
  String get aiCoachInboxEmptyWithFolders =>
      'Niciun chat neclasat — deschide un dosar mai sus pentru restul.';

  @override
  String get aiCoachFoldersHeading => 'Dosare';

  @override
  String get aiCoachNoChatsYet =>
      'Încă niciun chat.\nAtinge „Chat nou” sau creează un dosar.';

  @override
  String get aiCoachUnfiled => 'Neclasat';

  @override
  String get aiCoachDrawerRename => 'Redenumește';

  @override
  String get aiCoachDrawerMoveToFolder => 'Mută în dosar…';

  @override
  String get aiCoachFolderOptions => 'Opțiuni dosar';

  @override
  String get aiCoachNewChatInFolder => 'Chat nou în acest dosar';

  @override
  String get aiCoachRenameChatTitle => 'Redenumește chatul';

  @override
  String get aiCoachRenameChatNameLabel => 'Nume';

  @override
  String get aiCoachRenameChatNameHint => 'ex.: Planificare mese';

  @override
  String get aiCoachRenameFolderTitle => 'Redenumește dosarul';

  @override
  String get aiCoachNewFolderTitle => 'Dosar nou';

  @override
  String get aiCoachFolderNameLabel => 'Nume dosar';

  @override
  String get aiCoachDeleteFolderTitle => 'Ștergi dosarul?';

  @override
  String aiCoachDeleteFolderBody(String name) {
    return '„$name” va fi eliminat. Chaturile din el trec la neclasate.';
  }

  @override
  String get commonDelete => 'Șterge';

  @override
  String get commonCreate => 'Creează';

  @override
  String get commonSave => 'Salvează';

  @override
  String get aiCoachSnackRenameChatFailed => 'Nu s-a putut redenumi chatul.';

  @override
  String get aiCoachSnackCreateFolderFailed => 'Nu s-a putut crea dosarul.';

  @override
  String get aiCoachSnackRenameFolderFailed => 'Nu s-a putut redenumi dosarul.';

  @override
  String get aiCoachSnackDeleteFolderFailed => 'Nu s-a putut șterge dosarul.';

  @override
  String aiCoachThreadMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mesaje',
      few: '$count mesaje',
      one: '1 mesaj',
      zero: 'Fără mesaje',
    );
    return '$_temp0';
  }

  @override
  String get aiCoachTimeJustNow => 'chiar acum';

  @override
  String aiCoachTimeMinutesAgo(String minutes) {
    return 'acum $minutes min';
  }

  @override
  String aiCoachTimeHoursAgo(String hours) {
    return 'acum $hours h';
  }

  @override
  String aiCoachTimeDaysAgo(String days) {
    return 'acum $days zile';
  }

  @override
  String get aiCoachSnackMoveChatFailed =>
      'Nu s-a putut muta chatul. Verifică conexiunea și încearcă din nou.';

  @override
  String get aiCoachSnackWaitReplyFirst =>
      'Așteaptă să se termine răspunsul mai întâi.';

  @override
  String aiCoachMoveChatSheetTitle(String chatTitle) {
    return 'Mută „$chatTitle”';
  }

  @override
  String get aiCoachDeleteFolderMenuItem => 'Șterge dosarul';

  @override
  String get aiCoachFolderEmptyInboxHint =>
      'Mută un chat aici din inbox sau începe unul nou mai sus.';

  @override
  String aiCoachFolderSubtitleThreads(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chaturi',
      few: '$count chaturi',
      one: '1 chat',
      zero: 'Gol — atinge pentru a deschide',
    );
    return '$_temp0';
  }

  @override
  String get authLoginTitle => 'Autentificare';

  @override
  String get authSignInButton => 'Intră în cont';

  @override
  String get authRegisterPrompt => 'Nu ai cont? Înregistrează-te';

  @override
  String get authLoginFailedSnack =>
      'Autentificare eșuată. Verifică emailul și parola.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Parolă';

  @override
  String get authValidationEmailRequired => 'Introdu emailul';

  @override
  String get authValidationEmailInvalid => 'Introdu un email valid';

  @override
  String get authValidationPasswordRequired => 'Introdu parola';

  @override
  String get authForgotPassword => 'Ai uitat parola?';

  @override
  String get authForgotPasswordEnterEmail =>
      'Introdu mai întâi adresa de email';

  @override
  String get authForgotPasswordSnackSent => 'Emailul de resetare a fost trimis';

  @override
  String get authForgotPasswordSnackFailed =>
      'Nu s-a putut trimite emailul de resetare — încearcă mai târziu';

  @override
  String get authRegisterTitle => 'Creează cont';

  @override
  String get authRegisterSubtitle => 'Înregistrează-te pentru a începe';

  @override
  String get authConfirmPasswordLabel => 'Confirmă parola';

  @override
  String get authRegisterButton => 'Înregistrare';

  @override
  String get authRegisterFailedSnack =>
      'Înregistrarea a eșuat. Încearcă din nou.';

  @override
  String get authValidationPasswordMin6 =>
      'Parola trebuie să aibă cel puțin 6 caractere';

  @override
  String get authValidationConfirmRequired => 'Confirmă parola';

  @override
  String get authValidationPasswordsMismatch => 'Parolele nu coincid';

  @override
  String get authLoginPrompt => 'Ai deja cont? Autentificare';

  @override
  String get progressProfileYourProfile => 'Profilul tău';

  @override
  String get progressProfileSubtitleEmpty =>
      'Completează câteva detalii pentru obiective personalizate.';

  @override
  String get progressCommonEdit => 'Editează';

  @override
  String progressProfileAgeYears(String years) {
    return '$years ani';
  }

  @override
  String get progressWeightSectionTitle => 'Greutate';

  @override
  String get progressWeightLogButton => 'Înregistrează';

  @override
  String get progressWeightCurrent => 'Curentă';

  @override
  String get progressWeightTarget => 'Țintă';

  @override
  String get progressWeightChange => 'Schimbare';

  @override
  String get progressWeightToGo => 'Rămas';

  @override
  String get progressWeightOnTarget => 'La țintă';

  @override
  String get progressWeightEmpty =>
      'Încă nu ai greutăți înregistrate.\nAtinge „Înregistrează” pentru prima măsurătoare.';

  @override
  String get progressIntakeToday => 'Aport · astăzi';

  @override
  String progressIntakeDate(String date) {
    return 'Aport · $date';
  }

  @override
  String get progressEstimatedTdee => 'TDEE estimat';

  @override
  String progressBmiStatLabel(String category) {
    return 'IMC · $category';
  }

  @override
  String get progressBmiCategoryUnderweight => 'Subponderal';

  @override
  String get progressBmiCategoryHealthy => 'Greutate normală';

  @override
  String get progressBmiCategoryOverweight => 'Supraponderal';

  @override
  String get progressBmiCategoryObese => 'Obezitate';

  @override
  String get progressHistoryTitle => 'Istoric';

  @override
  String get progressDeleteWeightTitle => 'Ștergi înregistrarea?';

  @override
  String progressDeleteWeightMessage(String date) {
    return 'Elimini înregistrarea de greutate pentru $date?';
  }

  @override
  String get progressWeightLogSheetTitle => 'Înregistrează greutate';

  @override
  String get progressWeightFieldLabel => 'Greutate';

  @override
  String get progressWeightSuffixKg => 'kg';

  @override
  String get progressWeightDateLabel => 'Data';

  @override
  String get progressWeightNoteLabel => 'Notă (opțional)';

  @override
  String get progressWeightSave => 'Salvează';

  @override
  String get progressWeightSaving => 'Se salvează…';

  @override
  String get progressWeightInvalid => 'Introdu o greutate validă (0–500 kg)';

  @override
  String get progressWeightLoggedSnack => 'Greutate înregistrată';

  @override
  String get progressWeightSaveFailedSnack =>
      'Nu s-a putut salva. Încearcă din nou.';

  @override
  String get progressChartTargetLabel => 'țintă';

  @override
  String progressBmiChipPrefix(String value) {
    return 'IMC $value';
  }

  @override
  String get mealServingDialogTitle => 'Porție';

  @override
  String get mealServingAmountG => 'Cantitate (g)';

  @override
  String get mealRecipeDialogAdd => 'Adaugă';

  @override
  String get mealDialogCancel => 'Anulează';

  @override
  String get createMealTitle => 'Creează masă';

  @override
  String get createMealNameLabel => 'Nume masă';

  @override
  String get createMealFoodItemsHeader => 'Alimente';

  @override
  String get createMealAddFoodButton => 'Adaugă aliment';

  @override
  String get createMealEmptyItems => 'Niciun aliment adăugat';

  @override
  String get createMealTotalNutrition => 'Valori totale';

  @override
  String get createMealSaveButton => 'Salvează masa';

  @override
  String get createMealSnackNameRequired => 'Introdu numele mesei';

  @override
  String get createMealSnackItemsRequired => 'Adaugă cel puțin un aliment';

  @override
  String get createMealSnackSaved => 'Masă salvată';

  @override
  String createMealItemSubtitle(String grams, String cal) {
    return '$grams g • $cal cal';
  }

  @override
  String get createRecipeTitle => 'Creează rețetă';

  @override
  String get recipeNameLabel => 'Nume rețetă';

  @override
  String get recipeDescriptionLabel => 'Descriere (opțional)';

  @override
  String get recipeServingsLabel => 'Număr de porții';

  @override
  String get recipeIngredientsHeader => 'Ingrediente';

  @override
  String get recipeAddIngredient => 'Adaugă ingredient';

  @override
  String get recipeEmptyIngredients => 'Niciun ingredient adăugat';

  @override
  String recipeTotalNutritionServings(String count) {
    return 'Valori totale ($count porții)';
  }

  @override
  String recipeTotalCaloriesLine(String n) {
    return 'Calorii totale: $n';
  }

  @override
  String recipeTotalProteinLine(String n) {
    return 'Proteine totale: $n g';
  }

  @override
  String recipeTotalCarbsLine(String n) {
    return 'Carbohidrați totali: $n g';
  }

  @override
  String recipeTotalFatLine(String n) {
    return 'Grăsimi totale: $n g';
  }

  @override
  String get recipePerServingHeader => 'Per porție';

  @override
  String recipePerServingCalories(String n) {
    return 'Calorii: $n';
  }

  @override
  String recipePerServingProtein(String n) {
    return 'Proteine: $n g';
  }

  @override
  String recipePerServingCarbs(String n) {
    return 'Carbohidrați: $n g';
  }

  @override
  String recipePerServingFat(String n) {
    return 'Grăsimi: $n g';
  }

  @override
  String get recipeSaveButton => 'Salvează rețeta';

  @override
  String get recipeSnackNameRequired => 'Introdu numele rețetei';

  @override
  String get recipeSnackIngredientsRequired => 'Adaugă cel puțin un ingredient';

  @override
  String get recipeSnackServingsInvalid => 'Introdu un număr valid de porții';

  @override
  String get recipeSnackSaved => 'Rețetă salvată';

  @override
  String recipeIngredientSubtitle(String grams, String cal) {
    return '$grams g • $cal cal';
  }

  @override
  String get myMealsScreenTitle => 'Mesele mele';

  @override
  String get myMealsCreateTooltip => 'Creează masă';

  @override
  String get myMealsEmpty => 'Încă nu ai mese salvate';

  @override
  String get myMealsCreateFirst => 'Creează prima masă';

  @override
  String myMealsCardSubtitle(String cal, String p, String c, String f) {
    return '$cal cal • P: $p g • C: $c g • F: $f g';
  }

  @override
  String get myMealsAddToDiaryTooltip => 'Adaugă în jurnal';

  @override
  String get myMealsDeleteTooltip => 'Șterge';

  @override
  String get myMealsDeleteTitle => 'Ștergi masa?';

  @override
  String myMealsDeleteConfirm(String name) {
    return 'Ștergi „$name”?';
  }

  @override
  String myMealsAddedSnack(String name) {
    return '$name a fost adăugată în jurnal!';
  }

  @override
  String myMealsPartialSnack(String added, String total, String failed) {
    return 'Adăugate $added / $total elemente ($failed eșuate — alimentele pot lipsi).';
  }

  @override
  String get myRecipesScreenTitle => 'Rețetele mele';

  @override
  String get myRecipesCreateTooltip => 'Creează rețetă';

  @override
  String get myRecipesEmpty => 'Încă nu ai rețete salvate';

  @override
  String get myRecipesCreateFirst => 'Creează prima rețetă';

  @override
  String myRecipesCardSubtitle(String cal, String servings, String p) {
    return '$cal cal/porție • $servings porții • P: $p g';
  }

  @override
  String myRecipesAddedSnack(String name) {
    return '$name (1 porție) adăugată în jurnal!';
  }

  @override
  String myRecipesPartialSnack(String added, String total, String failed) {
    return '$added / $total ingrediente înregistrate ($failed eșuate — alimentele pot lipsi).';
  }

  @override
  String get myRecipesDeleteTitle => 'Ștergi rețeta?';

  @override
  String myRecipesDeleteConfirm(String name) {
    return 'Ștergi „$name”?';
  }

  @override
  String get addMealTitle => 'Adaugă masă';

  @override
  String get addMealSearchLabel => 'Caută aliment';

  @override
  String get addMealSearchHint => 'ex.: orez, pui, măr';

  @override
  String get addMealNoResults => 'Niciun rezultat';

  @override
  String addMealSearchResultLine(String cal, String p, String c, String f) {
    return '$cal cal/100g • P: $p g • C: $c g • F: $f g';
  }

  @override
  String get addMealMealTypeLabel => 'Tip masă';

  @override
  String get addMealSelectMealType => 'Alege tipul mesei';

  @override
  String get addMealFoodNameLabel => 'Nume aliment';

  @override
  String get addMealFoodNameRequired => 'Introdu numele alimentului';

  @override
  String get addMealCaloriesLabel => 'Calorii';

  @override
  String get addMealCaloriesRequired => 'Introdu caloriile';

  @override
  String get addMealCaloriesInvalid => 'Introdu un număr valid';

  @override
  String get addMealProteinLabel => 'Proteine (g)';

  @override
  String get addMealProteinRequired => 'Introdu proteinele';

  @override
  String get addMealProteinInvalid => 'Introdu un număr valid';

  @override
  String get addMealCarbsLabel => 'Carbohidrați (g)';

  @override
  String get addMealCarbsRequired => 'Introdu carbohidrații';

  @override
  String get addMealCarbsInvalid => 'Introdu un număr valid';

  @override
  String get addMealFatsLabel => 'Grăsimi (g)';

  @override
  String get addMealFatsRequired => 'Introdu grăsimile';

  @override
  String get addMealFatsInvalid => 'Introdu un număr valid';

  @override
  String get addMealSubmitButton => 'Adaugă masa';

  @override
  String get addMealSuccessSnack => 'Masă înregistrată local';

  @override
  String get foodDetailTitle => 'Detalii aliment';

  @override
  String get foodDetailPer100 => 'La 100 g';

  @override
  String get foodDetailPortionTitle => 'Porție';

  @override
  String get foodDetailMealTypeLabel => 'Masă';

  @override
  String foodDetailServingSizeLabel(String unit) {
    return 'Mărime porție ($unit)';
  }

  @override
  String get foodDetailServingsLabel => 'Porții';

  @override
  String get foodDetailTotalsTitle => 'Total';

  @override
  String get foodDetailValidationPortions =>
      'Introdu mărimea porției și numărul de porții';

  @override
  String get foodDetailSaveFailedSnack =>
      'Nu s-a putut salva în jurnal. Verifică conexiunea.';

  @override
  String get foodDetailAddedSnack => 'Adăugat în jurnal';

  @override
  String get foodDetailAddToDiary => 'Adaugă în jurnal';

  @override
  String get foodDetailSaving => 'Se salvează…';

  @override
  String get foodManualTitle => 'Adaugă aliment manual';

  @override
  String get foodManualSectionBasics => 'Bază';

  @override
  String get foodManualSectionPortion => 'Porție';

  @override
  String get foodManualSectionNutrition => 'Valori (per porție)';

  @override
  String get foodManualFoodNameLabel => 'Nume aliment';

  @override
  String get foodManualBrandLabel => 'Marcă (opțional)';

  @override
  String get foodManualServingSizeG => 'Mărime porție (g)';

  @override
  String get foodManualValidationName => 'Introdu numele alimentului';

  @override
  String get foodManualValidationCalories => 'Introdu caloriile';

  @override
  String get foodManualSaveFailedGeneric =>
      'Nu s-a putut salva alimentul. Încearcă din nou.';

  @override
  String get foodManualSavedAndLoggedSnack =>
      'Aliment salvat și adăugat în jurnal!';

  @override
  String get foodManualSavedLogFailedSnack =>
      'Aliment salvat — adăugarea în jurnal a eșuat.';

  @override
  String get foodManualAddToDiary => 'Adaugă în jurnal';

  @override
  String get foodManualSaving => 'Se salvează…';

  @override
  String get foodEditTitle => 'Editează înregistrarea';

  @override
  String get foodEditMealTypeLabel => 'Masă';

  @override
  String get foodEditFoodNameLabel => 'Nume aliment';

  @override
  String get foodEditServingSizeG => 'Mărime porție (g)';

  @override
  String get foodEditServingsLabel => 'Număr de porții';

  @override
  String get foodEditCaloriesLabel => 'Calorii';

  @override
  String get foodEditProteinLabel => 'Proteine (g)';

  @override
  String get foodEditCarbsLabel => 'Carbohidrați (g)';

  @override
  String get foodEditFatLabel => 'Grăsimi (g)';

  @override
  String get foodEditSaveButton => 'Salvează modificările';

  @override
  String get foodEditSaving => 'Se salvează…';

  @override
  String get foodEditMealTypeRequired => 'Alege masa';

  @override
  String get foodEditNameRequired => 'Introdu numele alimentului';

  @override
  String get foodEditCaloriesRequired => 'Introdu caloriile';

  @override
  String get foodEditUpdatedSnack => 'Înregistrare actualizată';

  @override
  String get foodEditSaveFailedSnack => 'Nu s-au putut salva modificările';

  @override
  String get aiOnboardingIntro =>
      'Răspunde unde e cazul. Poți combina obiective (ex. slăbit + masă musculară) și folosi câmpurile de text când opțiunile nu acoperă tot.';

  @override
  String get aiOnboardingAppBarTitle => 'Configurare coach';

  @override
  String get aiOnboardingSaveDraft => 'Salvează ciorna';

  @override
  String get aiOnboardingFinishButton => 'Finalizează și începe chatul';

  @override
  String get aiOnboardingSnackRequiredFields =>
      'Alege cel puțin un obiectiv, abordarea și tipul de dietă ca să termini.';

  @override
  String get aiOnboardingSnackSaveFailed =>
      'Nu s-a putut salva. Verifică conexiunea.';

  @override
  String get aiOnboardingSnackDraftSaved => 'Ciornă salvată.';

  @override
  String get aiOnboardingSectionGoalsTitle => 'Obiectivele tale';

  @override
  String get aiOnboardingSectionGoalsSubtitle => 'Alege unul sau mai multe';

  @override
  String get aiOnboardingNoteMainGoalLabel => 'Alt obiectiv sau context?';

  @override
  String get aiOnboardingNoteMainGoalHint => 'ex. semimaraton în 12 săptămâni';

  @override
  String get aiOnboardingSectionApproachTitle => 'Cum vrei să abordezi?';

  @override
  String get aiOnboardingSectionTrainingTitle => 'Antrenament & activitate';

  @override
  String get aiOnboardingSectionTrainingSubtitle =>
      'Influențează țintele de calorii și proteine';

  @override
  String get aiOnboardingLabelTrainingSessionsPerWeek =>
      'Ședințe de antrenament pe săptămână';

  @override
  String get aiOnboardingLabelTrainingTypes =>
      'Tipuri de antrenament (bifează tot ce se aplică)';

  @override
  String get aiOnboardingLabelSessionIntensity =>
      'Intensitate tipică a ședinței';

  @override
  String get aiOnboardingLabelJobActivity => 'Activitate la serviciu';

  @override
  String get aiOnboardingLabelDailySteps => 'Pași zilnici medii';

  @override
  String get aiOnboardingNoteTrainingLabel => 'Note antrenament';

  @override
  String get aiOnboardingNoteTrainingHint => 'ex. split push/pull/picioare';

  @override
  String get aiOnboardingSectionDietTitle => 'Tip de dietă';

  @override
  String get aiOnboardingNoteDietaryLabel => 'Note / restricții alimentare';

  @override
  String get aiOnboardingNoteDietaryHint =>
      'ex. low-FODMAP, post, program de post';

  @override
  String get aiOnboardingLabelAllergies => 'Alergii sau intoleranțe';

  @override
  String get aiOnboardingHintAllergies => 'ex. arahide, lactoză';

  @override
  String get aiOnboardingLabelDisliked => 'Alimente neplăcute';

  @override
  String get aiOnboardingHintDisliked => 'ex. ciuperci, ficat';

  @override
  String get aiOnboardingLabelFavorites => 'Alimente preferate';

  @override
  String get aiOnboardingHintFavorites => 'ex. pui, orez, iaurt';

  @override
  String get aiOnboardingLabelCuisines => 'Bucătării preferate';

  @override
  String get aiOnboardingHintCuisines => 'ex. italiană, japoneză';

  @override
  String get aiOnboardingLabelEatingOut => 'Frecvența mesei în oraș';

  @override
  String get aiOnboardingSectionCookingTitle => 'Gătit & buget';

  @override
  String get aiOnboardingLabelCookingPreference => 'Preferințe de gătit';

  @override
  String get aiOnboardingLabelBudget => 'Sensibilitate la buget';

  @override
  String get aiOnboardingLabelMealsPerDay => 'Mese pe zi';

  @override
  String get aiOnboardingSectionLifestyleTitle => 'Stil de viață & recuperare';

  @override
  String get aiOnboardingSectionLifestyleSubtitle =>
      'Energie, pofte, consecvență';

  @override
  String get aiOnboardingLabelSleep => 'Somn mediu';

  @override
  String get aiOnboardingLabelStress => 'Nivel de stres tipic';

  @override
  String get aiOnboardingLabelWater => 'Consum de apă';

  @override
  String get aiOnboardingLabelAlcohol => 'Frecvența alcoolului';

  @override
  String get aiOnboardingSectionStrugglesTitle => 'Ce te împiedică de obicei?';

  @override
  String get aiOnboardingLabelBiggestStruggles =>
      'Provocări principale (alege oricare)';

  @override
  String get aiOnboardingNoteStruggleLabel => 'Altceva ce te ține pe loc?';

  @override
  String get aiOnboardingNoteStruggleHint => 'ex. ture de noapte, weekenduri';

  @override
  String get aiOnboardingLabelStruggleWhen => 'Când e cel mai greu?';

  @override
  String get aiOnboardingSectionMotivationTitle => 'Motivație & structură';

  @override
  String get aiOnboardingLabelMotivation => 'Nivel de motivație';

  @override
  String get aiOnboardingLabelStructure => 'Cât de multă structură vrei?';

  @override
  String get aiOnboardingSectionCoachToneTitle => 'Tonul coachului';

  @override
  String get aiOnboardingGoalLoseWeight => 'Slăbit';

  @override
  String get aiOnboardingGoalGainMuscle => 'Masă musculară';

  @override
  String get aiOnboardingGoalMaintain => 'Menținere greutate';

  @override
  String get aiOnboardingGoalEatHealthier => 'Mâncat mai sănătos';

  @override
  String get aiOnboardingGoalImproveEnergy => 'Mai multă energie';

  @override
  String get aiOnboardingGoalImprovePerformance => 'Performanță sportivă';

  @override
  String get aiOnboardingGoalImproveConsistency => 'Consecvență';

  @override
  String get aiOnboardingApproachAggressive => 'Agresiv';

  @override
  String get aiOnboardingApproachBalanced => 'Echilibrat';

  @override
  String get aiOnboardingApproachFlexible => 'Flexibil';

  @override
  String get aiOnboardingApproachSustainable => 'Lent & durabil';

  @override
  String get aiOnboardingTrainingSessions7Plus => '7+';

  @override
  String get aiOnboardingTrainingLifting => 'Forță / ridicări';

  @override
  String get aiOnboardingTrainingCardio => 'Cardio';

  @override
  String get aiOnboardingTrainingHiit => 'HIIT / intermitent';

  @override
  String get aiOnboardingTrainingSports => 'Sport de echipă';

  @override
  String get aiOnboardingTrainingRunning => 'Alergare';

  @override
  String get aiOnboardingTrainingCycling => 'Ciclism';

  @override
  String get aiOnboardingTrainingSwimming => 'Înot';

  @override
  String get aiOnboardingTrainingYoga => 'Yoga / mobilitate';

  @override
  String get aiOnboardingTrainingWalking => 'Mers pe jos';

  @override
  String get aiOnboardingTrainingNone => 'Nimic momentan';

  @override
  String get aiOnboardingIntensityLight => 'Ușor';

  @override
  String get aiOnboardingIntensityModerate => 'Moderat';

  @override
  String get aiOnboardingIntensityHard => 'Intens';

  @override
  String get aiOnboardingIntensityVeryHard => 'Foarte intens';

  @override
  String get aiOnboardingJobDesk => 'În mare parte la birou';

  @override
  String get aiOnboardingJobMostlySeated => 'Așezat, cu mișcare ocazională';

  @override
  String get aiOnboardingJobOnFeet => 'Mult timp în picioare';

  @override
  String get aiOnboardingJobPhysicalLabor => 'Muncă fizică';

  @override
  String get aiOnboardingStepsUnder5k => '< 5k pași';

  @override
  String get aiOnboardingSteps5k7k => '5–7k';

  @override
  String get aiOnboardingSteps7k10k => '7–10k';

  @override
  String get aiOnboardingSteps10k15k => '10–15k';

  @override
  String get aiOnboardingStepsOver15k => '15k+';

  @override
  String get aiOnboardingDietOmnivore => 'Omnivor';

  @override
  String get aiOnboardingDietVegetarian => 'Vegetarian';

  @override
  String get aiOnboardingDietVegan => 'Vegan';

  @override
  String get aiOnboardingDietPescatarian => 'Pescetarian';

  @override
  String get aiOnboardingDietOther => 'Altul';

  @override
  String get aiOnboardingEatingOutRarely => 'Rareori';

  @override
  String get aiOnboardingEatingOutWeekly => '1–2× / săpt.';

  @override
  String get aiOnboardingEatingOutOften => '3–5× / săpt.';

  @override
  String get aiOnboardingEatingOutDaily => 'Zilnic';

  @override
  String get aiOnboardingCookingNone => 'Nu gătesc';

  @override
  String get aiOnboardingCookingSimple => 'Doar mese simple';

  @override
  String get aiOnboardingCookingEnjoys => 'Îmi place să gătesc';

  @override
  String get aiOnboardingBudgetLow => 'Nu e o problemă';

  @override
  String get aiOnboardingBudgetMedium => 'Oarecum';

  @override
  String get aiOnboardingBudgetHigh => 'Buget foarte limitat';

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
  String get aiOnboardingStressLow => 'Scăzut';

  @override
  String get aiOnboardingStressMedium => 'Mediu';

  @override
  String get aiOnboardingStressHigh => 'Ridicat';

  @override
  String get aiOnboardingWaterLow => 'Puțin';

  @override
  String get aiOnboardingWaterMedium => 'Mediu';

  @override
  String get aiOnboardingWaterHigh => 'Mult';

  @override
  String get aiOnboardingAlcoholNone => 'Deloc';

  @override
  String get aiOnboardingAlcoholOccasional => 'Ocazional';

  @override
  String get aiOnboardingAlcoholWeekly => '1–2× / săpt.';

  @override
  String get aiOnboardingAlcoholFrequent => '3+ / săpt.';

  @override
  String get aiOnboardingStruggleCravings => 'Pofte';

  @override
  String get aiOnboardingStruggleConsistency => 'Consecvență';

  @override
  String get aiOnboardingStruggleLateNight => 'Mâncat noaptea';

  @override
  String get aiOnboardingStruggleEmotional => 'Mâncat emoțional';

  @override
  String get aiOnboardingStruggleBoredom => 'Plictiseală';

  @override
  String get aiOnboardingStruggleTime => 'Lipsă de timp';

  @override
  String get aiOnboardingStruggleSocial => 'Social / restaurant';

  @override
  String get aiOnboardingStruggleTravel => 'Călătorii';

  @override
  String get aiOnboardingStrugglePortions => 'Control porții';

  @override
  String get aiOnboardingStrugglePlanning => 'Planificare mese';

  @override
  String get aiOnboardingTimingMorning => 'Dimineața';

  @override
  String get aiOnboardingTimingAfternoon => 'După-amiază';

  @override
  String get aiOnboardingTimingEvening => 'Seara';

  @override
  String get aiOnboardingTimingNight => 'Noaptea târziu';

  @override
  String get aiOnboardingTimingWeekends => 'Weekend';

  @override
  String get aiOnboardingTimingStress => 'Când sunt stresat';

  @override
  String get aiOnboardingMotivationLow => 'Scăzută';

  @override
  String get aiOnboardingMotivationMedium => 'Medie';

  @override
  String get aiOnboardingMotivationHigh => 'Ridicată';

  @override
  String get aiOnboardingStructureLow => 'Ghidare lejeră';

  @override
  String get aiOnboardingStructureMedium => 'Plan echilibrat';

  @override
  String get aiOnboardingStructureHigh => 'Plan detaliat';

  @override
  String get aiOnboardingToneDirect => 'Direct';

  @override
  String get aiOnboardingToneBalanced => 'Echilibrat';

  @override
  String get aiOnboardingToneGentler => 'Mai blând';

  @override
  String get createRecipeEnterAmountTitle => 'Cantitate ingredient';

  @override
  String nutritionTotalCalories(String n) {
    return 'Calorii: $n';
  }

  @override
  String nutritionTotalProtein(String n) {
    return 'Proteine: $n g';
  }

  @override
  String nutritionTotalCarbs(String n) {
    return 'Carbohidrați: $n g';
  }

  @override
  String nutritionTotalFat(String n) {
    return 'Grăsimi: $n g';
  }

  @override
  String get aiCoachErrorReplyFailed =>
      'Coachul nu poate răspunde acum. Verifică conexiunea și încearcă din nou.';

  @override
  String get aiCoachErrorNewChatFailed =>
      'Nu s-a putut începe un chat nou. Verifică conexiunea și încearcă din nou.';
}
