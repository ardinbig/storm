// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commission_tier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommissionTier _$CommissionTierFromJson(Map<String, dynamic> json) =>
    CommissionTier(
      id: json['id'] as String,
      level1: (json['level1'] as num).toDouble(),
      level2: (json['level2'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      category: json['category'] as String?,
    );

Map<String, dynamic> _$CommissionTierToJson(CommissionTier instance) =>
    <String, dynamic>{
      'id': instance.id,
      'level1': instance.level1,
      'level2': instance.level2,
      'created_at': instance.createdAt.toIso8601String(),
      'category': instance.category,
    };
