/// Storage keys for the app
///
/// This class contains all storage key constants used throughout the app.
/// Using constants prevents typos and makes refactoring easier.
class StorageKeys {
  // Private constructor to prevent instantiation
  StorageKeys._();

  // ==================== SECURE STORAGE KEYS ====================
  // These are stored in encrypted storage (flutter_secure_storage)

  /// JWT access token from backend
  static const String accessToken = 'access_token';

  /// JWT refresh token from backend
  static const String refreshToken = 'refresh_token';

  /// Token expiry timestamp (milliseconds since epoch)
  static const String tokenExpiry = 'token_expiry';

  // ==================== SHARED PREFERENCES KEYS ====================
  // These are stored in plain text (shared_preferences)

  /// User role: 'influencer' or 'brand'
  static const String userRole = 'user_role';

  /// User's email address
  static const String userEmail = 'user_email';

  /// User's phone number (if logged in via phone)
  static const String userPhone = 'user_phone';

  /// User's unique ID from backend
  static const String userId = 'user_id';

  /// Firebase UID
  static const String firebaseUid = 'firebase_uid';

  /// Is user logged in flag
  static const String isLoggedIn = 'is_logged_in';

  /// Device info cached value
  static const String deviceInfo = 'device_info';

  /// Has user completed onboarding
  static const String hasCompletedOnboarding = 'has_completed_onboarding';

  /// Login method used: 'google' or 'phone'
  static const String loginMethod = 'login_method';

  /// App theme preference: 'light', 'dark', 'system'
  static const String themeMode = 'theme_mode';
}