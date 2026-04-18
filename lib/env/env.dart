import 'package:envied/envied.dart';

part 'env.g.dart';

/// {@template env}
/// Environment variables generated from the `.env` file.
///
/// Run `dart run build_runner build --delete-conflicting-outputs`
/// to regenerate after modifying `.env`.
/// {@endtemplate}
@Envied(path: '.env', obfuscate: true)
abstract class Env {
  /// The API key used for authenticating requests.
  @EnviedField(varName: 'API_KEY', obfuscate: true)
  static final String apiKey = _Env.apiKey;

  /// The base URL of the backend API.
  @EnviedField(varName: 'BASE_URL', obfuscate: true)
  static final String baseUrl = _Env.baseUrl;

  /// The database connection string.
  @EnviedField(varName: 'DATABASE_URL', obfuscate: true)
  static final String databaseUrl = _Env.databaseUrl;

  /// The Sentry DSN for error reporting and observability.
  @EnviedField(varName: 'SENTRY_DSN', obfuscate: true)
  static final String sentryDsn = _Env.sentryDsn;
}
