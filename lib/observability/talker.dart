// coverage:ignore-file

import 'package:flutter/foundation.dart';
import 'package:storm/observability/sentry_talker_observer.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// No-op output used in non-debug mode to suppress all console logs.
void _noOpOutput(String message) {}

/// Initializes and returns the global [Talker] instance.
///
/// A [SentryTalkerObserver] is always attached to route errors, exceptions,
/// and critical log messages to Sentry regardless of build mode.
Talker initTalker() {
  final settings = kDebugMode
      ? TalkerSettings(maxHistoryItems: 200)
      : TalkerSettings(useConsoleLogs: false, maxHistoryItems: 50);

  return TalkerFlutter.init(
    observer: const SentryTalkerObserver(),
    settings: settings,
    logger: kDebugMode ? null : TalkerLogger(output: _noOpOutput),
  );
}
