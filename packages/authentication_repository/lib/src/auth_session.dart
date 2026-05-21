import 'package:authentication_repository/authentication_repository.dart';
import 'package:storm_api_client/storm_api_client.dart';

/// An immutable snapshot of a successful authentication.
///
/// Created by [AuthenticationRepository] after a login or a session restore
/// and exposed via [AuthenticationRepository.session].
class AuthSession {
  /// Creates an [AuthSession].
  ///
  /// [token] is a raw JWT string issued by the backend.
  /// [role] is the resolved [AuthRole] for this principal.
  /// [userInfo] must be provided when [role] is [AuthRole.admin] or
  /// [AuthRole.user]; [agentInfo] when [role] is [AuthRole.agent].
  const AuthSession({
    required this.token,
    required this.role,
    this.userInfo,
    this.agentInfo,
  });

  /// The raw JWT used to authenticate subsequent API calls.
  ///
  /// Injected into the HTTP client via the [Fresh] interceptor so callers
  /// never need to attach it manually.
  final String token;

  /// The access level of the authenticated principal.
  final AuthRole role;

  /// Profile details for admin / user principals.
  ///
  /// Non-null when [role] is [AuthRole.admin] or [AuthRole.user].
  final UserInfo? userInfo;

  /// Profile details for agent principals.
  ///
  /// Non-null when [role] is [AuthRole.agent].
  final AgentInfo? agentInfo;

  /// Display name for the authenticated principal.
  ///
  /// Resolution order:
  /// * **Agent** → [AgentInfo.name] if set, otherwise [AgentInfo.agentRef].
  /// * **User / Admin** → [UserInfo.name].
  /// * Falls back to an empty string if no profile data is available.
  String get displayName {
    if (role == AuthRole.agent) {
      return Option.fromNullable(agentInfo)
          .flatMap(
            (info) =>
                Option.fromNullable(info.name).alt(() => some(info.agentRef)),
          )
          .getOrElse(() => '');
    }
    return Option.fromNullable(userInfo).fold(() => '', (u) => u.name);
  }

  /// Whether this session belongs to the super-admin account (`suadmin`).
  bool get isSuperAdmin => userInfo?.username == 'suadmin';
}
