import 'package:json_annotation/json_annotation.dart';

// This line generates the .g.dart file
part 'token_response_model.g.dart';

/// Token response model matching backend TokenResponse
///
/// Represents the response from:
/// - POST /auth/phone
/// - POST /auth/google
/// - POST /auth/refresh
@JsonSerializable()
class TokenResponseModel {
  /// JWT access token for API authentication
  @JsonKey(name: 'access_token')
  final String accessToken;

  /// JWT refresh token for getting new access tokens
  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  /// Token type (always "bearer")
  @JsonKey(name: 'token_type')
  final String tokenType;

  /// Token expiry duration in seconds
  @JsonKey(name: 'expires_in')
  final int expiresIn;

  const TokenResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  /// Create model from JSON
  factory TokenResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseModelFromJson(json);

  /// Convert model to JSON
  Map<String, dynamic> toJson() => _$TokenResponseModelToJson(this);

  /// Calculate expiry timestamp
  /// Returns milliseconds since epoch when token expires
  int get expiryTimestamp {
    return DateTime.now().millisecondsSinceEpoch + (expiresIn * 1000);
  }

  /// Check if token is expired
  bool get isExpired {
    return DateTime.now().millisecondsSinceEpoch >= expiryTimestamp;
  }

  @override
  String toString() {
    return 'TokenResponseModel(tokenType: $tokenType, expiresIn: $expiresIn)';
  }
}