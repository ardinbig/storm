// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_history_row.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgentHistoryRow _$AgentHistoryRowFromJson(Map<String, dynamic> json) =>
    AgentHistoryRow(
      id: json['id'] as String,
      amount: (json['amount'] as num?)?.toDouble(),
      client: json['client'] as String?,
      currencyCode: json['currency_code'] as String?,
      date: json['date'] == null
          ? null
          : DateTime.parse(json['date'] as String),
      transactionType: json['transaction_type'] as String?,
    );

Map<String, dynamic> _$AgentHistoryRowToJson(AgentHistoryRow instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'client': instance.client,
      'currency_code': instance.currencyCode,
      'date': instance.date?.toIso8601String(),
      'transaction_type': instance.transactionType,
    };
