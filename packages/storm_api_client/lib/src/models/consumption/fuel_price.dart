import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'fuel_price.g.dart';

/// Database row.
@JsonSerializable(fieldRename: FieldRename.snake)
class FuelPrice extends Equatable {
  const FuelPrice({
    required this.id,
    required this.consumptionType,
    required this.price,
    required this.priceDate,
  });

  factory FuelPrice.fromJson(Map<String, Object?> json) =>
      _$FuelPriceFromJson(json);

  final String id;
  final String consumptionType;
  final double price;
  final DateTime priceDate;

  Map<String, Object?> toJson() => _$FuelPriceToJson(this);

  @override
  List<Object?> get props => [id, consumptionType, price, priceDate];
}
