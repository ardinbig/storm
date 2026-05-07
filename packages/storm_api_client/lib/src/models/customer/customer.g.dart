// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Customer _$CustomerFromJson(Map<String, dynamic> json) => Customer(
  id: json['id'] as String,
  status: (json['status'] as num).toInt(),
  cardId: json['card_id'] as String,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  middleName: json['middle_name'] as String?,
  phone: json['phone'] as String?,
  gender: json['gender'] as String?,
  maritalStatus: json['marital_status'] as String?,
  address: json['address'] as String?,
  affiliation: json['affiliation'] as String?,
  clientCode: json['client_code'] as String?,
  categoryRef: json['category_ref'] as String?,
  networks: json['networks'] as String?,
);

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'card_id': instance.cardId,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'middle_name': instance.middleName,
  'phone': instance.phone,
  'gender': instance.gender,
  'marital_status': instance.maritalStatus,
  'address': instance.address,
  'affiliation': instance.affiliation,
  'client_code': instance.clientCode,
  'category_ref': instance.categoryRef,
  'networks': instance.networks,
};
