import 'dart:async';

import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// {@template sentry_talker_observer}
/// A [TalkerObserver] that forwards errors and exceptions to Sentry and
/// adds regular log entries as Sentry breadcrumbs.
/// {@endtemplate}
class SentryTalkerObserver extends TalkerObserver {
  /// {@macro sentry_talker_observer}
  const SentryTalkerObserver();

  @override
  void onError(TalkerError err) {
    unawaited(
      Sentry.captureException(
        err.error,
        stackTrace: err.stackTrace,
      ),
    );
  }

  @override
  void onException(TalkerException err) {
    unawaited(
      Sentry.captureException(
        err.exception,
        stackTrace: err.stackTrace,
      ),
    );
  }

  @override
  void onLog(TalkerData log) {
    unawaited(
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: log.message,
          level: _mapLevel(log.logLevel ?? LogLevel.debug),
          timestamp: log.time,
          category: log.key,
        ),
      ),
    );
  }

  SentryLevel _mapLevel(LogLevel level) {
    return switch (level) {
      LogLevel.critical || LogLevel.error => SentryLevel.error,
      LogLevel.warning => SentryLevel.warning,
      LogLevel.info => SentryLevel.info,
      LogLevel.debug || LogLevel.verbose => SentryLevel.debug,
    };
  }
}
