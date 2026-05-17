//
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

void main() {
  group('AuthResponse', () {
    const fullJson = <String, Object?>{
      'token': 'jwt-tok',
      'user': <String, Object?>{
        'id': 'u1',
        'name': 'Test',
        'username': 'test',
        'email': 'a@b.com',
        'role': 'admin',
      },
    };

    test('parses all fields', () {
      final m = AuthResponse.fromJson(fullJson);
      expect(m.token, 'jwt-tok');
      expect(m.user.id, 'u1');
      expect(m.user.email, 'a@b.com');
    });

    test('toJson contains token and nested user object', () {
      final m = AuthResponse.fromJson(fullJson);
      final out = m.toJson();
      expect(out['token'], 'jwt-tok');
      expect(out['user'], isNotNull);
    });

    test('two instances with same data are equal', () {
      expect(
        AuthResponse.fromJson(fullJson),
        equals(AuthResponse.fromJson(fullJson)),
      );
    });

    test('two instances with different tokens are not equal', () {
      final a = AuthResponse.fromJson(fullJson);
      final b = AuthResponse.fromJson({...fullJson, 'token': 'other'});
      expect(a, isNot(equals(b)));
    });
  });

  group('UserInfo', () {
    const fullJson = <String, Object?>{
      'id': 'u1',
      'name': 'Test',
      'username': 'test',
      'email': 'a@b.com',
      'role': 'admin',
    };
    const minJson = <String, Object?>{
      'id': 'u1',
      'name': 'Test',
      'username': 'test',
    };

    test('parses all fields when present', () {
      final m = UserInfo.fromJson(fullJson);
      expect(m.id, 'u1');
      expect(m.email, 'a@b.com');
      expect(m.role, 'admin');
    });

    test('parses minimal JSON leaving optional fields null', () {
      final m = UserInfo.fromJson(minJson);
      expect(m.email, isNull);
      expect(m.role, isNull);
    });

    test('round-trips through toJson (full)', () {
      final m = UserInfo.fromJson(fullJson);
      expect(UserInfo.fromJson(m.toJson()), equals(m));
    });

    test('round-trips through toJson (minimal)', () {
      final m = UserInfo.fromJson(minJson);
      expect(UserInfo.fromJson(m.toJson()), equals(m));
    });

    test('equality holds for same data', () {
      expect(UserInfo.fromJson(fullJson), equals(UserInfo.fromJson(fullJson)));
    });

    test('equality fails for different usernames', () {
      final a = UserInfo.fromJson(fullJson);
      final b = UserInfo.fromJson({...fullJson, 'username': 'other'});
      expect(a, isNot(equals(b)));
    });
  });

  group('LoginRequest', () {
    const json = <String, Object?>{'username': 'user', 'password': 'pass'};

    test('parses JSON correctly', () {
      final m = LoginRequest.fromJson(json);
      expect(m.username, 'user');
      expect(m.password, 'pass');
    });

    test('round-trips through toJson', () {
      final m = LoginRequest.fromJson(json);
      expect(LoginRequest.fromJson(m.toJson()), equals(m));
    });

    test('equality holds for same data', () {
      expect(LoginRequest.fromJson(json), equals(LoginRequest.fromJson(json)));
    });

    test('equality fails for different passwords', () {
      const a = LoginRequest(username: 'u', password: 'a');
      const b = LoginRequest(username: 'u', password: 'b');
      expect(a, isNot(equals(b)));
    });
  });

  group('RegisterRequest', () {
    const fullJson = <String, Object?>{
      'name': 'Test',
      'username': 'test',
      'password': 'pass',
      'email': 'a@b.com',
    };

    const minJson = <String, Object?>{
      'name': 'Test',
      'username': 'test',
      'password': 'pass',
    };

    test('parses all fields when present', () {
      final m = RegisterRequest.fromJson(fullJson);
      expect(m.email, 'a@b.com');
    });

    test('parses minimal JSON leaving email null', () {
      final m = RegisterRequest.fromJson(minJson);
      expect(m.email, isNull);
    });

    test('round-trips through toJson (full)', () {
      final m = RegisterRequest.fromJson(fullJson);
      expect(RegisterRequest.fromJson(m.toJson()), equals(m));
    });

    test('round-trips through toJson (minimal)', () {
      final m = RegisterRequest.fromJson(minJson);
      expect(RegisterRequest.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different names', () {
      final a = RegisterRequest.fromJson(fullJson);
      final b = RegisterRequest.fromJson({...fullJson, 'name': 'Other'});
      expect(a, isNot(equals(b)));
    });
  });

  group('MeResponse', () {
    const fullJson = <String, Object?>{
      'id': 'u1',
      'role': 'user',
      'username': 'test',
      'name': 'Test',
    };

    const minJson = <String, Object?>{'id': 'u1', 'role': 'agent'};

    test('parses all fields when present', () {
      final m = MeResponse.fromJson(fullJson);
      expect(m.id, 'u1');
      expect(m.username, 'test');
      expect(m.name, 'Test');
    });

    test('parses minimal JSON leaving optional fields null', () {
      final m = MeResponse.fromJson(minJson);
      expect(m.username, isNull);
      expect(m.name, isNull);
    });

    test('round-trips through toJson (full)', () {
      final m = MeResponse.fromJson(fullJson);
      expect(MeResponse.fromJson(m.toJson()), equals(m));
    });

    test('round-trips through toJson (minimal)', () {
      final m = MeResponse.fromJson(minJson);
      expect(MeResponse.fromJson(m.toJson()), equals(m));
    });

    test('equality fails when role differs', () {
      final a = MeResponse.fromJson(fullJson);
      final b = MeResponse.fromJson({...fullJson, 'role': 'admin'});
      expect(a, isNot(equals(b)));
    });
  });
}
