import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:storm_api_client/storm_api_client.dart';

class MockTokenStorage extends Mock implements TokenStorage<OAuth2Token> {}

class LocalTokenStorage implements TokenStorage<OAuth2Token> {
  OAuth2Token? _token;

  @override
  Future<void> delete() async {
    _token = null;
  }

  @override
  Future<OAuth2Token?> read() async => _token;

  @override
  Future<void> write(OAuth2Token token) async {
    _token = token;
  }
}

/// Returns a [Dio] whose every request is immediately resolved with [response].
///
/// No real network call is made. Pass this to [buildFakeClient] to exercise
/// [StormApiClient] endpoint methods in isolation.
Dio buildFakeDio(Response<Object?> response) =>
    Dio(BaseOptions(baseUrl: 'https://test.example'))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) => handler.resolve(
            Response<Object?>(
              requestOptions: options,
              statusCode: response.statusCode ?? 200,
              data: response.data,
              statusMessage: response.statusMessage,
            ),
          ),
        ),
      );

/// Returns a [Dio] whose every request is rejected with a [DioException].
///
/// Supply [type] to control which network error branch of
/// `_mapDioToFailure` is exercised. Optionally provide [status] + [body]
/// to attach a response to the exception (needed for server-error branches).
Dio buildErrorDio({
  required DioExceptionType type,
  String? message,
  int? status,
  Object? body,
  String? statusMessage,
}) => Dio(BaseOptions(baseUrl: 'https://test.example'))
  ..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) => handler.reject(
        DioException(
          requestOptions: options,
          type: type,
          message: message,
          response: status == null
              ? null
              : Response<Object?>(
                  requestOptions: options,
                  statusCode: status,
                  data: body,
                  statusMessage: statusMessage,
                ),
        ),
      ),
    ),
  );

/// Wires a [StormApiClient] to [dio] using an in-memory [LocalTokenStorage].
///
/// The fresh interceptor is configured with [stormShouldRefreshNever] so it
/// never attempts token refresh during tests.
StormApiClient buildFakeClient(Dio dio) => StormApiClient(
  baseUrl: 'https://test.example',
  freshInterceptor: buildFreshInterceptor(
    tokenStorage: LocalTokenStorage(),
  ),
  dio: dio,
);
