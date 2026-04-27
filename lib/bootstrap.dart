import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:storm/env/env.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Bootstraps the application with the given [builder] and [talker].
///
/// - Hooks [FlutterError.onError] and platform-dispatcher errors into Talker.
/// - Sets [Bloc.observer] to [TalkerBlocObserver] for automatic BLoC logging.
/// - Initializes Sentry with [Env.sentryDsn] and the given [tracesSampleRate].
/// - Catches uncaught async errors with [runZonedGuarded] & logs them.
/// - Runs the app with the widget returned by [builder].
Future<void> bootstrap(
  FutureOr<Widget> Function() builder, {
  required Talker talker,
  double tracesSampleRate = 1.0,
}) async {
  // Flutter framework errors.
  FlutterError.onError = (details) {
    talker.handle(details.exception, details.stack);
  };

  // Platform-level errors not caught by the Flutter framework.
  PlatformDispatcher.instance.onError = (error, stack) {
    talker.handle(error, stack);
    return true;
  };

  Bloc.observer = TalkerBlocObserver(talker: talker);

  // Catches async errors that aren't caught by the Flutter framework
  // or platform dispatcher.
  await runZonedGuarded(
    () async {
      await SentryFlutter.init(
        (options) {
          options
            ..dsn = Env.sentryDsn
            ..tracesSampleRate = tracesSampleRate
            ..enableAutoSessionTracking = true
            ..enableUserInteractionTracing = true
            ..attachScreenshot = true
            ..connectionTimeout = const Duration(seconds: 5);
        },
        appRunner: () async => runApp(SentryWidget(child: await builder())),
      );
    },
    (error, stack) => talker.handle(error, stack),
  );
}
