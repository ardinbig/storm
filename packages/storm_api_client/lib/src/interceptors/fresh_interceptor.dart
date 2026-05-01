import 'package:fresh_dio/fresh_dio.dart';

/// Fresh never refreshes tokens.
bool stormShouldRefreshNever(dynamic _) => false;

/// Creates a [Fresh] Dio interceptor configured for the Storm API.
///
/// The Storm server issues simple JWTs (no refresh tokens), so
/// `refreshToken` always throws [RevokeTokenException].
Fresh<OAuth2Token> buildFreshInterceptor({
  required TokenStorage<OAuth2Token> tokenStorage,
}) {
  return Fresh<OAuth2Token>(
    tokenStorage: tokenStorage,
    refreshToken: (_, _) => throw RevokeTokenException(),
    shouldRefresh: stormShouldRefreshNever,
    tokenHeader: (token) => {
      'Authorization': 'Bearer ${token.accessToken}',
    },
  );
}
