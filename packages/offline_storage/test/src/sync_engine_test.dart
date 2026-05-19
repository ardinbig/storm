import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:offline_storage/offline_storage.dart';

class MockOfflineStorage extends Mock implements OfflineStorage {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockOfflineStorage offlineStorage;
  late MockDio dio;
  late SyncEngine engine;

  setUp(() {
    offlineStorage = MockOfflineStorage();
    dio = MockDio();
    engine = SyncEngine(offlineStorage: offlineStorage, dio: dio);

    when(
      () => offlineStorage.pendingOperations(),
    ).thenAnswer((_) async => const []);
  });

  PendingOperation operation({
    int? id = 1,
    String endpoint = '/api/v1/consumptions',
    String method = 'POST',
    String body = '{"foo":"bar"}',
  }) {
    return PendingOperation(
      id: id,
      endpoint: endpoint,
      method: method,
      body: body,
      createdAt: DateTime.utc(2026, 4, 8),
    );
  }

  group('SyncEngine', () {
    test(
      'drainQueue replays supported operations and removes successful rows',
      () async {
        when(
          () => offlineStorage.pendingOperations(),
        ).thenAnswer(
          (_) async => [
            operation(),
            operation(id: 2, method: 'PUT'),
            operation(id: 3, method: 'DELETE', body: '{}'),
          ],
        );
        when(
          () => dio.post<void>(any(), data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response<void>(requestOptions: RequestOptions()),
        );
        when(
          () => dio.put<void>(any(), data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response<void>(requestOptions: RequestOptions()),
        );
        when(
          () => dio.delete<void>(any()),
        ).thenAnswer(
          (_) async => Response<void>(requestOptions: RequestOptions()),
        );
        when(() => offlineStorage.remove(any())).thenAnswer((_) async {});

        final result = await engine.drainQueue();

        expect(result.synced, 3);
        expect(result.failed, 0);
        verify(() => offlineStorage.remove(1)).called(1);
        verify(() => offlineStorage.remove(2)).called(1);
        verify(() => offlineStorage.remove(3)).called(1);
      },
    );

    test(
      'drainQueue keeps queued row when api replay throws DioException',
      () async {
        when(
          () => offlineStorage.pendingOperations(),
        ).thenAnswer((_) async => [operation(id: 10)]);
        when(
          () => dio.post<void>(any(), data: any(named: 'data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            error: 'connection failed',
          ),
        );

        final result = await engine.drainQueue();

        expect(result.synced, 0);
        expect(result.failed, 1);
        verifyNever(() => offlineStorage.remove(any()));
      },
    );

    test(
      'drainQueue counts unsupported-method operations as failed',
      () async {
        when(
          () => offlineStorage.pendingOperations(),
        ).thenAnswer((_) async => [operation(id: 5, method: 'PATCH')]);

        final result = await engine.drainQueue();

        expect(result.synced, 0);
        expect(result.failed, 1);
        verifyNever(() => offlineStorage.remove(any()));
        verifyNever(() => dio.post<void>(any(), data: any(named: 'data')));
        verifyNever(() => dio.put<void>(any(), data: any(named: 'data')));
        verifyNever(() => dio.delete<void>(any()));
      },
    );

    test('drainQueue counts operation without id as failed', () async {
      when(
        () => offlineStorage.pendingOperations(),
      ).thenAnswer((_) async => [operation(id: null)]);
      when(
        () => dio.post<void>(any(), data: any(named: 'data')),
      ).thenAnswer(
        (_) async => Response<void>(requestOptions: RequestOptions()),
      );

      final result = await engine.drainQueue();

      expect(result.synced, 0);
      expect(result.failed, 1);
      verifyNever(() => offlineStorage.remove(any()));
    });

    test(
      'drainQueue returns failed=1 for an operation with invalid JSON body',
      () async {
        when(
          () => offlineStorage.pendingOperations(),
        ).thenAnswer((_) async => [operation(body: '{invalid-json}')]);

        final result = await engine.drainQueue();

        expect(result.synced, 0);
        expect(result.failed, 1);
        verifyNever(() => offlineStorage.remove(any()));
      },
    );

    test(
      'drainQueue reports partial success: synced=1, failed=1 when first op '
      'succeeds and second op fails',
      () async {
        when(
          () => offlineStorage.pendingOperations(),
        ).thenAnswer(
          (_) async => [
            operation(),
            operation(id: 2, method: 'PATCH'),
          ],
        );
        when(
          () => dio.post<void>(any(), data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response<void>(requestOptions: RequestOptions()),
        );
        when(() => offlineStorage.remove(1)).thenAnswer((_) async {});

        final result = await engine.drainQueue();

        // All ops are attempted, partial success is accurately reported.
        expect(result.synced, 1);
        expect(result.failed, 1);
        // The POST ran and succeeded, so remove(1) was called.
        verify(() => offlineStorage.remove(1)).called(1);
        verifyNever(() => offlineStorage.remove(2));
      },
    );

    test(
      'drainQueue continues past a failure so later successful ops are synced',
      () async {
        when(
          () => offlineStorage.pendingOperations(),
        ).thenAnswer(
          (_) async => [
            operation(method: 'PATCH'),
            operation(id: 2),
          ],
        );
        when(
          () => dio.post<void>(any(), data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response<void>(requestOptions: RequestOptions()),
        );
        when(() => offlineStorage.remove(2)).thenAnswer((_) async {});

        final result = await engine.drainQueue();

        expect(result.synced, 1);
        expect(result.failed, 1);
        verifyNever(() => offlineStorage.remove(1));
        verify(() => offlineStorage.remove(2)).called(1);
      },
    );
  });
}
