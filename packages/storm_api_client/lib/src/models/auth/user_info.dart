import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_info.g.dart';

/// Public-facing user information (password omitted).
@JsonSerializable(fieldRename: FieldRename.snake)
class UserInfo extends Equatable {
  const UserInfo({
    required this.id,
    required this.name,
    required this.username,
    this.email,
    this.role,
  });

  factory UserInfo.fromJson(Map<String, Object?> json) =>
      _$UserInfoFromJson(json);

  /// Primary key.
  final String id;

  /// Display name.
  final String name;

  /// Login identifier.
  final String username;

  /// Optional e-mail.
  final String? email;

  /// Backend role string (`"admin"`, `"user"`).
  final String? role;

  Map<String, Object?> toJson() => _$UserInfoToJson(this);

  @override
  List<Object?> get props => [id, name, username, email, role];
}
