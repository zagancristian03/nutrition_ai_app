import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../models/weight_entry.dart';
import '../services/profile_api_service.dart';

/// State holder for the user's profile + weight history.
///
/// Wired into the app tree alongside `DailyLogProvider`. `setUser` is called
/// by `AuthGate` whenever Firebase auth state changes so we load / clear
/// data for the right account.
class UserProfileProvider extends ChangeNotifier {
  UserProfileProvider({ProfileApiService? api})
      : _api = api ?? ProfileApiService();

  final ProfileApiService _api;

  String? _userId;
  UserProfile? _profile;
  List<WeightEntry> _weights = const [];

  bool _loadingProfile = false;
  bool _loadingWeights = false;

  // ----------------------------------------------------------------------- //
  // Public state                                                            //
  // ----------------------------------------------------------------------- //

  String?          get userId         => _userId;
  UserProfile?     get profile        => _profile;
  List<WeightEntry> get weights       => _weights;
  bool             get isLoading      => _loadingProfile || _loadingWeights;
  bool             get hasProfileData =>
      _profile != null &&
      (_profile!.currentWeightKg != null ||
          _profile!.heightCm != null ||
          _profile!.dateOfBirth != null);

  /// Most recent weight (or the value stored on the profile), in kg.
  double? get latestWeightKg {
    if (_weights.isNotEmpty) return _weights.last.weightKg;
    return _profile?.currentWeightKg;
  }

  // ----------------------------------------------------------------------- //
  // Auth                                                                    //
  // ----------------------------------------------------------------------- //

  Future<void> setUser(String? userId) async {
    if (_userId == userId) return;

    _userId = userId;
    _profile = null;
    _weights = const [];

    if (userId == null) {
      notifyListeners();
      return;
    }

    notifyListeners();
    await Future.wait([_loadProfile(), _loadWeights()]);
  }

  Future<void> refresh() async {
    if (_userId == null) return;
    await Future.wait([_loadProfile(), _loadWeights()]);
  }

  // ----------------------------------------------------------------------- //
  // Profile                                                                 //
  // ----------------------------------------------------------------------- //

  /// Merge the provided patch into the current profile and push it to the
  /// backend. Returns `true` on success.
  Future<bool> saveProfilePatch({
    String? displayName,
    Sex? sex,
    DateTime? dateOfBirth,
    double? heightCm,
    double? currentWeightKg,
    double? targetWeightKg,
    GoalType? goalType,
    ActivityLevel? activityLevel,
    double? weeklyRateKg,
  }) async {
    final uid = _userId;
    if (uid == null) return false;

    // Build a patch object that ONLY contains the fields we want to write.
    // Pre-populating from the cached profile would send everything and make
    // clearing a field impossible, so we keep it minimal.
    final patch = UserProfile(
      userId:          uid,
      displayName:     displayName,
      sex:             sex,
      dateOfBirth:     dateOfBirth,
      heightCm:        heightCm,
      currentWeightKg: currentWeightKg,
      targetWeightKg:  targetWeightKg,
      goalType:        goalType,
      activityLevel:   activityLevel,
      weeklyRateKg:    weeklyRateKg,
    );

    final saved = await _api.putProfile(patch);
    if (saved == null) return false;

    _profile = saved;
    notifyListeners();
    return true;
  }

  // ----------------------------------------------------------------------- //
  // Weight logs                                                             //
  // ----------------------------------------------------------------------- //

  Future<WeightEntry?> logWeight({
    required double weightKg,
    DateTime? loggedOn,
    String? note,
  }) async {
    final uid = _userId;
    if (uid == null) return null;

    final created = await _api.addWeightLog(
      userId:   uid,
      weightKg: weightKg,
      loggedOn: loggedOn,
      note:     note,
    );
    if (created == null) return null;

    // The backend also bumps user_profiles.current_weight_kg — reflect that
    // locally so subsequent BMR/TDEE calculations are immediately up to date.
    _profile = (_profile ?? UserProfile.empty(uid))
        .copyWith(currentWeightKg: weightKg);

    // Insert in chronological order (upsert on same-day).
    final next = [..._weights];
    final idx = next.indexWhere(
      (w) => _sameDay(w.loggedOn, created.loggedOn),
    );
    if (idx >= 0) {
      next[idx] = created;
    } else {
      next.add(created);
      next.sort((a, b) => a.loggedOn.compareTo(b.loggedOn));
    }
    _weights = next;

    notifyListeners();
    return created;
  }

  Future<bool> deleteWeight(WeightEntry entry) async {
    final uid = _userId;
    final id  = entry.id;
    if (uid == null || id == null) return false;

    final ok = await _api.deleteWeightLog(id: id, userId: uid);
    if (!ok) return false;

    _weights = _weights.where((w) => w.id != id).toList();
    notifyListeners();
    return true;
  }

  // ----------------------------------------------------------------------- //
  // Internals                                                               //
  // ----------------------------------------------------------------------- //

  Future<void> _loadProfile() async {
    final uid = _userId;
    if (uid == null) return;
    _loadingProfile = true;
    notifyListeners();
    try {
      _profile = await _api.getProfile(uid);
    } finally {
      _loadingProfile = false;
      notifyListeners();
    }
  }

  Future<void> _loadWeights() async {
    final uid = _userId;
    if (uid == null) return;
    _loadingWeights = true;
    notifyListeners();
    try {
      _weights = await _api.listWeightLogs(userId: uid, days: 365);
    } finally {
      _loadingWeights = false;
      notifyListeners();
    }
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
