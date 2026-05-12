import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/theme.dart';
import 'firebase_options.dart';
import 'providers/ai_provider.dart';
import 'providers/daily_log_provider.dart';
import 'providers/locale_controller.dart';
import 'providers/preferences_provider.dart';
import 'providers/saved_items_provider.dart';
import 'providers/theme_mode_provider.dart';
import 'providers/user_profile_provider.dart';
import 'screens/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleController.ensureTimezoneDataLoaded();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  final initialTheme = ThemeModeProvider.readInitial(prefs);
  final initialPrefs = PreferencesProvider.readInitial(prefs);
  final localeController = LocaleController.readInitial(prefs);
  await localeController.refreshDeviceTimezoneIfMissing();
  runApp(MyApp(
    initialThemeMode: initialTheme,
    initialPreferences: initialPrefs,
    localeController: localeController,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.initialThemeMode,
    required this.initialPreferences,
    required this.localeController,
  });

  final ThemeMode initialThemeMode;
  final PreferencesProvider initialPreferences;
  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeModeProvider(initial: initialThemeMode),
        ),
        ChangeNotifierProvider.value(value: localeController),
        ChangeNotifierProvider.value(value: initialPreferences),
        ChangeNotifierProvider(
          create: (_) => DailyLogProvider(locale: localeController),
        ),
        ChangeNotifierProvider(create: (_) => SavedItemsProvider()),
        ChangeNotifierProvider(
          create: (_) => UserProfileProvider(locale: localeController),
        ),
        ChangeNotifierProvider(
          create: (_) => AiProvider(locale: localeController),
        ),
      ],
      child: Consumer2<ThemeModeProvider, LocaleController>(
        builder: (context, theme, locale, _) {
          final platformLocale =
              WidgetsBinding.instance.platformDispatcher.locale;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
            locale: locale.resolveMaterialLocale(platformLocale),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            themeMode: theme.themeMode,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
