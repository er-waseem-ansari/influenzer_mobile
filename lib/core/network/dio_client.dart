import 'package:dio/dio.dart';
import 'package:influenzer_mobile/data/data_sources/local/token_storage_service.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';
/// Dio HTTP client configuration
///
/// Handles all API requests with:
/// - Base URL configuration
/// - Token injection
/// - Auto token refresh
/// - Request/response logging
class DioClient {
  final TokenStorageService _tokenStorage;
  late final Dio _dio;

  DioClient(this._tokenStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.apiBasePath,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        },
      ),
    );

    _addInterceptors();
  }

  /// Get the Dio instance
  Dio get dio => _dio;

  /// Add interceptors for token injection and logging
  void _addInterceptors() {
    _dio.interceptors.addAll([
      // Token injection interceptor
      _tokenInterceptor(),

      // Pretty logger (only in development)
      if (ApiConstants.isDevelopment)
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          compact: true,
        ),
    ]);
  }

  /// Interceptor to inject access token in requests
  Interceptor _tokenInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Get access token
        final token = await _tokenStorage.getAccessToken();

        // Add Bearer token to headers if exists
        if (token != null) {
          options.headers[ApiConstants.headerAuthorization] =
              ApiConstants.getBearerToken(token);
        }

        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 Unauthorized - token expired
        if (error.response?.statusCode == ApiConstants.statusUnauthorized) {
          // TODO: Implement auto token refresh here later
          // For now, just pass the error
        }

        handler.next(error);
      },
    );
  }
}