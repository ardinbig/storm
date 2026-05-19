import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:offline_storage/offline_storage.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  group('ConnectivityChecker', () {
    late MockConnectivity connectivity;
    late ConnectivityChecker checker;

    setUp(() {
      connectivity = MockConnectivity();
      checker = ConnectivityChecker(connectivity: connectivity);
    });

    test('isOnline returns true when at least one network is active', () async {
      when(
        () => connectivity.checkConnectivity(),
      ).thenAnswer(
        (_) async => [ConnectivityResult.none, ConnectivityResult.wifi],
      );

      final result = await checker.isOnline;

      expect(result, isTrue);
    });

    test(
      'isOnline returns false when all connectivity results are none',
      () async {
        when(
          () => connectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.none]);

        final result = await checker.isOnline;

        expect(result, isFalse);
      },
    );

    test(
      'isOnline returns false when connectivity result list is empty',
      () async {
        when(
          () => connectivity.checkConnectivity(),
        ).thenAnswer((_) async => []);

        final result = await checker.isOnline;

        expect(result, isFalse);
      },
    );

    test('isOnlineTask wraps isOnline in a Task', () async {
      when(
        () => connectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.wifi]);

      final result = await checker.isOnlineTask.run();

      expect(result, isTrue);
      verify(() => connectivity.checkConnectivity()).called(1);
    });
  });
}
