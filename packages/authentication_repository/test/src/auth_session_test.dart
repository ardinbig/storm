import 'package:authentication_repository/authentication_repository.dart';
import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

import '../helpers/mocks.dart';

void main() {
  group('AuthSession', () {
    test('displayName returns name for user and admin roles', () {
      const user = AuthSession(
        token: 't',
        role: AuthRole.user,
        userInfo: userInfo,
      );
      const admin = AuthSession(
        token: 't',
        role: AuthRole.admin,
        userInfo: userInfo,
      );
      expect(user.displayName, 'Admin');
      expect(admin.displayName, 'Admin');
    });

    test('displayName returns agent name when available', () {
      const session = AuthSession(
        token: 't',
        role: AuthRole.agent,
        agentInfo: agentInfo,
      );
      expect(session.displayName, 'Agent Smith');
    });

    test('displayName falls back to agentRef when name is null', () {
      const session = AuthSession(
        token: 't',
        role: AuthRole.agent,
        agentInfo: AgentInfo(
          id: 'a-2',
          agentRef: 'AGT-002',
          currencyCode: 'CDF',
        ),
      );
      expect(session.displayName, 'AGT-002');
    });

    test('displayName is empty when no profile fields are set', () {
      for (final role in AuthRole.values) {
        expect(
          AuthSession(token: 't', role: role).displayName,
          isEmpty,
          reason: 'expected empty for role $role',
        );
      }
    });

    group('isSuperAdmin', () {
      test('returns true only when userInfo.username is suadmin', () {
        expect(
          const AuthSession(
            token: 't',
            role: AuthRole.user,
            userInfo: UserInfo(
              id: 'su-1',
              name: 'Super Admin',
              username: 'suadmin',
            ),
          ).isSuperAdmin,
          isTrue,
        );

        for (final session in [
          const AuthSession(
            token: 't',
            role: AuthRole.user,
            userInfo: userInfo,
          ),
          const AuthSession(
            token: 't',
            role: AuthRole.admin,
            userInfo: userInfo,
          ),
          const AuthSession(token: 't', role: AuthRole.user),
          const AuthSession(
            token: 't',
            role: AuthRole.agent,
            agentInfo: agentInfo,
          ),
        ]) {
          expect(
            session.isSuperAdmin,
            isFalse,
            reason: 'unexpected true for $session',
          );
        }
      });
    });
  });
}
