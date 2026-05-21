//
// ignore_for_file: avoid_catching_errors
import 'package:authentication_repository/authentication_repository.dart';
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

  group('tryRestoreSession', () {
    test('emits unknown to unauthenticated when no token stored', () async {
      when(() => tokenStorage.read()).thenAnswer((_) async => null);

      final events = await captureStatus(
        repository,
        repository.tryRestoreSession,
      );

      expect(events, [AuthStatus.unknown, AuthStatus.unauthenticated]);
      expect(repository.session, isNull);
      verify(() => tokenStorage.read()).called(1);
      verifyNever(() => fresh.setToken(any()));
      verifyNever(() => apiClient.meTE());
    });

    test('restores agent session when /me role is agent', () async {
      stubToken(tokenStorage, fresh, persistedToken);
      when(() => apiClient.meTE()).thenReturn(
        TaskEither.right(const MeResponse(id: 'a-1', role: 'agent')),
      );
      when(
        () => apiClient.getAgentTE('a-1'),
      ).thenReturn(TaskEither.right(agentInfo));

      final events = await captureStatus(
        repository,
        repository.tryRestoreSession,
      );

      expect(events, [AuthStatus.unknown, AuthStatus.authenticated]);
      expect(repository.session!.token, 'persisted-token');
      expect(repository.session!.role, AuthRole.agent);
      expect(repository.session!.agentInfo, agentInfo);
      verify(() => tokenStorage.read()).called(1);
      verify(() => fresh.setToken(persistedToken)).called(1);
      verify(() => apiClient.meTE()).called(1);
      verify(() => apiClient.getAgentTE('a-1')).called(1);
      verifyNever(() => tokenStorage.delete());
    });

    test('replays current status for late subscribers', () async {
      stubToken(tokenStorage, fresh, persistedToken);
      when(() => apiClient.meTE()).thenReturn(
        TaskEither.right(const MeResponse(id: 'u-1', role: 'user')),
      );
      await repository.tryRestoreSession();

      final events = <AuthStatus>[];
      final sub = repository.status.listen(events.add);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(events, [AuthStatus.authenticated]);
      expect(repository.session!.token, 'persisted-token');
    });

    test('hydrates userInfo for user role', () async {
      stubToken(tokenStorage, fresh, persistedToken);
      when(() => apiClient.meTE()).thenReturn(
        TaskEither.right(
          const MeResponse(
            id: 'u-1',
            role: 'user',
            username: 'admin',
            name: 'Admin',
          ),
        ),
      );

      final events = await captureStatus(
        repository,
        repository.tryRestoreSession,
      );

      expect(events, [AuthStatus.unknown, AuthStatus.authenticated]);
      expect(repository.session!.role, AuthRole.user);
      expect(repository.session!.userInfo?.id, 'u-1');
      expect(repository.session!.userInfo?.username, 'admin');
      expect(repository.session!.userInfo?.name, 'Admin');
      expect(repository.session!.agentInfo, isNull);
      verifyNever(() => apiClient.getAgentTE(any()));
    });

    // suadmin and admin-role are ephemeral: tokens must be cleared on restore.
    for (final entry in {
      'suadmin': const MeResponse(
        id: 'su-1',
        role: 'user',
        username: 'suadmin',
        name: 'Super Admin',
      ),
      'admin role': const MeResponse(id: 'a-99', role: 'admin'),
    }.entries) {
      test('forces logout for ephemeral session (${entry.key})', () async {
        stubToken(tokenStorage, fresh, persistedToken);
        when(() => fresh.setToken(null)).thenAnswer((_) async {});
        when(() => tokenStorage.delete()).thenAnswer((_) async {});
        when(() => apiClient.meTE()).thenReturn(TaskEither.right(entry.value));

        final events = await captureStatus(
          repository,
          repository.tryRestoreSession,
        );

        expect(events, [AuthStatus.unknown, AuthStatus.unauthenticated]);
        expect(repository.session, isNull);
        verify(() => tokenStorage.delete()).called(1);
        verify(() => fresh.setToken(null)).called(1);
      });
    }

    // Both failure types must keep the agent session alive with no agentInfo.
    for (final entry in {
      'StormApiFailure': const StormApiFailure('Not found', 404),
      'StormNetworkFailure': const StormNetworkFailure('No internet'),
    }.entries) {
      test(
        'stays authenticated when getAgentTE returns Left(${entry.key})',
        () async {
          stubToken(
            tokenStorage,
            fresh,
            const OAuth2Token(accessToken: 'agent-token'),
          );
          when(() => apiClient.meTE()).thenReturn(
            TaskEither.right(const MeResponse(id: 'a-1', role: 'agent')),
          );
          when(
            () => apiClient.getAgentTE('a-1'),
          ).thenReturn(TaskEither.left(entry.value));

          await repository.tryRestoreSession();

          expect(repository.session!.role, AuthRole.agent);
          expect(repository.session!.agentInfo, isNull);
        },
      );
    }

    test('becomes unauthenticated when server rejects token', () async {
      stubToken(
        tokenStorage,
        fresh,
        const OAuth2Token(accessToken: 'expired-token'),
      );
      when(() => apiClient.meTE()).thenReturn(
        TaskEither.left(const StormApiFailure('Unauthorized', 401)),
      );
      when(() => tokenStorage.delete()).thenAnswer((_) async {});

      final events = await captureStatus(
        repository,
        repository.tryRestoreSession,
      );

      expect(events, [AuthStatus.unknown, AuthStatus.unauthenticated]);
      expect(repository.session, isNull);
      verify(() => tokenStorage.delete()).called(1);
    });

    test('stays authenticated when network is unavailable', () async {
      stubToken(
        tokenStorage,
        fresh,
        const OAuth2Token(accessToken: 'cached-token'),
      );
      when(() => apiClient.meTE()).thenReturn(
        TaskEither.left(const StormNetworkFailure('No internet')),
      );

      final events = await captureStatus(
        repository,
        repository.tryRestoreSession,
      );

      expect(events, [AuthStatus.unknown, AuthStatus.authenticated]);
      expect(repository.session!.token, 'cached-token');
      expect(repository.session!.role, AuthRole.user);
      verifyNever(() => tokenStorage.delete());
    });
  });
}
