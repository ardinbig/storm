import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_customer_request.g.dart';

/// Request body.
@JsonSerializable(fieldRename: FieldRename.snake)
class UpdateCustomerRequest extends Equatable {
  const UpdateCustomerRequest({
    this.firstName,
    this.lastName,
    this.middleName,
    this.phone,
    this.gender,
    this.maritalStatus,
    this.address,
    this.affiliation,
    this.cardId,
    this.categoryRef,
    this.networks,
  });

  factory UpdateCustomerRequest.fromJson(Map<String, Object?> json) =>
      _$UpdateCustomerRequestFromJson(json);

  final String? firstName;
  final String? lastName;
  final String? middleName;
  final String? phone;
  final String? gender;
  final String? maritalStatus;
  final String? address;
  final String? affiliation;
  final String? cardId;
  final String? categoryRef;
  final String? networks;

  Map<String, Object?> toJson() => _$UpdateCustomerRequestToJson(this);

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    middleName,
    phone,
    gender,
    maritalStatus,
    address,
    affiliation,
    cardId,
    categoryRef,
    networks,
  ];
}
