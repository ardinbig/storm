import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'balance_response.g.dart';

/// Response for a successful balance inquiry.
@JsonSerializable(fieldRename: FieldRename.snake)
class BalanceResponse extends Equatable {
  const BalanceResponse({
    required this.nfcRef,
    required this.clientCode,
    required this.amount,
    this.network,
  });

  factory BalanceResponse.fromJson(Map<String, Object?> json) =>
      _$BalanceResponseFromJson(json);

  final String nfcRef;
  final String clientCode;
  final double amount;
  final String? network;

  Map<String, Object?> toJson() => _$BalanceResponseToJson(this);

  @override
  List<Object?> get props => [nfcRef, clientCode, amount, network];
}
