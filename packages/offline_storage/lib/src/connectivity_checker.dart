import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fpdart/fpdart.dart';

/// Small utility to check if the device currently has connectivity.
class ConnectivityChecker {
  /// Creates a checker using [Connectivity] (injectable for tests).
  const ConnectivityChecker({this._connectivity});

  final Connectivity? _connectivity;

  /// Returns `true` when any active transport is available.
  Future<bool> get isOnline async {
    final conn = _connectivity ?? Connectivity();
    final results = await conn.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// [Task]-wrapped connectivity check, safe to use inside `TaskEither` chains.
  Task<bool> get isOnlineTask => Task(() => isOnline);
}
