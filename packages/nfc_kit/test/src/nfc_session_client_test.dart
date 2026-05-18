import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nfc_kit/nfc_kit.dart';

class MockNfcSessionClient extends Mock implements NfcSessionClient {}

void main() {
  late MockNfcSessionClient client;

  setUp(() {
    client = MockNfcSessionClient();
  });

  group('NfcSessionClientTE.pollTE', () {
    test('returns Right(uppercased tag ID) on success', () async {
      when(() => client.checkAvailability()).thenAnswer((_) async => true);
      when(() => client.poll()).thenAnswer((_) async => 'a1b2c3d4');
      when(() => client.finish()).thenAnswer((_) async {});

      final result = await client.pollTE().run();

      expect(result.isRight(), isTrue);
      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (id) => expect(id, 'A1B2C3D4'),
      );
      verify(() => client.finish()).called(1);
    });

    test(
      'returns Left(NfcUnavailableFailure) when NFC not available',
      () async {
        when(() => client.checkAvailability()).thenAnswer((_) async => false);

        final result = await client.pollTE().run();

        result.fold(
          (f) => expect(f, isA<NfcUnavailableFailure>()),
          (_) => fail('expected Left but got Right'),
        );
        verifyNever(() => client.poll());
        verifyNever(() => client.finish());
      },
    );

    test('returns Left(NfcEmptyTagFailure) when poll returns null', () async {
      when(() => client.checkAvailability()).thenAnswer((_) async => true);
      when(() => client.poll()).thenAnswer((_) async => null);

      final result = await client.pollTE().run();

      result.fold(
        (f) => expect(f, isA<NfcEmptyTagFailure>()),
        (_) => fail('expected Left but got Right'),
      );
      // finish must NOT be called, no session was opened for an empty tag
      verifyNever(() => client.finish());
    });

    test(
      'returns Left(NfcEmptyTagFailure) when poll returns empty string',
      () async {
        when(() => client.checkAvailability()).thenAnswer((_) async => true);
        when(() => client.poll()).thenAnswer((_) async => '');

        final result = await client.pollTE().run();

        result.fold(
          (f) => expect(f, isA<NfcEmptyTagFailure>()),
          (_) => fail('expected Left but got Right'),
        );
        // finish must NOT be called, no session was opened for an empty tag
        verifyNever(() => client.finish());
      },
    );

    test('returns Left(NfcPollFailure) when poll throws', () async {
      when(() => client.checkAvailability()).thenAnswer((_) async => true);
      when(() => client.poll()).thenThrow(Exception('NFC crash'));

      final result = await client.pollTE().run();

      result.fold(
        (f) {
          expect(f, isA<NfcPollFailure>());
          expect(f.message, contains('NFC crash'));
        },
        (_) => fail('expected Left but got Right'),
      );
    });

    test(
      'returns Left(NfcPollFailure) when checkAvailability throws',
      () async {
        when(() => client.checkAvailability()).thenThrow(
          Exception('hardware error'),
        );

        final result = await client.pollTE().run();

        result.fold(
          (f) {
            expect(f, isA<NfcPollFailure>());
            expect(f.message, contains('hardware error'));
          },
          (_) => fail('expected Left but got Right'),
        );
      },
    );

    test(
      'returns Left(NfcPollFailure) when finish throws after successful poll',
      () async {
        when(() => client.checkAvailability()).thenAnswer((_) async => true);
        when(() => client.poll()).thenAnswer((_) async => 'abc123');
        when(() => client.finish()).thenThrow(Exception('session closed'));

        final result = await client.pollTE().run();

        result.fold(
          (f) {
            expect(f, isA<NfcPollFailure>());
            expect(f.message, contains('session closed'));
          },
          (_) => fail('expected Left but got Right'),
        );
      },
    );
  });
}
