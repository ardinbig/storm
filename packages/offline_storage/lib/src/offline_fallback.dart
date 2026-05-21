import 'package:offline_storage/offline_storage.dart';
import 'package:storm_api_client/storm_api_client.dart';

/// Extends [TaskEither<StormFailure, R>] with transparent offline fallback.
///
/// On network failure, queues operation for replay; on API failure, propagates
/// unchanged. Success wraps result with `queuedOffline` flag.
extension OfflineFallbackX<R> on TaskEither<StormFailure, R> {
  /// Wraps result with offline status or queues operation on network failure.
  ///
  /// * Success → `(result: R, queuedOffline: false)`
  /// * Network failure → queues operation,
  ///     returns `(result: null, queuedOffline: true)`
  /// * API failure → propagates unchanged
  TaskEither<StormFailure, ({R? result, bool queuedOffline})>
  withOfflineFallback(
    IO<PendingOperation> pendingOp,
    OfflineStorage storage,
  ) =>
      map<({R? result, bool queuedOffline})>(
        (r) => (result: r, queuedOffline: false),
      ).orElse(
        (failure) => failure is StormNetworkFailure
            ? TaskEither.tryCatch(
                () async {
                  await storage.insert(pendingOp.run());
                  return (result: null, queuedOffline: true);
                },
                (e, _) => StormNetworkFailure(e.toString()),
              )
            : TaskEither.left(failure),
      );
}
