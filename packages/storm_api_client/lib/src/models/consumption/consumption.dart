import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

export 'create_consumption_request.dart';
export 'create_price_request.dart';
export 'fuel_price.dart';

part 'consumption.g.dart';

/// Database row.
@JsonSerializable(fieldRename: FieldRename.snake)
class Consumption extends Equatable {
  const Consumption({
    required this.clientRef,
    required this.consumptionType,
    required this.quantity,
    required this.price,
    required this.username,
    required this.consumptionDate,
    required this.status,
  });

  factory Consumption.fromJson(Map<String, Object?> json) =>
      _$ConsumptionFromJson(json);

  final String clientRef;
  final String consumptionType;
  final double quantity;
  final double price;
  final String username;
  final DateTime consumptionDate;
  final int status;

  Map<String, Object?> toJson() => _$ConsumptionToJson(this);

  @override
  List<Object?> get props => [
    clientRef,
    consumptionType,
    quantity,
    price,
    username,
    consumptionDate,
    status,
  ];
}
