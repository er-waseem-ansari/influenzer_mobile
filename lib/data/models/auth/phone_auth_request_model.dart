import 'package:json_annotation/json_annotation.dart';
import '../../../core/constants/app_constants.dart';

part 'phone_auth_request_model.g.dart';

/// Phone OTP authentication request model
///
/// Sent to: POST /auth/phone
@JsonSerializable()
class PhoneAuthRequestModel {
  /// Firebase ID token from phone authentication
  @JsonKey(name: 'id_token')
  final String idToken;

  /// User role (influencer or brand)
  @JsonKey(name: 'role')
  final String role;

  /// Optional device information
  @JsonKey(name: 'device_info')
  final String? deviceInfo;

  const PhoneAuthRequestModel({
    required this.idToken,
    required this.role,
    this.deviceInfo,
  });

  /// Create model from JSON
  factory PhoneAuthRequestModel.fromJson(Map<String, dynamic> json) =>
      _$PhoneAuthRequestModelFromJson(json);

  /// Convert model to JSON
  Map<String, dynamic> toJson() => _$PhoneAuthRequestModelToJson(this);

  /// Factory constructor with UserRole enum
  factory PhoneAuthRequestModel.create({
    required String idToken,
    required UserRole userRole,
    String? deviceInfo,
  }) {
    return PhoneAuthRequestModel(
      idToken: idToken,
      role: userRole.toJson(),
      deviceInfo: deviceInfo,
    );
  }

  @override
  String toString() {
    return 'PhoneAuthRequestModel(role: $role, hasDeviceInfo: ${deviceInfo != null})';
  }
}