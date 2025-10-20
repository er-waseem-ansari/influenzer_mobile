part of 'auth_bloc.dart';

/// Base class for all Auth states
abstract class AuthState {
  const AuthState();
}

/// Initial state - App just started
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state - Authentication in progress
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Success state - Authentication successful
class AuthSuccess extends AuthState {
  final TokenResponseModel tokenResponse;
  final UserRole userRole;
  final LoginMethod loginMethod;

  const AuthSuccess({
    required this.tokenResponse,
    required this.userRole,
    required this.loginMethod,
  });
}

/// Failure state - Authentication failed
class AuthFailure extends AuthState {
  final String error;

  const AuthFailure({required this.error});
}

/// Phone OTP Sent - OTP sent successfully
class PhoneOtpSent extends AuthState {
  final String phoneNumber;

  const PhoneOtpSent({required this.phoneNumber});
}

/// Auth Status Checked - Used for checking initial auth state
class AuthStatusChecked extends AuthState {
  final bool isLoggedIn;
  final UserRole? userRole;
  final LoginMethod? loginMethod;

  const AuthStatusChecked({
    required this.isLoggedIn,
    this.userRole,
    this.loginMethod,
  });
}