// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_agent_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateAgentRequest _$UpdateAgentRequestFromJson(Map<String, dynamic> json) =>
    UpdateAgentRequest(
      name: json['name'] as String?,
      currencyCode: json['currency_code'] as String?,
      stationId: json['station_id'] as String?,
    );

Map<String, dynamic> _$UpdateAgentRequestToJson(UpdateAgentRequest instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'currency_code': ?instance.currencyCode,
      'station_id': ?instance.stationId,
    };
