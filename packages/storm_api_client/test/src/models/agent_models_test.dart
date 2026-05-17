//
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

const _agentInfoFull = <String, Object?>{
  'id': 'a1',
  'agent_ref': 'AGT01',
  'currency_code': 'USD',
  'name': 'Alice',
  'balance': 250.0,
};

const _agentInfoMin = <String, Object?>{
  'id': 'a1',
  'agent_ref': 'AGT01',
  'currency_code': 'USD',
};

void main() {
  group('AgentInfo', () {
    test('parses all fields when present', () {
      final m = AgentInfo.fromJson(_agentInfoFull);
      expect(m.id, 'a1');
      expect(m.agentRef, 'AGT01');
      expect(m.name, 'Alice');
      expect(m.balance, 250.0);
    });

    test('parses minimal JSON leaving optional fields null', () {
      final m = AgentInfo.fromJson(_agentInfoMin);
      expect(m.name, isNull);
      expect(m.balance, isNull);
    });

    test('round-trips through toJson (full)', () {
      final m = AgentInfo.fromJson(_agentInfoFull);
      expect(AgentInfo.fromJson(m.toJson()), equals(m));
    });

    test('round-trips through toJson (minimal)', () {
      final m = AgentInfo.fromJson(_agentInfoMin);
      expect(AgentInfo.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different agentRef', () {
      final a = AgentInfo.fromJson(_agentInfoFull);
      final b = AgentInfo.fromJson({
        ..._agentInfoFull,
        'agent_ref': 'AGT99',
      });
      expect(a, isNot(equals(b)));
    });
  });

  group('AgentAuthResponse', () {
    const json = <String, Object?>{
      'token': 'tok',
      'agent': _agentInfoFull,
    };

    test('parses token and nested agent', () {
      final m = AgentAuthResponse.fromJson(json);
      expect(m.token, 'tok');
      expect(m.agent.agentRef, 'AGT01');
    });

    test('toJson contains token and agent object', () {
      final m = AgentAuthResponse.fromJson(json);
      final out = m.toJson();
      expect(out['token'], 'tok');
      expect(out['agent'], isNotNull);
    });

    test('equality fails for different tokens', () {
      final a = AgentAuthResponse.fromJson(json);
      final b = AgentAuthResponse.fromJson({...json, 'token': 'other'});
      expect(a, isNot(equals(b)));
    });
  });

  group('AgentHistoryRow', () {
    const fullJson = <String, Object?>{
      'id': 'h1',
      'amount': 50.0,
      'client': 'CLI1',
      'currency_code': 'USD',
      'date': '2024-06-01T10:00:00.000Z',
      'transaction_type': 'WITHDRAWAL',
    };
    const minJson = <String, Object?>{'id': 'h1'};

    test('parses all fields when present', () {
      final m = AgentHistoryRow.fromJson(fullJson);
      expect(m.id, 'h1');
      expect(m.amount, 50.0);
      expect(m.client, 'CLI1');
      expect(m.transactionType, 'WITHDRAWAL');
      expect(m.date, isNotNull);
    });

    test('parses minimal JSON leaving optional fields null', () {
      final m = AgentHistoryRow.fromJson(minJson);
      expect(m.amount, isNull);
      expect(m.client, isNull);
      expect(m.date, isNull);
    });

    test('round-trips through toJson (full)', () {
      final m = AgentHistoryRow.fromJson(fullJson);
      expect(AgentHistoryRow.fromJson(m.toJson()), equals(m));
    });

    test('round-trips through toJson (minimal)', () {
      final m = AgentHistoryRow.fromJson(minJson);
      expect(AgentHistoryRow.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different id', () {
      final a = AgentHistoryRow.fromJson(fullJson);
      final b = AgentHistoryRow.fromJson({...fullJson, 'id': 'h2'});
      expect(a, isNot(equals(b)));
    });
  });

  group('AgentLoginRequest', () {
    const json = <String, Object?>{'username': 'AGT01', 'password': 'pass'};

    test('parses JSON correctly', () {
      final m = AgentLoginRequest.fromJson(json);
      expect(m.username, 'AGT01');
      expect(m.password, 'pass');
    });

    test('round-trips through toJson', () {
      final m = AgentLoginRequest.fromJson(json);
      expect(AgentLoginRequest.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different passwords', () {
      const a = AgentLoginRequest(username: 'AGT01', password: 'a');
      const b = AgentLoginRequest(username: 'AGT01', password: 'b');
      expect(a, isNot(equals(b)));
    });
  });

  group('CreateAgentRequest', () {
    const fullJson = <String, Object?>{
      'agent_ref': 'AGT01',
      'password': 'pass',
      'name': 'Alice',
      'currency_code': 'USD',
    };
    const minJson = <String, Object?>{
      'agent_ref': 'AGT01',
      'password': 'pass',
    };

    test('parses all fields when present', () {
      final m = CreateAgentRequest.fromJson(fullJson);
      expect(m.name, 'Alice');
      expect(m.currencyCode, 'USD');
    });

    test('parses minimal JSON leaving optional fields null', () {
      final m = CreateAgentRequest.fromJson(minJson);
      expect(m.name, isNull);
      expect(m.currencyCode, isNull);
    });

    test('round-trips through toJson (full)', () {
      final m = CreateAgentRequest.fromJson(fullJson);
      expect(CreateAgentRequest.fromJson(m.toJson()), equals(m));
    });

    test('round-trips through toJson (minimal)', () {
      final m = CreateAgentRequest.fromJson(minJson);
      expect(CreateAgentRequest.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different agentRef', () {
      final a = CreateAgentRequest.fromJson(fullJson);
      final b = CreateAgentRequest.fromJson({
        ...fullJson,
        'agent_ref': 'X',
      });
      expect(a, isNot(equals(b)));
    });
  });

  group('UpdateAgentRequest', () {
    test('toJson omits null fields (includeIfNull: false)', () {
      const m = UpdateAgentRequest(name: 'Alice');
      final json = m.toJson();
      expect(json.containsKey('currency_code'), isFalse);
      expect(json['name'], 'Alice');
    });

    test('parses populated JSON correctly', () {
      final m = UpdateAgentRequest.fromJson(
        const {'name': 'Alice', 'currency_code': 'EUR', 'station_id': 's1'},
      );
      expect(m.name, 'Alice');
      expect(m.currencyCode, 'EUR');
      expect(m.stationId, 's1');
    });

    test('parses empty JSON leaving all fields null', () {
      final m = UpdateAgentRequest.fromJson({});
      expect(m.name, isNull);
      expect(m.currencyCode, isNull);
      expect(m.stationId, isNull);
    });

    test('round-trips through toJson when fields are set', () {
      const m = UpdateAgentRequest(name: 'Alice', currencyCode: 'USD');
      expect(UpdateAgentRequest.fromJson(m.toJson()), equals(m));
    });

    test('equality fails when name differs', () {
      const a = UpdateAgentRequest(name: 'Alice');
      const b = UpdateAgentRequest(name: 'Bob');
      expect(a, isNot(equals(b)));
    });
  });

  group('UpdateAgentPasswordRequest', () {
    const json = <String, Object?>{
      'agent_ref': 'AGT01',
      'last_password': 'old',
      'new_password': 'new',
    };

    test('parses JSON correctly', () {
      final m = UpdateAgentPasswordRequest.fromJson(json);
      expect(m.agentRef, 'AGT01');
      expect(m.lastPassword, 'old');
      expect(m.newPassword, 'new');
    });

    test('round-trips through toJson', () {
      final m = UpdateAgentPasswordRequest.fromJson(json);
      expect(UpdateAgentPasswordRequest.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different newPassword', () {
      final a = UpdateAgentPasswordRequest.fromJson(json);
      final b = UpdateAgentPasswordRequest.fromJson({
        ...json,
        'new_password': 'x',
      });
      expect(a, isNot(equals(b)));
    });
  });

  group('AgentRegisterCustomerRequest', () {
    const fullJson = <String, Object?>{
      'first_name': 'John',
      'last_name': 'Doe',
      'phone': '0600000001',
      'card_ref': 'CARD1',
      'middle_name': 'M',
      'gender': 'M',
      'marital_status': 'single',
      'address': '1 St',
      'affiliation': 'Org',
    };
    const minJson = <String, Object?>{
      'first_name': 'John',
      'last_name': 'Doe',
      'phone': '0600000001',
      'card_ref': 'CARD1',
    };

    test('parses all fields when present', () {
      final m = AgentRegisterCustomerRequest.fromJson(fullJson);
      expect(m.middleName, 'M');
      expect(m.affiliation, 'Org');
    });

    test('parses minimal JSON leaving optional fields null', () {
      final m = AgentRegisterCustomerRequest.fromJson(minJson);
      expect(m.middleName, isNull);
      expect(m.gender, isNull);
    });

    test('round-trips through toJson (full)', () {
      final m = AgentRegisterCustomerRequest.fromJson(fullJson);
      expect(AgentRegisterCustomerRequest.fromJson(m.toJson()), equals(m));
    });

    test('round-trips through toJson (minimal)', () {
      final m = AgentRegisterCustomerRequest.fromJson(minJson);
      expect(AgentRegisterCustomerRequest.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different cardRef', () {
      final a = AgentRegisterCustomerRequest.fromJson(fullJson);
      final b = AgentRegisterCustomerRequest.fromJson({
        ...fullJson,
        'card_ref': 'X',
      });
      expect(a, isNot(equals(b)));
    });
  });
}
