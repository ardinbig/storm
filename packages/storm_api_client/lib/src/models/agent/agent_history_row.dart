import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'agent_history_row.g.dart';

/// A single row from the agent's transaction history view.
@JsonSerializable(fieldRename: FieldRename.snake)
class AgentHistoryRow extends Equatable {
  const AgentHistoryRow({
    required this.id,
    this.amount,
    this.client,
    this.currencyCode,
    this.date,
    this.transactionType,
  });

  factory AgentHistoryRow.fromJson(Map<String, Object?> json) =>
      _$AgentHistoryRowFromJson(json);

  /// Transaction primary key.
  final String id;

  /// Monetary amount involved.
  final double? amount;

  /// Formatted client name.
  final String? client;

  /// ISO currency code.
  final String? currencyCode;

  /// Timestamp of the transaction.
  final DateTime? date;

  /// Example. `"WITHDRAWAL"`.
  final String? transactionType;

  Map<String, Object?> toJson() => _$AgentHistoryRowToJson(this);

  @override
  List<Object?> get props => [
    id,
    amount,
    client,
    currencyCode,
    date,
    transactionType,
  ];
}
