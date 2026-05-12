import 'package:flutter/foundation.dart' show kReleaseMode;

/// Backend base URL resolution.
///
/// **Debug / profile:** If [kApiBaseUrlFromEnvironment] is empty, the app uses
/// the LAN fallback `http://[kBackendLanHost]:kBackendPort` so physical
/// devices, emulators, and local FastAPI work without a dart-define.
///
/// **Release:** `API_BASE_URL` **must** be set via
/// `--dart-define=API_BASE_URL=https://...` (your public HTTPS API). Release
/// builds **fail fast** if it is missing, so you cannot accidentally ship an
/// APK/AAB that calls a local IP. The real hostname is not hardcoded here.

/// LAN API — when this drifts from your PC’s Wi‑Fi IPv4, search/diary will
/// time out on a physical phone. Run `ipconfig` (Windows) and set the address
/// that shares a subnet with the phone (often `192.168.x.x`).
///
/// Or avoid editing this file and run the app with an override:
///
///   flutter run --dart-define=API_BASE_URL=http://YOUR_PC_IP:8000
///
/// Keep [kBackendLanHost] in sync with that IPv4, or rely on the define only.
///
/// Presets — use the one that matches how the **phone** reaches this PC:
///
/// * **Windows Mobile Hotspot:** the phone is on `192.168.137.x`; this PC is
///   almost always `192.168.137.1` (check `ipconfig` → “Local Area Connection*” /
///   vEthernet / Wi‑Fi hotstop). This is **not** the same IPv4 as your home router LAN.
/// * **Same Wi‑Fi / LAN as the phone:** use this PC’s IPv4 on that network
///   (e.g. `192.168.1.17` from `ipconfig`).
const String kBackendLanHostWindowsMobileHotspot = '192.168.137.1';
const String kBackendLanHostHomeLan = '192.168.1.17';
const String kBackendLanHostHotspot = '10.186.89.122';

/// Active API host (must be reachable from the phone’s browser at `http://HOST:8000/docs`).
const String kBackendLanHost = kBackendLanHostWindowsMobileHotspot;

const int kBackendPort = 8000;

/// Optional full base URL from build/run (no trailing slash).
/// Example: `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000`
/// for Android emulator (host loopback).
const String kApiBaseUrlFromEnvironment = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: '',
);

/// Resolves to dart-define if set; otherwise LAN fallback in debug/profile only.
///
/// In **release**, an empty [kApiBaseUrlFromEnvironment] throws [StateError].
String get kBackendBaseUrl {
  final v = kApiBaseUrlFromEnvironment.trim();
  if (v.isNotEmpty) {
    return v.endsWith('/') ? v.substring(0, v.length - 1) : v;
  }
  if (kReleaseMode) {
    throw StateError(
      'API_BASE_URL must be provided for release builds using '
      '--dart-define=API_BASE_URL=https://...',
    );
  }
  return 'http://$kBackendLanHost:$kBackendPort';
}
