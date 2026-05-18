import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nfc_kit/nfc_kit.dart';
import 'package:talker/talker.dart';

class MockTalker extends Mock implements Talker {}

const _channel = MethodChannel('flutter_nfc_kit/method');

String _tagJson({String id = 'A1B2C3D4'}) => jsonEncode({
  'type': 'iso7816',
  'id': id,
  'standard': 'ISO 14443-4',
});

void _mockChannel(Future<Object?> Function(MethodCall) handler) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_channel, handler);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockTalker talker;
  late FlutterNfcKitSessionClient client;

  setUp(() {
    talker = MockTalker();
    when(() => talker.info(any<Object?>())).thenReturn(null);
    when(() => talker.warning(any<Object?>())).thenReturn(null);
    when(
      () => talker.error(any<Object?>(), any<Object?>(), any<StackTrace?>()),
    ).thenReturn(null);
    client = FlutterNfcKitSessionClient(talker: talker);
  });

  tearDown(() => _mockChannel((_) async => null));

  group('FlutterNfcKitSessionClient', () {
    test('implements NfcSessionClient', () {
      expect(client, isA<NfcSessionClient>());
    });
  });

  group('checkAvailability', () {
    Future<void> mockAvailability(String value) async {
      _mockChannel(
        (call) async => call.method == 'getNFCAvailability' ? value : null,
      );
    }

    test('returns true when NFC is available', () async {
      await mockAvailability('available');
      expect(await client.checkAvailability(), isTrue);
      verify(() => talker.info(any<Object?>())).called(1);
    });

    test('returns false when NFC is disabled', () async {
      await mockAvailability('disabled');
      expect(await client.checkAvailability(), isFalse);
      verify(() => talker.info(any<Object?>())).called(1);
    });

    test('returns false when NFC is not supported', () async {
      await mockAvailability('not_supported');
      expect(await client.checkAvailability(), isFalse);
      verify(() => talker.info(any<Object?>())).called(1);
    });
  });

  group('poll', () {
    test('returns tag ID for non-empty ID', () async {
      _mockChannel(
        (call) async => call.method == 'poll' ? _tagJson() : null,
      );
      expect(await client.poll(), equals('A1B2C3D4'));
      verify(() => talker.info(any<Object?>())).called(2);
      verifyNever(() => talker.warning(any<Object?>()));
    });

    test('returns null and warns for empty ID', () async {
      _mockChannel(
        (call) async => call.method == 'poll' ? _tagJson(id: '') : null,
      );
      expect(await client.poll(), isNull);
      verify(() => talker.info(any<Object?>())).called(1);
      verify(() => talker.warning(any<Object?>())).called(1);
    });

    test('rethrows and logs error on failure', () async {
      _mockChannel(
        (_) async =>
            throw PlatformException(code: 'NFC_ERROR', message: 'poll failed'),
      );
      await expectLater(() => client.poll(), throwsA(isA<PlatformException>()));
      verify(
        () => talker.error(any<Object?>(), any<Object?>(), any<StackTrace?>()),
      ).called(1);
    });
  });

  group('finish', () {
    test('completes and logs info twice on success', () async {
      _mockChannel((_) async => null);
      await expectLater(client.finish(), completes);
      verify(() => talker.info(any<Object?>())).called(2);
    });

    test('rethrows and logs error on failure', () async {
      _mockChannel(
        (_) async => throw PlatformException(
          code: 'FINISH_ERROR',
          message: 'session error',
        ),
      );
      await expectLater(
        () => client.finish(),
        throwsA(isA<PlatformException>()),
      );
      verify(
        () => talker.error(any<Object?>(), any<Object?>(), any<StackTrace?>()),
      ).called(1);
    });
  });
}
