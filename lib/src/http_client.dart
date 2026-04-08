import 'package:dio/dio.dart';

import 'config.dart';

/// Abstract token store for persisting auth tokens across app restarts.
///
/// Implement this interface using SharedPreferences, FlutterSecureStorage,
/// or any other persistence mechanism.
abstract class TokenStore {
  Future<void> saveTokens({required String accessToken, String? refreshToken});
  Future<({String? accessToken, String? refreshToken})> loadTokens();
  Future<void> clearTokens();
}

/// Default in-memory token store (tokens lost on restart).
class InMemoryTokenStore implements TokenStore {
  String? _accessToken;
  String? _refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    _accessToken = accessToken;
    if (refreshToken != null) _refreshToken = refreshToken;
  }

  @override
  Future<({String? accessToken, String? refreshToken})> loadTokens() async {
    return (accessToken: _accessToken, refreshToken: _refreshToken);
  }

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
  }
}

/// Internal HTTP client with auth interceptor.
/// Every request automatically includes Bearer token and app context headers.
class OlympusHttpClient {
  OlympusHttpClient(this.config) {
    _dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.timeout,
        receiveTimeout: config.timeout,
        headers: {'X-App-Id': config.appId, 'X-SDK-Version': 'dart/0.1.0'},
      ),
    );

    _dio.interceptors.add(_AuthInterceptor(this));
    _dio.interceptors.add(_RefreshInterceptor(this));
    _dio.interceptors.add(_ErrorInterceptor());
  }

  final OlympusConfig config;
  late final Dio _dio;

  /// Token store for persisting auth tokens.
  TokenStore _tokenStore = InMemoryTokenStore();

  /// Access token set after login (overrides API key for user-scoped requests).
  String? _accessToken;
  String? _refreshToken;
  bool _isRefreshing = false;

  /// Set a custom token store for persistence (e.g., SharedPreferences).
  void setTokenStore(TokenStore store) => _tokenStore = store;

  void setAccessToken(String token) {
    _accessToken = token;
    _tokenStore.saveTokens(accessToken: token, refreshToken: _refreshToken);
  }

  void setRefreshToken(String token) {
    _refreshToken = token;
    if (_accessToken != null) {
      _tokenStore.saveTokens(accessToken: _accessToken!, refreshToken: token);
    }
  }

  void setTokens({required String accessToken, required String refreshToken}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _tokenStore.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  void clearAccessToken() {
    _accessToken = null;
    _refreshToken = null;
    _tokenStore.clearTokens();
  }

  /// Load persisted tokens on startup.
  Future<void> restoreTokens() async {
    final tokens = await _tokenStore.loadTokens();
    _accessToken = tokens.accessToken;
    _refreshToken = tokens.refreshToken;
  }

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

  Future<Map<String, dynamic>> put(String path, {Object? data}) async {
    final response = await _dio.put<Map<String, dynamic>>(path, data: data);
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> patch(String path, {Object? data}) async {
    final response = await _dio.patch<Map<String, dynamic>>(path, data: data);
    return response.data ?? {};
  }

  Future<void> delete(String path) async {
    await _dio.delete<void>(path);
  }

  /// GET request that returns a JSON array (instead of an object).
  ///
  /// Most endpoints return a JSON object, but a handful (e.g.
  /// `GET /vision/cameras`, `GET /vision/surveillance/events`) return a
  /// top-level array. Use this helper for those cases.
  Future<List<dynamic>> getList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      path,
      queryParameters: queryParameters,
    );
    return response.data ?? const [];
  }

  /// Upload raw image/file bytes as a `multipart/form-data` POST.
  ///
  /// The bytes are sent as the `file` field — matching FastAPI's
  /// `UploadFile = File(...)` parameter convention used by Vision and
  /// other ingestion endpoints. Returns the decoded JSON response.
  Future<Map<String, dynamic>> uploadBytes(
    String path, {
    required List<int> bytes,
    required String filename,
    String contentType = 'application/octet-stream',
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? extraFields,
  }) async {
    final formData = FormData.fromMap({
      ...?extraFields,
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: DioMediaType.parse(contentType),
      ),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: formData,
      queryParameters: queryParameters,
      options: Options(contentType: 'multipart/form-data'),
    );
    return response.data ?? {};
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

/// Intercepts 401 responses and attempts token refresh before failing.
class _RefreshInterceptor extends Interceptor {
  _RefreshInterceptor(this._client);
  final OlympusHttpClient _client;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401 ||
        _client._isRefreshing ||
        _client._refreshToken == null ||
        err.requestOptions.path == '/auth/refresh' ||
        err.requestOptions.path == '/auth/login') {
      handler.next(err);
      return;
    }

    _client._isRefreshing = true;
    try {
      final response = await _client._dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': _client._refreshToken},
      );
      final data = response.data;
      final newAccess = data?['access_token'] as String?;
      final newRefresh = data?['refresh_token'] as String?;

      if (newAccess == null) {
        _client.clearAccessToken();
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const OlympusAuthExpiredError(),
          ),
        );
        return;
      }

      _client.setTokens(
        accessToken: newAccess,
        refreshToken: newRefresh ?? _client._refreshToken!,
      );

      // Retry original request with new token
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newAccess';
      final retryResponse = await _client._dio.fetch<dynamic>(opts);
      handler.resolve(retryResponse);
    } on DioException {
      _client.clearAccessToken();
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const OlympusAuthExpiredError(),
        ),
      );
    } finally {
      _client._isRefreshing = false;
    }
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final data = err.response?.data;
    if (data is Map<String, dynamic>) {
      final error = data['error'] as Map<String, dynamic>?;
      if (error != null) {
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            type: err.type,
            error: OlympusApiError(
              code: error['code'] as String? ?? 'UNKNOWN',
              message: error['message'] as String? ?? 'Unknown error',
              requestId: error['request_id'] as String?,
              statusCode: err.response?.statusCode ?? 0,
            ),
          ),
        );
        return;
      }
    }
    handler.next(err);
  }
}

/// Thrown when the session has expired and refresh failed.
/// Apps should redirect to login when catching this.
class OlympusAuthExpiredError implements Exception {
  const OlympusAuthExpiredError();

  @override
  String toString() =>
      'OlympusAuthExpiredError: Session expired, please log in again';
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
