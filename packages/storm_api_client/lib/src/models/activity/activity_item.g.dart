// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityItem _$ActivityItemFromJson(Map<String, dynamic> json) => ActivityItem(
  kind: json['kind'] as String,
  agentRef: json['agent_ref'] as String?,
  amount: (json['amount'] as num?)?.toDouble(),
  clientRef: json['client_ref'] as String?,
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  stationId: json['station_id'] as String?,
);

Map<String, dynamic> _$ActivityItemToJson(ActivityItem instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'agent_ref': instance.agentRef,
      'amount': instance.amount,
      'client_ref': instance.clientRef,
      'date': instance.date?.toIso8601String(),
      'station_id': instance.stationId,
    };
