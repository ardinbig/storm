import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:storm_api_client/storm_api_client.dart';

/// {@template authentication_repository}
/// Repository that manages authentication state and communicates with the
/// [StormApiClient] on behalf of the business-logic layer.
///
/// Token persistence is handled via `SecureTokenStorage` and the
/// [Fresh] interceptor, tokens survive app restarts for up to 3 days.
/// {@endtemplate}
class AuthenticationRepository {
  /// {@macro authentication_repository}
  AuthenticationRepository({
    required StormApiClient apiClient,
    required TokenStorage<OAuth2Token> tokenStorage,
    required Fresh<OAuth2Token> freshInterceptor,
  }) : _apiClient = apiClient,
       _tokenStorage = tokenStorage,
       _freshInterceptor = freshInterceptor;

  final StormApiClient _apiClient;
  final TokenStorage<OAuth2Token> _tokenStorage;
  final Fresh<OAuth2Token> _freshInterceptor;

  final _statusController = StreamController<AuthStatus>.broadcast();
  AuthStatus _currentStatus = AuthStatus.unknown;

  /// The current [AuthSession] (if authenticated).
  AuthSession? get session => _session;
  AuthSession? _session;

  /// Stream of [AuthStatus] changes.
  Stream<AuthStatus> get status async* {
    yield _currentStatus;
    yield* _statusController.stream;
  }

  void _setStatus(AuthStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  /// Wraps [Fresh.setToken] in a [TaskEither] so it can be used in Do-blocks.
  TaskEither<StormFailure, Unit> _setInterceptorToken(OAuth2Token? token) =>
      TaskEither.tryCatch(
        () async {
          await _freshInterceptor.setToken(token);
          return unit;
        },
        mapStormError,
      );

  /// Wraps [TokenStorage.write] in a [TaskEither].
  TaskEither<StormFailure, Unit> _persistToken(OAuth2Token token) =>
      TaskEither.tryCatch(
        () async {
          await _tokenStorage.write(token);
          return unit;
        },
        mapStormError,
      );

  /// Maps a raw backend role string to an [AuthRole].
  static AuthRole _normalizeRole(String raw) => switch (raw.toLowerCase()) {
    'agent' => AuthRole.agent,
    'admin' => AuthRole.admin,
    _ => AuthRole.user,
  };

  /// Returns `true` for accounts that must re-authenticate on every cold
  /// restart: the super-admin (`suadmin`) and any account with the `admin`
  /// role.  Tokens for these principals are never persisted.
  static bool _isEphemeralSession({
    required String? username,
    required String role,
  }) =>
      (username ?? '').toLowerCase() == 'suadmin' ||
      role.toLowerCase() == 'admin';

  /// Tries to restore a persisted session on app startup.
  ///
  /// If a valid (non-expired) token is found in secure storage the session is
  /// restored; otherwise emits [AuthStatus.unauthenticated].
  ///
  /// **Offline resilience:** a [StormNetworkFailure] is converted into a
  /// minimal `AuthRole.user` session, the device stays authenticated until
  /// connectivity is restored.
  ///
  /// **Ephemeral accounts:** `suadmin` and `admin`-role tokens are cleared and
  /// the user must log in explicitly on every cold start.
  Future<void> tryRestoreSession() async {
    final token = await _tokenStorage.read();
    if (token == null) {
      _setStatus(AuthStatus.unauthenticated);
      return;
    }

    final result = await _verifyAndHydrate(token).run();
    if (result.isLeft()) {
      await _tokenStorage.delete();
      _setStatus(AuthStatus.unauthenticated);
    } else {
      _session = result.toNullable();
      _setStatus(AuthStatus.authenticated);
    }
  }

  TaskEither<StormFailure, AuthSession> _verifyAndHydrate(
    OAuth2Token token,
  ) =>
      TaskEither<StormFailure, AuthSession>.Do(($) async {
        await $(_setInterceptorToken(token));

        final me = await $(_apiClient.meTE());

        if (_isEphemeralSession(username: me.username, role: me.role)) {
          await $(_setInterceptorToken(null));
          return $(
            TaskEither.left(
              const StormApiFailure(
                'Ephemeral session - must login explicitly',
                403,
              ),
            ),
          );
        }

        final role = _normalizeRole(me.role);
        AgentInfo? agentInfo;
        UserInfo? userInfo;

        if (role == AuthRole.agent) {
          // Non-fatal: keep session alive even when profile hydration fails.
          agentInfo = (await _apiClient.getAgentTE(me.id).run()).toNullable();
        } else {
          userInfo = UserInfo(
            id: me.id,
            name: me.name ?? '',
            username: me.username ?? '',
            role: me.role,
          );
        }

        return AuthSession(
          token: token.accessToken,
          role: role,
          agentInfo: agentInfo,
          userInfo: userInfo,
        );
      }).orElse(
        (failure) => failure is StormNetworkFailure
            ? TaskEither.right(
                AuthSession(token: token.accessToken, role: AuthRole.user),
              )
            : TaskEither.left(failure),
      );

  /// Authenticates a **system user** (role `user` or `admin`).
  ///
  /// On success the JWT is persisted **unless** the session is ephemeral
  /// (`suadmin` or `admin` role), in those cases the token lives in memory
  /// only and a cold restart always requires a fresh login.
  TaskEither<StormFailure, AuthSession> loginAsUser({
    required String username,
    required String password,
  }) => TaskEither<StormFailure, AuthSession>.Do(($) async {
    final response = await $(
      _apiClient.systemLoginTE(
        LoginRequest(username: username, password: password),
      ),
    );

    final oauthToken = OAuth2Token(accessToken: response.token);
    await $(_setInterceptorToken(oauthToken));

    final ephemeral = _isEphemeralSession(
      username: response.user.username,
      role: response.user.role ?? 'user',
    );
    if (!ephemeral) await $(_persistToken(oauthToken));

    _session = AuthSession(
      token: response.token,
      role: _normalizeRole(response.user.role ?? 'user'),
      userInfo: response.user,
    );
    _setStatus(AuthStatus.authenticated);
    return _session!;
  });

  /// Authenticates an **agent**.
  TaskEither<StormFailure, AuthSession> loginAsAgent({
    required String username,
    required String password,
  }) => TaskEither<StormFailure, AuthSession>.Do(($) async {
    final response = await $(
      _apiClient.agentLoginTE(
        AgentLoginRequest(username: username, password: password),
      ),
    );

    final oauthToken = OAuth2Token(accessToken: response.token);
    await $(_setInterceptorToken(oauthToken));
    await $(_persistToken(oauthToken));

    _session = AuthSession(
      token: response.token,
      role: AuthRole.agent,
      agentInfo: response.agent,
    );
    _setStatus(AuthStatus.authenticated);
    return _session!;
  });

  /// Logs out the current session and clears persisted tokens.
  ///
  /// Server errors and network failures are suppressed, local auth state is
  /// always cleared regardless of the server response.
  Future<void> logout() async {
    await _apiClient
        .logoutTE()
        .orElse((_) => TaskEither<StormFailure, Unit>.right(unit))
        .run();
    await _tokenStorage.delete();
    await _freshInterceptor.setToken(null);
    _session = null;
    _setStatus(AuthStatus.unauthenticated);
  }

  /// Cleans up the [StreamController].
  Future<void> dispose() async => _statusController.close();
}
