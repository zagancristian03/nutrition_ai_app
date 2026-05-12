import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// JSON API headers with [Authorization: Bearer] when signed in with Firebase.
Future<Map<String, String>> apiAuthJsonHeaders() async {
  final headers = <String, String>{'Content-Type': 'application/json'};
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return headers;
    final token = await user.getIdToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
  } catch (e, st) {
    debugPrint('[apiAuthJsonHeaders] $e\n$st');
  }
  return headers;
}
