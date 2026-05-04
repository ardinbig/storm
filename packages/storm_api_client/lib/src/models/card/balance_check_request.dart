import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'balance_check_request.g.dart';

/// Request body for password-protected balance inquiry.
@JsonSerializable(fieldRename: FieldRename.snake)
class BalanceCheckRequest extends Equatable {
  const BalanceCheckRequest({required this.password});

  factory BalanceCheckRequest.fromJson(Map<String, Object?> json) =>
      _$BalanceCheckRequestFromJson(json);

  /// Plaintext card password / PIN to verify ownership.
  final String password;

  Map<String, Object?> toJson() => _$BalanceCheckRequestToJson(this);

  @override
  List<Object?> get props => [password];
}
