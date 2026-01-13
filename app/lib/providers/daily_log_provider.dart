import 'package:flutter/foundation.dart';
import '../models/daily_log.dart';
import '../models/food_entry.dart';

class DailyLogProvider extends ChangeNotifier {
  // Store logs by date (date string as key)
  final Map<String, DailyLog> _logsByDate = {};
  DateTime _selectedDate = DateTime.now();

  DailyLogProvider({DailyLog? dailyLog}) {
    if (dailyLog != null) {
      final dateKey = _getDateKey(dailyLog.date);
      _logsByDate[dateKey] = dailyLog;
      _selectedDate = dailyLog.date;
    } else {
      _selectedDate = DateTime.now();
    }
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  /// Get current selected date
  DateTime get selectedDate => _selectedDate;

  /// Get current daily log for selected date
  DailyLog get dailyLog {
    final dateKey = _getDateKey(_selectedDate);
    return _logsByDate[dateKey] ?? DailyLog(date: _selectedDate);
  }

  /// Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  /// Get current date (for backward compatibility)
  DateTime get date => _selectedDate;

  /// Get goals
  double get calorieGoal => dailyLog.calorieGoal;
  double get proteinGoal => dailyLog.proteinGoal;
  double get carbsGoal => dailyLog.carbsGoal;
  double get fatGoal => dailyLog.fatGoal;

  /// Get totals (computed from entries)
  double get totalCalories => dailyLog.totalCalories;
  double get totalProtein => dailyLog.totalProtein;
  double get totalCarbs => dailyLog.totalCarbs;
  double get totalFat => dailyLog.totalFat;

  /// Get entries
  List<FoodEntry> get entries => dailyLog.entries;

  /// Get entries grouped by meal type
  Map<String, List<FoodEntry>> get entriesByMealType =>
      dailyLog.entriesByMealType;

  /// Add a food entry
  void addEntry(FoodEntry entry) {
    final log = dailyLog;
    log.entries.add(entry);
    _logsByDate[_getDateKey(_selectedDate)] = log;
    notifyListeners();
  }

  /// Update a food entry
  void updateEntry(FoodEntry oldEntry, FoodEntry newEntry) {
    final log = dailyLog;
    final index = log.entries.indexOf(oldEntry);
    if (index != -1) {
      log.entries[index] = newEntry;
      _logsByDate[_getDateKey(_selectedDate)] = log;
      notifyListeners();
    }
  }

  /// Remove a food entry
  void removeEntry(FoodEntry entry) {
    final log = dailyLog;
    log.entries.remove(entry);
    _logsByDate[_getDateKey(_selectedDate)] = log;
    notifyListeners();
  }

  /// Remove entry by index
  void removeEntryAt(int index) {
    final log = dailyLog;
    if (index >= 0 && index < log.entries.length) {
      log.entries.removeAt(index);
      _logsByDate[_getDateKey(_selectedDate)] = log;
      notifyListeners();
    }
  }

  /// Update nutrition goals
  void updateGoals({
    double? calorieGoal,
    double? proteinGoal,
    double? carbsGoal,
    double? fatGoal,
  }) {
    final log = dailyLog;
    if (calorieGoal != null) {
      log.calorieGoal = calorieGoal;
    }
    if (proteinGoal != null) {
      log.proteinGoal = proteinGoal;
    }
    if (carbsGoal != null) {
      log.carbsGoal = carbsGoal;
    }
    if (fatGoal != null) {
      log.fatGoal = fatGoal;
    }
    _logsByDate[_getDateKey(_selectedDate)] = log;
    notifyListeners();
  }

  /// Set daily log (useful for loading from Firestore later)
  void setDailyLog(DailyLog log) {
    _logsByDate[_getDateKey(log.date)] = log;
    notifyListeners();
  }

  /// Clear all entries for selected date
  void clearEntries() {
    final log = dailyLog;
    log.entries.clear();
    _logsByDate[_getDateKey(_selectedDate)] = log;
    notifyListeners();
  }
}
