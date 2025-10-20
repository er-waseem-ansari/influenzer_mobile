import 'package:dio/dio.dart';
import 'package:influenzer_mobile/core/network/dio_client.dart';
import 'package:influenzer_mobile/core/constants/api_constants.dart';
import 'package:influenzer_mobile/data/models/auth/google_auth_request_model.dart';
import 'package:influenzer_mobile/data/models/auth/phone_auth_request_model.dart';
import 'package:influenzer_mobile/data/models/auth/token_refresh_request_model.dart';
import 'package:influenzer_mobile/data/models/auth/token_response_model.dart';
import 'package:influenzer_mobile/core/constants/app_constants.dart';

/// Service for backend authentication API calls
///
/// Communicates with FastAPI backend to verify tokens and get JWT tokens
abstract class AuthBackendService {
  Future<TokenResponseModel> googleAuth({
    required String idToken,
    required UserRole userRole,
    String? deviceInfo,
  });

  Future<TokenResponseModel> phoneAuth({
    required String idToken,
    required UserRole userRole,
    String? deviceInfo,
  });

  Future<TokenResponseModel> refreshToken({
    required String refreshToken,
  });
}

class AuthBackendServiceImpl implements AuthBackendService {
  final DioClient _dioClient;

  AuthBackendServiceImpl(this._dioClient);

  /// Send Google ID token to backend for verification
  ///
  /// Backend verifies token with Google Cloud and returns JWT tokens
  @override
  Future<TokenResponseModel> googleAuth({
    required String idToken,
    required UserRole userRole,
    String? deviceInfo,
  }) async {
    try {
      // Create request model
      final request = GoogleAuthRequestModel.create(
        idToken: idToken,
        userRole: userRole,
        deviceInfo: deviceInfo,
      );

      // Send POST request to backend
      final response = await _dioClient.dio.post(
        ApiConstants.getEndpoint(ApiConstants.authGoogle),
        data: request.toJson(),
      );

      // Parse response
      if (response.statusCode == ApiConstants.statusOk ||
          response.statusCode == ApiConstants.statusCreated) {
        final tokenResponse = TokenResponseModel.fromJson(response.data);
        return tokenResponse;
      } else {
        throw Exception('Google auth failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'Google authentication');
    } catch (e) {
      throw Exception('Google auth failed: ${e.toString()}');
    }
  }

  /// Send Firebase phone ID token to backend for verification
  ///
  /// Backend verifies token with Firebase Admin and returns JWT tokens
  @override
  Future<TokenResponseModel> phoneAuth({
    required String idToken,
    required UserRole userRole,
    String? deviceInfo,
  }) async {
    try {
      // Create request model
      final request = PhoneAuthRequestModel.create(
        idToken: idToken,
        userRole: userRole,
        deviceInfo: deviceInfo,
      );

      // Send POST request to backend
      final response = await _dioClient.dio.post(
        ApiConstants.getEndpoint(ApiConstants.authPhone),
        data: request.toJson(),
      );

      // Parse response
      if (response.statusCode == ApiConstants.statusOk ||
          response.statusCode == ApiConstants.statusCreated) {
        final tokenResponse = TokenResponseModel.fromJson(response.data);
        return tokenResponse;
      } else {
        throw Exception('Phone auth failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'Phone authentication');
    } catch (e) {
      throw Exception('Phone auth failed: ${e.toString()}');
    }
  }

  /// Refresh access token using refresh token
  ///
  /// Sent to: POST /auth/refresh
  @override
  Future<TokenResponseModel> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final request = TokenRefreshRequestModel(
        refreshToken: refreshToken,
      );

      final response = await _dioClient.dio.post(
        ApiConstants.getEndpoint(ApiConstants.authRefresh),
        data: request.toJson(),
      );

      if (response.statusCode == ApiConstants.statusOk ||
          response.statusCode == ApiConstants.statusCreated) {
        final tokenResponse = TokenResponseModel.fromJson(response.data);
        return tokenResponse;
      } else {
        throw Exception('Token refresh failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'Token refresh');
    } catch (e) {
      throw Exception('Token refresh failed: ${e.toString()}');
    }
  }

  /// Handle Dio exceptions with detailed error messages
  Exception _handleDioException(DioException e, String operation) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('$operation: Connection timeout');
      case DioExceptionType.sendTimeout:
        return Exception('$operation: Send timeout');
      case DioExceptionType.receiveTimeout:
        return Exception('$operation: Receive timeout');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final errorData = e.response?.data;
        return Exception('$operation: Server error ($statusCode) - $errorData');
      case DioExceptionType.cancel:
        return Exception('$operation: Request cancelled');
      case DioExceptionType.unknown:
        return Exception('$operation: ${e.error}');
      default:
        return Exception('$operation: Unknown error');
    }
  }
}