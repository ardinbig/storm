// Not required for test files
// ignore_for_file: prefer_const_constructors
import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

void main() {
  group('StormApiClient', () {
    test('can be instantiated', () {
      expect(StormApiClient(), isNotNull);
    });
  });
}
