// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_auth_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhoneAuthRequestModel _$PhoneAuthRequestModelFromJson(
  Map<String, dynamic> json,
) => PhoneAuthRequestModel(
  idToken: json['id_token'] as String,
  role: json['role'] as String,
  deviceInfo: json['device_info'] as String?,
);

Map<String, dynamic> _$PhoneAuthRequestModelToJson(
  PhoneAuthRequestModel instance,
) => <String, dynamic>{
  'id_token': instance.idToken,
  'role': instance.role,
  'device_info': instance.deviceInfo,
};
