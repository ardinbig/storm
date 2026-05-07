import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_consumption_request.g.dart';

/// Request body.
@JsonSerializable(fieldRename: FieldRename.snake)
class CreateConsumptionRequest extends Equatable {
  const CreateConsumptionRequest({
    required this.date,
    required this.clientRef,
    required this.consumptionType,
    required this.quantity,
    required this.price,
    required this.username,
    required this.isOnline,
  });

  factory CreateConsumptionRequest.fromJson(Map<String, Object?> json) =>
      _$CreateConsumptionRequestFromJson(json);

  final String date;
  final String clientRef;
  final String consumptionType;
  final double quantity;
  final double price;
  final String username;
  final bool isOnline;

  Map<String, Object?> toJson() => _$CreateConsumptionRequestToJson(this);

  @override
  List<Object?> get props => [
    date,
    clientRef,
    consumptionType,
    quantity,
    price,
    username,
    isOnline,
  ];
}
