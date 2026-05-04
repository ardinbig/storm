import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_card_request.g.dart';

/// Request body.
@JsonSerializable(fieldRename: FieldRename.snake)
class CreateCardRequest extends Equatable {
  const CreateCardRequest({required this.cardId});

  factory CreateCardRequest.fromJson(Map<String, Object?> json) =>
      _$CreateCardRequestFromJson(json);

  final String cardId;

  Map<String, Object?> toJson() => _$CreateCardRequestToJson(this);

  @override
  List<Object?> get props => [cardId];
}
