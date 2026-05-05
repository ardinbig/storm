import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_category_request.g.dart';

/// Request body.
@JsonSerializable(fieldRename: FieldRename.snake)
class CreateCategoryRequest extends Equatable {
  const CreateCategoryRequest({required this.name});

  factory CreateCategoryRequest.fromJson(Map<String, Object?> json) =>
      _$CreateCategoryRequestFromJson(json);

  final String name;

  Map<String, Object?> toJson() => _$CreateCategoryRequestToJson(this);

  @override
  List<Object?> get props => [name];
}
