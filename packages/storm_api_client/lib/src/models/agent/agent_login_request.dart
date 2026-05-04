import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'agent_login_request.g.dart';

/// Request body.
@JsonSerializable(fieldRename: FieldRename.snake)
class AgentLoginRequest extends Equatable {
  const AgentLoginRequest({
    required this.username,
    required this.password,
  });

  factory AgentLoginRequest.fromJson(Map<String, Object?> json) =>
      _$AgentLoginRequestFromJson(json);

  /// The agent's `agent_ref` used as login identifier.
  final String username;

  /// Plaintext password.
  final String password;

  Map<String, Object?> toJson() => _$AgentLoginRequestToJson(this);

  @override
  List<Object?> get props => [username, password];
}
