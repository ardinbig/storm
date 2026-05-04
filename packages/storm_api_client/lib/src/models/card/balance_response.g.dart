// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BalanceResponse _$BalanceResponseFromJson(Map<String, dynamic> json) =>
    BalanceResponse(
      nfcRef: json['nfc_ref'] as String,
      clientCode: json['client_code'] as String,
      amount: (json['amount'] as num).toDouble(),
      network: json['network'] as String?,
    );

Map<String, dynamic> _$BalanceResponseToJson(BalanceResponse instance) =>
    <String, dynamic>{
      'nfc_ref': instance.nfcRef,
      'client_code': instance.clientCode,
      'amount': instance.amount,
      'network': instance.network,
    };
