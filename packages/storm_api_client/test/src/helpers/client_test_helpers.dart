import 'package:fresh_dio/fresh_dio.dart';
import 'package:mocktail/mocktail.dart';

class MockTokenStorage extends Mock implements TokenStorage<OAuth2Token> {}

class LocalTokenStorage implements TokenStorage<OAuth2Token> {
  OAuth2Token? _token;

  @override
  Future<void> delete() async {
    _token = null;
  }

  @override
  Future<OAuth2Token?> read() async => _token;

  @override
  Future<void> write(OAuth2Token token) async {
    _token = token;
  }
}
