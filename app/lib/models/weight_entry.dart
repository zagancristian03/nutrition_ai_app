import 'package:flutter/foundation.dart';

/// A single weight measurement — one per user per day.
@immutable
class WeightEntry {
  final int? id;
  final String userId;
  final double weightKg;
  final DateTime loggedOn;
  final String? note;
  final DateTime createdAt;

  const WeightEntry({
    this.id,
    required this.userId,
    required this.weightKg,
    required this.loggedOn,
    this.note,
    required this.createdAt,
  });

  factory WeightEntry.fromJson(Map<String, dynamic> j) {
    double asDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    DateTime asDateTime(dynamic v, {DateTime? fallback}) {
      final parsed = DateTime.tryParse(v?.toString() ?? '');
      return parsed ?? fallback ?? DateTime.now();
    }

    return WeightEntry(
      id:        (j['id'] as num?)?.toInt(),
      userId:    j['user_id']?.toString() ?? '',
      weightKg:  asDouble(j['weight_kg']),
      loggedOn:  asDateTime(j['logged_on']),
      note:      (j['note'] as String?)?.trim().isEmpty == true
                    ? null : j['note'] as String?,
      createdAt: asDateTime(j['created_at']),
    );
  }
}
