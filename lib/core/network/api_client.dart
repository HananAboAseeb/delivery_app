import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_interceptors.dart';

/// Single Responsibility: Configures and provides the Dio instance for all HTTP requests.
/// Follows Clean Architecture by abstracting the HTTP client from the repositories.
class ApiClient {
  late final Dio dio;

  // Base URL matching the Swagger specification
  static const String baseUrl = 'https://erp.neosending.com';

  ApiClient({Dio? overrideDio}) {
    dio = overrideDio ?? Dio(_baseOptions());
    _setupInterceptors();
  }

  BaseOptions _baseOptions() {
    return BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
  }

  void _setupInterceptors() {
    // Exact URL Logger for Debugging
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('REQUEST URL: ${options.uri.toString()}');
          return handler.next(options);
        },
      ),
    );

    // 1. Auth & Error handling Interceptor
    dio.interceptors.add(AuthInterceptor());

    // 2. Logging Interceptor (Pretty Dio Logger for debugging)
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ),
    );
  }

  // --- HTTP Methods wrapped for clarity ---

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await dio.put(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) async {
    return await dio.delete(path, data: data);
  }

  /// Debug function to verify if the API is reachable
  Future<bool> checkConnectivity() async {
    try {
      print(
          'Connectivity Check: Pinging https://erp.neosending.com/swagger/index.html');
      final response =
          await dio.get('https://erp.neosending.com/swagger/index.html');
      print('Connectivity Check OK | Status: ${response.statusCode}');
      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 400;
    } catch (e) {
      print('Connectivity Check FAILED | Error: $e');
      return false;
    }
  }
}
