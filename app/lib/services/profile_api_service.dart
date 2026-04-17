import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/user_profile.dart';
import '../models/weight_entry.dart';
import 'food_api_service.dart';

/// HTTP client for the user-profile + weight-tracking endpoints:
///
///   * `/user-profile/{user_id}`  — GET / PUT
///   * `/weight-logs`             — GET / POST / DELETE
///
/// All calls are keyed by the Firebase UID passed in `userId`.
class ProfileApiService {
  static const String _baseUrl = FoodApiService.baseUrl;
  static const Duration _timeout = Duration(seconds: 10);

  static String _dateToIso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  // ----------------------------------------------------------------------- //
  // Profile                                                                 //
  // ----------------------------------------------------------------------- //

  /// GET /user-profile/{userId}. Returns an empty profile skeleton for new
  /// users — the backend never 404s on this endpoint.
  Future<UserProfile> getProfile(String userId) async {
    final uri = Uri.parse('$_baseUrl/user-profile/$userId');
    try {
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return UserProfile.fromJson(decoded);
        }
      }
      debugPrint(
        '[ProfileApiService] getProfile HTTP ${response.statusCode} body=${response.body}',
      );
    } catch (e) {
      debugPrint('[ProfileApiService] getProfile error: $e');
    }
    return UserProfile.empty(userId);
  }

  /// PUT /user-profile/{userId} — partial upsert. Only the fields set on the
  /// profile object are sent.
  Future<UserProfile?> putProfile(UserProfile profile) async {
    final uri = Uri.parse('$_baseUrl/user-profile/${profile.userId}');
    try {
      final response = await http
          .put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(profile.toUpdateJson()),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return UserProfile.fromJson(decoded);
        }
      }
      debugPrint(
        '[ProfileApiService] putProfile HTTP ${response.statusCode} body=${response.body}',
      );
    } catch (e) {
      debugPrint('[ProfileApiService] putProfile error: $e');
    }
    return null;
  }

  // ----------------------------------------------------------------------- //
  // Weight logs                                                             //
  // ----------------------------------------------------------------------- //

  /// GET /weight-logs?user_id=...&days=...
  Future<List<WeightEntry>> listWeightLogs({
    required String userId,
    int days = 365,
  }) async {
    final uri = Uri.parse('$_baseUrl/weight-logs').replace(queryParameters: {
      'user_id': userId,
      'days':    '$days',
    });
    try {
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map(WeightEntry.fromJson)
              .toList();
        }
      }
      debugPrint(
        '[ProfileApiService] listWeightLogs HTTP ${response.statusCode} '
        'body=${response.body}',
      );
    } catch (e) {
      debugPrint('[ProfileApiService] listWeightLogs error: $e');
    }
    return const [];
  }

  /// POST /weight-logs — insert or update the entry for (user, day).
  Future<WeightEntry?> addWeightLog({
    required String userId,
    required double weightKg,
    DateTime? loggedOn,
    String? note,
  }) async {
    final uri = Uri.parse('$_baseUrl/weight-logs');
    final body = <String, dynamic>{
      'user_id':   userId,
      'weight_kg': weightKg,
      if (loggedOn != null) 'logged_on': _dateToIso(loggedOn),
      if (note     != null && note.trim().isNotEmpty) 'note': note.trim(),
    };

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(_timeout);

      if (response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return WeightEntry.fromJson(decoded);
        }
      }
      debugPrint(
        '[ProfileApiService] addWeightLog HTTP ${response.statusCode} '
        'body=${response.body}',
      );
    } catch (e) {
      debugPrint('[ProfileApiService] addWeightLog error: $e');
    }
    return null;
  }

  /// DELETE /weight-logs/{id}?user_id=...
  Future<bool> deleteWeightLog({required int id, required String userId}) async {
    final uri = Uri.parse('$_baseUrl/weight-logs/$id')
        .replace(queryParameters: {'user_id': userId});
    try {
      final response = await http.delete(uri).timeout(_timeout);
      return response.statusCode == 204;
    } catch (e) {
      debugPrint('[ProfileApiService] deleteWeightLog error: $e');
      return false;
    }
  }
}
