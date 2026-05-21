//
// ignore_for_file: avoid_catching_errors
import 'package:authentication_repository/authentication_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

import '../helpers/mocks.dart';

void main() {
  late MockStormApiClient apiClient;
  late MockTokenStorage tokenStorage;
  late MockFresh fresh;
  late AuthenticationRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeOAuth2Token());
    registerFallbackValue(FakeLoginRequest());
    registerFallbackValue(FakeAgentLoginRequest());
  });

  setUp(() {
    apiClient = MockStormApiClient();
    tokenStorage = MockTokenStorage();
    fresh = MockFresh();
    repository = AuthenticationRepository(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
      freshInterceptor: fresh,
    );
  });

  tearDown(() async {
    try {
      await repository.dispose();
    } on StateError {
      // Already disposed in test.
    }
  });

  group('loginAsUser', () {
    test('emits authenticated and persists token', () async {
      when(() => apiClient.systemLoginTE(any())).thenReturn(
        TaskEither.right(
          const AuthResponse(token: 'user-token', user: userInfo),
        ),
      );
      when(() => fresh.setToken(any())).thenAnswer((_) async {});
      when(() => tokenStorage.write(any())).thenAnswer((_) async {});

      late Either<StormFailure, AuthSession> result;
      final events = await captureStatus(repository, () async {
        result = await repository
            .loginAsUser(username: 'admin', password: 'secret')
            .run();
      });

      expect(events, [AuthStatus.unknown, AuthStatus.authenticated]);
      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (session) {
          expect(session.role, AuthRole.user);
          expect(session.userInfo, userInfo);
          expect(session.token, 'user-token');
          expect(repository.session, session);
        },
      );
      verify(() => apiClient.systemLoginTE(any())).called(1);
      verify(() => fresh.setToken(any())).called(1);
      verify(() => tokenStorage.write(any())).called(1);
    });

    // admin-role and suadmin accounts are ephemeral:
    // token must never be written to storage.
    for (final entry in {
      'admin role': (
        username: 'sysadmin',
        userInfo: const UserInfo(
          id: 'u-99',
          name: 'System Admin',
          username: 'sysadmin',
          role: 'admin',
        ),
        token: 'admin-token',
      ),
      'suadmin (lowercase)': (
        username: 'suadmin',
        userInfo: const UserInfo(
          id: 'su-1',
          name: 'Super Admin',
          username: 'suadmin',
          role: 'user',
        ),
        token: 'su-token',
      ),
      'suadmin (uppercase)': (
        username: 'SUADMIN',
        userInfo: const UserInfo(
          id: 'su-1',
          name: 'Super Admin',
          username: 'suadmin', // canonical from backend
          role: 'user',
        ),
        token: 'su-token',
      ),
      'suadmin (mixed case)': (
        username: 'Suadmin',
        userInfo: const UserInfo(
          id: 'su-1',
          name: 'Super Admin',
          username: 'suadmin',
          role: 'user',
        ),
        token: 'su-token',
      ),
    }.entries) {
      test('keeps session ephemeral for ${entry.key}', () async {
        when(() => apiClient.systemLoginTE(any())).thenReturn(
          TaskEither.right(
            AuthResponse(token: entry.value.token, user: entry.value.userInfo),
          ),
        );
        when(() => fresh.setToken(any())).thenAnswer((_) async {});

        final result = await repository
            .loginAsUser(username: entry.value.username, password: 'secret')
            .run();

        result.fold(
          (f) => fail('expected Right but got Left: $f'),
          (session) {
            expect(session.token, entry.value.token);
            verifyNever(() => tokenStorage.write(any()));
            verify(() => fresh.setToken(any())).called(1);
          },
        );
      });
    }

    test('returns Left(StormApiFailure) on invalid credentials', () async {
      when(() => apiClient.systemLoginTE(any())).thenReturn(
        TaskEither.left(const StormApiFailure('Invalid credentials', 401)),
      );

      final result = await repository
          .loginAsUser(username: 'admin', password: 'bad')
          .run();

      result.fold(
        (f) {
          expect(f, isA<StormApiFailure>());
          expect(f.message, 'Invalid credentials');
        },
        (_) => fail('expected Left but got Right'),
      );
      expect(repository.session, isNull);
      verifyNever(() => tokenStorage.write(any()));
      verifyNever(() => fresh.setToken(any()));
    });

    test('returns Left(StormNetworkFailure) on network error', () async {
      when(() => apiClient.systemLoginTE(any())).thenReturn(
        TaskEither.left(const StormNetworkFailure('No internet')),
      );

      final result = await repository
          .loginAsUser(username: 'admin', password: 'pass')
          .run();

      result.fold(
        (f) => expect(f, isA<StormNetworkFailure>()),
        (_) => fail('expected Left but got Right'),
      );
      expect(repository.session, isNull);
    });
  });

  group('loginAsAgent', () {
    test('emits authenticated and persists token', () async {
      when(() => apiClient.agentLoginTE(any())).thenReturn(
        TaskEither.right(
          const AgentAuthResponse(token: 'agent-token', agent: agentInfo),
        ),
      );
      when(() => fresh.setToken(any())).thenAnswer((_) async {});
      when(() => tokenStorage.write(any())).thenAnswer((_) async {});

      late Either<StormFailure, AuthSession> result;
      final events = await captureStatus(repository, () async {
        result = await repository
            .loginAsAgent(username: 'AGT-001', password: 'secret')
            .run();
      });

      expect(events, [AuthStatus.unknown, AuthStatus.authenticated]);
      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (session) {
          expect(session.role, AuthRole.agent);
          expect(session.agentInfo, agentInfo);
          expect(session.token, 'agent-token');
          expect(repository.session, session);
        },
      );
      verify(() => apiClient.agentLoginTE(any())).called(1);
      verify(() => fresh.setToken(any())).called(1);
      verify(() => tokenStorage.write(any())).called(1);
    });

    test('returns Left(StormApiFailure) on invalid credentials', () async {
      when(() => apiClient.agentLoginTE(any())).thenReturn(
        TaskEither.left(
          const StormApiFailure('Invalid agent ID or password', 401),
        ),
      );

      final result = await repository
          .loginAsAgent(username: 'AGT-X', password: 'bad')
          .run();

      result.fold(
        (f) {
          expect(f, isA<StormApiFailure>());
          expect(f.message, 'Invalid agent ID or password');
        },
        (_) => fail('expected Left but got Right'),
      );
      expect(repository.session, isNull);
    });
  });
}
