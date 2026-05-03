import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Casual user preferences that persist across app launches.
///
/// Kept intentionally small — anything dev-only (backend URL, user id, etc.)
/// belongs elsewhere.
class PreferencesProvider extends ChangeNotifier {
  PreferencesProvider({
    bool showCoachTips = true,
    bool confirmDelete = true,
    bool haptics = true,
    String weightUnit = 'kg',
  })  : _showCoachTips = showCoachTips,
        _confirmDelete = confirmDelete,
        _haptics = haptics,
        _weightUnit = weightUnit;

  static const _kShowCoachTips = 'pref_show_coach_tips';
  static const _kConfirmDelete = 'pref_confirm_delete';
  static const _kHaptics       = 'pref_haptics';
  static const _kWeightUnit    = 'pref_weight_unit'; // 'kg' or 'lb'

  bool   _showCoachTips;
  bool   _confirmDelete;
  bool   _haptics;
  String _weightUnit;

  bool   get showCoachTips => _showCoachTips;
  bool   get confirmDelete => _confirmDelete;
  bool   get haptics       => _haptics;
  String get weightUnit    => _weightUnit;

  /// Load all preferences synchronously from a [SharedPreferences] handle.
  /// Call from `main()` after `await SharedPreferences.getInstance()`.
  static PreferencesProvider readInitial(SharedPreferences prefs) {
    return PreferencesProvider(
      showCoachTips: prefs.getBool(_kShowCoachTips) ?? true,
      confirmDelete: prefs.getBool(_kConfirmDelete) ?? true,
      haptics:       prefs.getBool(_kHaptics) ?? true,
      weightUnit:    prefs.getString(_kWeightUnit) ?? 'kg',
    );
  }

  Future<void> setShowCoachTips(bool v) async {
    if (_showCoachTips == v) return;
    _showCoachTips = v;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kShowCoachTips, v);
  }

  Future<void> setConfirmDelete(bool v) async {
    if (_confirmDelete == v) return;
    _confirmDelete = v;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kConfirmDelete, v);
  }

  Future<void> setHaptics(bool v) async {
    if (_haptics == v) return;
    _haptics = v;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kHaptics, v);
  }

  Future<void> setWeightUnit(String unit) async {
    final next = unit == 'lb' ? 'lb' : 'kg';
    if (_weightUnit == next) return;
    _weightUnit = next;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_kWeightUnit, next);
  }

  /// Convenience: trigger a light-impact haptic only when [haptics] is on.
  void hapticLight() {
    if (!_haptics) return;
    HapticFeedback.lightImpact();
  }

  /// Convenience: trigger a selection haptic only when [haptics] is on.
  void hapticSelect() {
    if (!_haptics) return;
    HapticFeedback.selectionClick();
  }

  /// Format kg in the user's preferred unit.
  String formatWeight(double kg, {int fractionDigits = 1}) {
    if (_weightUnit == 'lb') {
      final lb = kg * 2.20462262;
      return '${lb.toStringAsFixed(fractionDigits)} lb';
    }
    return '${kg.toStringAsFixed(fractionDigits)} kg';
  }
}
