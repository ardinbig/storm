import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

import '../helpers/client_test_helpers.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const OAuth2Token(accessToken: 'fallback'));
  });

  group('interceptor and exception helpers', () {
    test('constructor creates internal dio when not provided', () {
      final fresh = buildFreshInterceptor(tokenStorage: LocalTokenStorage());
      final client = StormApiClient(
        baseUrl: 'https://example.test',
        freshInterceptor: fresh,
      );

      expect(identical(client.fresh, fresh), isTrue);
    });

    test('StormApiException fromErrorResponse and toString expose details', () {
      const errorResponse = ErrorResponse(error: 'Forbidden', code: 403);
      final exception = StormApiException.fromErrorResponse(errorResponse);

      expect(exception.error, 'Forbidden');
      expect(exception.statusCode, 403);
      expect(exception.toString(), 'StormApiException(403): Forbidden');
    });

    test('StormApiNetworkException toString includes message', () {
      const exception = StormApiNetworkException('no internet');
      expect(exception.toString(), 'StormApiNetworkException: no internet');
    });

    group('StormFailure', () {
      test(
        'StormApiFailure exposes message, statusCode and correct asException',
        () {
          const failure = StormApiFailure('Not Found', 404);
          expect(failure.message, 'Not Found');
          expect(failure.statusCode, 404);

          final ex = failure.asException;
          expect(ex, isA<StormApiException>());
          expect((ex as StormApiException).error, 'Not Found');
          expect(ex.statusCode, 404);
        },
      );

      test('StormNetworkFailure exposes message and correct asException', () {
        const failure = StormNetworkFailure('no internet');
        expect(failure.message, 'no internet');

        final ex = failure.asException;
        expect(ex, isA<StormApiNetworkException>());
        expect((ex as StormApiNetworkException).message, 'no internet');
      });
    });

    test('stormShouldRefreshNever always returns false', () {
      expect(stormShouldRefreshNever(null), isFalse);
      expect(
        stormShouldRefreshNever(
          Response<void>(requestOptions: RequestOptions(path: '/x')),
        ),
        isFalse,
      );
    });

    group('buildFreshInterceptor', () {
      MockTokenStorage setupMockTokenStorage() {
        final tokenStorage = MockTokenStorage();
        when(tokenStorage.read).thenAnswer((_) async => null);
        when(() => tokenStorage.write(any())).thenAnswer((_) async {});
        when(tokenStorage.delete).thenAnswer((_) async {});
        return tokenStorage;
      }

      test('stores token, adds bearer header, and revokes', () async {
        final tokenStorage = setupMockTokenStorage();
        final fresh = buildFreshInterceptor(tokenStorage: tokenStorage);
        await fresh.setToken(const OAuth2Token(accessToken: 'abc'));

        final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
          ..interceptors.add(fresh)
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                expect(options.headers['Authorization'], 'Bearer abc');
                handler.resolve(Response<void>(requestOptions: options));
              },
            ),
          );

        await dio.get<void>('/check');
        verify(
          () => tokenStorage.write(const OAuth2Token(accessToken: 'abc')),
        ).called(1);

        await expectLater(
          fresh.refreshToken(
            tokenUsedForRequest: const OAuth2Token(accessToken: 'abc'),
          ),
          throwsA(isA<RevokeTokenException>()),
        );
        verify(tokenStorage.delete).called(1);
      });

      test('does not refresh or delete token on 401 response', () async {
        final tokenStorage = setupMockTokenStorage();
        final fresh = buildFreshInterceptor(tokenStorage: tokenStorage);
        await fresh.setToken(const OAuth2Token(accessToken: 'abc'));

        final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
          ..interceptors.add(fresh)
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                handler.resolve(
                  Response<Object?>(
                    requestOptions: options,
                    statusCode: 401,
                    data: const {'error': 'Unauthorized', 'code': 401},
                  ),
                );
              },
            ),
          );

        final response = await dio.get<Object?>('/no-refresh');
        expect(response.statusCode, 401);
        verifyNever(tokenStorage.delete);
      });

      test('does not refresh on 401 dio error response', () async {
        final tokenStorage = setupMockTokenStorage();
        final fresh = buildFreshInterceptor(tokenStorage: tokenStorage);
        await fresh.setToken(const OAuth2Token(accessToken: 'abc'));

        final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
          ..interceptors.add(fresh)
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                handler.reject(
                  DioException(
                    requestOptions: options,
                    type: DioExceptionType.badResponse,
                    response: Response<Object?>(
                      requestOptions: options,
                      statusCode: 401,
                      data: const {'error': 'Unauthorized', 'code': 401},
                    ),
                  ),
                );
              },
            ),
          );

        await expectLater(
          dio.get<Object?>('/no-refresh-error'),
          throwsA(isA<DioException>()),
        );
        verifyNever(tokenStorage.delete);
      });
    });
  });
}
