import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_agent_password_request.g.dart';

/// Request body.
@JsonSerializable(fieldRename: FieldRename.snake)
class UpdateAgentPasswordRequest extends Equatable {
  const UpdateAgentPasswordRequest({
    required this.agentRef,
    required this.lastPassword,
    required this.newPassword,
  });

  factory UpdateAgentPasswordRequest.fromJson(Map<String, Object?> json) =>
      _$UpdateAgentPasswordRequestFromJson(json);

  final String agentRef;
  final String lastPassword;
  final String newPassword;

  Map<String, Object?> toJson() => _$UpdateAgentPasswordRequestToJson(this);

  @override
  List<Object?> get props => [agentRef, lastPassword, newPassword];
}
