import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:fpdart/fpdart.dart';
import 'package:nfc_kit/nfc_kit.dart';
import 'package:talker/talker.dart';

/// Abstract NFC session client - enables injection and mocking in tests.
abstract class NfcSessionClient {
  /// Returns `true` if NFC is available and enabled on the current device.
  Future<bool> checkAvailability();

  /// Polls for a single NFC tag and returns its raw tag ID string.
  ///
  /// Returns `null` if the tag ID is empty or unavailable.
  /// [timeout] is honoured on Android only.
  Future<String?> poll({Duration timeout = const Duration(seconds: 10)});

  /// Signals the NFC subsystem that the session is complete.
  Future<void> finish();
}

/// [TaskEither] extension on any [NfcSessionClient].
///
/// Provides [pollTE] - a fully typed FP surface for NFC polling.
extension NfcSessionClientTE on NfcSessionClient {
  /// [TaskEither] surface for [poll].
  ///
  /// Returns [Right(String)] with the (non-empty, uppercase) tag ID on
  /// success, or a typed [NfcFailure] as [Left]:
  /// - [NfcUnavailableFailure] if NFC is not available.
  /// - [NfcEmptyTagFailure] if the tag was read but the ID was empty.
  /// - [NfcPollFailure] for platform-channel / hardware exceptions.
  ///
  /// Always calls [finish] on success and failure paths so the session
  /// is never left open.
  TaskEither<NfcFailure, String> pollTE({
    Duration timeout = const Duration(seconds: 10),
  }) => TaskEither<NfcFailure, String>.Do(($) async {
    final available = await $(
      TaskEither<NfcFailure, bool>.tryCatch(
        checkAvailability,
        (e, _) => NfcPollFailure(e.toString()),
      ),
    );
    if (!available) {
      return $(
        TaskEither<NfcFailure, String>.left(const NfcUnavailableFailure()),
      );
    }

    final rawId = await $(
      TaskEither<NfcFailure, String?>.tryCatch(
        () => poll(timeout: timeout),
        (e, _) => NfcPollFailure(e.toString()),
      ).flatMap(
        (id) => id == null || id.isEmpty
            ? TaskEither<NfcFailure, String>.left(
                const NfcEmptyTagFailure(),
              )
            : TaskEither<NfcFailure, String>.right(id.toUpperCase()),
      ),
    );

    await $(
      TaskEither<NfcFailure, Unit>.tryCatch(
        () => finish().then((_) => unit),
        (e, _) => NfcPollFailure(e.toString()),
      ),
    );

    return rawId;
  });
}

/// Production implementation backed by [FlutterNfcKit] with [Talker] logging.
class FlutterNfcKitSessionClient implements NfcSessionClient {
  /// Creates a [FlutterNfcKitSessionClient].
  const FlutterNfcKitSessionClient({required Talker talker}) : _talker = talker;

  final Talker _talker;

  @override
  Future<bool> checkAvailability() async {
    final availability = await FlutterNfcKit.nfcAvailability;
    final isAvailable = availability == NFCAvailability.available;
    _talker.info(
      'NfcKit: availability = $availability (available: $isAvailable)',
    );
    return isAvailable;
  }

  @override
  Future<String?> poll({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    _talker.info('NfcKit: starting poll (timeout: $timeout)');
    try {
      final tag = await FlutterNfcKit.poll(timeout: timeout);
      final id = tag.id.isEmpty ? null : tag.id;
      if (id != null) {
        _talker.info('NfcKit: tag discovered — id=$id type=${tag.type}');
      } else {
        _talker.warning('NfcKit: tag discovered but ID was empty');
      }
      return id;
    } on Object catch (e, st) {
      _talker.error('NfcKit: poll failed', e, st);
      rethrow;
    }
  }

  @override
  Future<void> finish() async {
    _talker.info('NfcKit: finishing session');
    try {
      await FlutterNfcKit.finish();
      _talker.info('NfcKit: session finished');
    } on Object catch (e, st) {
      _talker.error('NfcKit: finish failed', e, st);
      rethrow;
    }
  }
}
