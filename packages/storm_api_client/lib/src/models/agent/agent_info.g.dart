// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgentInfo _$AgentInfoFromJson(Map<String, dynamic> json) => AgentInfo(
  id: json['id'] as String,
  agentRef: json['agent_ref'] as String,
  currencyCode: json['currency_code'] as String,
  name: json['name'] as String?,
  balance: (json['balance'] as num?)?.toDouble(),
);

Map<String, dynamic> _$AgentInfoToJson(AgentInfo instance) => <String, dynamic>{
  'id': instance.id,
  'agent_ref': instance.agentRef,
  'currency_code': instance.currencyCode,
  'name': instance.name,
  'balance': instance.balance,
};
