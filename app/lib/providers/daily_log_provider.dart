import 'package:flutter/foundation.dart';

import '../models/daily_log.dart';
import '../models/food_entry.dart';
import '../services/diary_api_service.dart';

/// State for the user's diary (entries) + targets (goals).
///
/// All mutations go through the backend first, then update local state so
/// everything survives an app restart. Entries and goals are cached per
/// (userId, date) so switching between tabs is instant.
class DailyLogProvider extends ChangeNotifier {
  DailyLogProvider({DiaryApiService? api}) : _api = api ?? DiaryApiService();

  final DiaryApiService _api;

  /// Firebase UID of the signed-in user. `null` means no user is signed in
  /// yet; all write operations are no-ops in that state.
  String? _userId;

  /// Logs cached in memory, keyed by `YYYY-M-D`.
  final Map<String, DailyLog> _logsByDate = {};

  DateTime _selectedDate = DateTime.now();

  double _calorieGoal = 2000;
  double _proteinGoal = 150;
  double _carbsGoal   = 250;
  double _fatGoal     = 65;

  bool _loading = false;

  /// Set when [listFoodLogs] fails so the UI can show a banner instead of
  /// looking like an empty diary.
  String? _diaryLoadError;

  // ----------------------------------------------------------------------- //
  // Public state                                                            //
  // ----------------------------------------------------------------------- //

  String? get userId => _userId;
  bool    get isLoading => _loading;
  String? get diaryLoadError => _diaryLoadError;
  DateTime get selectedDate => _selectedDate;
  DateTime get date => _selectedDate; // backward compat

  double get calorieGoal => _calorieGoal;
  double get proteinGoal => _proteinGoal;
  double get carbsGoal   => _carbsGoal;
  double get fatGoal     => _fatGoal;

  List<FoodEntry> get entries => _currentLog.entries;

  double get totalCalories =>
      entries.fold(0.0, (s, e) => s + e.totalCalories);
  double get totalProtein =>
      entries.fold(0.0, (s, e) => s + e.totalProtein);
  double get totalCarbs =>
      entries.fold(0.0, (s, e) => s + e.totalCarbs);
  double get totalFat =>
      entries.fold(0.0, (s, e) => s + e.totalFat);

  Map<String, List<FoodEntry>> get entriesByMealType {
    final out = <String, List<FoodEntry>>{};
    for (final e in entries) {
      out.putIfAbsent(e.mealType, () => []).add(e);
    }
    return out;
  }

  // ----------------------------------------------------------------------- //
  // Auth + date switching                                                   //
  // ----------------------------------------------------------------------- //

  /// Called by `AuthGate` (or equivalent) whenever the Firebase auth state
  /// changes. Pass `null` to clear all local state on sign-out.
  Future<void> setUser(String? userId) async {
    if (_userId == userId) return;

    _userId = userId;
    _logsByDate.clear();

    if (userId == null) {
      _calorieGoal = 2000;
      _proteinGoal = 150;
      _carbsGoal   = 250;
      _fatGoal     = 65;
      _diaryLoadError = null;
      notifyListeners();
      return;
    }

    _diaryLoadError = null;
    notifyListeners();
    await _loadGoals();
    await _loadEntriesFor(_selectedDate);
  }

  /// Change the day being viewed. Triggers a backend fetch if we don't have
  /// that day cached locally.
  Future<void> setSelectedDate(DateTime date) async {
    final d = DateTime(date.year, date.month, date.day);
    if (_sameDay(d, _selectedDate) && _logsByDate.containsKey(_dateKey(d))) {
      _selectedDate = d;
      notifyListeners();
      return;
    }
    _selectedDate = d;
    notifyListeners();

    if (_userId != null) {
      await _loadEntriesFor(d);
    }
  }

  /// Force a reload of the currently-selected day from the backend.
  Future<void> refresh() async {
    if (_userId == null) return;
    _diaryLoadError = null;
    _logsByDate.remove(_dateKey(_selectedDate));
    await _loadEntriesFor(_selectedDate);
  }

  /// Clears [diaryLoadError] without fetching (e.g. user dismissed a banner).
  void clearDiaryLoadError() {
    if (_diaryLoadError == null) return;
    _diaryLoadError = null;
    notifyListeners();
  }

  // ----------------------------------------------------------------------- //
  // Entries — add / update / remove                                         //
  // ----------------------------------------------------------------------- //

  /// Create an entry from a food catalog row (POST /food-logs).
  /// Returns the persisted entry (with server-assigned logId) on success,
  /// or `null` on failure (an error snackbar is the caller's responsibility).
  Future<FoodEntry?> addEntryForFood({
    required String foodId,
    required String mealType,
    required double grams,
    required double servings,
  }) async {
    final uid = _userId;
    if (uid == null) return null;

    final created = await _api.createFoodLog(
      userId:     uid,
      foodId:     foodId,
      loggedDate: _selectedDate,
      mealType:   mealType,
      grams:      grams,
      servings:   servings,
    );

    if (created == null) return null;

    final log = _getOrCreateLog(_selectedDate);
    log.entries.add(created);
    notifyListeners();
    return created;
  }

  /// Persist a user-edited entry.
  Future<bool> updateEntry(FoodEntry oldEntry, FoodEntry newEntry) async {
    final uid = _userId;
    final logId = oldEntry.logId;
    if (uid == null || logId == null) {
      // Local-only fallback (e.g. sync failed earlier).
      _replaceLocal(oldEntry, newEntry);
      return false;
    }

    final updated = await _api.updateFoodLog(
      logId:      logId,
      userId:     uid,
      mealType:   newEntry.mealType,
      grams:      newEntry.servingSize,
      servings:   newEntry.servings,
      foodName:   newEntry.foodName,
      calories:   newEntry.totalCalories,
      protein:    newEntry.totalProtein,
      carbs:      newEntry.totalCarbs,
      fat:        newEntry.totalFat,
    );

    if (updated == null) return false;

    _replaceLocal(oldEntry, updated);
    return true;
  }

  /// Delete an entry (backend + local).
  Future<bool> removeEntry(FoodEntry entry) async {
    final uid = _userId;
    final logId = entry.logId;
    if (uid == null || logId == null) {
      _removeLocal(entry);
      return false;
    }

    final ok = await _api.deleteFoodLog(logId: logId, userId: uid);
    if (ok) _removeLocal(entry);
    return ok;
  }

  /// Legacy helper used by `DiaryScreen`.
  Future<void> removeEntryAt(int index) async {
    final list = _currentLog.entries;
    if (index < 0 || index >= list.length) return;
    await removeEntry(list[index]);
  }

  // ----------------------------------------------------------------------- //
  // Goals                                                                   //
  // ----------------------------------------------------------------------- //

  Future<bool> updateGoals({
    double? calorieGoal,
    double? proteinGoal,
    double? carbsGoal,
    double? fatGoal,
  }) async {
    final uid = _userId;
    final next = {
      'calorie_goal': calorieGoal ?? _calorieGoal,
      'protein_goal': proteinGoal ?? _proteinGoal,
      'carbs_goal':   carbsGoal   ?? _carbsGoal,
      'fat_goal':     fatGoal     ?? _fatGoal,
    };

    if (uid == null) {
      _calorieGoal = next['calorie_goal']!;
      _proteinGoal = next['protein_goal']!;
      _carbsGoal   = next['carbs_goal']!;
      _fatGoal     = next['fat_goal']!;
      notifyListeners();
      return false;
    }

    final saved = await _api.putGoals(
      userId:      uid,
      calorieGoal: next['calorie_goal']!,
      proteinGoal: next['protein_goal']!,
      carbsGoal:   next['carbs_goal']!,
      fatGoal:     next['fat_goal']!,
    );

    if (saved != null) {
      _calorieGoal = saved.calorieGoal;
      _proteinGoal = saved.proteinGoal;
      _carbsGoal   = saved.carbsGoal;
      _fatGoal     = saved.fatGoal;
    } else {
      // Keep the optimistic update so the UI isn't empty.
      _calorieGoal = next['calorie_goal']!;
      _proteinGoal = next['protein_goal']!;
      _carbsGoal   = next['carbs_goal']!;
      _fatGoal     = next['fat_goal']!;
    }

    notifyListeners();
    return saved != null;
  }

  // ----------------------------------------------------------------------- //
  // Internals                                                               //
  // ----------------------------------------------------------------------- //

  DailyLog get _currentLog => _getOrCreateLog(_selectedDate);

  DailyLog _getOrCreateLog(DateTime d) {
    final key = _dateKey(d);
    return _logsByDate.putIfAbsent(key, () => DailyLog(date: d));
  }

  Future<void> _loadEntriesFor(DateTime d) async {
    final uid = _userId;
    if (uid == null) return;

    _loading = true;
    _diaryLoadError = null;
    notifyListeners();
    try {
      final rows = await _api.listFoodLogs(userId: uid, date: d);
      if (rows == null) {
        _diaryLoadError =
            'Could not load your diary. Check your connection and try again.';
        _loading = false;
        notifyListeners();
        return;
      }
      final log = DailyLog(
        date: d,
        calorieGoal: _calorieGoal,
        proteinGoal: _proteinGoal,
        carbsGoal:   _carbsGoal,
        fatGoal:     _fatGoal,
        entries:     rows,
      );
      _logsByDate[_dateKey(d)] = log;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadGoals() async {
    final uid = _userId;
    if (uid == null) return;
    final g = await _api.getGoals(uid);
    _calorieGoal = g.calorieGoal;
    _proteinGoal = g.proteinGoal;
    _carbsGoal   = g.carbsGoal;
    _fatGoal     = g.fatGoal;
    notifyListeners();
  }

  void _replaceLocal(FoodEntry oldEntry, FoodEntry newEntry) {
    // An edit might change the diary date; move the row between caches.
    bool moved = false;
    for (final log in _logsByDate.values) {
      final idx = log.entries.indexOf(oldEntry);
      if (idx == -1) continue;
      if (_sameDay(log.date, newEntry.loggedDate)) {
        log.entries[idx] = newEntry;
      } else {
        log.entries.removeAt(idx);
        _getOrCreateLog(newEntry.loggedDate).entries.add(newEntry);
      }
      moved = true;
      break;
    }
    if (!moved) {
      _getOrCreateLog(newEntry.loggedDate).entries.add(newEntry);
    }
    notifyListeners();
  }

  void _removeLocal(FoodEntry entry) {
    for (final log in _logsByDate.values) {
      if (log.entries.remove(entry)) {
        notifyListeners();
        return;
      }
    }
  }

  static String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
