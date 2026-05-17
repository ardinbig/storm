import 'package:dio/dio.dart';
import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

import '../helpers/helpers.dart';

void main() {
  group('_mapDioToFailure', () {
    // meTE() is used as the trigger for all error-branch tests:
    // it does a single GET and casts to Map<String,Object?>, which makes it
    // easy to inject both DioException failures and a bad-cast TypeError.

    test('connectionError produces StormNetworkFailure', () async {
      final dio = buildErrorDio(
        type: DioExceptionType.connectionError,
        message: 'connection refused',
      );
      final result = await buildFakeClient(dio).meTE().run();
      assertLeft(result, (f) {
        expect(f, isA<StormNetworkFailure>());
        expect(f.message, 'connection refused');
      });
    });

    test('connectionTimeout produces StormNetworkFailure', () async {
      final dio = buildErrorDio(type: DioExceptionType.connectionTimeout);
      final result = await buildFakeClient(dio).meTE().run();
      assertLeft(result, (f) => expect(f, isA<StormNetworkFailure>()));
    });

    test('sendTimeout produces StormNetworkFailure', () async {
      final dio = buildErrorDio(type: DioExceptionType.sendTimeout);
      final result = await buildFakeClient(dio).meTE().run();
      assertLeft(result, (f) => expect(f, isA<StormNetworkFailure>()));
    });

    test('receiveTimeout produces StormNetworkFailure', () async {
      final dio = buildErrorDio(type: DioExceptionType.receiveTimeout);
      final result = await buildFakeClient(dio).meTE().run();
      assertLeft(result, (f) => expect(f, isA<StormNetworkFailure>()));
    });

    test(
      'response with valid ErrorResponse body produces StormApiFailure',
      () async {
        final dio = buildErrorDio(
          type: DioExceptionType.badResponse,
          status: 404,
          body: <String, Object?>{'error': 'Not Found', 'code': 404},
          statusMessage: 'Not Found',
        );
        final result = await buildFakeClient(dio).meTE().run();
        assertLeft(result, (f) {
          expect(f, isA<StormApiFailure>());
          expect((f as StormApiFailure).statusCode, 404);
          expect(f.message, 'Not Found');
        });
      },
    );

    test(
      'response with unrecognised Map body falls back to statusMessage',
      () async {
        // Body IS a Map but does not match ErrorResponse schema →
        // fromJson throws inside try/catch, falls through to statusMessage.
        final dio = buildErrorDio(
          type: DioExceptionType.badResponse,
          status: 500,
          body: <String, Object?>{'unexpected': 'shape'},
          statusMessage: 'Internal Server Error',
        );
        final result = await buildFakeClient(dio).meTE().run();
        assertLeft(result, (f) {
          expect(f, isA<StormApiFailure>());
          expect((f as StormApiFailure).statusCode, 500);
          expect(f.message, 'Internal Server Error');
        });
      },
    );

    test(
      'DioException with null response produces StormNetworkFailure',
      () async {
        // Type is not a timeout/connection type AND response is null →
        // hits the final fallback return (line 63 of storm_api_client.dart).
        final dio = buildErrorDio(
          type: DioExceptionType.unknown,
          message: 'unknown error',
        );
        final result = await buildFakeClient(dio).meTE().run();
        assertLeft(result, (f) {
          expect(f, isA<StormNetworkFailure>());
          expect(f.message, 'unknown error');
        });
      },
    );

    test(
      'non-DioException error (bad cast) produces StormNetworkFailure',
      () async {
        // data: 42 causes `42 as Map<String,Object?>` to throw a TypeError
        // inside the async closure. TaskEither.tryCatch catches it and passes
        // it to _mapDioToFailure, hitting the `error is! DioException` branch.
        final dio = buildFakeDio(
          Response<Object?>(
            requestOptions: RequestOptions(path: '/'),
            data: 42,
            statusCode: 200,
          ),
        );
        final result = await buildFakeClient(dio).meTE().run();
        assertLeft(result, (f) => expect(f, isA<StormNetworkFailure>()));
      },
    );
  });
}
