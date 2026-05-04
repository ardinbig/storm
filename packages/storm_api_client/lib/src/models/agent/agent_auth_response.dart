import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:storm_api_client/src/models/agent/agent_info.dart';

part 'agent_auth_response.g.dart';

/// Successful agent authentication response.
@JsonSerializable(fieldRename: FieldRename.snake)
class AgentAuthResponse extends Equatable {
  const AgentAuthResponse({
    required this.token,
    required this.agent,
  });

  factory AgentAuthResponse.fromJson(Map<String, Object?> json) =>
      _$AgentAuthResponseFromJson(json);

  /// Signed JWT.
  final String token;

  /// Agent profile (no password).
  final AgentInfo agent;

  Map<String, Object?> toJson() => _$AgentAuthResponseToJson(this);

  @override
  List<Object?> get props => [token, agent];
}
