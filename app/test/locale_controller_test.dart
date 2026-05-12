import 'package:app/models/user_profile.dart';
import 'package:app/providers/locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Manual ro resolves to Romanian material locale', () {
    final lc = LocaleController(
      mode: UserLocaleMode.manual,
      preferredLocale: 'ro',
    );
    final loc = lc.resolveMaterialLocale(const Locale('en', 'US'));
    expect(loc.languageCode, 'ro');
  });

  test('System with unsupported device language falls back to English', () {
    final lc = LocaleController(mode: UserLocaleMode.system);
    final loc = lc.resolveMaterialLocale(const Locale('ja'));
    expect(loc.languageCode, 'en');
  });

  test('preferredLocaleForAi uses manual tag when set', () {
    final lc = LocaleController(
      mode: UserLocaleMode.manual,
      preferredLocale: 'ro',
    );
    expect(
      lc.preferredLocaleForAi(const Locale('en')),
      'ro',
    );
  });
}
