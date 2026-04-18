import 'package:flutter/foundation.dart';
import 'package:storm/observability/sentry_talker_observer.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// No-op output used in release mode to suppress all console logs.
void _noOpOutput(String message) {}

/// Initializes and returns the global [Talker] instance.
///
/// - Console output is disabled in release mode ([kReleaseMode]).
/// - Max history is capped at 100 entries.
/// - In non-release builds, logs are forwarded via [TalkerFlutter] defaults.
/// - A [SentryTalkerObserver] is attached to route errors to Sentry.
Talker initTalker() {
  final settings = kReleaseMode
      ? TalkerSettings(useConsoleLogs: false, maxHistoryItems: 100)
      : TalkerSettings(maxHistoryItems: 100);

  return TalkerFlutter.init(
    observer: const SentryTalkerObserver(),
    settings: settings,
    logger: kReleaseMode ? TalkerLogger(output: _noOpOutput) : null,
  );
}
