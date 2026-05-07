// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_customer_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateCustomerRequest _$UpdateCustomerRequestFromJson(
  Map<String, dynamic> json,
) => UpdateCustomerRequest(
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  middleName: json['middle_name'] as String?,
  phone: json['phone'] as String?,
  gender: json['gender'] as String?,
  maritalStatus: json['marital_status'] as String?,
  address: json['address'] as String?,
  affiliation: json['affiliation'] as String?,
  cardId: json['card_id'] as String?,
  categoryRef: json['category_ref'] as String?,
  networks: json['networks'] as String?,
);

Map<String, dynamic> _$UpdateCustomerRequestToJson(
  UpdateCustomerRequest instance,
) => <String, dynamic>{
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'middle_name': instance.middleName,
  'phone': instance.phone,
  'gender': instance.gender,
  'marital_status': instance.maritalStatus,
  'address': instance.address,
  'affiliation': instance.affiliation,
  'card_id': instance.cardId,
  'category_ref': instance.categoryRef,
  'networks': instance.networks,
};
