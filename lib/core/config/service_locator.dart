import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:influenzer_mobile/data/data_sources/remote/auth/firebase_auth_service.dart';
import 'package:influenzer_mobile/data/data_sources/remote/auth/google_appauth_service.dart';
import 'package:influenzer_mobile/data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:influenzer_mobile/core/network/dio_client.dart';
import 'package:influenzer_mobile/data/data_sources/local/token_storage_service.dart';
import 'package:influenzer_mobile/data/data_sources/local/user_local_service.dart';
import 'package:influenzer_mobile/data/data_sources/remote/backend/auth_backend_service.dart';

/// Service Locator (Dependency Injection)
///
/// Centralizes all service initialization and dependency management
/// Call setupServiceLocator() in main() before runApp()
final getIt = GetIt.instance;

/// Setup all services and dependencies
///
/// Call this in main() with: await setupServiceLocator();
Future<void> setupServiceLocator() async {
  // ==================== LOCAL STORAGE ====================

  /// Register secure storage (for tokens)
  const secureStorage = FlutterSecureStorage();
  getIt.registerSingleton<FlutterSecureStorage>(secureStorage);

  /// Register shared preferences (for user data)
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPrefs);

  // ==================== LOCAL SERVICES ====================

  /// Register token storage service
  getIt.registerSingleton<TokenStorageService>(
    TokenStorageService(getIt<FlutterSecureStorage>()),
  );

  /// Register user local service
  getIt.registerSingleton<UserLocalService>(
    UserLocalService(getIt<SharedPreferences>()),
  );

  // ==================== HTTP CLIENT ====================

  /// Register Dio client (HTTP requests)
  getIt.registerSingleton<DioClient>(
    DioClient(getIt<TokenStorageService>()),
  );

  // ==================== REMOTE SERVICES ====================

  /// Register Firebase auth service (phone OTP)
  getIt.registerSingleton<FirebaseAuthService>(
    FirebaseAuthServiceImpl(),
  );

  /// Register Google AppAuth service (Google OAuth2)
  getIt.registerSingleton<GoogleAppAuthService>(
    GoogleAppAuthServiceImpl(),
  );

  /// Register backend auth service (API calls)
  getIt.registerSingleton<AuthBackendService>(
    AuthBackendServiceImpl(getIt<DioClient>()),
  );

  // ==================== REPOSITORIES ====================

  /// Register auth repository
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      googleAppAuth: getIt<GoogleAppAuthService>(),
      firebaseAuth: getIt<FirebaseAuthService>(),
      authBackend: getIt<AuthBackendService>(),
      tokenStorage: getIt<TokenStorageService>(),
      userLocal: getIt<UserLocalService>(),
    ),
  );

  print('✅ Service Locator initialized');
}