/// API configuration constants
///
/// Contains all API endpoints, headers, and configuration values.
/// Centralizes API-related constants for easy maintenance.
class ApiConstants {
  // Private constructor to prevent instantiation
  ApiConstants._();

  // ==================== BASE URLs ====================

  /// Development base URL (your local backend)
  /// TODO: Update the port number to match your backend
  static const String baseUrlDev = 'http://10.0.2.2:8000'; // Android emulator localhost
  // static const String baseUrlDev = 'http://localhost:8000'; // iOS simulator or web

  /// Production base URL
  /// TODO: Update this when you deploy your backend
  static const String baseUrlProd = 'https://your-api.com';

  /// Current environment flag
  /// Set to false when deploying to production
  static const bool isDevelopment = true;

  /// Get the appropriate base URL based on environment
  static String get baseUrl => isDevelopment ? baseUrlDev : baseUrlProd;

  // ==================== API VERSION ====================

  /// API version prefix (from your FastAPI router)
  static const String apiVersion = '/api/v1';

  /// Full API base path
  static String get apiBasePath => '$baseUrl$apiVersion';

  // ==================== AUTH ENDPOINTS ====================

  /// Phone OTP authentication endpoint
  /// POST /api/v1/auth/phone
  static const String authPhone = '/auth/phone';

  /// Google authentication endpoint
  /// POST /api/v1/auth/google
  static const String authGoogle = '/auth/google';

  /// Token refresh endpoint
  /// POST /api/v1/auth/refresh
  static const String authRefresh = '/auth/refresh';

  /// Helper method to get full endpoint URL
  static String getEndpoint(String endpoint) {
    return '$apiBasePath$endpoint';
  }

  // ==================== HTTP HEADERS ====================

  /// Content-Type header key
  static const String headerContentType = 'Content-Type';

  /// Authorization header key
  static const String headerAuthorization = 'Authorization';

  /// Content-Type JSON value
  static const String contentTypeJson = 'application/json';

  /// Bearer token prefix
  static const String bearer = 'Bearer';

  /// Helper to create Bearer token header value
  static String getBearerToken(String token) => '$bearer $token';

  // ==================== TIMEOUTS ====================

  /// Connection timeout duration
  static const Duration connectionTimeout = Duration(seconds: 30);

  /// Receive timeout duration
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Send timeout duration
  static const Duration sendTimeout = Duration(seconds: 30);

  // ==================== STATUS CODES ====================

  /// Success status codes
  static const int statusOk = 200;
  static const int statusCreated = 201;

  /// Client error status codes
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;

  /// Server error status codes
  static const int statusInternalServerError = 500;
  static const int statusServiceUnavailable = 503;
}