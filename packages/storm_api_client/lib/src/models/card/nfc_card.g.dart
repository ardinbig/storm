// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nfc_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NfcCard _$NfcCardFromJson(Map<String, dynamic> json) => NfcCard(
  id: json['id'] as String,
  cardId: json['card_id'] as String,
  status: json['status'] as String?,
);

Map<String, dynamic> _$NfcCardToJson(NfcCard instance) => <String, dynamic>{
  'id': instance.id,
  'card_id': instance.cardId,
  'status': instance.status,
};
