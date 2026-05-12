import 'package:flutter/widgets.dart';

import 'package:app/l10n/app_localizations.dart';

/// Maps backend / transport [code] values to localized UI messages.
///
/// JSON should use machine-readable codes; never rely on English [detail]
/// for primary UI copy. [detail] is only passed through for debugging when
/// no mapping exists.
String localizedApiMessage(
  BuildContext context,
  String code, {
  String? detail,
}) {
  final loc = AppLocalizations.of(context);
  if (loc == null) {
    return detail ?? code;
  }
  switch (code.toUpperCase()) {
    case 'NETWORK_TIMEOUT':
    case 'TIMEOUT':
      return loc.errorNetworkTimeout;
    case 'SERVER_GENERIC':
    case 'INTERNAL_ERROR':
      return loc.errorServerGeneric;
    case 'DIARY_LOAD_FAILED':
      return loc.diaryLoadFailedGeneric;
    case 'AI_COACH_REPLY_FAILED':
      return loc.aiCoachErrorReplyFailed;
    case 'AI_COACH_NEW_CHAT_FAILED':
      return loc.aiCoachErrorNewChatFailed;
    default:
      final d = detail ?? code;
      return loc.errorUnknownWithDetail(d);
  }
}
