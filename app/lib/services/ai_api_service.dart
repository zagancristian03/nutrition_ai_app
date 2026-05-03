import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'food_api_service.dart';

/// HTTP client for the AI coaching backend (`/ai/*`).
///
/// All requests are keyed by the Firebase UID. The OpenAI key NEVER leaves
/// the FastAPI server — this client only ever talks to our own backend.
class AiApiService {
  static String get _baseUrl => FoodApiService.baseUrl;
  static const Duration _shortTimeout = Duration(seconds: 10);
  static const Duration _longTimeout  = Duration(seconds: 45);

  // --------------------------------------------------------------------- //
  // Onboarding                                                            //
  // --------------------------------------------------------------------- //

  /// GET /ai/profile/{userId}
  Future<AiProfile?> getProfile(String userId) async {
    final uri = Uri.parse('$_baseUrl/ai/profile/$userId');
    try {
      final r = await http.get(uri).timeout(_shortTimeout);
      if (r.statusCode == 200) {
        final decoded = json.decode(r.body);
        if (decoded is Map<String, dynamic>) return AiProfile.fromJson(decoded);
      }
      debugPrint('[AiApiService] getProfile ${r.statusCode} ${r.body}');
    } catch (e) {
      debugPrint('[AiApiService] getProfile error: $e');
    }
    return null;
  }

  /// POST /ai/onboarding?user_id=...&mark_completed=...
  Future<AiProfile?> saveOnboarding({
    required String userId,
    required Map<String, dynamic> answers,
    bool markCompleted = true,
  }) async {
    final uri = Uri.parse('$_baseUrl/ai/onboarding').replace(
      queryParameters: {
        'user_id': userId,
        'mark_completed': markCompleted ? 'true' : 'false',
      },
    );
    try {
      final r = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(answers),
          )
          .timeout(_longTimeout);
      if (r.statusCode == 200) {
        final decoded = json.decode(r.body);
        if (decoded is Map<String, dynamic>) return AiProfile.fromJson(decoded);
      }
      debugPrint('[AiApiService] saveOnboarding ${r.statusCode} ${r.body}');
    } catch (e) {
      debugPrint('[AiApiService] saveOnboarding error: $e');
    }
    return null;
  }

  // --------------------------------------------------------------------- //
  // Chat                                                                  //
  // --------------------------------------------------------------------- //

  /// POST /ai/chat
  ///
  /// Returns `null` on any failure; the caller is responsible for showing
  /// a snackbar / error banner.
  Future<AiChatReply?> sendChat({
    required String userId,
    required String message,
    int? threadId,
  }) async {
    final uri = Uri.parse('$_baseUrl/ai/chat');
    final body = <String, dynamic>{
      'user_id': userId,
      'message': message,
      if (threadId != null) 'thread_id': threadId,
    };
    try {
      final r = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(_longTimeout);
      if (r.statusCode == 200) {
        final decoded = json.decode(r.body);
        if (decoded is Map<String, dynamic>) return AiChatReply.fromJson(decoded);
      }
      debugPrint('[AiApiService] sendChat ${r.statusCode} ${r.body}');
    } catch (e) {
      debugPrint('[AiApiService] sendChat error: $e');
    }
    return null;
  }

  /// GET /ai/chat/history?user_id=...&thread_id=...
  Future<AiChatHistory?> getChatHistory({
    required String userId,
    int? threadId,
    int limit = 100,
  }) async {
    final uri = Uri.parse('$_baseUrl/ai/chat/history').replace(
      queryParameters: {
        'user_id': userId,
        if (threadId != null) 'thread_id': '$threadId',
        'limit': '$limit',
      },
    );
    try {
      final r = await http.get(uri).timeout(_shortTimeout);
      if (r.statusCode == 200) {
        final decoded = json.decode(r.body);
        if (decoded is Map<String, dynamic>) return AiChatHistory.fromJson(decoded);
      }
      debugPrint('[AiApiService] getChatHistory ${r.statusCode} ${r.body}');
    } catch (e) {
      debugPrint('[AiApiService] getChatHistory error: $e');
    }
    return null;
  }

  /// GET /ai/chat/threads?user_id=...
  Future<List<AiChatThreadSummary>> listThreads({
    required String userId,
    int limit = 30,
  }) async {
    final uri = Uri.parse('$_baseUrl/ai/chat/threads').replace(
      queryParameters: {
        'user_id': userId,
        'limit': '$limit',
      },
    );
    try {
      final r = await http.get(uri).timeout(_shortTimeout);
      if (r.statusCode == 200) {
        final decoded = json.decode(r.body);
        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map(AiChatThreadSummary.fromJson)
              .toList();
        }
      }
      debugPrint('[AiApiService] listThreads ${r.statusCode} ${r.body}');
    } catch (e) {
      debugPrint('[AiApiService] listThreads error: $e');
    }
    return const [];
  }

  /// POST /ai/chat/threads — empty thread, ready for the first message.
  Future<AiChatThreadSummary?> createChatThread({
    required String userId,
    String? title,
    int? folderId,
  }) async {
    final uri = Uri.parse('$_baseUrl/ai/chat/threads');
    final body = <String, dynamic>{
      'user_id': userId,
      if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
      if (folderId != null) 'folder_id': folderId,
    };
    try {
      final r = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(_shortTimeout);
      if (r.statusCode == 200) {
        final decoded = json.decode(r.body);
        if (decoded is Map<String, dynamic>) {
          return AiChatThreadSummary.fromJson(decoded);
        }
      }
      debugPrint('[AiApiService] createChatThread ${r.statusCode} ${r.body}');
    } catch (e) {
      debugPrint('[AiApiService] createChatThread error: $e');
    }
    return null;
  }

  /// PATCH /ai/chat/threads/{threadId}?user_id=...
  ///
  /// [patch] may include `title` and/or `folder_id` (use `null` for unfiled).
  Future<AiChatThreadSummary?> patchChatThread({
    required String userId,
    required int threadId,
    required Map<String, dynamic> patch,
  }) async {
    if (patch.isEmpty) return null;
    final uri = Uri.parse('$_baseUrl/ai/chat/threads/$threadId').replace(
      queryParameters: {'user_id': userId},
    );
    try {
      final r = await http
          .patch(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(patch),
          )
          .timeout(_shortTimeout);
      if (r.statusCode >= 200 && r.statusCode < 300) {
        final decoded = json.decode(r.body);
        if (decoded is Map<String, dynamic>) {
          return AiChatThreadSummary.fromJson(decoded);
        }
      }
      debugPrint('[AiApiService] patchChatThread ${r.statusCode} ${r.body}');
    } catch (e) {
      debugPrint('[AiApiService] patchChatThread error: $e');
    }
    return null;
  }

  /// GET /ai/chat/folders?user_id=...
  Future<List<AiChatFolder>> listFolders({required String userId}) async {
    final uri = Uri.parse('$_baseUrl/ai/chat/folders').replace(
      queryParameters: {'user_id': userId},
    );
    try {
      final r = await http.get(uri).timeout(_shortTimeout);
      if (r.statusCode == 200) {
        final decoded = json.decode(r.body);
        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map(AiChatFolder.fromJson)
              .toList();
        }
      }
      debugPrint('[AiApiService] listFolders ${r.statusCode} ${r.body}');
    } catch (e) {
      debugPrint('[AiApiService] listFolders error: $e');
    }
    return const [];
  }

  /// POST /ai/chat/folders
  Future<AiChatFolder?> createFolder({
    required String userId,
    required String name,
  }) async {
    final uri = Uri.parse('$_baseUrl/ai/chat/folders');
    try {
      final r = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'user_id': userId, 'name': name.trim()}),
          )
          .timeout(_shortTimeout);
      if (r.statusCode >= 200 && r.statusCode < 300) {
        final decoded = json.decode(r.body);
        if (decoded is Map<String, dynamic>) {
          return AiChatFolder.fromJson(decoded);
        }
      }
      debugPrint('[AiApiService] createFolder ${r.statusCode} ${r.body}');
    } catch (e) {
      debugPrint('[AiApiService] createFolder error: $e');
    }
    return null;
  }

  /// PATCH /ai/chat/folders/{folderId}?user_id=...
  Future<AiChatFolder?> renameFolder({
    required String userId,
    required int folderId,
    required String name,
  }) async {
    final uri = Uri.parse('$_baseUrl/ai/chat/folders/$folderId').replace(
      queryParameters: {'user_id': userId},
    );
    try {
      final r = await http
          .patch(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'name': name.trim()}),
          )
          .timeout(_shortTimeout);
      if (r.statusCode == 200) {
        final decoded = json.decode(r.body);
        if (decoded is Map<String, dynamic>) {
          return AiChatFolder.fromJson(decoded);
        }
      }
      debugPrint('[AiApiService] renameFolder ${r.statusCode} ${r.body}');
    } catch (e) {
      debugPrint('[AiApiService] renameFolder error: $e');
    }
    return null;
  }

  /// DELETE /ai/chat/folders/{folderId}?user_id=...
  Future<bool> deleteFolder({
    required String userId,
    required int folderId,
  }) async {
    final uri = Uri.parse('$_baseUrl/ai/chat/folders/$folderId').replace(
      queryParameters: {'user_id': userId},
    );
    try {
      final r = await http.delete(uri).timeout(_shortTimeout);
      if (r.statusCode == 200) return true;
      debugPrint('[AiApiService] deleteFolder ${r.statusCode} ${r.body}');
    } catch (e) {
      debugPrint('[AiApiService] deleteFolder error: $e');
    }
    return false;
  }

  // --------------------------------------------------------------------- //
  // Reviews                                                               //
  // --------------------------------------------------------------------- //

  /// POST /ai/review/day
  Future<String?> reviewDay({
    required String userId,
    DateTime? onDate,
  }) async {
    final params = {
      'user_id': userId,
      if (onDate != null) 'on_date': _dateIso(onDate),
    };
    final uri = Uri.parse('$_baseUrl/ai/review/day').replace(queryParameters: params);
    return _postForReviewText(uri);
  }

  /// POST /ai/review/week
  Future<String?> reviewWeek({
    required String userId,
    DateTime? today,
  }) async {
    final params = {
      'user_id': userId,
      if (today != null) 'today': _dateIso(today),
    };
    final uri = Uri.parse('$_baseUrl/ai/review/week').replace(queryParameters: params);
    return _postForReviewText(uri);
  }

  Future<String?> _postForReviewText(Uri uri) async {
    try {
      final r = await http.post(uri).timeout(_longTimeout);
      if (r.statusCode == 200) {
        final decoded = json.decode(r.body);
        if (decoded is Map<String, dynamic>) {
          final review = decoded['review'];
          if (review is String) return review;
        }
      }
      debugPrint('[AiApiService] review ${r.statusCode} ${r.body}');
    } catch (e) {
      debugPrint('[AiApiService] review error: $e');
    }
    return null;
  }

  // --------------------------------------------------------------------- //
  // Meal recommendations                                                  //
  // --------------------------------------------------------------------- //

  /// POST /ai/recommend/meal
  Future<AiMealRecommendations?> recommendMeal({
    required String userId,
    DateTime? today,
  }) async {
    final params = {
      'user_id': userId,
      if (today != null) 'today': _dateIso(today),
    };
    final uri = Uri.parse('$_baseUrl/ai/recommend/meal')
        .replace(queryParameters: params);
    try {
      final r = await http.post(uri).timeout(_longTimeout);
      if (r.statusCode == 200) {
        final decoded = json.decode(r.body);
        if (decoded is Map<String, dynamic>) {
          return AiMealRecommendations.fromJson(decoded);
        }
      }
      debugPrint('[AiApiService] recommendMeal ${r.statusCode} ${r.body}');
    } catch (e) {
      debugPrint('[AiApiService] recommendMeal error: $e');
    }
    return null;
  }

  static String _dateIso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}


// --------------------------------------------------------------------------- //
// DTOs                                                                        //
// --------------------------------------------------------------------------- //

class AiProfile {
  final String userId;
  final bool onboardingCompleted;

  // Goals
  final List<String> mainGoals;
  final String? mainGoalNote;
  final String? approachStyle;

  // Diet
  final String? dietaryPattern;
  final String? dietaryPatternNote;
  final String? allergies;
  final String? dislikedFoods;
  final String? favoriteFoods;
  final String? cuisinesEnjoyed;
  final String? eatingOutFrequency;
  final String? budgetSensitivity;
  final String? cookingPreference;
  final int? mealFrequency;

  // Training
  final int? trainingFrequencyPerWeek;
  final List<String> trainingTypes;
  final String? trainingIntensity;
  final String? trainingNotes;
  final String? jobActivity;
  final String? stepsPerDayBand;

  // Lifestyle
  final String? sleepHoursBand;
  final String? stressLevel;
  final String? waterIntake;
  final String? alcoholFrequency;

  // Behavioral
  final List<String> biggestStruggles;
  final String? biggestStruggleNote;
  final String? struggleTiming;
  final String? motivationLevel;
  final String? structurePreference;

  final String coachTone;
  final String? derivedSummary;

  const AiProfile({
    required this.userId,
    required this.onboardingCompleted,
    required this.coachTone,
    this.mainGoals            = const [],
    this.mainGoalNote,
    this.approachStyle,
    this.dietaryPattern,
    this.dietaryPatternNote,
    this.allergies,
    this.dislikedFoods,
    this.favoriteFoods,
    this.cuisinesEnjoyed,
    this.eatingOutFrequency,
    this.budgetSensitivity,
    this.cookingPreference,
    this.mealFrequency,
    this.trainingFrequencyPerWeek,
    this.trainingTypes        = const [],
    this.trainingIntensity,
    this.trainingNotes,
    this.jobActivity,
    this.stepsPerDayBand,
    this.sleepHoursBand,
    this.stressLevel,
    this.waterIntake,
    this.alcoholFrequency,
    this.biggestStruggles     = const [],
    this.biggestStruggleNote,
    this.struggleTiming,
    this.motivationLevel,
    this.structurePreference,
    this.derivedSummary,
  });

  factory AiProfile.fromJson(Map<String, dynamic> j) {
    int? asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    List<String> asStringList(dynamic v) {
      if (v is List) {
        return v.where((e) => e != null).map((e) => e.toString()).toList();
      }
      return const [];
    }

    return AiProfile(
      userId:                   j['user_id']?.toString() ?? '',
      onboardingCompleted:      j['onboarding_completed'] == true,
      coachTone:                (j['coach_tone'] as String?) ?? 'balanced',

      mainGoals:                asStringList(j['main_goals']),
      mainGoalNote:             j['main_goal_note']         as String?,
      approachStyle:            j['approach_style']         as String?,

      dietaryPattern:           j['dietary_pattern']        as String?,
      dietaryPatternNote:       j['dietary_pattern_note']   as String?,
      allergies:                j['allergies']              as String?,
      dislikedFoods:            j['disliked_foods']         as String?,
      favoriteFoods:            j['favorite_foods']         as String?,
      cuisinesEnjoyed:          j['cuisines_enjoyed']       as String?,
      eatingOutFrequency:       j['eating_out_frequency']   as String?,
      budgetSensitivity:        j['budget_sensitivity']     as String?,
      cookingPreference:        j['cooking_preference']     as String?,
      mealFrequency:            asInt(j['meal_frequency']),

      trainingFrequencyPerWeek: asInt(j['training_frequency_per_week']),
      trainingTypes:            asStringList(j['training_types']),
      trainingIntensity:        j['training_intensity']     as String?,
      trainingNotes:            j['training_notes']         as String?,
      jobActivity:              j['job_activity']           as String?,
      stepsPerDayBand:          j['steps_per_day_band']     as String?,

      sleepHoursBand:           j['sleep_hours_band']       as String?,
      stressLevel:              j['stress_level']           as String?,
      waterIntake:              j['water_intake']           as String?,
      alcoholFrequency:         j['alcohol_frequency']      as String?,

      biggestStruggles:         asStringList(j['biggest_struggles']),
      biggestStruggleNote:      j['biggest_struggle_note']  as String?,
      struggleTiming:           j['struggle_timing']        as String?,
      motivationLevel:          j['motivation_level']       as String?,
      structurePreference:      j['structure_preference']   as String?,

      derivedSummary:           j['derived_summary']        as String?,
    );
  }
}

class AiChatReply {
  final int threadId;
  final String reply;
  const AiChatReply({required this.threadId, required this.reply});

  factory AiChatReply.fromJson(Map<String, dynamic> j) {
    final tid = j['thread_id'];
    return AiChatReply(
      threadId: tid is int ? tid : int.tryParse(tid?.toString() ?? '') ?? 0,
      reply:    (j['reply'] as String?) ?? '',
    );
  }
}

class AiChatFolder {
  final int id;
  final String name;
  final int sortOrder;

  const AiChatFolder({
    required this.id,
    required this.name,
    this.sortOrder = 0,
  });

  factory AiChatFolder.fromJson(Map<String, dynamic> j) {
    final idRaw = j['id'];
    final id = idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? '') ?? 0;
    final so = j['sort_order'];
    final order = so is int ? so : int.tryParse(so?.toString() ?? '0') ?? 0;
    return AiChatFolder(
      id: id,
      name: (j['name'] as String?)?.trim().isNotEmpty == true
          ? (j['name'] as String).trim()
          : 'Folder',
      sortOrder: order,
    );
  }
}

class AiChatThreadSummary {
  final int id;
  final String? title;
  final int messageCount;
  final DateTime? updatedAt;
  final int? folderId;

  const AiChatThreadSummary({
    required this.id,
    this.title,
    this.messageCount = 0,
    this.updatedAt,
    this.folderId,
  });

  String get displayTitle {
    final t = title?.trim();
    if (t != null && t.isNotEmpty) return t;
    return 'Chat #$id';
  }

  factory AiChatThreadSummary.fromJson(Map<String, dynamic> j) {
    final idRaw = j['id'];
    final id = idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? '') ?? 0;
    final mc = j['message_count'];
    final count = mc is int ? mc : int.tryParse(mc?.toString() ?? '0') ?? 0;
    DateTime? u;
    final ur = j['updated_at']?.toString();
    if (ur != null && ur.isNotEmpty) {
      u = DateTime.tryParse(ur)?.toLocal();
    }
    int? fid;
    final fr = j['folder_id'];
    if (fr is int) {
      fid = fr;
    } else if (fr != null) {
      fid = int.tryParse(fr.toString());
    }
    return AiChatThreadSummary(
      id: id,
      title: j['title'] as String?,
      messageCount: count,
      updatedAt: u,
      folderId: fid,
    );
  }
}

class AiChatMessage {
  final String role;     // 'user' | 'assistant' | 'system'
  final String content;
  final DateTime? createdAt;

  const AiChatMessage({
    required this.role,
    required this.content,
    this.createdAt,
  });

  bool get isUser => role == 'user';

  factory AiChatMessage.fromJson(Map<String, dynamic> j) {
    DateTime? ts;
    final raw = j['created_at']?.toString();
    if (raw != null && raw.isNotEmpty) {
      ts = DateTime.tryParse(raw)?.toLocal();
    }
    return AiChatMessage(
      role:      (j['role'] as String?) ?? 'assistant',
      content:   (j['content'] as String?) ?? '',
      createdAt: ts,
    );
  }
}

class AiChatHistory {
  final int? threadId;
  final String? title;
  final String? summary;
  final List<AiChatMessage> messages;

  const AiChatHistory({
    this.threadId,
    this.title,
    this.summary,
    this.messages = const [],
  });

  factory AiChatHistory.fromJson(Map<String, dynamic> j) {
    final raw = j['messages'];
    final msgs = <AiChatMessage>[];
    if (raw is List) {
      for (final m in raw) {
        if (m is Map<String, dynamic>) msgs.add(AiChatMessage.fromJson(m));
      }
    }
    final tid = j['thread_id'];
    int? threadId;
    if (tid is int) {
      threadId = tid;
    } else if (tid != null) {
      threadId = int.tryParse(tid.toString());
    }
    return AiChatHistory(
      threadId: threadId,
      title:    j['title']   as String?,
      summary:  j['summary'] as String?,
      messages: msgs,
    );
  }
}

class AiMealSuggestion {
  final String name;
  final String? why;
  final double? estimatedCalories;
  final double? estimatedProtein;
  final double? estimatedCarbs;
  final double? estimatedFat;

  const AiMealSuggestion({
    required this.name,
    this.why,
    this.estimatedCalories,
    this.estimatedProtein,
    this.estimatedCarbs,
    this.estimatedFat,
  });

  factory AiMealSuggestion.fromJson(Map<String, dynamic> j) {
    double? d(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }
    return AiMealSuggestion(
      name:              (j['name'] as String?)?.trim().isNotEmpty == true
                            ? (j['name'] as String).trim()
                            : 'Suggestion',
      why:               j['why'] as String?,
      estimatedCalories: d(j['estimated_calories']),
      estimatedProtein:  d(j['estimated_protein']),
      estimatedCarbs:    d(j['estimated_carbs']),
      estimatedFat:      d(j['estimated_fat']),
    );
  }
}

class AiMealRecommendations {
  final Map<String, double> remaining;
  final List<AiMealSuggestion> suggestions;

  const AiMealRecommendations({
    this.remaining = const {},
    this.suggestions = const [],
  });

  factory AiMealRecommendations.fromJson(Map<String, dynamic> j) {
    final rem = <String, double>{};
    final raw = j['remaining'];
    if (raw is Map) {
      raw.forEach((k, v) {
        if (v is num) {
          rem[k.toString()] = v.toDouble();
        } else if (v is String) {
          rem[k.toString()] = double.tryParse(v) ?? 0.0;
        }
      });
    }
    final list = <AiMealSuggestion>[];
    final rawList = j['suggestions'];
    if (rawList is List) {
      for (final s in rawList) {
        if (s is Map<String, dynamic>) list.add(AiMealSuggestion.fromJson(s));
      }
    }
    return AiMealRecommendations(remaining: rem, suggestions: list);
  }
}
