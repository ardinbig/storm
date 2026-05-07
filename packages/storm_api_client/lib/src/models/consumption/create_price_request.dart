import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_price_request.g.dart';

/// Request body.
@JsonSerializable(fieldRename: FieldRename.snake)
class CreatePriceRequest extends Equatable {
  const CreatePriceRequest({
    required this.consumptionType,
    required this.price,
  });

  factory CreatePriceRequest.fromJson(Map<String, Object?> json) =>
      _$CreatePriceRequestFromJson(json);

  final String consumptionType;
  final double price;

  Map<String, Object?> toJson() => _$CreatePriceRequestToJson(this);

  @override
  List<Object?> get props => [consumptionType, price];
}
