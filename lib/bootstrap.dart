import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Bootstraps the application with the given [builder] and [talker].
///
/// - Hooks [FlutterError.onError] and platform-dispatcher errors into Talker.
/// - Sets [Bloc.observer] to [TalkerBlocObserver] for automatic BLoC logging.
Future<void> bootstrap(
  FutureOr<Widget> Function() builder, {
  required Talker talker,
}) async {
  FlutterError.onError = (details) {
    talker.handle(details.exception, details.stack);
  };

  Bloc.observer = TalkerBlocObserver(talker: talker);

  // TODO(ardinbig): Add Sentry initialization

  runApp(await builder());
}
