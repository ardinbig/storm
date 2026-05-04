import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_commission_request.g.dart';

/// Request body.
@JsonSerializable(fieldRename: FieldRename.snake)
class CreateCommissionRequest extends Equatable {
  const CreateCommissionRequest({required this.percentage});

  factory CreateCommissionRequest.fromJson(Map<String, Object?> json) =>
      _$CreateCommissionRequestFromJson(json);

  final double percentage;

  Map<String, Object?> toJson() => _$CreateCommissionRequestToJson(this);

  @override
  List<Object?> get props => [percentage];
}
