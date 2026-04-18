// coverage:ignore-file

import 'package:injectable/injectable.dart';
import 'package:storm/observability/observability.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Registers all third-party and cross-cutting dependencies that
/// cannot be annotated with `@injectable` directly (external packages).
@module
abstract class AppModule {
  // Observability
  // =============

  @lazySingleton
  Talker get talker => initTalker();
}
