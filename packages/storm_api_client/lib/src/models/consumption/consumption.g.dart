// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consumption.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Consumption _$ConsumptionFromJson(Map<String, dynamic> json) => Consumption(
  clientRef: json['client_ref'] as String,
  consumptionType: json['consumption_type'] as String,
  quantity: (json['quantity'] as num).toDouble(),
  price: (json['price'] as num).toDouble(),
  username: json['username'] as String,
  consumptionDate: DateTime.parse(json['consumption_date'] as String),
  status: (json['status'] as num).toInt(),
);

Map<String, dynamic> _$ConsumptionToJson(Consumption instance) =>
    <String, dynamic>{
      'client_ref': instance.clientRef,
      'consumption_type': instance.consumptionType,
      'quantity': instance.quantity,
      'price': instance.price,
      'username': instance.username,
      'consumption_date': instance.consumptionDate.toIso8601String(),
      'status': instance.status,
    };
