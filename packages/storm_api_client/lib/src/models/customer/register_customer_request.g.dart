// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_customer_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterCustomerRequest _$RegisterCustomerRequestFromJson(
  Map<String, dynamic> json,
) => RegisterCustomerRequest(
  cardId: json['card_id'] as String,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  phone: json['phone'] as String,
  middleName: json['middle_name'] as String?,
  gender: json['gender'] as String?,
  maritalStatus: json['marital_status'] as String?,
  address: json['address'] as String?,
  affiliation: json['affiliation'] as String?,
  clientCode: json['client_code'] as String?,
  categoryRef: json['category_ref'] as String?,
  networks: json['networks'] as String?,
);

Map<String, dynamic> _$RegisterCustomerRequestToJson(
  RegisterCustomerRequest instance,
) => <String, dynamic>{
  'card_id': instance.cardId,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'phone': instance.phone,
  'middle_name': instance.middleName,
  'gender': instance.gender,
  'marital_status': instance.maritalStatus,
  'address': instance.address,
  'affiliation': instance.affiliation,
  'client_code': instance.clientCode,
  'category_ref': instance.categoryRef,
  'networks': instance.networks,
};
