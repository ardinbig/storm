// Not required for test files
// ignore_for_file: prefer_const_constructors
import 'package:station_repository/station_repository.dart';
import 'package:test/test.dart';

void main() {
  group('StationRepository', () {
    test('can be instantiated', () {
      expect(StationRepository(), isNotNull);
    });
  });
}
