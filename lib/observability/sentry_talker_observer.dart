// coverage:ignore-file

import 'dart:async';

import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// {@template sentry_talker_observer}
/// A [TalkerObserver] that forwards errors and exceptions to Sentry and
/// adds regular log entries as Sentry breadcrumbs.
///
/// Behaviour per log level:
/// - **critical** – captured as a Sentry event with [SentryLevel.fatal] AND
///   added as a breadcrumb so the full trail is preserved.
/// - **error** – forwarded via [Sentry.captureException]; in [onLog] (for
///   non-exception error logs) also captured as a Sentry event.
/// - **warning / info / debug / verbose** – added as breadcrumbs only.
///
/// [onError] and [onException] enrich the Sentry scope with the Talker key
/// and message for easier filtering in the Sentry dashboard.
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
        withScope: (scope) async {
          await scope.setTag('talker.key', err.key);
          if (err.message != null) {
            scope.setContexts('talker', <String, dynamic>{
              'message': err.message,
            });
          }
        },
      ),
    );
  }

  @override
  void onException(TalkerException err) {
    unawaited(
      Sentry.captureException(
        err.exception,
        stackTrace: err.stackTrace,
        withScope: (scope) async {
          await scope.setTag('talker.key', err.key);
          if (err.message != null) {
            scope.setContexts('talker', <String, dynamic>{
              'message': err.message,
            });
          }
        },
      ),
    );
  }

  @override
  void onLog(TalkerData log) {
    final level = log.logLevel ?? LogLevel.debug;
    final sentryLevel = _mapLevel(level);

    // Capture critical and error-level logs as Sentry events.
    if (level == LogLevel.critical || level == LogLevel.error) {
      unawaited(
        Sentry.captureMessage(
          log.message ?? '',
          level: sentryLevel,
          withScope: (scope) => scope.setTag('talker.key', log.key ?? 'log'),
        ),
      );
    }

    unawaited(
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: log.message,
          level: sentryLevel,
          timestamp: log.time,
          category: log.key,
          type: _mapBreadcrumbType(level),
        ),
      ),
    );
  }

  /// Maps a Talker [LogLevel] to the corresponding [SentryLevel].
  SentryLevel _mapLevel(LogLevel level) {
    return switch (level) {
      LogLevel.critical => SentryLevel.fatal,
      LogLevel.error => SentryLevel.error,
      LogLevel.warning => SentryLevel.warning,
      LogLevel.info => SentryLevel.info,
      LogLevel.debug || LogLevel.verbose => SentryLevel.debug,
    };
  }

  /// Maps a Talker [LogLevel] to a Sentry breadcrumb type string.
  String _mapBreadcrumbType(LogLevel level) {
    return switch (level) {
      LogLevel.critical || LogLevel.error || LogLevel.warning => 'error',
      LogLevel.debug || LogLevel.verbose => 'debug',
      _ => 'default',
    };
  }
}
