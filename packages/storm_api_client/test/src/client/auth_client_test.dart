import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

import '../helpers/helpers.dart';

void main() {
  group('StormApiClient — auth', () {
    group('systemLoginTE', () {
      test('returns AuthResponse on success', () async {
        final dio = buildFakeDio(
          okResponse({'token': 'jwt-tok', 'user': userInfoJson}),
        );
        final result = await buildFakeClient(dio)
            .systemLoginTE(
              const LoginRequest(username: 'user', password: 'pass'),
            )
            .run();
        assertRight(result, (v) {
          expect(v.token, 'jwt-tok');
          expect(v.user.id, 'u1');
        });
      });
    });

    group('registerTE', () {
      test('returns UserInfo on success', () async {
        final dio = buildFakeDio(okResponse(userInfoJson));
        final result = await buildFakeClient(dio)
            .registerTE(
              const RegisterRequest(
                name: 'Test User',
                username: 'testuser',
                password: 'pass',
              ),
            )
            .run();
        assertRight(result, (v) => expect(v.id, 'u1'));
      });
    });

    group('logoutTE', () {
      test('returns unit on success', () async {
        final dio = buildFakeDio(okResponse(null));
        final result = await buildFakeClient(dio).logoutTE().run();
        assertRight(result, (v) => expect(v, unit));
      });
    });

    group('agentLoginTE', () {
      test('returns AgentAuthResponse on success', () async {
        final dio = buildFakeDio(
          okResponse({'token': 'agent-tok', 'agent': agentInfoJson}),
        );
        final result = await buildFakeClient(dio)
            .agentLoginTE(
              const AgentLoginRequest(username: 'AGT01', password: 'pass'),
            )
            .run();
        assertRight(result, (v) {
          expect(v.token, 'agent-tok');
          expect(v.agent.agentRef, 'AGT01');
        });
      });
    });

    group('meTE', () {
      test('returns MeResponse on success', () async {
        final dio = buildFakeDio(okResponse({'id': 'u1', 'role': 'user'}));
        final result = await buildFakeClient(dio).meTE().run();
        assertRight(result, (v) {
          expect(v.id, 'u1');
          expect(v.role, 'user');
        });
      });
    });
  });
}
