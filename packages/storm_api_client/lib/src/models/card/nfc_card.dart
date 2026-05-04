import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'nfc_card.g.dart';

/// Database row - NFC card master records.
@JsonSerializable(fieldRename: FieldRename.snake)
class NfcCard extends Equatable {
  const NfcCard({
    required this.id,
    required this.cardId,
    this.status,
  });

  factory NfcCard.fromJson(Map<String, Object?> json) =>
      _$NfcCardFromJson(json);

  /// Primary key.
  final String id;

  /// Physical NFC card identifier string.
  final String cardId;

  /// Current lifecycle status.
  final String? status;

  Map<String, Object?> toJson() => _$NfcCardToJson(this);

  @override
  List<Object?> get props => [id, cardId, status];
}
