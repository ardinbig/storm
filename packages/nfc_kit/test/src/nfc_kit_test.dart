// Not required for test files
// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_kit/nfc_kit.dart';

void main() {
  group('NfcKit', () {
    test('can be instantiated', () {
      expect(NfcKit(), isNotNull);
    });
  });
}
