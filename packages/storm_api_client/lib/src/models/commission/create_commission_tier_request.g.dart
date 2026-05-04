// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_commission_tier_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCommissionTierRequest _$CreateCommissionTierRequestFromJson(
  Map<String, dynamic> json,
) => CreateCommissionTierRequest(
  level1: (json['level1'] as num).toDouble(),
  level2: (json['level2'] as num).toDouble(),
  category: json['category'] as String?,
);

Map<String, dynamic> _$CreateCommissionTierRequestToJson(
  CreateCommissionTierRequest instance,
) => <String, dynamic>{
  'level1': instance.level1,
  'level2': instance.level2,
  'category': instance.category,
};
