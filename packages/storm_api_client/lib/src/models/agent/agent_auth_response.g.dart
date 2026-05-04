// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgentAuthResponse _$AgentAuthResponseFromJson(Map<String, dynamic> json) =>
    AgentAuthResponse(
      token: json['token'] as String,
      agent: AgentInfo.fromJson(json['agent'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AgentAuthResponseToJson(AgentAuthResponse instance) =>
    <String, dynamic>{'token': instance.token, 'agent': instance.agent};
