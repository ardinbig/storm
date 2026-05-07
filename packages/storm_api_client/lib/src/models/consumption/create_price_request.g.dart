// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_price_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePriceRequest _$CreatePriceRequestFromJson(Map<String, dynamic> json) =>
    CreatePriceRequest(
      consumptionType: json['consumption_type'] as String,
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$CreatePriceRequestToJson(CreatePriceRequest instance) =>
    <String, dynamic>{
      'consumption_type': instance.consumptionType,
      'price': instance.price,
    };
