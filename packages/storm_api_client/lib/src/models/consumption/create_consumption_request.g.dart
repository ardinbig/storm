// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_consumption_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateConsumptionRequest _$CreateConsumptionRequestFromJson(
  Map<String, dynamic> json,
) => CreateConsumptionRequest(
  date: json['date'] as String,
  clientRef: json['client_ref'] as String,
  consumptionType: json['consumption_type'] as String,
  quantity: (json['quantity'] as num).toDouble(),
  price: (json['price'] as num).toDouble(),
  username: json['username'] as String,
  isOnline: json['is_online'] as bool,
);

Map<String, dynamic> _$CreateConsumptionRequestToJson(
  CreateConsumptionRequest instance,
) => <String, dynamic>{
  'date': instance.date,
  'client_ref': instance.clientRef,
  'consumption_type': instance.consumptionType,
  'quantity': instance.quantity,
  'price': instance.price,
  'username': instance.username,
  'is_online': instance.isOnline,
};
