import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'card_detail.g.dart';

/// Database row - card balance and credentials.
@JsonSerializable(fieldRename: FieldRename.snake)
class CardDetail extends Equatable {
  const CardDetail({
    required this.id,
    required this.amount,
    required this.nfcRef,
    required this.clientCode,
    this.network,
  });

  factory CardDetail.fromJson(Map<String, Object?> json) =>
      _$CardDetailFromJson(json);

  final String id;
  final double amount;
  final String nfcRef;
  final String clientCode;
  final String? network;

  Map<String, Object?> toJson() => _$CardDetailToJson(this);

  @override
  List<Object?> get props => [id, amount, nfcRef, clientCode, network];
}
