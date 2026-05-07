// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdrawal_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WithdrawalResponse _$WithdrawalResponseFromJson(Map<String, dynamic> json) =>
    WithdrawalResponse(
      message: json['message'] as String,
      clientBalance: (json['client_balance'] as num).toDouble(),
      agentBalance: (json['agent_balance'] as num).toDouble(),
    );

Map<String, dynamic> _$WithdrawalResponseToJson(WithdrawalResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'client_balance': instance.clientBalance,
      'agent_balance': instance.agentBalance,
    };
