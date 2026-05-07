// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
  id: json['id'] as String,
  agentAccount: json['agent_account'] as String?,
  clientAccount: json['client_account'] as String?,
  amount: (json['amount'] as num?)?.toDouble(),
  commission: (json['commission'] as num?)?.toDouble(),
  currencyCode: json['currency_code'] as String?,
  transactionType: json['transaction_type'] as String?,
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
);

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'agent_account': instance.agentAccount,
      'client_account': instance.clientAccount,
      'amount': instance.amount,
      'commission': instance.commission,
      'currency_code': instance.currencyCode,
      'transaction_type': instance.transactionType,
      'date': instance.date?.toIso8601String(),
    };
