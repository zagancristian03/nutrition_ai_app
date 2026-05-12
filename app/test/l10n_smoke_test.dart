import 'package:app/l10n/api_error_mapper.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App starts in English', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (ctx) => Text(AppLocalizations.of(ctx)!.settingsScreenTitle),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Romanian locale loads', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ro'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (ctx) => Text(AppLocalizations.of(ctx)!.settingsScreenTitle),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Setări'), findsOneWidget);
  });

  testWidgets('API NETWORK_TIMEOUT maps to localized message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (ctx) => Text(localizedApiMessage(ctx, 'NETWORK_TIMEOUT')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('timed out'), findsOneWidget);
  });
}
