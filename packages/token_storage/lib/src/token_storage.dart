import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fresh/fresh.dart';

/// Persists [OAuth2Token] in encrypted device storage.
///
/// Tokens older than [maxAge] are treated as expired and deleted
/// automatically on the next [read].
class SecureTokenStorage implements TokenStorage<OAuth2Token> {
  SecureTokenStorage({
    FlutterSecureStorage? storage,
    this.maxAge = const Duration(days: 3),
  }) : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'storm_oauth2_token';
  static const _timestampKey = 'storm_token_timestamp';

  final FlutterSecureStorage _storage;

  /// Maximum session duration before the token is considered expired.
  final Duration maxAge;

  @override
  Future<OAuth2Token?> read() async {
    final raw = await _storage.read(key: _tokenKey);
    final ts = await _storage.read(key: _timestampKey);
    if (raw == null || ts == null) return null;

    final storedAt = DateTime.tryParse(ts);
    if (storedAt == null) return null;

    // Enforce max session duration.
    if (DateTime.now().difference(storedAt) > maxAge) {
      await delete();
      return null;
    }

    final json = jsonDecode(raw) as Map<String, Object?>;
    return OAuth2Token(
      accessToken: json['access_token']! as String,
    );
  }

  @override
  Future<void> write(OAuth2Token token) async {
    final json = jsonEncode({'access_token': token.accessToken});
    await _storage.write(key: _tokenKey, value: json);
    await _storage.write(
      key: _timestampKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<void> delete() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _timestampKey);
  }
}
