// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardDetail _$CardDetailFromJson(Map<String, dynamic> json) => CardDetail(
  id: json['id'] as String,
  amount: (json['amount'] as num).toDouble(),
  nfcRef: json['nfc_ref'] as String,
  clientCode: json['client_code'] as String,
  network: json['network'] as String?,
);

Map<String, dynamic> _$CardDetailToJson(CardDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'nfc_ref': instance.nfcRef,
      'client_code': instance.clientCode,
      'network': instance.network,
    };
