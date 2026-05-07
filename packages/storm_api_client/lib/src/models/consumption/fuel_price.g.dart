// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel_price.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FuelPrice _$FuelPriceFromJson(Map<String, dynamic> json) => FuelPrice(
  id: json['id'] as String,
  consumptionType: json['consumption_type'] as String,
  price: (json['price'] as num).toDouble(),
  priceDate: DateTime.parse(json['price_date'] as String),
);

Map<String, dynamic> _$FuelPriceToJson(FuelPrice instance) => <String, dynamic>{
  'id': instance.id,
  'consumption_type': instance.consumptionType,
  'price': instance.price,
  'price_date': instance.priceDate.toIso8601String(),
};
