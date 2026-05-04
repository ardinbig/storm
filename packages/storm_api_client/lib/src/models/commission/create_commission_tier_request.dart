import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_commission_tier_request.g.dart';

/// Request body.
@JsonSerializable(fieldRename: FieldRename.snake)
class CreateCommissionTierRequest extends Equatable {
  const CreateCommissionTierRequest({
    required this.level1,
    required this.level2,
    this.category,
  });

  factory CreateCommissionTierRequest.fromJson(Map<String, Object?> json) =>
      _$CreateCommissionTierRequestFromJson(json);

  final double level1;
  final double level2;
  final String? category;

  Map<String, Object?> toJson() => _$CreateCommissionTierRequestToJson(this);

  @override
  List<Object?> get props => [level1, level2, category];
}
