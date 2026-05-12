import 'package:app/l10n/diary_date_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;

void main() {
  setUpAll(() {
    tzdata.initializeTimeZones();
  });

  test('Diary calendar day follows Europe/Bucharest, not UTC-only', () {
    // 2024-01-15 22:00 UTC → 2024-01-16 00:00 in Bucharest (UTC+2 standard / EET)
    final utc = DateTime.utc(2024, 1, 15, 22);
    final d = diaryDateOnlyUtcInstant(utc, 'Europe/Bucharest');
    expect(d.year, 2024);
    expect(d.month, 1);
    expect(d.day, 16);
  });

  test('Unknown IANA zone falls back to UTC calendar day', () {
    final utc = DateTime.utc(2024, 6, 10, 3);
    final d = diaryDateOnlyUtcInstant(utc, 'Not/A_Real_Zone');
    expect(d.day, 10);
  });
}
