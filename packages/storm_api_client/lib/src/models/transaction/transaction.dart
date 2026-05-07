import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

export 'withdrawal_request.dart';
export 'withdrawal_response.dart';

part 'transaction.g.dart';

/// Database row.
@JsonSerializable(fieldRename: FieldRename.snake)
class Transaction extends Equatable {
  const Transaction({
    required this.id,
    this.agentAccount,
    this.clientAccount,
    this.amount,
    this.commission,
    this.currencyCode,
    this.transactionType,
    this.date,
  });

  factory Transaction.fromJson(Map<String, Object?> json) =>
      _$TransactionFromJson(json);

  final String id;
  final String? agentAccount;
  final String? clientAccount;
  final double? amount;
  final double? commission;
  final String? currencyCode;
  final String? transactionType;
  final DateTime? date;

  Map<String, Object?> toJson() => _$TransactionToJson(this);

  @override
  List<Object?> get props => [
    id,
    agentAccount,
    clientAccount,
    amount,
    commission,
    currencyCode,
    transactionType,
    date,
  ];
}
