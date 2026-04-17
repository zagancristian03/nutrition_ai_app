import 'package:flutter/foundation.dart';

/// Biological sex used for BMR calculations.
enum Sex {
  male,
  female,
  other;

  String get wire => name; // male / female / other
  String get label {
    switch (this) {
      case Sex.male:   return 'Male';
      case Sex.female: return 'Female';
      case Sex.other:  return 'Other';
    }
  }

  static Sex? fromWire(String? s) {
    switch (s) {
      case 'male':   return Sex.male;
      case 'female': return Sex.female;
      case 'other':  return Sex.other;
      default:       return null;
    }
  }
}

/// Primary body-composition goal.
enum GoalType {
  lose,
  maintain,
  gain;

  String get wire => name;
  String get label {
    switch (this) {
      case GoalType.lose:     return 'Lose weight';
      case GoalType.maintain: return 'Maintain weight';
      case GoalType.gain:     return 'Gain weight';
    }
  }

  static GoalType? fromWire(String? s) {
    switch (s) {
      case 'lose':     return GoalType.lose;
      case 'maintain': return GoalType.maintain;
      case 'gain':     return GoalType.gain;
      default:         return null;
    }
  }
}

/// Activity factor used to turn BMR → TDEE.
enum ActivityLevel {
  sedentary,
  light,
  moderate,
  active,
  veryActive;

  String get wire {
    switch (this) {
      case ActivityLevel.sedentary:  return 'sedentary';
      case ActivityLevel.light:      return 'light';
      case ActivityLevel.moderate:   return 'moderate';
      case ActivityLevel.active:     return 'active';
      case ActivityLevel.veryActive: return 'very_active';
    }
  }

  String get label {
    switch (this) {
      case ActivityLevel.sedentary:  return 'Sedentary';
      case ActivityLevel.light:      return 'Lightly active';
      case ActivityLevel.moderate:   return 'Moderately active';
      case ActivityLevel.active:     return 'Very active';
      case ActivityLevel.veryActive: return 'Extremely active';
    }
  }

  String get hint {
    switch (this) {
      case ActivityLevel.sedentary:  return 'Little or no exercise';
      case ActivityLevel.light:      return '1–3 workouts / week';
      case ActivityLevel.moderate:   return '3–5 workouts / week';
      case ActivityLevel.active:     return '6–7 workouts / week';
      case ActivityLevel.veryActive: return 'Hard daily training / physical job';
    }
  }

  /// Multiplier applied to BMR (Mifflin–St Jeor) to estimate TDEE.
  double get factor {
    switch (this) {
      case ActivityLevel.sedentary:  return 1.2;
      case ActivityLevel.light:      return 1.375;
      case ActivityLevel.moderate:   return 1.55;
      case ActivityLevel.active:     return 1.725;
      case ActivityLevel.veryActive: return 1.9;
    }
  }

  static ActivityLevel? fromWire(String? s) {
    switch (s) {
      case 'sedentary':   return ActivityLevel.sedentary;
      case 'light':       return ActivityLevel.light;
      case 'moderate':    return ActivityLevel.moderate;
      case 'active':      return ActivityLevel.active;
      case 'very_active': return ActivityLevel.veryActive;
      default:            return null;
    }
  }
}

/// Immutable snapshot of a user's body profile + goal. Mirrors
/// `schemas.UserProfile` on the backend. Every field is nullable — the row is
/// created lazily and the Edit Profile screen lets the user fill it in.
@immutable
class UserProfile {
  final String userId;
  final String? displayName;
  final Sex? sex;
  final DateTime? dateOfBirth;
  final double? heightCm;
  final double? currentWeightKg;
  final double? targetWeightKg;
  final GoalType? goalType;
  final ActivityLevel? activityLevel;
  final double? weeklyRateKg;
  final DateTime? updatedAt;

  const UserProfile({
    required this.userId,
    this.displayName,
    this.sex,
    this.dateOfBirth,
    this.heightCm,
    this.currentWeightKg,
    this.targetWeightKg,
    this.goalType,
    this.activityLevel,
    this.weeklyRateKg,
    this.updatedAt,
  });

  factory UserProfile.empty(String userId) => UserProfile(userId: userId);

  UserProfile copyWith({
    String? displayName,
    Sex? sex,
    DateTime? dateOfBirth,
    double? heightCm,
    double? currentWeightKg,
    double? targetWeightKg,
    GoalType? goalType,
    ActivityLevel? activityLevel,
    double? weeklyRateKg,
    DateTime? updatedAt,
    bool clearDisplayName = false,
    bool clearDateOfBirth = false,
    bool clearWeeklyRate  = false,
  }) {
    return UserProfile(
      userId: userId,
      displayName:     clearDisplayName ? null : (displayName     ?? this.displayName),
      sex:                                 sex ?? this.sex,
      dateOfBirth:     clearDateOfBirth ? null : (dateOfBirth     ?? this.dateOfBirth),
      heightCm:                             heightCm        ?? this.heightCm,
      currentWeightKg:                      currentWeightKg ?? this.currentWeightKg,
      targetWeightKg:                       targetWeightKg  ?? this.targetWeightKg,
      goalType:                             goalType        ?? this.goalType,
      activityLevel:                        activityLevel   ?? this.activityLevel,
      weeklyRateKg:    clearWeeklyRate  ? null : (weeklyRateKg    ?? this.weeklyRateKg),
      updatedAt:                            updatedAt       ?? this.updatedAt,
    );
  }

  /// Age in whole years based on [dateOfBirth]; null if unknown.
  int? get ageYears {
    final dob = dateOfBirth;
    if (dob == null) return null;
    final now = DateTime.now();
    var a = now.year - dob.year;
    final beforeBirthday = (now.month < dob.month) ||
        (now.month == dob.month && now.day < dob.day);
    if (beforeBirthday) a -= 1;
    return a < 0 ? null : a;
  }

  /// Everything needed for a meaningful BMR/TDEE calculation is present.
  bool get isComplete =>
      sex != null &&
      dateOfBirth != null &&
      heightCm != null && heightCm! > 0 &&
      currentWeightKg != null && currentWeightKg! > 0 &&
      activityLevel != null &&
      goalType != null;

  factory UserProfile.fromJson(Map<String, dynamic> j) {
    double? asDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    DateTime? asDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return UserProfile(
      userId:          j['user_id']?.toString() ?? '',
      displayName:     (j['display_name'] as String?)?.trim().isEmpty == true
          ? null
          : j['display_name'] as String?,
      sex:             Sex.fromWire(j['sex'] as String?),
      dateOfBirth:     asDate(j['date_of_birth']),
      heightCm:        asDouble(j['height_cm']),
      currentWeightKg: asDouble(j['current_weight_kg']),
      targetWeightKg:  asDouble(j['target_weight_kg']),
      goalType:        GoalType.fromWire(j['goal_type'] as String?),
      activityLevel:   ActivityLevel.fromWire(j['activity_level'] as String?),
      weeklyRateKg:    asDouble(j['weekly_rate_kg']),
      updatedAt:       asDate(j['updated_at']),
    );
  }

  /// Only non-null fields are serialised — matches the backend's partial-
  /// upsert semantics on PUT.
  Map<String, dynamic> toUpdateJson() {
    final out = <String, dynamic>{};
    if (displayName     != null) out['display_name']      = displayName;
    if (sex             != null) out['sex']               = sex!.wire;
    if (dateOfBirth     != null) {
      final d = dateOfBirth!;
      out['date_of_birth'] =
          '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';
    }
    if (heightCm        != null) out['height_cm']         = heightCm;
    if (currentWeightKg != null) out['current_weight_kg'] = currentWeightKg;
    if (targetWeightKg  != null) out['target_weight_kg']  = targetWeightKg;
    if (goalType        != null) out['goal_type']         = goalType!.wire;
    if (activityLevel   != null) out['activity_level']    = activityLevel!.wire;
    if (weeklyRateKg    != null) out['weekly_rate_kg']    = weeklyRateKg;
    return out;
  }
}
