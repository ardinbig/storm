import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

void main() {
  group('mapStormError', () {
    group('given a StormApiException', () {
      test('returns StormApiFailure with matching message and statusCode', () {
        const exception = StormApiException('Not Found', 404);
        final failure = mapStormError(exception, StackTrace.empty);

        expect(failure, isA<StormApiFailure>());
        expect((failure as StormApiFailure).message, 'Not Found');
        expect(failure.statusCode, 404);
      });
    });

    group('given a StormApiNetworkException', () {
      test('returns StormNetworkFailure with matching message', () {
        const exception = StormApiNetworkException('connection timed out');
        final failure = mapStormError(exception, StackTrace.empty);

        expect(failure, isA<StormNetworkFailure>());
        expect(
          (failure as StormNetworkFailure).message,
          'connection timed out',
        );
      });
    });

    group('given any other error type', () {
      test(
        'returns StormNetworkFailure whose message is the error toString',
        () {
          final error = Exception('unexpected crash');
          final failure = mapStormError(error, StackTrace.empty);

          expect(failure, isA<StormNetworkFailure>());
          expect(failure.message, error.toString());
        },
      );

      test('handles a plain StateError', () {
        final error = StateError('bad state');
        final failure = mapStormError(error, StackTrace.empty);

        expect(failure, isA<StormNetworkFailure>());
        expect(failure.message, error.toString());
      });
    });
  });

  group('StormApiFailure', () {
    test('toDisplayMessage returns the server-provided error message', () {
      const failure = StormApiFailure('Unauthorized', 401);
      expect(failure.toDisplayMessage, 'Unauthorized');
    });

    test('toDisplayMessage equals message field', () {
      const failure = StormApiFailure('Service Unavailable', 503);
      expect(failure.toDisplayMessage, failure.message);
    });
  });

  group('StormNetworkFailure', () {
    test('toDisplayMessage returns the human-readable network string', () {
      const failure = StormNetworkFailure('no internet');
      expect(failure.toDisplayMessage, 'Network error. Please retry.');
    });

    test('toDisplayMessage is independent of the internal message', () {
      const failure = StormNetworkFailure('E-CONN-REFUSED');
      expect(failure.toDisplayMessage, 'Network error. Please retry.');
    });
  });
}
