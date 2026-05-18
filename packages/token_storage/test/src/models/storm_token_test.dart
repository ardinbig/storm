import 'package:flutter_test/flutter_test.dart';
import 'package:token_storage/token_storage.dart';

void main() {
  group('StormToken', () {
    test('constructs with required accessToken only', () {
      const t = StormToken(accessToken: 'tok');

      expect(t.accessToken, 'tok');
      expect(t.refreshToken, isNull);
      expect(t.expiresAt, isNull);
    });

    test('constructs with all optional fields', () {
      final expiry = DateTime.utc(2026, 12, 31);
      final t = StormToken(
        accessToken: 'tok',
        refreshToken: 'ref',
        expiresAt: expiry,
      );

      expect(t.refreshToken, 'ref');
      expect(t.expiresAt, expiry);
    });

    test('fromJson parses all fields when present', () {
      final expiry = DateTime.utc(2026, 12, 31);
      final t = StormToken.fromJson({
        'access_token': 'tok',
        'refresh_token': 'ref',
        'expires_at': expiry.toIso8601String(),
      });

      expect(t.accessToken, 'tok');
      expect(t.refreshToken, 'ref');
      expect(t.expiresAt, expiry);
    });

    test('fromJson sets optional fields to null when absent', () {
      final t = StormToken.fromJson({'access_token': 'tok'});

      expect(t.refreshToken, isNull);
      expect(t.expiresAt, isNull);
    });

    test('toJson includes all fields when set', () {
      final expiry = DateTime.utc(2026, 12, 31);
      final t = StormToken(
        accessToken: 'tok',
        refreshToken: 'ref',
        expiresAt: expiry,
      );

      final json = t.toJson();

      expect(json['access_token'], 'tok');
      expect(json['refresh_token'], 'ref');
      expect(json['expires_at'], expiry.toIso8601String());
    });

    test('toJson omits refresh_token and expires_at when null', () {
      const t = StormToken(accessToken: 'tok');

      final json = t.toJson();

      expect(json.containsKey('refresh_token'), isFalse);
      expect(json.containsKey('expires_at'), isFalse);
    });

    test('round trips through fromJson and toJson without data loss', () {
      final expiry = DateTime.utc(2026, 6, 15, 12);
      final original = StormToken(
        accessToken: 'a',
        refreshToken: 'r',
        expiresAt: expiry,
      );

      final restored = StormToken.fromJson(original.toJson());

      expect(restored.accessToken, original.accessToken);
      expect(restored.refreshToken, original.refreshToken);
      expect(restored.expiresAt, original.expiresAt);
    });
  });
}
