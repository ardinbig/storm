import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'agent_register_customer_request.g.dart';

/// Request body when an agent registers a new customer.
@JsonSerializable(fieldRename: FieldRename.snake)
class AgentRegisterCustomerRequest extends Equatable {
  const AgentRegisterCustomerRequest({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.cardRef,
    this.middleName,
    this.gender,
    this.maritalStatus,
    this.address,
    this.affiliation,
  });

  factory AgentRegisterCustomerRequest.fromJson(Map<String, Object?> json) =>
      _$AgentRegisterCustomerRequestFromJson(json);

  final String firstName;
  final String lastName;
  final String phone;
  final String cardRef;
  final String? middleName;
  final String? gender;
  final String? maritalStatus;
  final String? address;
  final String? affiliation;

  Map<String, Object?> toJson() => _$AgentRegisterCustomerRequestToJson(this);

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    phone,
    cardRef,
    middleName,
    gender,
    maritalStatus,
    address,
    affiliation,
  ];
}
