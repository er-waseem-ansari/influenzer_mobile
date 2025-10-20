import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/constants/app_constants.dart';

/// Service for storing and retrieving user-related data
///
/// Uses SharedPreferences for non-sensitive user data.
/// This data persists across app restarts.
class UserLocalService {
  final SharedPreferences _prefs;

  UserLocalService(this._prefs);

  // ==================== USER AUTHENTICATION DATA ====================

  /// Save user role
  Future<bool> saveUserRole(UserRole role) async {
    return await _prefs.setString(StorageKeys.userRole, role.toJson());
  }

  /// Get user role
  UserRole? getUserRole() {
    final roleStr = _prefs.getString(StorageKeys.userRole);
    if (roleStr == null) return null;
    try {
      return UserRole.fromJson(roleStr);
    } catch (e) {
      return null;
    }
  }

  /// Save login method
  Future<bool> saveLoginMethod(LoginMethod method) async {
    return await _prefs.setString(StorageKeys.loginMethod, method.toJson());
  }

  /// Get login method
  LoginMethod? getLoginMethod() {
    final methodStr = _prefs.getString(StorageKeys.loginMethod);
    if (methodStr == null) return null;
    try {
      return LoginMethod.fromJson(methodStr);
    } catch (e) {
      return null;
    }
  }

  /// Set logged in status
  Future<bool> setLoggedIn(bool isLoggedIn) async {
    return await _prefs.setBool(StorageKeys.isLoggedIn, isLoggedIn);
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getBool(StorageKeys.isLoggedIn) ?? false;
  }

  // ==================== USER PROFILE DATA ====================

  /// Save user email
  Future<bool> saveUserEmail(String email) async {
    return await _prefs.setString(StorageKeys.userEmail, email);
  }

  /// Get user email
  String? getUserEmail() {
    return _prefs.getString(StorageKeys.userEmail);
  }

  /// Save user phone
  Future<bool> saveUserPhone(String phone) async {
    return await _prefs.setString(StorageKeys.userPhone, phone);
  }

  /// Get user phone
  String? getUserPhone() {
    return _prefs.getString(StorageKeys.userPhone);
  }

  /// Save user ID
  Future<bool> saveUserId(String userId) async {
    return await _prefs.setString(StorageKeys.userId, userId);
  }

  /// Get user ID
  String? getUserId() {
    return _prefs.getString(StorageKeys.userId);
  }

  /// Save Firebase UID
  Future<bool> saveFirebaseUid(String uid) async {
    return await _prefs.setString(StorageKeys.firebaseUid, uid);
  }

  /// Get Firebase UID
  String? getFirebaseUid() {
    return _prefs.getString(StorageKeys.firebaseUid);
  }

  // ==================== DEVICE & APP DATA ====================

  /// Save device info
  Future<bool> saveDeviceInfo(String deviceInfo) async {
    return await _prefs.setString(StorageKeys.deviceInfo, deviceInfo);
  }

  /// Get device info
  String? getDeviceInfo() {
    return _prefs.getString(StorageKeys.deviceInfo);
  }

  /// Set onboarding completed
  Future<bool> setOnboardingCompleted(bool completed) async {
    return await _prefs.setBool(StorageKeys.hasCompletedOnboarding, completed);
  }

  /// Check if onboarding completed
  bool hasCompletedOnboarding() {
    return _prefs.getBool(StorageKeys.hasCompletedOnboarding) ?? false;
  }

  // ==================== CLEAR DATA ====================

  /// Clear all user data (logout)
  Future<bool> clearUserData() async {
    final keys = [
      StorageKeys.userRole,
      StorageKeys.userEmail,
      StorageKeys.userPhone,
      StorageKeys.userId,
      StorageKeys.firebaseUid,
      StorageKeys.loginMethod,
      StorageKeys.isLoggedIn,
      StorageKeys.deviceInfo,
    ];

    for (final key in keys) {
      await _prefs.remove(key);
    }

    return true;
  }

  /// Clear everything (nuclear option)
  Future<bool> clearAll() async {
    return await _prefs.clear();
  }
}