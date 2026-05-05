import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'metrics_response.g.dart';

/// Response body.
@JsonSerializable(fieldRename: FieldRename.snake)
class MetricsResponse extends Equatable {
  const MetricsResponse({required this.requests});

  factory MetricsResponse.fromJson(Map<String, Object?> json) =>
      _$MetricsResponseFromJson(json);

  /// Total number of HTTP requests handled since the server started.
  final int requests;

  Map<String, Object?> toJson() => _$MetricsResponseToJson(this);

  @override
  List<Object?> get props => [requests];
}
