import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Single Responsibility: Handles injecting the Bearer token into requests
/// and intercepting 401/403 errors globally.
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Storage key for the token
  static const String tokenKey = 'access_token';

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Read the token from secure storage
    final token = await _storage.read(key: tokenKey);

    // If token exists, add it to the Authorization header
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Continue the request
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Global error handling for unauthenticated requests
    if (err.response?.statusCode == 401) {
      // Trigger logout or token refresh logic here
      // For example: emit a stream event that the AppBloc listens to
      print('HTTP 401: Unauthorized. Token may be expired.');
    } else if (err.response?.statusCode == 403) {
      print('HTTP 403: Forbidden.');
    }

    // Continue propagating the error to the repository caller
    return handler.next(err);
  }
}
