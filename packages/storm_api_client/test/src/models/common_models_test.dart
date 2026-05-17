//
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

void main() {
  group('ErrorResponse', () {
    const json = <String, Object?>{'error': 'Not Found', 'code': 404};

    test('parses JSON correctly', () {
      final m = ErrorResponse.fromJson(json);
      expect(m.error, 'Not Found');
      expect(m.code, 404);
    });

    test('round-trips through toJson', () {
      final m = ErrorResponse.fromJson(json);
      expect(ErrorResponse.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different code', () {
      const a = ErrorResponse(error: 'err', code: 404);
      const b = ErrorResponse(error: 'err', code: 500);
      expect(a, isNot(equals(b)));
    });
  });

  group('MetricsResponse', () {
    const json = <String, Object?>{'requests': 42};

    test('parses JSON correctly', () {
      final m = MetricsResponse.fromJson(json);
      expect(m.requests, 42);
    });

    test('round-trips through toJson', () {
      final m = MetricsResponse.fromJson(json);
      expect(MetricsResponse.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different request count', () {
      const a = MetricsResponse(requests: 1);
      const b = MetricsResponse(requests: 2);
      expect(a, isNot(equals(b)));
    });
  });

  group('Category', () {
    const json = <String, Object?>{
      'id': 'cat1',
      'name': 'Gold',
      'created_at': '2024-01-01T00:00:00.000Z',
    };

    test('parses all fields correctly', () {
      final m = Category.fromJson(json);
      expect(m.id, 'cat1');
      expect(m.name, 'Gold');
      expect(m.createdAt, isA<DateTime>());
    });

    test('round-trips through toJson', () {
      final m = Category.fromJson(json);
      expect(Category.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different name', () {
      final a = Category.fromJson(json);
      final b = Category.fromJson({...json, 'name': 'Silver'});
      expect(a, isNot(equals(b)));
    });
  });

  group('CreateCategoryRequest', () {
    const json = <String, Object?>{'name': 'Gold'};

    test('parses JSON correctly', () {
      final m = CreateCategoryRequest.fromJson(json);
      expect(m.name, 'Gold');
    });

    test('round-trips through toJson', () {
      final m = CreateCategoryRequest.fromJson(json);
      expect(CreateCategoryRequest.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different name', () {
      const a = CreateCategoryRequest(name: 'Gold');
      const b = CreateCategoryRequest(name: 'Silver');
      expect(a, isNot(equals(b)));
    });
  });

  group('ActivityItem', () {
    const fullJson = <String, Object?>{
      'kind': 'WITHDRAWAL',
      'agent_ref': 'AGT01',
      'amount': 100.0,
      'client_ref': 'CLI1',
      'date': '2024-06-01T10:00:00.000Z',
      'station_id': 'ST01',
    };

    const minJson = <String, Object?>{'kind': 'CONSUMPTION'};

    test('parses all fields when present', () {
      final m = ActivityItem.fromJson(fullJson);
      expect(m.kind, 'WITHDRAWAL');
      expect(m.agentRef, 'AGT01');
      expect(m.amount, 100.0);
      expect(m.date, isNotNull);
    });

    test('parses minimal JSON leaving optional fields null', () {
      final m = ActivityItem.fromJson(minJson);
      expect(m.kind, 'CONSUMPTION');
      expect(m.agentRef, isNull);
      expect(m.amount, isNull);
      expect(m.date, isNull);
    });

    test('round-trips through toJson (full)', () {
      final m = ActivityItem.fromJson(fullJson);
      expect(ActivityItem.fromJson(m.toJson()), equals(m));
    });

    test('round-trips through toJson (minimal)', () {
      final m = ActivityItem.fromJson(minJson);
      expect(ActivityItem.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different kind', () {
      final a = ActivityItem.fromJson(fullJson);
      final b = ActivityItem.fromJson({
        ...fullJson,
        'kind': 'CONSUMPTION',
      });
      expect(a, isNot(equals(b)));
    });
  });

  group('PaginatedActivityResponse', () {
    const itemJson = <String, Object?>{'kind': 'WITHDRAWAL'};

    final fullJson = <String, Object?>{
      'data': <Object?>[itemJson],
      'page': 1,
      'page_size': 10,
      'total_items': 1,
      'total_pages': 1,
      'has_next_page': false,
      'has_prev_page': false,
      'remaining_items': 0,
    };

    final emptyJson = <String, Object?>{
      'data': <Object?>[],
      'page': 1,
      'page_size': 10,
      'total_items': 0,
      'total_pages': 1,
      'has_next_page': false,
      'has_prev_page': false,
      'remaining_items': 0,
    };

    test('parses response with items correctly', () {
      final m = PaginatedActivityResponse.fromJson(fullJson);
      expect(m.data, hasLength(1));
      expect(m.data.first.kind, 'WITHDRAWAL');
      expect(m.totalItems, 1);
    });

    test('parses empty data list correctly', () {
      final m = PaginatedActivityResponse.fromJson(emptyJson);
      expect(m.data, isEmpty);
      expect(m.hasNextPage, isFalse);
    });

    test('toJson contains pagination metadata', () {
      final m = PaginatedActivityResponse.fromJson(fullJson);
      final out = m.toJson();
      expect(out['page'], 1);
      expect(out['total_items'], 1);
    });

    test('round-trips through toJson (empty)', () {
      final m = PaginatedActivityResponse.fromJson(emptyJson);
      expect(PaginatedActivityResponse.fromJson(m.toJson()), equals(m));
    });

    test('equality fails for different page', () {
      final a = PaginatedActivityResponse.fromJson(emptyJson);
      final b = PaginatedActivityResponse.fromJson({...emptyJson, 'page': 2});
      expect(a, isNot(equals(b)));
    });
  });
}
