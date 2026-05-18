import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_kit/nfc_kit.dart';

void main() {
  group('NfcUnavailableFailure', () {
    test('is a NfcFailure', () {
      const failure = NfcUnavailableFailure();
      expect(failure, isA<NfcFailure>());
    });

    test('has default message', () {
      const failure = NfcUnavailableFailure();
      expect(failure.message, 'NFC is not available.');
    });

    test('accepts custom message', () {
      const failure = NfcUnavailableFailure('Custom unavailable');
      expect(failure.message, 'Custom unavailable');
    });
  });

  group('NfcEmptyTagFailure', () {
    test('is a NfcFailure', () {
      const failure = NfcEmptyTagFailure();
      expect(failure, isA<NfcFailure>());
    });

    test('has default message', () {
      const failure = NfcEmptyTagFailure();
      expect(failure.message, 'NFC tag ID was empty.');
    });

    test('accepts custom message', () {
      const failure = NfcEmptyTagFailure('Custom empty');
      expect(failure.message, 'Custom empty');
    });
  });

  group('NfcPollFailure', () {
    test('is a NfcFailure', () {
      const failure = NfcPollFailure('Poll failed');
      expect(failure, isA<NfcFailure>());
    });

    test('stores message', () {
      const failure = NfcPollFailure('Poll failed');
      expect(failure.message, 'Poll failed');
    });
  });
}
