// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_auth_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleAuthRequestModel _$GoogleAuthRequestModelFromJson(
  Map<String, dynamic> json,
) => GoogleAuthRequestModel(
  idToken: json['id_token'] as String,
  role: json['role'] as String,
  deviceInfo: json['device_info'] as String?,
);

Map<String, dynamic> _$GoogleAuthRequestModelToJson(
  GoogleAuthRequestModel instance,
) => <String, dynamic>{
  'id_token': instance.idToken,
  'role': instance.role,
  'device_info': instance.deviceInfo,
};
