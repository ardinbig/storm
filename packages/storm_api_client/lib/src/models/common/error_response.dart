import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'error_response.g.dart';

/// Wire-format for JSON error responses.
@JsonSerializable(fieldRename: FieldRename.snake)
class ErrorResponse extends Equatable {
  const ErrorResponse({
    required this.error,
    required this.code,
  });

  factory ErrorResponse.fromJson(Map<String, Object?> json) =>
      _$ErrorResponseFromJson(json);

  /// Readable error description.
  final String error;

  /// Numeric HTTP status code echoed in the body.
  final int code;

  Map<String, Object?> toJson() => _$ErrorResponseToJson(this);

  @override
  List<Object?> get props => [error, code];
}
