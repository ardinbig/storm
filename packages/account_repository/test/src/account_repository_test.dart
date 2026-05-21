// Not required for test files
// ignore_for_file: prefer_const_constructors
import 'package:account_repository/account_repository.dart';
import 'package:test/test.dart';

void main() {
  group('AccountRepository', () {
    test('can be instantiated', () {
      expect(AccountRepository(), isNotNull);
    });
  });
}
