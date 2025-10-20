import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:influenzer_mobile/core/constants/app_constants.dart';
import 'package:influenzer_mobile/data/data_sources/local/user_local_service.dart';
import 'package:influenzer_mobile/data/models/auth/token_response_model.dart';
import 'package:influenzer_mobile/data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Authentication BLoC
///
/// Manages all authentication flows and state
/// Events: Sign in, OTP verification, logout, etc.
/// States: Loading, Success, Failure, Initial
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final UserLocalService _userLocal;

  AuthBloc({
    required AuthRepository authRepository,
    required UserLocalService userLocal,
  })  : _authRepository = authRepository,
        _userLocal = userLocal,
        super(const AuthInitial()) {
    // Register event handlers
    on<GoogleSignInEvent>(_onGoogleSignIn);
    on<RequestPhoneOtpEvent>(_onRequestPhoneOtp);
    on<VerifyPhoneOtpEvent>(_onVerifyPhoneOtp);
    on<RefreshTokenEvent>(_onRefreshToken);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  // ==================== EVENT HANDLERS ====================

  /// Handle Google Sign In
  Future<void> _onGoogleSignIn(
      GoogleSignInEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    try {
      final tokenResponse = await _authRepository.googleSignIn(
        userRole: event.userRole,
        deviceInfo: event.deviceInfo,
      );

      emit(AuthSuccess(
        tokenResponse: tokenResponse,
        userRole: event.userRole,
        loginMethod: LoginMethod.google,
      ));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  /// Handle Phone OTP Request
  Future<void> _onRequestPhoneOtp(
      RequestPhoneOtpEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.requestPhoneOtp(
        phoneNumber: event.phoneNumber,
      );

      emit(PhoneOtpSent(phoneNumber: event.phoneNumber));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  /// Handle Phone OTP Verification
  Future<void> _onVerifyPhoneOtp(
      VerifyPhoneOtpEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    try {
      final tokenResponse = await _authRepository.verifyPhoneOtp(
        otp: event.otp,
        userRole: event.userRole,
        deviceInfo: event.deviceInfo,
      );

      emit(AuthSuccess(
        tokenResponse: tokenResponse,
        userRole: event.userRole,
        loginMethod: LoginMethod.phone,
      ));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  /// Handle Token Refresh
  Future<void> _onRefreshToken(
      RefreshTokenEvent event,
      Emitter<AuthState> emit,
      ) async {
    try {
      final tokenResponse = await _authRepository.refreshAccessToken();

      // Get current user role
      final userRole = _userLocal.getUserRole();
      final loginMethod = _userLocal.getLoginMethod();

      emit(AuthSuccess(
        tokenResponse: tokenResponse,
        userRole: userRole ?? UserRole.brand,
        loginMethod: loginMethod ?? LoginMethod.google,
      ));
    } catch (e) {
      // If refresh fails, logout
      emit(const AuthFailure(error: 'Session expired. Please login again.'));
    }
  }

  /// Handle Logout
  Future<void> _onLogout(
      LogoutEvent event,
      Emitter<AuthState> emit,
      ) async {
    try {
      await _authRepository.logout();
      emit(const AuthInitial());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  /// Check current auth status
  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event,
      Emitter<AuthState> emit,
      ) async {
    try {
      final isLoggedIn = _authRepository.isLoggedIn();

      if (isLoggedIn) {
        final userRole = _userLocal.getUserRole();
        final loginMethod = _userLocal.getLoginMethod();

        emit(AuthStatusChecked(
          isLoggedIn: true,
          userRole: userRole,
          loginMethod: loginMethod,
        ));
      } else {
        emit(const AuthStatusChecked(isLoggedIn: false));
      }
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }
}