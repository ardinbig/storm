// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_register_customer_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgentRegisterCustomerRequest _$AgentRegisterCustomerRequestFromJson(
  Map<String, dynamic> json,
) => AgentRegisterCustomerRequest(
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  phone: json['phone'] as String,
  cardRef: json['card_ref'] as String,
  middleName: json['middle_name'] as String?,
  gender: json['gender'] as String?,
  maritalStatus: json['marital_status'] as String?,
  address: json['address'] as String?,
  affiliation: json['affiliation'] as String?,
);

Map<String, dynamic> _$AgentRegisterCustomerRequestToJson(
  AgentRegisterCustomerRequest instance,
) => <String, dynamic>{
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'phone': instance.phone,
  'card_ref': instance.cardRef,
  'middle_name': instance.middleName,
  'gender': instance.gender,
  'marital_status': instance.maritalStatus,
  'address': instance.address,
  'affiliation': instance.affiliation,
};
