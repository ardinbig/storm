import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_agent_request.g.dart';

/// Request body.
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class UpdateAgentRequest extends Equatable {
  const UpdateAgentRequest({this.name, this.currencyCode, this.stationId});

  factory UpdateAgentRequest.fromJson(Map<String, Object?> json) =>
      _$UpdateAgentRequestFromJson(json);

  /// Display name.
  final String? name;

  /// ISO currency code.
  final String? currencyCode;

  /// Station (system-user UUID) this agent belongs to.
  /// Pass `null` via JSON to unlink the agent from a station.
  final String? stationId;

  Map<String, Object?> toJson() => _$UpdateAgentRequestToJson(this);

  @override
  List<Object?> get props => [name, currencyCode, stationId];
}
