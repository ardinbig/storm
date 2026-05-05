import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'me_response.g.dart';

/// Response.
@JsonSerializable(fieldRename: FieldRename.snake)
class MeResponse extends Equatable {
  const MeResponse({
    required this.id,
    required this.role,
    this.username,
    this.name,
  });

  factory MeResponse.fromJson(Map<String, Object?> json) =>
      _$MeResponseFromJson(json);

  /// The authenticated user's or agent's UUID.
  final String id;

  /// `"user"` or `"agent"`.
  final String role;

  /// Login identifier - present for system users.
  final String? username;

  /// Display name - present for system users.
  final String? name;

  Map<String, Object?> toJson() => _$MeResponseToJson(this);

  @override
  List<Object?> get props => [id, role, username, name];
}
