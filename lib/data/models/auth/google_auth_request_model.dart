import 'package:json_annotation/json_annotation.dart';
import '../../../core/constants/app_constants.dart';

part 'google_auth_request_model.g.dart';

/// Google authentication request model
///
/// Sent to: POST /auth/google
@JsonSerializable()
class GoogleAuthRequestModel {
  /// Firebase ID token from Google Sign-In
  @JsonKey(name: 'id_token')
  final String idToken;

  /// User role (influencer or brand)
  @JsonKey(name: 'role')
  final String role;

  /// Optional device information
  @JsonKey(name: 'device_info')
  final String? deviceInfo;

  const GoogleAuthRequestModel({
    required this.idToken,
    required this.role,
    this.deviceInfo,
  });

  /// Create model from JSON
  factory GoogleAuthRequestModel.fromJson(Map<String, dynamic> json) =>
      _$GoogleAuthRequestModelFromJson(json);

  /// Convert model to JSON
  Map<String, dynamic> toJson() => _$GoogleAuthRequestModelToJson(this);

  /// Factory constructor with UserRole enum
  factory GoogleAuthRequestModel.create({
    required String idToken,
    required UserRole userRole,
    String? deviceInfo,
  }) {
    return GoogleAuthRequestModel(
      idToken: idToken,
      role: userRole.toJson(), // Convert enum to string
      deviceInfo: deviceInfo,
    );
  }

  @override
  String toString() {
    return 'GoogleAuthRequestModel(role: $role, hasDeviceInfo: ${deviceInfo != null})';
  }
}