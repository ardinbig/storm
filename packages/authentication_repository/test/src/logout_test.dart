//
// ignore_for_file: avoid_catching_errors
import 'dart:async';

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

  group('logout', () {
    void verifyCleanup() {
      expect(repository.session, isNull);
      verify(() => tokenStorage.delete()).called(1);
      verify(() => fresh.setToken(null)).called(1);
    }

    test('clears auth state when api logout succeeds', () async {
      // Login first so there is an active session.
      when(() => apiClient.systemLoginTE(any())).thenReturn(
        TaskEither.right(
          const AuthResponse(token: 'user-token', user: userInfo),
        ),
      );
      when(() => fresh.setToken(any())).thenAnswer((_) async {});
      when(() => tokenStorage.write(any())).thenAnswer((_) async {});
      await repository.loginAsUser(username: 'admin', password: 'secret').run();

      when(() => apiClient.logoutTE()).thenReturn(TaskEither.right(unit));
      when(() => tokenStorage.delete()).thenAnswer((_) async {});
      when(() => fresh.setToken(null)).thenAnswer((_) async {});

      final events = <AuthStatus>[];
      final sub = repository.status.listen(events.add);
      await repository.logout();
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(events, contains(AuthStatus.unauthenticated));
      verify(() => apiClient.logoutTE()).called(1);
      verifyCleanup();
    });

    for (final entry in {
      'network error': const StormNetworkFailure('No internet'),
      'api error': const StormApiFailure('Unauthorized', 401),
    }.entries) {
      test('clears auth state when api logout fails (${entry.key})', () async {
        when(
          () => apiClient.logoutTE(),
        ).thenReturn(TaskEither.left(entry.value));
        when(() => tokenStorage.delete()).thenAnswer((_) async {});
        when(() => fresh.setToken(null)).thenAnswer((_) async {});

        final events = await captureStatus(repository, repository.logout);

        expect(events, contains(AuthStatus.unauthenticated));
        verifyCleanup();
      });
    }
  });

  group('dispose', () {
    test('status stream closes after dispose', () async {
      final events = <AuthStatus>[];
      final done = Completer<void>();
      final sub = repository.status.listen(events.add, onDone: done.complete);

      await repository.dispose();
      await done.future;
      await sub.cancel();

      expect(events, [AuthStatus.unknown]);
    });
  });
}
