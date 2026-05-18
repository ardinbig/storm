import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:offline_storage/offline_storage.dart';
import 'package:storm_api_client/storm_api_client.dart' show Dio;

/// Sync result containing counts of successful and failed operations.
class SyncResult {
  const SyncResult({required this.synced, required this.failed});

  /// Number of successfully replayed operations.
  final int synced;

  /// Number of failed operations remaining in queue.
  final int failed;
}

/// {@template sync_engine}
/// Drains the offline queue when the device has connectivity.
///
/// Replays pending operations in FIFO order using the injected [Dio] instance.
/// Use [ConnectivityChecker] to determine when to call [drainQueue].
///
/// Uses constructor-based dependency injection for maximum flexibility;
/// consumers provide a pre-configured [Dio] instance.
/// {@endtemplate}
class SyncEngine {
  /// {@macro sync_engine}
  ///
  /// **Parameters:**
  /// * `offlineStorage`: The [OfflineStorage] instance managing the SQLite
  ///   queue.
  /// * `dio`: The configured [Dio] instance for making HTTP requests.
  const SyncEngine({
    required OfflineStorage offlineStorage,
    required Dio dio,
  }) : _offlineStorage = offlineStorage,
       _dio = dio;

  final OfflineStorage _offlineStorage;
  final Dio _dio;

  /// Replays all pending operations in FIFO order.
  ///
  /// Attempts every operation regardless of individual failures.
  /// Returns result counts; failed operations remain queued.
  Future<SyncResult> drainQueue() async {
    final operations = await _offlineStorage.pendingOperations();

    // Run ALL operations sequentially (FIFO), collecting per-op Either results.
    final results = await operations
        .traverseTaskSeq<Either<Object, Unit>>(
          (op) => Task(() => _replayOperation(op).run()),
        )
        .run();

    final synced = results.where((e) => e.isRight()).length;
    return SyncResult(synced: synced, failed: results.length - synced);
  }

  /// Replays a single operation (POST, PUT, DELETE) and removes it on success.
  ///
  /// Returns [Left] on error (network, API, unsupported method, or missing id).
  TaskEither<Object, Unit> _replayOperation(PendingOperation op) =>
      TaskEither.tryCatch(
        () async {
          final data = jsonDecode(op.body);
          switch (op.method.toUpperCase()) {
            case 'POST':
              await _dio.post<void>(op.endpoint, data: data);
            case 'PUT':
              await _dio.put<void>(op.endpoint, data: data);
            case 'DELETE':
              await _dio.delete<void>(op.endpoint);
            default:
              throw UnsupportedError('Unsupported method: ${op.method}');
          }
          if (op.id case final id?) {
            await _offlineStorage.remove(id);
          } else {
            throw StateError('Operation has no id — cannot remove from queue');
          }
          return unit;
        },
        (e, _) => e,
      );
}
