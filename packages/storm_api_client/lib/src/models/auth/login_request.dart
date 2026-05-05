import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';

/// Request body.
@JsonSerializable(fieldRename: FieldRename.snake)
class LoginRequest extends Equatable {
  const LoginRequest({
    required this.username,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, Object?> json) =>
      _$LoginRequestFromJson(json);

  /// The user's login identifier.
  final String username;

  /// Plaintext password to verify.
  final String password;

  Map<String, Object?> toJson() => _$LoginRequestToJson(this);

  @override
  List<Object?> get props => [username, password];
}
