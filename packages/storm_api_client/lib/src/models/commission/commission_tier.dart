import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'commission_tier.g.dart';

/// Database row.
@JsonSerializable(fieldRename: FieldRename.snake)
class CommissionTier extends Equatable {
  const CommissionTier({
    required this.id,
    required this.level1,
    required this.level2,
    required this.createdAt,
    this.category,
  });

  factory CommissionTier.fromJson(Map<String, Object?> json) =>
      _$CommissionTierFromJson(json);

  final String id;
  final double level1;
  final double level2;
  final DateTime createdAt;
  final String? category;

  Map<String, Object?> toJson() => _$CommissionTierToJson(this);

  @override
  List<Object?> get props => [id, level1, level2, createdAt, category];
}
