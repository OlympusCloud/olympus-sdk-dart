import 'package:dio/dio.dart';

import 'config.dart';

/// Internal HTTP client with auth interceptor.
/// Every request automatically includes Bearer token and app context headers.
class OlympusHttpClient {
  OlympusHttpClient(this.config) {
    _dio = Dio(BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.timeout,
      receiveTimeout: config.timeout,
      headers: {
        'X-App-Id': config.appId,
        'X-SDK-Version': 'dart/0.1.0',
      },
    ));

    _dio.interceptors.add(_AuthInterceptor(this));
    _dio.interceptors.add(_ErrorInterceptor());
  }

  final OlympusConfig config;
  late final Dio _dio;

  /// Access token set after login (overrides API key for user-scoped requests).
  String? _accessToken;

  void setAccessToken(String token) => _accessToken = token;
  void clearAccessToken() => _accessToken = null;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Object? data,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(path, data: data);
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Object? data,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(path, data: data);
    return response.data ?? {};
  }

  Future<void> delete(String path) async {
    await _dio.delete<void>(path);
  }

  /// Raw Dio access for streaming responses.
  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._client);
  final OlympusHttpClient _client;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Use access token if available (user-scoped), otherwise API key
    final token = _client._accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      options.headers['Authorization'] = 'Bearer ${_client.config.apiKey}';
    }
    handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final data = err.response?.data;
    if (data is Map<String, dynamic>) {
      final error = data['error'] as Map<String, dynamic>?;
      if (error != null) {
        handler.reject(DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: err.type,
          error: OlympusApiError(
            code: error['code'] as String? ?? 'UNKNOWN',
            message: error['message'] as String? ?? 'Unknown error',
            requestId: error['request_id'] as String?,
            statusCode: err.response?.statusCode ?? 0,
          ),
        ));
        return;
      }
    }
    handler.next(err);
  }
}

/// Structured API error from Olympus Cloud.
class OlympusApiError implements Exception {
  const OlympusApiError({
    required this.code,
    required this.message,
    this.requestId,
    this.statusCode = 0,
  });

  final String code;
  final String message;
  final String? requestId;
  final int statusCode;

  @override
  String toString() =>
      'OlympusApiError($code): $message [status=$statusCode, reqId=$requestId]';
}
