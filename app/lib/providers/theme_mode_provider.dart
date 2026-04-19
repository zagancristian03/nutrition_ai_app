import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists [ThemeMode] (light / dark / system) for the whole app.
class ThemeModeProvider extends ChangeNotifier {
  ThemeModeProvider({ThemeMode initial = ThemeMode.system}) : _themeMode = initial;

  static const _prefsKey = 'theme_mode';

  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  /// Call from [main] after loading [SharedPreferences].
  static ThemeMode readInitial(SharedPreferences prefs) {
    switch (prefs.getString(_prefsKey)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_prefsKey, mode.name);
  }
}
