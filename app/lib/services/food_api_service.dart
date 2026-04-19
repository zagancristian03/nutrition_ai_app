import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/constants.dart';
import '../models/food_item.dart';

/// HTTP client for the FastAPI food backend.
///
/// Change [baseUrl] for your environment (see comments below).
class FoodApiService {
  /// Backend root URL **without** a trailing slash.
  ///
  /// - **Android emulator:** host machine is `10.0.2.2` (not `localhost`).
  /// - **iOS simulator / desktop / web:** often `http://localhost:8000`.
  /// - **Physical device:** use your PC's LAN IP (Wi‑Fi IP if the phone is on
  ///   Wi‑Fi, or Ethernet IP if only that interface is active). Same subnet /
  ///   same router; disable AP/client isolation; allow port 8000 in Windows
  ///   Firewall. `No route to host` = no L2/L3 path (wrong IP, isolation, or
  ///   PC not reachable on that interface).
  /// - **Android http://** also needs `usesCleartextTraffic` in AndroidManifest.
  static const String baseUrl = 'http://$kBackendLanHost:$kBackendPort';

  static const String _searchPath = '/foods/search';
  static const String _foodsPath = '/foods';
  static const Duration _timeout = Duration(seconds: 10);

  static void _logNetworkFailure(String context, Uri uri, Object e, StackTrace st) {
    debugPrint('[FoodApiService] $context FAILED');
    debugPrint('[FoodApiService]   baseUrl=$baseUrl');
    debugPrint('[FoodApiService]   uri=$uri');
    debugPrint('[FoodApiService]   errorType=${e.runtimeType}');
    debugPrint('[FoodApiService]   message=$e');

    if (e is SocketException) {
      final osm = e.osError?.message ?? '';
      debugPrint(
        '[FoodApiService]   hint: SocketException — unreachable host, refused '
        'port, wrong IP, no Wi‑Fi route, or cleartext blocked. '
        'osError=$osm',
      );
      if (osm.contains('No route to host') || osm.contains('113')) {
        debugPrint(
          '[FoodApiService]   hint: "No route to host" — phone cannot reach this '
          'IP. Try: (1) PC and phone on same Wi‑Fi (not guest/VPN); (2) router '
          'AP/client isolation off; (3) `ipconfig` and match baseUrl to the '
          'interface the PC actually uses (Wi‑Fi vs Ethernet); (4) ping PC from '
          'another device; (5) Windows Firewall inbound rule for TCP 8000.',
        );
      }
    } else if (e is TimeoutException) {
      debugPrint(
        '[FoodApiService]   hint: Timeout — host not responding (firewall, '
        'wrong IP, or server down).',
      );
    } else if (e is http.ClientException) {
      debugPrint(
        '[FoodApiService]   hint: ClientException — often TLS/DNS or failed '
        'socket before response. uri=${e.uri}',
      );
    } else if (e is HandshakeException) {
      debugPrint('[FoodApiService]   hint: HandshakeException — TLS/SSL issue.');
    } else if (e is FormatException) {
      debugPrint('[FoodApiService]   hint: FormatException — bad URL or encoding.');
    }

    debugPrint('[FoodApiService]   stack: $st');
  }

  /// One-shot connectivity check: `GET /foods/search?q=test`.
  /// Logs success/failure; returns a short message for UI (e.g. SnackBar).
  Future<String> testBackendConnection() async {
    final uri = Uri.parse('$baseUrl$_searchPath').replace(
      queryParameters: const {'q': 'test'},
    );

    debugPrint('[FoodApiService] === BACKEND TEST ===');
    debugPrint('[FoodApiService] baseUrl=$baseUrl');
    debugPrint('[FoodApiService] fullUrl=$uri');

    try {
      final response = await http
          .get(
            uri,
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        debugPrint(
          '[FoodApiService] TEST OK status=200 bodyLength=${response.body.length}',
        );
        return 'API OK (200), ${response.body.length} bytes';
      }

      debugPrint(
        '[FoodApiService] TEST HTTP error status=${response.statusCode} '
        'body=${response.body}',
      );
      return 'API HTTP ${response.statusCode}';
    } catch (e, st) {
      _logNetworkFailure('TEST', uri, e, st);
      return 'API FAILED: $e';
    }
  }

  /// Search foods via `GET /foods/search?q=...`.
  ///
  /// Returns an empty list on error or empty query; logs URL and errors.
  Future<List<FoodItem>> searchFood(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return [];
    }

    final uri = Uri.parse('$baseUrl$_searchPath').replace(
      queryParameters: {'q': trimmed},
    );

    debugPrint('[FoodApiService] searchFood baseUrl=$baseUrl');
    debugPrint('[FoodApiService] searchFood fullUrl=$uri');

    try {
      final response = await http
          .get(
            uri,
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        // Log enough of the raw body to diagnose "0 macros everywhere"
        // without flooding the terminal on large responses.
        final previewLen = response.body.length > 1200 ? 1200 : response.body.length;
        debugPrint(
          '[FoodApiService] searchFood 200 cache=${response.headers['x-cache']} '
          'elapsed=${response.headers['x-elapsed-ms']}ms '
          'bytes=${response.body.length} '
          'body[0..$previewLen]=${response.body.substring(0, previewLen)}',
        );

        final decoded = json.decode(response.body);
        if (decoded is! List) {
          debugPrint(
            '[FoodApiService] unexpected JSON (expected list): ${response.body}',
          );
          return [];
        }

        final items = decoded
            .map((item) => FoodItem.fromJson(item as Map<String, dynamic>))
            .toList();

        if (items.isNotEmpty) {
          final f = items.first;
          debugPrint(
            '[FoodApiService] searchFood parsed[0] name=${f.name} '
            'brand=${f.brand} kcal=${f.caloriesPer100g} '
            'p=${f.proteinPer100g} c=${f.carbsPer100g} f=${f.fatPer100g}',
          );
        }

        return items;
      }

      debugPrint(
        '[FoodApiService] error status=${response.statusCode} body=${response.body}',
      );
      return [];
    } catch (e, st) {
      _logNetworkFailure('searchFood', uri, e, st);
      return [];
    }
  }

  /// Calls GET /foods/_debug/stats and returns a short human-readable summary
  /// for display in the UI (SnackBar / AlertDialog).
  Future<String> debugStats() async {
    final uri = Uri.parse('$baseUrl/foods/_debug/stats');
    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        return 'stats HTTP ${response.statusCode}: ${response.body}';
      }
      final decoded = json.decode(response.body);
      if (decoded is! Map) return 'unexpected stats payload: ${response.body}';
      final counts = decoded['counts'];
      final top = decoded['top_by_kcal'];
      return 'counts=$counts\ntop_by_kcal=$top';
    } catch (e) {
      return 'stats error: $e';
    }
  }

  /// Insert a user-entered food into the catalog via `POST /foods`.
  ///
  /// All macros must be expressed **per 100 g** (the canonical storage format).
  /// Returns the newly created [FoodItem] with the DB-assigned `id`, or
  /// `null` on any failure — the caller should treat a null as "keep the row
  /// local only" and surface an error to the user.
  Future<FoodItem?> createFood({
    required String name,
    String? brand,
    required double caloriesPer100g,
    double proteinPer100g = 0,
    double carbsPer100g = 0,
    double fatPer100g = 0,
    double? servingSizeG,
  }) async {
    final r = await createFoodWithDiagnostics(
      name: name,
      brand: brand,
      caloriesPer100g: caloriesPer100g,
      proteinPer100g: proteinPer100g,
      carbsPer100g: carbsPer100g,
      fatPer100g: fatPer100g,
      servingSizeG: servingSizeG,
    );
    return r.food;
  }

  /// Same as [createFood] but also returns the error payload from the server
  /// so the UI can show the real reason (HTTP 500 detail, 422 validation, …)
  /// instead of a generic "please try again".
  Future<CreateFoodResult> createFoodWithDiagnostics({
    required String name,
    String? brand,
    required double caloriesPer100g,
    double proteinPer100g = 0,
    double carbsPer100g = 0,
    double fatPer100g = 0,
    double? servingSizeG,
  }) async {
    final uri = Uri.parse('$baseUrl$_foodsPath');

    final body = <String, dynamic>{
      'name': name,
      if (brand != null && brand.trim().isNotEmpty) 'brand': brand,
      'calories_per_100g': caloriesPer100g,
      'protein_per_100g': proteinPer100g,
      'carbs_per_100g': carbsPer100g,
      'fat_per_100g': fatPer100g,
      if (servingSizeG != null) 'serving_size_g': servingSizeG,
    };

    debugPrint('[FoodApiService] createFood uri=$uri body=$body');

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
        if (decoded is! Map<String, dynamic>) {
          debugPrint(
            '[FoodApiService] createFood unexpected JSON: ${response.body}',
          );
          return CreateFoodResult(
            food: null,
            errorMessage: 'Server returned an unexpected response.',
          );
        }
        return CreateFoodResult(food: FoodItem.fromJson(decoded));
      }

      debugPrint(
        '[FoodApiService] createFood HTTP ${response.statusCode} body=${response.body}',
      );
      return CreateFoodResult(
        food: null,
        errorMessage: _extractErrorMessage(response.statusCode, response.body),
      );
    } catch (e, st) {
      _logNetworkFailure('createFood', uri, e, st);
      return CreateFoodResult(
        food: null,
        errorMessage: 'Network error: $e',
      );
    }
  }

  static String _extractErrorMessage(int status, String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) {
        final d = decoded['detail'];
        if (d is String && d.isNotEmpty) return 'Error $status: $d';
        if (d is List && d.isNotEmpty) {
          // FastAPI validation errors
          final first = d.first;
          if (first is Map && first['msg'] is String) {
            return 'Error $status: ${first['msg']}';
          }
        }
      }
    } catch (_) {
      // fall through
    }
    return 'Error $status. Please try again.';
  }
}

/// Outcome of `createFoodWithDiagnostics` — either `food` is non-null or
/// `errorMessage` explains what went wrong (never both).
class CreateFoodResult {
  final FoodItem? food;
  final String? errorMessage;

  const CreateFoodResult({this.food, this.errorMessage});
}
