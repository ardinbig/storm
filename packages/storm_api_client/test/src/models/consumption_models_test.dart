//
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

void main() {
  group('Consumption', () {
    const json = <String, Object?>{
      'client_ref': 'CLI1',
      'consumption_type': 'diesel',
      'quantity': 5.0,
      'price': 2.0,
      'username': 'user',
      'consumption_date': '2024-06-01T10:00:00.000Z',
      'status': 1,
    };

    test('parses all fields correctly', () {
      final m = Consumption.fromJson(json);
      expect(m.clientRef, 'CLI1');
      expect(m.consumptionType, 'diesel');
      expect(m.quantity, 5.0);
      expect(m.consumptionDate, isA<DateTime>());
      expect(m.status, 1);
    });

    test('round-trips through toJson', () {
      final m = Consumption.fromJson(json);
      expect(Consumption.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different quantity', () {
      final a = Consumption.fromJson(json);
      final b = Consumption.fromJson({...json, 'quantity': 99.0});
      expect(a, isNot(equals(b)));
    });
  });

  group('CreateConsumptionRequest', () {
    const json = <String, Object?>{
      'date': '2024-01-01',
      'client_ref': 'CLI1',
      'consumption_type': 'diesel',
      'quantity': 5.0,
      'price': 2.0,
      'username': 'user',
      'is_online': true,
    };

    test('parses all fields correctly', () {
      final m = CreateConsumptionRequest.fromJson(json);
      expect(m.clientRef, 'CLI1');
      expect(m.isOnline, isTrue);
    });

    test('round-trips through toJson', () {
      final m = CreateConsumptionRequest.fromJson(json);
      expect(CreateConsumptionRequest.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different isOnline', () {
      final a = CreateConsumptionRequest.fromJson(json);
      final b = CreateConsumptionRequest.fromJson({
        ...json,
        'is_online': false,
      });
      expect(a, isNot(equals(b)));
    });
  });

  group('FuelPrice', () {
    const json = <String, Object?>{
      'id': 'p1',
      'consumption_type': 'diesel',
      'price': 2.0,
      'price_date': '2024-01-01T00:00:00.000Z',
    };

    test('parses all fields correctly', () {
      final m = FuelPrice.fromJson(json);
      expect(m.id, 'p1');
      expect(m.consumptionType, 'diesel');
      expect(m.price, 2.0);
      expect(m.priceDate, isA<DateTime>());
    });

    test('round-trips through toJson', () {
      final m = FuelPrice.fromJson(json);
      expect(FuelPrice.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different price', () {
      final a = FuelPrice.fromJson(json);
      final b = FuelPrice.fromJson({...json, 'price': 99.0});
      expect(a, isNot(equals(b)));
    });
  });

  group('CreatePriceRequest', () {
    const json = <String, Object?>{
      'consumption_type': 'diesel',
      'price': 2.0,
    };

    test('parses JSON correctly', () {
      final m = CreatePriceRequest.fromJson(json);
      expect(m.consumptionType, 'diesel');
      expect(m.price, 2.0);
    });

    test('round-trips through toJson', () {
      final m = CreatePriceRequest.fromJson(json);
      expect(CreatePriceRequest.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different price', () {
      const a = CreatePriceRequest(consumptionType: 'diesel', price: 2);
      const b = CreatePriceRequest(consumptionType: 'diesel', price: 3);
      expect(a, isNot(equals(b)));
    });
  });
}
