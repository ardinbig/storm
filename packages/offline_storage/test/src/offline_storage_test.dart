import 'package:flutter_test/flutter_test.dart';
import 'package:offline_storage/offline_storage.dart';

void main() {
  group('OfflineStorage', () {
    test('can be instantiated', () {
      expect(OfflineStorage(), isNotNull);
    });
  });
}
