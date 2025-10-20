import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/storage_keys.dart';

/// Service for securely storing and retrieving authentication tokens
///
/// Uses flutter_secure_storage for encrypted storage on device.
/// Tokens are never stored in plain text.
class TokenStorageService {
  final FlutterSecureStorage _secureStorage;

  TokenStorageService(this._secureStorage);

  // ==================== SAVE TOKENS ====================

  /// Save access token securely
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(
      key: StorageKeys.accessToken,
      value: token,
    );
  }

  /// Save refresh token securely
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(
      key: StorageKeys.refreshToken,
      value: token,
    );
  }

  /// Save token expiry timestamp (milliseconds since epoch)
  Future<void> saveTokenExpiry(int expiryTimestamp) async {
    await _secureStorage.write(
      key: StorageKeys.tokenExpiry,
      value: expiryTimestamp.toString(),
    );
  }

  /// Save all tokens at once (convenience method)
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiryTimestamp,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
      saveTokenExpiry(expiryTimestamp),
    ]);
  }

  // ==================== READ TOKENS ====================

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: StorageKeys.accessToken);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: StorageKeys.refreshToken);
  }

  /// Get token expiry timestamp
  Future<int?> getTokenExpiry() async {
    final expiryStr = await _secureStorage.read(key: StorageKeys.tokenExpiry);
    if (expiryStr == null) return null;
    return int.tryParse(expiryStr);
  }

  /// Check if access token exists
  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Check if token is expired
  Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch;
    return now >= expiry;
  }

  // ==================== DELETE TOKENS ====================

  /// Delete access token
  Future<void> deleteAccessToken() async {
    await _secureStorage.delete(key: StorageKeys.accessToken);
  }

  /// Delete refresh token
  Future<void> deleteRefreshToken() async {
    await _secureStorage.delete(key: StorageKeys.refreshToken);
  }

  /// Delete token expiry
  Future<void> deleteTokenExpiry() async {
    await _secureStorage.delete(key: StorageKeys.tokenExpiry);
  }

  /// Delete all tokens (logout)
  Future<void> deleteAllTokens() async {
    await Future.wait([
      deleteAccessToken(),
      deleteRefreshToken(),
      deleteTokenExpiry(),
    ]);
  }

  /// Clear ALL secure storage (nuclear option - use with caution)
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}