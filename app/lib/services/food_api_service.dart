import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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
  static const String baseUrl = 'http://192.168.137.1:8000';

  static const String _searchPath = '/foods/search';
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
        final decoded = json.decode(response.body);
        if (decoded is! List) {
          debugPrint(
            '[FoodApiService] unexpected JSON (expected list): ${response.body}',
          );
          return [];
        }
        return decoded
            .map((item) => FoodItem.fromJson(item as Map<String, dynamic>))
            .toList();
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
}
