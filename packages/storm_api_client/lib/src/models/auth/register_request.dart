import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'register_request.g.dart';

/// Request body.
@JsonSerializable(fieldRename: FieldRename.snake)
class RegisterRequest extends Equatable {
  const RegisterRequest({
    required this.name,
    required this.username,
    required this.password,
    this.email,
  });

  factory RegisterRequest.fromJson(Map<String, Object?> json) =>
      _$RegisterRequestFromJson(json);

  /// Display name.
  final String name;

  /// Desired login identifier (must be unique).
  final String username;

  /// Plaintext password (will be Argon2-hashed before storage).
  final String password;

  /// Optional e-mail.
  final String? email;

  Map<String, Object?> toJson() => _$RegisterRequestToJson(this);

  @override
  List<Object?> get props => [name, username, password, email];
}
