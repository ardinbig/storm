//
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

void main() {
  group('NfcCard', () {
    const fullJson = <String, Object?>{
      'id': 'c1',
      'card_id': 'CARD1',
      'status': 'active',
    };

    const minJson = <String, Object?>{'id': 'c1', 'card_id': 'CARD1'};

    test('parses all fields when present', () {
      final m = NfcCard.fromJson(fullJson);
      expect(m.id, 'c1');
      expect(m.cardId, 'CARD1');
      expect(m.status, 'active');
    });

    test('parses minimal JSON leaving status null', () {
      final m = NfcCard.fromJson(minJson);
      expect(m.status, isNull);
    });

    test('round-trips through toJson (full)', () {
      final m = NfcCard.fromJson(fullJson);
      expect(NfcCard.fromJson(m.toJson()), equals(m));
    });

    test('round-trips through toJson (minimal)', () {
      final m = NfcCard.fromJson(minJson);
      expect(NfcCard.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different cardId', () {
      final a = NfcCard.fromJson(fullJson);
      final b = NfcCard.fromJson({...fullJson, 'card_id': 'OTHER'});
      expect(a, isNot(equals(b)));
    });
  });

  group('BalanceCheckRequest', () {
    const json = <String, Object?>{'password': 'pin123'};

    test('parses JSON correctly', () {
      final m = BalanceCheckRequest.fromJson(json);
      expect(m.password, 'pin123');
    });

    test('round-trips through toJson', () {
      final m = BalanceCheckRequest.fromJson(json);
      expect(BalanceCheckRequest.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different passwords', () {
      const a = BalanceCheckRequest(password: 'a');
      const b = BalanceCheckRequest(password: 'b');
      expect(a, isNot(equals(b)));
    });
  });

  group('BalanceResponse', () {
    const fullJson = <String, Object?>{
      'nfc_ref': 'NFC1',
      'client_code': 'CLI1',
      'amount': 100.0,
      'network': 'NET1',
    };

    const minJson = <String, Object?>{
      'nfc_ref': 'NFC1',
      'client_code': 'CLI1',
      'amount': 100.0,
    };

    test('parses all fields when present', () {
      final m = BalanceResponse.fromJson(fullJson);
      expect(m.nfcRef, 'NFC1');
      expect(m.amount, 100.0);
      expect(m.network, 'NET1');
    });

    test('parses minimal JSON leaving network null', () {
      final m = BalanceResponse.fromJson(minJson);
      expect(m.network, isNull);
    });

    test('round-trips through toJson (full)', () {
      final m = BalanceResponse.fromJson(fullJson);
      expect(BalanceResponse.fromJson(m.toJson()), equals(m));
    });

    test('round-trips through toJson (minimal)', () {
      final m = BalanceResponse.fromJson(minJson);
      expect(BalanceResponse.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different amounts', () {
      final a = BalanceResponse.fromJson(fullJson);
      final b = BalanceResponse.fromJson({...fullJson, 'amount': 0.0});
      expect(a, isNot(equals(b)));
    });
  });

  group('CreateCardRequest', () {
    const json = <String, Object?>{'card_id': 'CARD1'};

    test('parses JSON correctly', () {
      final m = CreateCardRequest.fromJson(json);
      expect(m.cardId, 'CARD1');
    });

    test('round-trips through toJson', () {
      final m = CreateCardRequest.fromJson(json);
      expect(CreateCardRequest.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different cardId', () {
      const a = CreateCardRequest(cardId: 'CARD1');
      const b = CreateCardRequest(cardId: 'CARD2');
      expect(a, isNot(equals(b)));
    });
  });

  group('CardDetail', () {
    const fullJson = <String, Object?>{
      'id': 'cd1',
      'amount': 500.0,
      'nfc_ref': 'NFC1',
      'client_code': 'CLI1',
      'network': 'NET1',
    };

    const minJson = <String, Object?>{
      'id': 'cd1',
      'amount': 500.0,
      'nfc_ref': 'NFC1',
      'client_code': 'CLI1',
    };

    test('parses all fields when present', () {
      final m = CardDetail.fromJson(fullJson);
      expect(m.id, 'cd1');
      expect(m.amount, 500.0);
      expect(m.network, 'NET1');
    });

    test('parses minimal JSON leaving network null', () {
      final m = CardDetail.fromJson(minJson);
      expect(m.network, isNull);
    });

    test('round-trips through toJson (full)', () {
      final m = CardDetail.fromJson(fullJson);
      expect(CardDetail.fromJson(m.toJson()), equals(m));
    });

    test('round-trips through toJson (minimal)', () {
      final m = CardDetail.fromJson(minJson);
      expect(CardDetail.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different amounts', () {
      final a = CardDetail.fromJson(fullJson);
      final b = CardDetail.fromJson({...fullJson, 'amount': 0.0});
      expect(a, isNot(equals(b)));
    });
  });
}
