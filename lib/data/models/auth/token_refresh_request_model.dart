import 'package:json_annotation/json_annotation.dart';

part 'token_refresh_request_model.g.dart';

/// Token refresh request model
///
/// Sent to: POST /auth/refresh
@JsonSerializable()
class TokenRefreshRequestModel {
  /// Refresh token to exchange for new access token
  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  const TokenRefreshRequestModel({
    required this.refreshToken,
  });

  /// Create model from JSON
  factory TokenRefreshRequestModel.fromJson(Map<String, dynamic> json) =>
      _$TokenRefreshRequestModelFromJson(json);

  /// Convert model to JSON
  Map<String, dynamic> toJson() => _$TokenRefreshRequestModelToJson(this);

  @override
  String toString() {
    return 'TokenRefreshRequestModel(refreshToken: ${refreshToken.substring(0, 10)}...)';
  }
}