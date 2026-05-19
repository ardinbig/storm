import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:offline_storage/offline_storage.dart';
import 'package:storm_api_client/storm_api_client.dart';

class MockOfflineStorage extends Mock implements OfflineStorage {}

void main() {
  late MockOfflineStorage offlineStorage;

  final pendingOp = PendingOperation(
    endpoint: '/api/v1/consumptions',
    method: 'POST',
    body: '{"foo":"bar"}',
    createdAt: DateTime.utc(2026, 4, 29),
  );

  IO<PendingOperation> pendingOpIO() => IO(() => pendingOp);

  setUpAll(() {
    registerFallbackValue(pendingOp);
  });

  setUp(() {
    offlineStorage = MockOfflineStorage();
  });

  group('OfflineFallbackX.withOfflineFallback', () {
    test(
      'Right(R) is wrapped as (result: r, queuedOffline: false)',
      () async {
        final result = await TaskEither<StormFailure, Unit>.right(
          unit,
        ).withOfflineFallback(pendingOpIO(), offlineStorage).run();

        expect(result.isRight(), isTrue);
        final value = result.getOrElse((_) => throw Exception('unexpected'));
        expect(value.queuedOffline, isFalse);
        expect(value.result, unit);
        verifyNever(() => offlineStorage.insert(any()));
      },
    );

    test(
      'Left(StormNetworkFailure) inserts operation and returns '
      '(result: null, queuedOffline: true)',
      () async {
        when(() => offlineStorage.insert(any())).thenAnswer((_) async {});

        final result = await TaskEither<StormFailure, Unit>.left(
          const StormNetworkFailure('No internet'),
        ).withOfflineFallback(pendingOpIO(), offlineStorage).run();

        expect(result.isRight(), isTrue);
        final value = result.getOrElse((_) => throw Exception('unexpected'));
        expect(value.queuedOffline, isTrue);
        expect(value.result, isNull);
        verify(() => offlineStorage.insert(any())).called(1);
      },
    );

    test(
      'Left(StormApiFailure) propagates unchanged, no insert called',
      () async {
        const apiFailure = StormApiFailure('Bad request', 400);

        final result = await TaskEither<StormFailure, Unit>.left(
          apiFailure,
        ).withOfflineFallback(pendingOpIO(), offlineStorage).run();

        expect(result.isLeft(), isTrue);
        result.fold(
          (f) => expect(f, equals(apiFailure)),
          (_) => throw Exception('Expected Left'),
        );
        verifyNever(() => offlineStorage.insert(any()));
      },
    );

    test(
      'Left(StormNetworkFailure) when storage.insert throws returns '
      'Left(StormNetworkFailure)',
      () async {
        when(
          () => offlineStorage.insert(any()),
        ).thenThrow(Exception('disk full'));

        final result = await TaskEither<StormFailure, Unit>.left(
          const StormNetworkFailure('No internet'),
        ).withOfflineFallback(pendingOpIO(), offlineStorage).run();

        expect(result.isLeft(), isTrue);
        result.fold(
          (f) {
            expect(f, isA<StormNetworkFailure>());
            expect((f as StormNetworkFailure).message, contains('disk full'));
          },
          (_) => throw Exception('Expected Left'),
        );
      },
    );

    test('pendingOp IO is evaluated lazily, not called on success', () async {
      var ioEvaluated = false;
      final lazyOp = IO<PendingOperation>(() {
        ioEvaluated = true;
        return pendingOp;
      });

      await TaskEither<StormFailure, Unit>.right(
        unit,
      ).withOfflineFallback(lazyOp, offlineStorage).run();

      expect(ioEvaluated, isFalse);
    });

    test(
      'pendingOp IO is evaluated when StormNetworkFailure occurs',
      () async {
        when(() => offlineStorage.insert(any())).thenAnswer((_) async {});
        var ioEvaluated = false;
        final lazyOp = IO<PendingOperation>(() {
          ioEvaluated = true;
          return pendingOp;
        });

        await TaskEither<StormFailure, Unit>.left(
          const StormNetworkFailure('No internet'),
        ).withOfflineFallback(lazyOp, offlineStorage).run();

        expect(ioEvaluated, isTrue);
      },
    );

    test(
      'works with non-Unit type, result is preserved when online',
      () async {
        final result = await TaskEither<StormFailure, String>.right(
          'hello',
        ).withOfflineFallback(pendingOpIO(), offlineStorage).run();

        expect(result.isRight(), isTrue);
        final value = result.getOrElse((_) => throw Exception('unexpected'));
        expect(value.result, 'hello');
        expect(value.queuedOffline, isFalse);
      },
    );
  });
}
