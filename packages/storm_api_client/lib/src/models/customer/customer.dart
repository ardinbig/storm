import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

export 'customer_by_card_response.dart';
export 'register_customer_request.dart';
export 'update_customer_request.dart';

part 'customer.g.dart';

/// Database row.
@JsonSerializable(fieldRename: FieldRename.snake)
class Customer extends Equatable {
  const Customer({
    required this.id,
    required this.status,
    required this.cardId,
    this.firstName,
    this.lastName,
    this.middleName,
    this.phone,
    this.gender,
    this.maritalStatus,
    this.address,
    this.affiliation,
    this.clientCode,
    this.categoryRef,
    this.networks,
  });

  factory Customer.fromJson(Map<String, Object?> json) =>
      _$CustomerFromJson(json);

  final String id;
  final int status;
  final String cardId;
  final String? firstName;
  final String? lastName;
  final String? middleName;
  final String? phone;
  final String? gender;
  final String? maritalStatus;
  final String? address;
  final String? affiliation;
  final String? clientCode;
  final String? categoryRef;
  final String? networks;

  Map<String, Object?> toJson() => _$CustomerToJson(this);

  @override
  List<Object?> get props => [
    id,
    status,
    cardId,
    firstName,
    lastName,
    middleName,
    phone,
    gender,
    maritalStatus,
    address,
    affiliation,
    clientCode,
    categoryRef,
    networks,
  ];
}
