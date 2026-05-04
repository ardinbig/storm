import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_agent_request.g.dart';

/// Request body.
@JsonSerializable(fieldRename: FieldRename.snake)
class CreateAgentRequest extends Equatable {
  const CreateAgentRequest({
    required this.agentRef,
    required this.password,
    this.name,
    this.currencyCode,
  });

  factory CreateAgentRequest.fromJson(Map<String, Object?> json) =>
      _$CreateAgentRequestFromJson(json);

  final String agentRef;
  final String password;
  final String? name;
  final String? currencyCode;

  Map<String, Object?> toJson() => _$CreateAgentRequestToJson(this);

  @override
  List<Object?> get props => [agentRef, password, name, currencyCode];
}
