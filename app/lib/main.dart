import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/theme.dart';
import 'firebase_options.dart';
import 'providers/ai_provider.dart';
import 'providers/daily_log_provider.dart';
import 'providers/preferences_provider.dart';
import 'providers/saved_items_provider.dart';
import 'providers/theme_mode_provider.dart';
import 'providers/user_profile_provider.dart';
import 'screens/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  final initialTheme = ThemeModeProvider.readInitial(prefs);
  final initialPrefs = PreferencesProvider.readInitial(prefs);
  runApp(MyApp(initialThemeMode: initialTheme, initialPreferences: initialPrefs));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.initialThemeMode,
    required this.initialPreferences,
  });

  final ThemeMode initialThemeMode;
  final PreferencesProvider initialPreferences;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeModeProvider(initial: initialThemeMode),
        ),
        ChangeNotifierProvider.value(value: initialPreferences),
        ChangeNotifierProvider(create: (_) => DailyLogProvider()),
        ChangeNotifierProvider(create: (_) => SavedItemsProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => AiProvider()),
      ],
      child: Consumer<ThemeModeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
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
