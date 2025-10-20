part of 'auth_bloc.dart';

/// Base class for all Auth events
abstract class AuthEvent {
  const AuthEvent();
}

/// Google Sign In Event
class GoogleSignInEvent extends AuthEvent {
  final UserRole userRole;
  final String? deviceInfo;

  const GoogleSignInEvent({
    required this.userRole,
    this.deviceInfo,
  });
}

/// Request Phone OTP Event
class RequestPhoneOtpEvent extends AuthEvent {
  final String phoneNumber;

  const RequestPhoneOtpEvent({
    required this.phoneNumber,
  });
}

/// Verify Phone OTP Event
class VerifyPhoneOtpEvent extends AuthEvent {
  final String otp;
  final UserRole userRole;
  final String? deviceInfo;

  const VerifyPhoneOtpEvent({
    required this.otp,
    required this.userRole,
    this.deviceInfo,
  });
}

/// Refresh Token Event
class RefreshTokenEvent extends AuthEvent {
  const RefreshTokenEvent();
}

/// Logout Event
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

/// Check Auth Status Event
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}