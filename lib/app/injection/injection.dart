// coverage:ignore-file

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:storm/app/injection/injection.config.dart';

/// Global [GetIt] service locator instance.
final GetIt getIt = GetIt.instance;

/// Initializes all injectable dependencies.
///
/// Call this in `main()` before `runApp()`.
/// The optional [environment] parameter enables flavor-specific
/// registrations (e.g., `'development'`, `'staging'`, `'production'`).
@InjectableInit()
void configureDependencies({String? environment}) =>
    getIt.init(environment: environment);
