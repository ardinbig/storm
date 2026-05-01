import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:storm_api_client/storm_api_client.dart';

/// {@template storm_api_client}
/// Dio-based HTTP client for the Storm REST API.
///
/// Token management is handled by a [Fresh] interceptor - callers never
/// set tokens manually.
///
/// Every endpoint is exposed through a `*TE()` method returning
/// [TaskEither]`<`[StormFailure]`, T>` - the canonical functional interface
/// consumed by repositories.
/// {@endtemplate}
class StormApiClient {
  /// {@macro storm_api_client}
  StormApiClient({
    required String baseUrl,
    required Fresh<OAuth2Token> freshInterceptor,
    Dio? dio,
  }) : _fresh = freshInterceptor,
       _dio = (dio ?? Dio(BaseOptions(baseUrl: baseUrl)))
         ..interceptors.add(freshInterceptor);

  //
  // ignore: unused_field
  final Dio _dio;
  final Fresh<OAuth2Token> _fresh;

  /// Exposes the [Fresh] interceptor for the repository layer to listen
  /// to [AuthenticationStatus] changes or set tokens after login.
  Fresh<OAuth2Token> get fresh => _fresh;
}
