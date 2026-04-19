import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:app/config/theme.dart';
import 'package:app/providers/theme_mode_provider.dart';

void main() {
  testWidgets('Light/dark themes apply from ThemeModeProvider', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ThemeModeProvider(initial: ThemeMode.light),
          ),
        ],
        child: Consumer<ThemeModeProvider>(
          builder: (context, theme, _) {
            return MaterialApp(
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: theme.themeMode,
              home: const Scaffold(body: Text('ok')),
            );
          },
        ),
      ),
    );
    expect(find.text('ok'), findsOneWidget);
  });
}
