import 'package:dio/dio.dart';
import 'package:olympus_sdk/src/config.dart';
import 'package:olympus_sdk/src/http_client.dart';
import 'package:test/test.dart';

void main() {
  group('OlympusHttpClient', () {
    late OlympusHttpClient client;

    setUp(() {
      client = OlympusHttpClient(
        const OlympusConfig(appId: 'com.test', apiKey: 'oc_test_key'),
      );
    });

    test('sets base URL from config', () {
      expect(client.dio.options.baseUrl, 'https://api.olympuscloud.ai/api/v1');
    });

    test('sets X-App-Id header', () {
      expect(client.dio.options.headers['X-App-Id'], 'com.test');
    });

    test('sets X-SDK-Version header', () {
      expect(client.dio.options.headers['X-SDK-Version'], 'dart/0.1.0');
    });

    test('sets connect and receive timeout', () {
      expect(client.dio.options.connectTimeout, const Duration(seconds: 30));
      expect(client.dio.options.receiveTimeout, const Duration(seconds: 30));
    });

    test('has 2 interceptors (auth + error)', () {
      // Dio always has LogInterceptor-like internal ones, but we added 2
      expect(client.dio.interceptors.length, greaterThanOrEqualTo(2));
    });

    test('setAccessToken and clearAccessToken work', () {
      // Before setting token, API key is used (verified via interceptor)
      client.setAccessToken('jwt_token_123');
      // After setting, the token should be used by interceptor
      // We test this indirectly via the interceptor test below
      client.clearAccessToken();
      // After clearing, API key should be used again
    });

    test('config is accessible', () {
      expect(client.config.appId, 'com.test');
      expect(client.config.apiKey, 'oc_test_key');
    });
  });

  group('Auth interceptor', () {
    test('uses API key when no access token set', () async {
      final client = OlympusHttpClient(
        const OlympusConfig(
          appId: 'com.test',
          apiKey: 'oc_api_key_abc',
          baseUrl: 'https://httpbin.org', // won't actually call
        ),
      );

      // Add test interceptor AFTER auth interceptor (at end) to capture headers
      String? capturedAuthHeader;
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedAuthHeader = options.headers['Authorization'] as String?;
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.cancel,
              ),
            );
          },
        ),
      );

      try {
        await client.get('/test');
      } catch (_) {}

      expect(capturedAuthHeader, 'Bearer oc_api_key_abc');
    });

    test('uses access token when set', () async {
      final client = OlympusHttpClient(
        const OlympusConfig(
          appId: 'com.test',
          apiKey: 'oc_api_key_abc',
          baseUrl: 'https://httpbin.org',
        ),
      );

      client.setAccessToken('jwt_user_token_xyz');

      String? capturedAuthHeader;
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedAuthHeader = options.headers['Authorization'] as String?;
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.cancel,
              ),
            );
          },
        ),
      );

      try {
        await client.get('/test');
      } catch (_) {}

      expect(capturedAuthHeader, 'Bearer jwt_user_token_xyz');
    });

    test('reverts to API key after clearAccessToken', () async {
      final client = OlympusHttpClient(
        const OlympusConfig(
          appId: 'com.test',
          apiKey: 'oc_api_key_abc',
          baseUrl: 'https://httpbin.org',
        ),
      );

      client.setAccessToken('jwt_token');
      client.clearAccessToken();

      String? capturedAuthHeader;
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedAuthHeader = options.headers['Authorization'] as String?;
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.cancel,
              ),
            );
          },
        ),
      );

      try {
        await client.get('/test');
      } catch (_) {}

      expect(capturedAuthHeader, 'Bearer oc_api_key_abc');
    });
  });

  group('OlympusApiError', () {
    test('toString includes all fields', () {
      const error = OlympusApiError(
        code: 'UNAUTHORIZED',
        message: 'Invalid token',
        requestId: 'req-123',
        statusCode: 401,
      );
      expect(
        error.toString(),
        'OlympusApiError(UNAUTHORIZED): Invalid token [status=401, reqId=req-123]',
      );
    });

    test('default statusCode is 0', () {
      const error = OlympusApiError(code: 'ERR', message: 'msg');
      expect(error.statusCode, 0);
      expect(error.requestId, isNull);
    });

    test('implements Exception', () {
      const error = OlympusApiError(code: 'ERR', message: 'msg');
      expect(error, isA<Exception>());
    });
  });
}
