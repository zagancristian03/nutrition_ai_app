/// LAN API — when this drifts from your PC’s Wi‑Fi IPv4, search/diary will
/// time out on a physical phone. Run `ipconfig` (Windows) and set the address
/// that shares a subnet with the phone (often `192.168.x.x`).
///
/// Or avoid editing this file and run the app with an override:
///
///   flutter run --dart-define=API_BASE_URL=http://YOUR_PC_IP:8000
///
/// Keep [kBackendLanHost] in sync with that IPv4, or rely on the define only.
const String kBackendLanHost = '192.168.1.16';
const int kBackendPort = 8000;

/// Optional full base URL from build/run (no trailing slash).
/// Example: `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000`
/// for Android emulator (host loopback).
const String kApiBaseUrlFromEnvironment = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: '',
);

/// Resolves to dart-define if set, otherwise `http://[kBackendLanHost]:port`.
String get kBackendBaseUrl {
  final v = kApiBaseUrlFromEnvironment.trim();
  if (v.isNotEmpty) {
    return v.endsWith('/') ? v.substring(0, v.length - 1) : v;
  }
  return 'http://$kBackendLanHost:$kBackendPort';
}
