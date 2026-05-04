// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_agent_password_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateAgentPasswordRequest _$UpdateAgentPasswordRequestFromJson(
  Map<String, dynamic> json,
) => UpdateAgentPasswordRequest(
  agentRef: json['agent_ref'] as String,
  lastPassword: json['last_password'] as String,
  newPassword: json['new_password'] as String,
);

Map<String, dynamic> _$UpdateAgentPasswordRequestToJson(
  UpdateAgentPasswordRequest instance,
) => <String, dynamic>{
  'agent_ref': instance.agentRef,
  'last_password': instance.lastPassword,
  'new_password': instance.newPassword,
};
