import 'package:flutter_test/flutter_test.dart';
import 'package:offline_storage/offline_storage.dart';

void main() {
  group('PendingOperation', () {
    final createdAt = DateTime.utc(2026, 4, 7);

    final operation = PendingOperation(
      endpoint: '/api/v1/consumptions',
      method: 'POST',
      body: '{"foo":"bar"}',
      createdAt: createdAt,
    );

    group('constructor', () {
      test('defaults status to 0 for offline queue items', () {
        expect(operation.status, 0);
        expect(operation.id, isNull);
      });

      test('accepts an explicit status and id', () {
        final op = PendingOperation(
          id: 5,
          endpoint: '/api/v1/x',
          method: 'PUT',
          body: '{}',
          createdAt: createdAt,
          status: 1,
        );

        expect(op.id, 5);
        expect(op.status, 1);
      });
    });

    group('toMap', () {
      test('omits id key when id is null', () {
        final map = operation.toMap();

        expect(map.containsKey('id'), isFalse);
      });

      test('includes id key when id is set', () {
        final map = operation.copyWith(id: 3).toMap();

        expect(map['id'], 3);
      });

      test('serializes all required fields correctly', () {
        final map = operation.toMap();

        expect(map['endpoint'], operation.endpoint);
        expect(map['method'], operation.method);
        expect(map['body'], operation.body);
        expect(map['created_at'], createdAt.toIso8601String());
        expect(map['status'], 0);
      });
    });

    group('fromMap', () {
      test('reads status and keeps row id', () {
        final op = PendingOperation.fromMap({
          'id': 7,
          'endpoint': '/api/v1/agents/customers',
          'method': 'POST',
          'body': '{"first_name":"John"}',
          'created_at': '2026-04-07T10:00:00.000Z',
          'status': 0,
        });

        expect(op.id, 7);
        expect(op.status, 0);
        expect(op.endpoint, '/api/v1/agents/customers');
      });

      test('defaults status to 0 when status key is absent', () {
        final op = PendingOperation.fromMap({
          'id': 1,
          'endpoint': '/api/v1/x',
          'method': 'POST',
          'body': '{}',
          'created_at': '2026-04-07T10:00:00.000Z',
        });

        expect(op.status, 0);
      });

      test('round-trips through toMap without data loss', () {
        final original = PendingOperation(
          id: 9,
          endpoint: '/api/v1/consumptions',
          method: 'DELETE',
          body: '{"id":42}',
          createdAt: createdAt,
          status: 1,
        );

        final restored = PendingOperation.fromMap(original.toMap());

        expect(restored.id, original.id);
        expect(restored.endpoint, original.endpoint);
        expect(restored.method, original.method);
        expect(restored.body, original.body);
        expect(restored.createdAt, original.createdAt);
        expect(restored.status, original.status);
      });
    });

    group('copyWith', () {
      test('replaces only the specified field and preserves all others', () {
        final copy = operation.copyWith(endpoint: '/api/v1/other');

        expect(copy.endpoint, '/api/v1/other');
        expect(copy.method, operation.method);
        expect(copy.body, operation.body);
        expect(copy.createdAt, operation.createdAt);
        expect(copy.status, operation.status);
        expect(copy.id, operation.id);
      });

      test('can update every field at once', () {
        final newDate = DateTime.utc(2026, 6);
        final copy = operation.copyWith(
          id: 99,
          endpoint: '/new',
          method: 'PUT',
          body: '{"x":1}',
          createdAt: newDate,
          status: 1,
        );

        expect(copy.id, 99);
        expect(copy.endpoint, '/new');
        expect(copy.method, 'PUT');
        expect(copy.body, '{"x":1}');
        expect(copy.createdAt, newDate);
        expect(copy.status, 1);
      });

      test('with no arguments returns an equal but distinct instance', () {
        final copy = operation.copyWith();

        expect(copy.endpoint, operation.endpoint);
        expect(copy.method, operation.method);
        expect(copy.body, operation.body);
        expect(copy.createdAt, operation.createdAt);
        expect(copy.status, operation.status);
        expect(copy.id, operation.id);
        expect(identical(copy, operation), isFalse);
      });
    });
  });
}
