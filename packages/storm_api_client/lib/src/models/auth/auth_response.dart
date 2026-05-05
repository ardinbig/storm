import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:storm_api_client/src/models/auth/user_info.dart';

part 'auth_response.g.dart';

/// Successful authentication response returned by login endpoints.
@JsonSerializable(fieldRename: FieldRename.snake)
class AuthResponse extends Equatable {
  const AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, Object?> json) =>
      _$AuthResponseFromJson(json);

  /// Signed JWT.
  final String token;

  /// Summary of the authenticated user (no password).
  final UserInfo user;

  Map<String, Object?> toJson() => _$AuthResponseToJson(this);

  @override
  List<Object?> get props => [token, user];
}
