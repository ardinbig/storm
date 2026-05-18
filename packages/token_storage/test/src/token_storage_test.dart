// Not required for test files
// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:token_storage/token_storage.dart';

void main() {
  group('TokenStorage', () {
    test('can be instantiated', () {
      expect(TokenStorage(), isNotNull);
    });
  });
}
