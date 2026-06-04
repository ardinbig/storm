import 'package:authentication_repository/authentication_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:storm_api_client/storm_api_client.dart';

class MockStormApiClient extends Mock implements StormApiClient {}

class MockTokenStorage extends Mock implements TokenStorage<OAuth2Token> {}

class MockFresh extends Mock implements Fresh<OAuth2Token> {}

class FakeOAuth2Token extends Fake implements OAuth2Token {}

class FakeLoginRequest extends Fake implements LoginRequest {}

class FakeAgentLoginRequest extends Fake implements AgentLoginRequest {}

// Shared fixtures.
const persistedToken = OAuth2Token(accessToken: 'persisted-token');
const userInfo = UserInfo(id: 'u-1', name: 'Admin', username: 'admin');
const agentInfo = AgentInfo(
  id: 'a-1',
  agentRef: 'AGT-001',
  currencyCode: 'CDF',
  name: 'Agent Smith',
);

/// Stubs token storage and the fresh interceptor to return [token].
void stubToken(
  MockTokenStorage tokenStorage,
  MockFresh fresh,
  OAuth2Token token,
) {
  when(() => tokenStorage.read()).thenAnswer((_) async => token);
  when(() => fresh.setToken(token)).thenAnswer((_) async {});
}

/// Subscribes to [repository] status, pumps the event loop, runs [action],
/// pumps again, cancels, and returns the collected events.
Future<List<AuthStatus>> captureStatus(
  AuthenticationRepository repository,
  Future<void> Function() action,
) async {
  final events = <AuthStatus>[];
  final sub = repository.status.listen(events.add);
  await Future<void>.delayed(Duration.zero);
  await action();
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return events;
}
