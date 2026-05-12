import 'package:timezone/timezone.dart' as tz;

/// Calendar date in the user's diary, derived from an instant and IANA zone.
///
/// [instant] should be UTC (e.g. `DateTime.now().toUtc()`). [ianaTimezone] is
/// used as in `Europe/Bucharest`. If the zone is unknown, falls back to UTC.
DateTime diaryDateOnlyUtcInstant(
  DateTime instant,
  String? ianaTimezone,
) {
  final utc = instant.toUtc();
  final tzName = ianaTimezone?.trim();
  if (tzName == null || tzName.isEmpty) {
    return DateTime.utc(utc.year, utc.month, utc.day);
  }
  try {
    final loc = tz.getLocation(tzName);
    final z = tz.TZDateTime.from(utc, loc);
    return DateTime.utc(z.year, z.month, z.day);
  } catch (_) {
    return DateTime.utc(utc.year, utc.month, utc.day);
  }
}
