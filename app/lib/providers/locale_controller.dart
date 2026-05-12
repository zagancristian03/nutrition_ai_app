import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import '../models/user_profile.dart';
import '../services/profile_api_service.dart';

/// User-preferred language options the Settings UI can offer (extend here + ARB).
const List<String> kSupportedManualLanguageTags = ['en', 'ro'];

/// Resolves [MaterialApp.locale], AI language, diary IANA timezone, and syncs
/// `user_profiles` with `locale_mode` / `preferred_locale` / `timezone`.
class LocaleController extends ChangeNotifier {
  LocaleController({
    UserLocaleMode mode = UserLocaleMode.system,
    String? preferredLocale,
    String? timezone,
  })  : _mode = mode,
        _preferredLocale = preferredLocale,
        _timezone = timezone;

  static const _kLocaleMode = 'locale_mode';
  static const _kPreferredLocale = 'preferred_locale';
  static const _kTimezone = 'timezone';

  static const List<Locale> _supportedMaterialLocales = [
    Locale('en'),
    Locale('ro'),
  ];

  static UserLocaleMode _parseMode(String? raw) {
    switch (raw) {
      case 'manual':
        return UserLocaleMode.manual;
      default:
        return UserLocaleMode.system;
    }
  }

  /// Must run once before using [diaryDateOnlyUtcInstant] zone lookups.
  static void ensureTimezoneDataLoaded() {
    tzdata.initializeTimeZones();
  }

  static LocaleController readInitial(SharedPreferences prefs) {
    return LocaleController(
      mode: _parseMode(prefs.getString(_kLocaleMode)),
      preferredLocale: prefs.getString(_kPreferredLocale),
      timezone: prefs.getString(_kTimezone),
    );
  }

  UserLocaleMode _mode;
  String? _preferredLocale;
  String? _timezone;

  UserLocaleMode get mode => _mode;
  String? get preferredLocaleWire => _preferredLocale;
  String? get timezoneIana => _timezone;

  void _applyProfile(UserProfile p) {
    _mode = p.localeMode ?? UserLocaleMode.system;
    _preferredLocale = p.preferredLocale;
    if (p.timezone != null && p.timezone!.trim().isNotEmpty) {
      _timezone = p.timezone!.trim();
    }
  }

  bool _localLooksNonDefault() =>
      _mode == UserLocaleMode.manual ||
      (_preferredLocale != null && _preferredLocale!.trim().isNotEmpty) ||
      (_timezone != null && _timezone!.trim().isNotEmpty);

  /// After profile GET: remote wins when it carries explicit locale or TZ;
  /// otherwise push local cache to the profile row (authenticated only).
  /// Returns the profile row to use as the in-memory source of truth (may be
  /// the same object or a refreshed one from PUT).
  Future<UserProfile> syncWithRemoteProfile(
    UserProfile profile,
    ProfileApiService api,
  ) async {
    if (profile.hasExplicitRemoteLocaleSettings) {
      _applyProfile(profile);
      notifyListeners();
      await _persistLocal();
      return profile;
    }
    if (_localLooksNonDefault()) {
      final patch = UserProfile(
        userId: profile.userId,
        localeMode: _mode,
        preferredLocale: _preferredLocale,
        timezone: _timezone,
      );
      final saved = await api.putLocaleSettings(patch);
      if (saved != null) {
        _applyProfile(saved);
        notifyListeners();
        await _persistLocal();
        return saved;
      }
    } else {
      _applyProfile(profile);
    }
    notifyListeners();
    await _persistLocal();
    return profile;
  }

  Future<void> _persistLocal() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      _kLocaleMode,
      _mode == UserLocaleMode.manual ? 'manual' : 'system',
    );
    if (_preferredLocale != null && _preferredLocale!.isNotEmpty) {
      await p.setString(_kPreferredLocale, _preferredLocale!);
    } else {
      await p.remove(_kPreferredLocale);
    }
    if (_timezone != null && _timezone!.isNotEmpty) {
      await p.setString(_kTimezone, _timezone!);
    } else {
      await p.remove(_kTimezone);
    }
  }

  /// Fills [timezoneIana] from the OS when we have no cached value.
  Future<void> refreshDeviceTimezoneIfMissing() async {
    if (_timezone != null && _timezone!.trim().isNotEmpty) return;
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      if (zone.trim().isEmpty) return;
      _timezone = zone.trim();
      notifyListeners();
      await _persistLocal();
    } catch (e) {
      debugPrint('[LocaleController] refreshDeviceTimezoneIfMissing: $e');
    }
  }

  static Locale _fallbackLocale() => const Locale('en');

  static bool _supported(Locale l) {
    for (final s in _supportedMaterialLocales) {
      if (s.languageCode != l.languageCode) continue;
      if (s.countryCode == null || l.countryCode == null) return true;
      if (s.countryCode == l.countryCode) return true;
    }
    return false;
  }

  /// Effective [Locale] for Material/Cupertino (not necessarily AI language).
  Locale resolveMaterialLocale(Locale? platformLocale) {
    if (_mode == UserLocaleMode.manual) {
      final tag = (_preferredLocale ?? '').trim();
      if (tag.isEmpty) return _fallbackLocale();
      return _parseBcp47(tag) ?? _fallbackLocale();
    }
    final device = platformLocale ?? _fallbackLocale();
    if (_supported(device)) return device;
    final langOnly = Locale(device.languageCode);
    if (_supported(langOnly)) return langOnly;
    return _fallbackLocale();
  }

  /// BCP‑47 tag for AI/coaching (explicit manual tag or inferred from device).
  String preferredLocaleForAi(Locale? platformLocale) {
    if (_mode == UserLocaleMode.manual) {
      final t = (_preferredLocale ?? '').trim();
      return t.isNotEmpty ? t : 'en';
    }
    final loc = platformLocale ?? const Locale('en');
    if (loc.countryCode != null && loc.countryCode!.isNotEmpty) {
      return '${loc.languageCode}-${loc.countryCode}';
    }
    return loc.languageCode;
  }

  Future<void> setSystemDefault() async {
    _mode = UserLocaleMode.system;
    _preferredLocale = null;
    notifyListeners();
    await _persistLocal();
  }

  Future<void> setManualLanguage(String bcp47LanguageCode) async {
    if (!kSupportedManualLanguageTags.contains(bcp47LanguageCode)) {
      debugPrint(
        '[LocaleController] unsupported language tag: $bcp47LanguageCode',
      );
      return;
    }
    _mode = UserLocaleMode.manual;
    _preferredLocale = bcp47LanguageCode;
    notifyListeners();
    await _persistLocal();
  }

  Future<void> commitLanguageSelection(
    ProfileApiService api,
    String? userId,
  ) async {
    await _persistLocal();
    if (userId == null) return;
    final patch = UserProfile(
      userId: userId,
      localeMode: _mode,
      preferredLocale: _preferredLocale,
      timezone: _timezone,
    );
    final saved = await api.putLocaleSettings(patch);
    if (saved != null) {
      _applyProfile(saved);
      notifyListeners();
    }
  }

  Locale? _parseBcp47(String tag) {
    final parts = tag.replaceAll('_', '-').split('-');
    if (parts.isEmpty) return null;
    final lang = parts[0].toLowerCase();
    if (parts.length >= 2) {
      final region = parts[1].toUpperCase();
      return Locale.fromSubtags(languageCode: lang, countryCode: region);
    }
    return Locale(lang);
  }
}
