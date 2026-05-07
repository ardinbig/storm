import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'customer_by_card_response.g.dart';

/// Minimal response when looking up a customer by card.
@JsonSerializable(fieldRename: FieldRename.snake)
class CustomerByCardResponse extends Equatable {
  const CustomerByCardResponse({required this.clientCode});

  factory CustomerByCardResponse.fromJson(Map<String, Object?> json) =>
      _$CustomerByCardResponseFromJson(json);

  final String clientCode;

  Map<String, Object?> toJson() => _$CustomerByCardResponseToJson(this);

  @override
  List<Object?> get props => [clientCode];
}
