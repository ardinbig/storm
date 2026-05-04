// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_login_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgentLoginRequest _$AgentLoginRequestFromJson(Map<String, dynamic> json) =>
    AgentLoginRequest(
      username: json['username'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$AgentLoginRequestToJson(AgentLoginRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };
