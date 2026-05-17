//
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

void main() {
  group('Commission', () {
    const json = <String, Object?>{
      'id': 'com1',
      'percentage': 5.0,
      'created_at': '2024-01-01T00:00:00.000Z',
    };

    test('parses all fields correctly', () {
      final m = Commission.fromJson(json);
      expect(m.id, 'com1');
      expect(m.percentage, 5.0);
      expect(m.createdAt, isA<DateTime>());
    });

    test('round-trips through toJson', () {
      final m = Commission.fromJson(json);
      expect(Commission.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different percentage', () {
      final a = Commission.fromJson(json);
      final b = Commission.fromJson({...json, 'percentage': 10.0});
      expect(a, isNot(equals(b)));
    });
  });

  group('CommissionTier', () {
    const fullJson = <String, Object?>{
      'id': 'tier1',
      'level1': 0.1,
      'level2': 0.2,
      'created_at': '2024-01-01T00:00:00.000Z',
      'category': 'gold',
    };

    const minJson = <String, Object?>{
      'id': 'tier1',
      'level1': 0.1,
      'level2': 0.2,
      'created_at': '2024-01-01T00:00:00.000Z',
    };

    test('parses all fields when present', () {
      final m = CommissionTier.fromJson(fullJson);
      expect(m.level1, 0.1);
      expect(m.category, 'gold');
    });

    test('parses minimal JSON leaving category null', () {
      final m = CommissionTier.fromJson(minJson);
      expect(m.category, isNull);
    });

    test('round-trips through toJson (full)', () {
      final m = CommissionTier.fromJson(fullJson);
      expect(CommissionTier.fromJson(m.toJson()), equals(m));
    });

    test('round-trips through toJson (minimal)', () {
      final m = CommissionTier.fromJson(minJson);
      expect(CommissionTier.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different level2', () {
      final a = CommissionTier.fromJson(fullJson);
      final b = CommissionTier.fromJson({...fullJson, 'level2': 0.9});
      expect(a, isNot(equals(b)));
    });
  });

  group('CreateCommissionRequest', () {
    const json = <String, Object?>{'percentage': 7.5};

    test('parses JSON correctly', () {
      final m = CreateCommissionRequest.fromJson(json);
      expect(m.percentage, 7.5);
    });

    test('round-trips through toJson', () {
      final m = CreateCommissionRequest.fromJson(json);
      expect(CreateCommissionRequest.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different percentage', () {
      const a = CreateCommissionRequest(percentage: 5);
      const b = CreateCommissionRequest(percentage: 10);
      expect(a, isNot(equals(b)));
    });
  });

  group('CreateCommissionTierRequest', () {
    const fullJson = <String, Object?>{
      'level1': 0.1,
      'level2': 0.2,
      'category': 'gold',
    };
    const minJson = <String, Object?>{'level1': 0.1, 'level2': 0.2};

    test('parses all fields when present', () {
      final m = CreateCommissionTierRequest.fromJson(fullJson);
      expect(m.level1, 0.1);
      expect(m.category, 'gold');
    });

    test('parses minimal JSON leaving category null', () {
      final m = CreateCommissionTierRequest.fromJson(minJson);
      expect(m.category, isNull);
    });

    test('round-trips through toJson (full)', () {
      final m = CreateCommissionTierRequest.fromJson(fullJson);
      expect(CreateCommissionTierRequest.fromJson(m.toJson()), equals(m));
    });

    test('round-trips through toJson (minimal)', () {
      final m = CreateCommissionTierRequest.fromJson(minJson);
      expect(CreateCommissionTierRequest.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different level1', () {
      final a = CreateCommissionTierRequest.fromJson(fullJson);
      final b = CreateCommissionTierRequest.fromJson({
        ...fullJson,
        'level1': 0.5,
      });
      expect(a, isNot(equals(b)));
    });
  });
}
