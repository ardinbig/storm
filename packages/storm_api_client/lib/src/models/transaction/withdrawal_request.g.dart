// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdrawal_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WithdrawalRequest _$WithdrawalRequestFromJson(Map<String, dynamic> json) =>
    WithdrawalRequest(
      clientCode: json['client_code'] as String,
      withdrawalAmount: (json['withdrawal_amount'] as num).toDouble(),
      clientPassword: json['client_password'] as String,
      agentCode: json['agent_code'] as String,
      currencyType: json['currency_type'] as String,
    );

Map<String, dynamic> _$WithdrawalRequestToJson(WithdrawalRequest instance) =>
    <String, dynamic>{
      'client_code': instance.clientCode,
      'withdrawal_amount': instance.withdrawalAmount,
      'client_password': instance.clientPassword,
      'agent_code': instance.agentCode,
      'currency_type': instance.currencyType,
    };
