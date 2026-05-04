// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_agent_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateAgentRequest _$CreateAgentRequestFromJson(Map<String, dynamic> json) =>
    CreateAgentRequest(
      agentRef: json['agent_ref'] as String,
      password: json['password'] as String,
      name: json['name'] as String?,
      currencyCode: json['currency_code'] as String?,
    );

Map<String, dynamic> _$CreateAgentRequestToJson(CreateAgentRequest instance) =>
    <String, dynamic>{
      'agent_ref': instance.agentRef,
      'password': instance.password,
      'name': instance.name,
      'currency_code': instance.currencyCode,
    };
