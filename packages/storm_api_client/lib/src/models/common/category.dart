import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

/// Database row.
@JsonSerializable(fieldRename: FieldRename.snake)
class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, Object?> json) =>
      _$CategoryFromJson(json);

  final String id;
  final String name;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$CategoryToJson(this);

  @override
  List<Object?> get props => [id, name, createdAt];
}
