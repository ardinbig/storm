import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'withdrawal_response.g.dart';

/// Successful withdrawal response.
@JsonSerializable(fieldRename: FieldRename.snake)
class WithdrawalResponse extends Equatable {
  const WithdrawalResponse({
    required this.message,
    required this.clientBalance,
    required this.agentBalance,
  });

  factory WithdrawalResponse.fromJson(Map<String, Object?> json) =>
      _$WithdrawalResponseFromJson(json);

  final String message;
  final double clientBalance;
  final double agentBalance;

  Map<String, Object?> toJson() => _$WithdrawalResponseToJson(this);

  @override
  List<Object?> get props => [message, clientBalance, agentBalance];
}
