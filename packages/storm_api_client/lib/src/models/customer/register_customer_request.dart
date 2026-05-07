import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'register_customer_request.g.dart';

/// Request body.
@JsonSerializable(fieldRename: FieldRename.snake)
class RegisterCustomerRequest extends Equatable {
  const RegisterCustomerRequest({
    required this.cardId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.middleName,
    this.gender,
    this.maritalStatus,
    this.address,
    this.affiliation,
    this.clientCode,
    this.categoryRef,
    this.networks,
  });

  factory RegisterCustomerRequest.fromJson(Map<String, Object?> json) =>
      _$RegisterCustomerRequestFromJson(json);

  final String cardId;
  final String firstName;
  final String lastName;
  final String phone;
  final String? middleName;
  final String? gender;
  final String? maritalStatus;
  final String? address;
  final String? affiliation;
  final String? clientCode;
  final String? categoryRef;
  final String? networks;

  Map<String, Object?> toJson() => _$RegisterCustomerRequestToJson(this);

  @override
  List<Object?> get props => [
    cardId,
    firstName,
    lastName,
    phone,
    middleName,
    gender,
    maritalStatus,
    address,
    affiliation,
    clientCode,
    categoryRef,
    networks,
  ];
}
