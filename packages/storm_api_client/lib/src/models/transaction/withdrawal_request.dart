import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'withdrawal_request.g.dart';

/// Request body.
@JsonSerializable(fieldRename: FieldRename.snake)
class WithdrawalRequest extends Equatable {
  const WithdrawalRequest({
    required this.clientCode,
    required this.withdrawalAmount,
    required this.clientPassword,
    required this.agentCode,
    required this.currencyType,
  });

  factory WithdrawalRequest.fromJson(Map<String, Object?> json) =>
      _$WithdrawalRequestFromJson(json);

  final String clientCode;
  final double withdrawalAmount;
  final String clientPassword;
  final String agentCode;
  final String currencyType;

  Map<String, Object?> toJson() => _$WithdrawalRequestToJson(this);

  @override
  List<Object?> get props => [
    clientCode,
    withdrawalAmount,
    clientPassword,
    agentCode,
    currencyType,
  ];
}
