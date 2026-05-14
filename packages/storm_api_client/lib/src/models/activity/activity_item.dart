import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity_item.g.dart';

/// A single event in the unified activity feed.
///
/// Each row is either a financial withdrawal (`kind = "WITHDRAWAL"`) or a
/// fuel dispensing event (`kind = "CONSUMPTION"`).
@JsonSerializable(fieldRename: FieldRename.snake)
class ActivityItem extends Equatable {
  const ActivityItem({
    required this.kind,
    this.agentRef,
    this.amount,
    this.clientRef,
    this.date,
    this.stationId,
  });

  factory ActivityItem.fromJson(Map<String, Object?> json) =>
      _$ActivityItemFromJson(json);

  /// `"WITHDRAWAL"` or `"CONSUMPTION"`.
  final String kind;

  /// Agent reference code that performed the operation.
  final String? agentRef;

  /// Monetary amount.
  final double? amount;

  /// Client reference (NFC code for withdrawals; `client_ref` for
  /// consumptions).
  final String? clientRef;

  /// Timestamp of the event.
  final DateTime? date;

  /// Station (system-user UUID) the agent belongs to, if any.
  final String? stationId;

  Map<String, Object?> toJson() => _$ActivityItemToJson(this);

  @override
  List<Object?> get props => [
    kind,
    agentRef,
    amount,
    clientRef,
    date,
    stationId,
  ];
}
