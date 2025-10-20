/// Application-wide constants
///
/// Contains enums, app metadata, and general configuration values.

// ==================== USER ROLE ENUM ====================

/// User role enum matching backend roles
enum UserRole {
  influencer,
  brand;

  /// Convert enum to string value for API
  String toJson() {
    switch (this) {
      case UserRole.influencer:
        return 'influencer';
      case UserRole.brand:
        return 'brand';
    }
  }

  /// Create enum from string value
  static UserRole fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'influencer':
        return UserRole.influencer;
      case 'brand':
        return UserRole.brand;
      default:
        throw ArgumentError('Invalid user role: $value');
    }
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case UserRole.influencer:
        return 'Influencer';
      case UserRole.brand:
        return 'Brand';
    }
  }
}

// ==================== LOGIN METHOD ENUM ====================

/// Authentication method used by user
enum LoginMethod {
  google,
  phone;

  String toJson() {
    switch (this) {
      case LoginMethod.google:
        return 'google';
      case LoginMethod.phone:
        return 'phone';
    }
  }

  static LoginMethod fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'google':
        return LoginMethod.google;
      case 'phone':
        return LoginMethod.phone;
      default:
        throw ArgumentError('Invalid login method: $value');
    }
  }
}

// ==================== APP METADATA ====================

class AppConstants {
  // Private constructor
  AppConstants._();

  /// Application name
  static const String appName = 'Influenzer';

  /// Application version
  static const String appVersion = '1.0.0';

  /// Support email
  static const String supportEmail = 'support@yourapp.com';

  // ==================== VALIDATION CONSTANTS ====================

  /// Minimum phone number length
  static const int minPhoneLength = 10;

  /// Maximum phone number length
  static const int maxPhoneLength = 15;

  /// OTP length
  static const int otpLength = 6;

  /// OTP resend timeout in seconds
  static const int otpResendTimeout = 60;

  // ==================== UI CONSTANTS ====================

  /// Default padding
  static const double defaultPadding = 16.0;

  /// Default border radius
  static const double defaultBorderRadius = 8.0;

  /// Animation duration
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
}