//
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

void main() {
  group('Customer', () {
    const fullJson = <String, Object?>{
      'id': 'cu1',
      'status': 1,
      'card_id': 'CARD1',
      'first_name': 'John',
      'last_name': 'Doe',
      'middle_name': 'M',
      'phone': '0600000001',
      'gender': 'M',
      'marital_status': 'single',
      'address': '1 St',
      'affiliation': 'Org',
      'client_code': 'CLI1',
      'category_ref': 'cat1',
      'networks': 'NET1',
    };

    const minJson = <String, Object?>{
      'id': 'cu1',
      'status': 1,
      'card_id': 'CARD1',
    };

    test('parses all fields when present', () {
      final m = Customer.fromJson(fullJson);
      expect(m.id, 'cu1');
      expect(m.firstName, 'John');
      expect(m.clientCode, 'CLI1');
    });

    test('parses minimal JSON leaving optional fields null', () {
      final m = Customer.fromJson(minJson);
      expect(m.firstName, isNull);
      expect(m.clientCode, isNull);
    });

    test('round-trips through toJson (full)', () {
      final m = Customer.fromJson(fullJson);
      expect(Customer.fromJson(m.toJson()), equals(m));
    });

    test('round-trips through toJson (minimal)', () {
      final m = Customer.fromJson(minJson);
      expect(Customer.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different status', () {
      final a = Customer.fromJson(fullJson);
      final b = Customer.fromJson({...fullJson, 'status': 0});
      expect(a, isNot(equals(b)));
    });
  });

  group('CustomerByCardResponse', () {
    const json = <String, Object?>{'client_code': 'CLI1'};

    test('parses JSON correctly', () {
      final m = CustomerByCardResponse.fromJson(json);
      expect(m.clientCode, 'CLI1');
    });

    test('round-trips through toJson', () {
      final m = CustomerByCardResponse.fromJson(json);
      expect(CustomerByCardResponse.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different clientCode', () {
      const a = CustomerByCardResponse(clientCode: 'CLI1');
      const b = CustomerByCardResponse(clientCode: 'CLI2');
      expect(a, isNot(equals(b)));
    });
  });

  group('RegisterCustomerRequest', () {
    const fullJson = <String, Object?>{
      'card_id': 'CARD1',
      'first_name': 'John',
      'last_name': 'Doe',
      'phone': '0600000001',
      'middle_name': 'M',
      'gender': 'M',
      'marital_status': 'single',
      'address': '1 St',
      'affiliation': 'Org',
      'client_code': 'CLI1',
      'category_ref': 'cat1',
      'networks': 'NET1',
    };

    const minJson = <String, Object?>{
      'card_id': 'CARD1',
      'first_name': 'John',
      'last_name': 'Doe',
      'phone': '0600000001',
    };

    test('parses all fields when present', () {
      final m = RegisterCustomerRequest.fromJson(fullJson);
      expect(m.middleName, 'M');
      expect(m.clientCode, 'CLI1');
    });

    test('parses minimal JSON leaving optional fields null', () {
      final m = RegisterCustomerRequest.fromJson(minJson);
      expect(m.middleName, isNull);
      expect(m.networks, isNull);
    });

    test('round-trips through toJson (full)', () {
      final m = RegisterCustomerRequest.fromJson(fullJson);
      expect(RegisterCustomerRequest.fromJson(m.toJson()), equals(m));
    });

    test('round-trips through toJson (minimal)', () {
      final m = RegisterCustomerRequest.fromJson(minJson);
      expect(RegisterCustomerRequest.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different cardId', () {
      final a = RegisterCustomerRequest.fromJson(fullJson);
      final b = RegisterCustomerRequest.fromJson({
        ...fullJson,
        'card_id': 'X',
      });
      expect(a, isNot(equals(b)));
    });
  });

  group('UpdateCustomerRequest', () {
    test('parses populated JSON correctly', () {
      final m = UpdateCustomerRequest.fromJson(
        const {'first_name': 'Jane', 'phone': '0600000002'},
      );
      expect(m.firstName, 'Jane');
      expect(m.phone, '0600000002');
    });

    test('parses empty JSON leaving all fields null', () {
      final m = UpdateCustomerRequest.fromJson({});
      expect(m.firstName, isNull);
      expect(m.cardId, isNull);
    });

    test('round-trips through toJson when fields are set', () {
      const m = UpdateCustomerRequest(firstName: 'Jane', phone: '0600000002');
      expect(UpdateCustomerRequest.fromJson(m.toJson()), equals(m));
    });

    test('round-trips through toJson when all fields are null', () {
      const m = UpdateCustomerRequest();
      expect(UpdateCustomerRequest.fromJson(m.toJson()), equals(m));
    });

    test('equality fails when firstName differs', () {
      const a = UpdateCustomerRequest(firstName: 'Jane');
      const b = UpdateCustomerRequest(firstName: 'John');
      expect(a, isNot(equals(b)));
    });
  });
}
