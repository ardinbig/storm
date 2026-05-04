import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'agent_info.g.dart';

/// Public-facing agent information (password omitted).
@JsonSerializable(fieldRename: FieldRename.snake)
class AgentInfo extends Equatable {
  const AgentInfo({
    required this.id,
    required this.agentRef,
    required this.currencyCode,
    this.name,
    this.balance,
  });

  factory AgentInfo.fromJson(Map<String, Object?> json) =>
      _$AgentInfoFromJson(json);

  /// Primary key.
  final String id;

  /// Unique agent reference code.
  final String agentRef;

  /// ISO currency code.
  final String currencyCode;

  /// Display name.
  final String? name;

  /// Current balance.
  final double? balance;

  Map<String, Object?> toJson() => _$AgentInfoToJson(this);

  @override
  List<Object?> get props => [id, agentRef, currencyCode, name, balance];
}
