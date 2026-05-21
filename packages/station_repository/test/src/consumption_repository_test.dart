import 'package:mocktail/mocktail.dart';
import 'package:station_repository/station_repository.dart';
import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

class MockStormApiClient extends Mock implements StormApiClient {}

class FakeCreateConsumptionRequest extends Fake
    implements CreateConsumptionRequest {}

void main() {
  late MockStormApiClient apiClient;
  late ConsumptionRepository repository;

  final consumption = Consumption(
    clientRef: 'CL-001',
    consumptionType: 'diesel',
    quantity: 40,
    price: 40000,
    username: 'agent-1',
    consumptionDate: DateTime(2026),
    status: 1,
  );

  final fuelPrice = FuelPrice(
    id: 'price-1',
    consumptionType: 'diesel',
    price: 1000,
    priceDate: DateTime(2026, 1, 2),
  );

  setUpAll(() {
    registerFallbackValue(FakeCreateConsumptionRequest());
  });

  setUp(() {
    apiClient = MockStormApiClient();
    repository = ConsumptionRepository(apiClient: apiClient);
  });

  group('ConsumptionRepository', () {
    test('create forwards payload and generates an ISO-8601 date', () async {
      when(
        () => apiClient.createConsumptionTE(any()),
      ).thenReturn(TaskEither.right(unit));

      final result = await repository
          .create(
            clientRef: 'CL-001',
            consumptionType: 'diesel',
            quantity: 40,
            price: 40000,
            username: 'agent-1',
            isOnline: true,
          )
          .run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (_) {},
      );

      final captured =
          verify(
                () => apiClient.createConsumptionTE(captureAny()),
              ).captured.single
              as CreateConsumptionRequest;

      expect(captured.clientRef, 'CL-001');
      expect(captured.consumptionType, 'diesel');
      expect(captured.quantity, 40);
      expect(captured.price, 40000);
      expect(captured.username, 'agent-1');
      expect(captured.isOnline, isTrue);
      expect(DateTime.tryParse(captured.date), isNotNull);
    });

    test('create returns StormApiFailure on api error', () async {
      when(() => apiClient.createConsumptionTE(any())).thenReturn(
        TaskEither.left(const StormApiFailure('Invalid request', 400)),
      );

      final result = await repository
          .create(
            clientRef: 'CL-001',
            consumptionType: 'diesel',
            quantity: 40,
            price: 40000,
            username: 'agent-1',
            isOnline: false,
          )
          .run();

      result.fold(
        (f) {
          expect(f, isA<StormApiFailure>());
          expect(f.message, 'Invalid request');
        },
        (_) => fail('expected Left but got Right'),
      );
      verify(() => apiClient.createConsumptionTE(any())).called(1);
    });

    test('listAll returns all consumptions from api client', () async {
      when(() => apiClient.listConsumptionsTE()).thenReturn(
        TaskEither.right([consumption]),
      );

      final result = await repository.listAll().run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (list) => expect(list, [consumption]),
      );
      verify(() => apiClient.listConsumptionsTE()).called(1);
    });

    test('listAll returns empty list when there are no records', () async {
      when(() => apiClient.listConsumptionsTE()).thenReturn(
        TaskEither.right([]),
      );

      final result = await repository.listAll().run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (list) => expect(list, isEmpty),
      );
      verify(() => apiClient.listConsumptionsTE()).called(1);
    });

    test('listByClient returns consumptions for selected client', () async {
      when(() => apiClient.listConsumptionsByClientTE('CL-001')).thenReturn(
        TaskEither.right([consumption]),
      );

      final result = await repository.listByClient('CL-001').run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (list) => expect(list, [consumption]),
      );
      verify(() => apiClient.listConsumptionsByClientTE('CL-001')).called(1);
    });

    test('listByClient returns StormNetworkFailure on error', () async {
      when(() => apiClient.listConsumptionsByClientTE('CL-001')).thenReturn(
        TaskEither.left(const StormNetworkFailure('No internet')),
      );

      final result = await repository.listByClient('CL-001').run();

      result.fold(
        (f) {
          expect(f, isA<StormNetworkFailure>());
          expect(f.message, 'No internet');
        },
        (_) => fail('expected Left but got Right'),
      );
      verify(() => apiClient.listConsumptionsByClientTE('CL-001')).called(1);
    });

    test('listPrices returns all configured prices', () async {
      when(() => apiClient.listPricesTE()).thenReturn(
        TaskEither.right([fuelPrice]),
      );

      final result = await repository.listPrices().run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (list) => expect(list, [fuelPrice]),
      );
      verify(() => apiClient.listPricesTE()).called(1);
    });

    test('priceByType returns price for requested fuel type', () async {
      when(() => apiClient.priceByTypeTE('diesel')).thenReturn(
        TaskEither.right(fuelPrice),
      );

      final result = await repository.priceByType('diesel').run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (p) => expect(p, fuelPrice),
      );
      verify(() => apiClient.priceByTypeTE('diesel')).called(1);
    });

    test('priceByType returns StormApiFailure for unknown fuel type', () async {
      when(() => apiClient.priceByTypeTE('unknown')).thenReturn(
        TaskEither.left(const StormApiFailure('Price not found', 404)),
      );

      final result = await repository.priceByType('unknown').run();

      result.fold(
        (f) {
          expect(f, isA<StormApiFailure>());
          expect(f.message, 'Price not found');
        },
        (_) => fail('expected Left but got Right'),
      );
      verify(() => apiClient.priceByTypeTE('unknown')).called(1);
    });

    test('createPrice forwards request and returns created price', () async {
      const request = CreatePriceRequest(
        consumptionType: 'diesel',
        price: 1100,
      );
      when(() => apiClient.createPriceTE(request)).thenReturn(
        TaskEither.right(fuelPrice),
      );

      final result = await repository.createPrice(request).run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (p) => expect(p, fuelPrice),
      );
      verify(() => apiClient.createPriceTE(request)).called(1);
    });

    test(
      'createPrice returns StormApiFailure for invalid price data',
      () async {
        const request = CreatePriceRequest(
          consumptionType: 'diesel',
          price: -1,
        );
        when(() => apiClient.createPriceTE(request)).thenReturn(
          TaskEither.left(const StormApiFailure('Invalid price', 400)),
        );

        final result = await repository.createPrice(request).run();

        result.fold(
          (f) {
            expect(f, isA<StormApiFailure>());
            expect(f.message, 'Invalid price');
          },
          (_) => fail('expected Left but got Right'),
        );
        verify(() => apiClient.createPriceTE(request)).called(1);
      },
    );
  });
}
