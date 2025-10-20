import 'package:firebase_auth/firebase_auth.dart';
import 'package:influenzer_mobile/core/constants/app_constants.dart';
import 'package:influenzer_mobile/data/data_sources/local/token_storage_service.dart';
import 'package:influenzer_mobile/data/data_sources/local/user_local_service.dart';
import 'package:influenzer_mobile/data/data_sources/remote/auth/firebase_auth_service.dart';
import 'package:influenzer_mobile/data/data_sources/remote/auth/google_appauth_service.dart';
import 'package:influenzer_mobile/data/data_sources/remote/backend/auth_backend_service.dart';
import 'package:influenzer_mobile/data/models/auth/token_response_model.dart';

/// Authentication Repository
///
/// Orchestrates all auth services (Firebase, Google AppAuth, Backend)
/// Provides a single interface for authentication operations
abstract class AuthRepository {
  Future<TokenResponseModel> googleSignIn({
    required UserRole userRole,
    String? deviceInfo,
  });

  Future<void> requestPhoneOtp({
    required String phoneNumber,
  });

  Future<TokenResponseModel> verifyPhoneOtp({
    required String otp,
    required UserRole userRole,
    String? deviceInfo,
  });

  Future<TokenResponseModel> refreshAccessToken();

  Future<void> logout();

  bool isLoggedIn();
}

class AuthRepositoryImpl implements AuthRepository {
  final GoogleAppAuthService _googleAppAuth;
  final FirebaseAuthService _firebaseAuth;
  final AuthBackendService _authBackend;
  final TokenStorageService _tokenStorage;
  final UserLocalService _userLocal;

  AuthRepositoryImpl({
    required GoogleAppAuthService googleAppAuth,
    required FirebaseAuthService firebaseAuth,
    required AuthBackendService authBackend,
    required TokenStorageService tokenStorage,
    required UserLocalService userLocal,
  })  : _googleAppAuth = googleAppAuth,
        _firebaseAuth = firebaseAuth,
        _authBackend = authBackend,
        _tokenStorage = tokenStorage,
        _userLocal = userLocal;

  /// Google OAuth2 Sign In Flow
  ///
  /// 1. Get ID token from Google via flutter_appauth
  /// 2. Send ID token to backend for verification
  /// 3. Backend verifies with Google Cloud
  /// 4. Backend returns JWT tokens
  /// 5. Store tokens locally
  @override
  Future<TokenResponseModel> googleSignIn({
    required UserRole userRole,
    String? deviceInfo,
  }) async {
    try {
      // 1. Get Google ID token
      final googleIdToken = await _googleAppAuth.signInWithGoogle();

      // 2. Send to backend for verification
      final tokenResponse = await _authBackend.googleAuth(
        idToken: googleIdToken,
        userRole: userRole,
        deviceInfo: deviceInfo,
      );

      // 3. Store tokens and user data
      await _storeAuthData(tokenResponse, userRole, LoginMethod.google);

      return tokenResponse;
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  /// Phone OTP Request Flow
  ///
  /// 1. Send phone number to Firebase
  /// 2. Firebase sends OTP to user's phone
  @override
  Future<void> requestPhoneOtp({
    required String phoneNumber,
  }) async {
    try {
      // Store phone number temporarily for later use
      await _userLocal.saveUserPhone(phoneNumber);

      // Request OTP from Firebase
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onVerificationCompleted: (PhoneAuthCredential credential) {
          // Auto-retrieval on Android (optional)
        },
        onVerificationFailed: (FirebaseAuthException e) {
          throw Exception('Phone verification failed: ${e.message}');
        },
        onCodeSent: (String verificationId, int? resendToken) {
          // Store verification ID for later use
          _storeVerificationId(verificationId);
        },
        onCodeAutoRetrievalTimeout: (String verificationId) {
          _storeVerificationId(verificationId);
        },
      );
    } catch (e) {
      throw Exception('Failed to request phone OTP: ${e.toString()}');
    }
  }

  /// Phone OTP Verification Flow
  ///
  /// 1. Create Firebase credential from OTP code
  /// 2. Sign in with Firebase to get ID token
  /// 3. Send ID token to backend for verification
  /// 4. Backend verifies with Firebase Admin
  /// 5. Backend returns JWT tokens
  /// 6. Store tokens locally
  @override
  Future<TokenResponseModel> verifyPhoneOtp({
    required String otp,
    required UserRole userRole,
    String? deviceInfo,
  }) async {
    try {
      // 1. Get stored verification ID
      final verificationId = _getStoredVerificationId();
      if (verificationId == null) {
        throw Exception('Verification ID not found. Request OTP first.');
      }

      // 2. Create Firebase credential
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      // 3. Sign in with Firebase to get ID token
      final firebaseIdToken = await _firebaseAuth.signInWithPhone(credential);

      // 4. Send to backend for verification
      final tokenResponse = await _authBackend.phoneAuth(
        idToken: firebaseIdToken,
        userRole: userRole,
        deviceInfo: deviceInfo,
      );

      // 5. Store tokens and user data
      await _storeAuthData(tokenResponse, userRole, LoginMethod.phone);

      // 6. Clear stored verification ID
      _clearStoredVerificationId();

      return tokenResponse;
    } catch (e) {
      throw Exception('Phone OTP verification failed: ${e.toString()}');
    }
  }

  /// Refresh access token using refresh token
  @override
  Future<TokenResponseModel> refreshAccessToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();

      if (refreshToken == null) {
        throw Exception('Refresh token not found');
      }

      final tokenResponse = await _authBackend.refreshToken(
        refreshToken: refreshToken,
      );

      // Update stored tokens
      await _tokenStorage.saveTokens(
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
        expiryTimestamp: tokenResponse.expiryTimestamp,
      );

      return tokenResponse;
    } catch (e) {
      throw Exception('Token refresh failed: ${e.toString()}');
    }
  }

  /// Logout - Clear all auth data
  @override
  Future<void> logout() async {
    try {
      await Future.wait([
        _tokenStorage.deleteAllTokens(),
        _userLocal.clearUserData(),
        _firebaseAuth.signOut(),
      ]);
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  /// Check if user is logged in
  @override
  bool isLoggedIn() {
    return _userLocal.isLoggedIn();
  }

  // ==================== PRIVATE HELPERS ====================

  /// Store tokens and user data after successful auth
  Future<void> _storeAuthData(
      TokenResponseModel tokenResponse,
      UserRole userRole,
      LoginMethod loginMethod,
      ) async {
    await Future.wait([
      // Store tokens in secure storage
      _tokenStorage.saveTokens(
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
        expiryTimestamp: tokenResponse.expiryTimestamp,
      ),
      // Store user data
      _userLocal.saveUserRole(userRole),
      _userLocal.saveLoginMethod(loginMethod),
      _userLocal.setLoggedIn(true),
    ]);
  }

  /// Store Firebase verification ID in memory (not persistent)
  String? _verificationIdInMemory;

  void _storeVerificationId(String verificationId) {
    _verificationIdInMemory = verificationId;
  }

  String? _getStoredVerificationId() {
    return _verificationIdInMemory;
  }

  void _clearStoredVerificationId() {
    _verificationIdInMemory = null;
  }
}