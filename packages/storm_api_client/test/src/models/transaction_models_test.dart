//
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

void main() {
  group('Transaction', () {
    const fullJson = <String, Object?>{
      'id': 't1',
      'agent_account': 'AGT01',
      'client_account': 'CLI1',
      'amount': 100.0,
      'commission': 5.0,
      'currency_code': 'USD',
      'transaction_type': 'WITHDRAWAL',
      'date': '2024-06-01T10:00:00.000Z',
    };

    const minJson = <String, Object?>{'id': 't1'};

    test('parses all fields when present', () {
      final m = Transaction.fromJson(fullJson);
      expect(m.id, 't1');
      expect(m.amount, 100.0);
      expect(m.transactionType, 'WITHDRAWAL');
      expect(m.date, isNotNull);
    });

    test('parses minimal JSON leaving optional fields null', () {
      final m = Transaction.fromJson(minJson);
      expect(m.agentAccount, isNull);
      expect(m.amount, isNull);
      expect(m.date, isNull);
    });

    test('round-trips through toJson (full)', () {
      final m = Transaction.fromJson(fullJson);
      expect(Transaction.fromJson(m.toJson()), equals(m));
    });

    test('round-trips through toJson (minimal)', () {
      final m = Transaction.fromJson(minJson);
      expect(Transaction.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different id', () {
      final a = Transaction.fromJson(fullJson);
      final b = Transaction.fromJson({...fullJson, 'id': 't2'});
      expect(a, isNot(equals(b)));
    });
  });

  group('WithdrawalRequest', () {
    const json = <String, Object?>{
      'client_code': 'CLI1',
      'withdrawal_amount': 50.0,
      'client_password': 'pin',
      'agent_code': 'AGT01',
      'currency_type': 'USD',
    };

    test('parses all fields correctly', () {
      final m = WithdrawalRequest.fromJson(json);
      expect(m.clientCode, 'CLI1');
      expect(m.withdrawalAmount, 50.0);
      expect(m.currencyType, 'USD');
    });

    test('round-trips through toJson', () {
      final m = WithdrawalRequest.fromJson(json);
      expect(WithdrawalRequest.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different amounts', () {
      final a = WithdrawalRequest.fromJson(json);
      final b = WithdrawalRequest.fromJson({
        ...json,
        'withdrawal_amount': 1.0,
      });
      expect(a, isNot(equals(b)));
    });
  });

  group('WithdrawalResponse', () {
    const json = <String, Object?>{
      'message': 'OK',
      'client_balance': 90.0,
      'agent_balance': 10.0,
    };

    test('parses all fields correctly', () {
      final m = WithdrawalResponse.fromJson(json);
      expect(m.message, 'OK');
      expect(m.clientBalance, 90.0);
      expect(m.agentBalance, 10.0);
    });

    test('round-trips through toJson', () {
      final m = WithdrawalResponse.fromJson(json);
      expect(WithdrawalResponse.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different clientBalance', () {
      final a = WithdrawalResponse.fromJson(json);
      final b = WithdrawalResponse.fromJson({
        ...json,
        'client_balance': 0.0,
      });
      expect(a, isNot(equals(b)));
    });
  });
}
