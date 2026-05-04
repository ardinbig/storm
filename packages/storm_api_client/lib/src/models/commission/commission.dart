import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

export 'commission_tier.dart';
export 'create_commission_request.dart';
export 'create_commission_tier_request.dart';

part 'commission.g.dart';

/// Database row.
@JsonSerializable(fieldRename: FieldRename.snake)
class Commission extends Equatable {
  const Commission({
    required this.id,
    required this.percentage,
    required this.createdAt,
  });

  factory Commission.fromJson(Map<String, Object?> json) =>
      _$CommissionFromJson(json);

  final String id;
  final double percentage;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$CommissionToJson(this);

  @override
  List<Object?> get props => [id, percentage, createdAt];
}
