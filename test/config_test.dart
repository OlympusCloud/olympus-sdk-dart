import 'package:olympus_sdk/src/config.dart';
import 'package:test/test.dart';

void main() {
  group('OlympusConfig', () {
    test('production defaults', () {
      const config = OlympusConfig(appId: 'com.test', apiKey: 'oc_key');
      expect(config.appId, 'com.test');
      expect(config.apiKey, 'oc_key');
      expect(config.baseUrl, 'https://api.olympuscloud.ai/api/v1');
      expect(config.environment, OlympusEnvironment.production);
      expect(config.timeout, const Duration(seconds: 30));
    });

    test('sandbox factory', () {
      final config =
          OlympusConfig.sandbox(appId: 'com.test', apiKey: 'oc_sandbox');
      expect(config.baseUrl, 'https://sandbox.api.olympuscloud.ai/api/v1');
      expect(config.environment, OlympusEnvironment.sandbox);
      expect(config.appId, 'com.test');
      expect(config.apiKey, 'oc_sandbox');
    });

    test('dev factory', () {
      final config = OlympusConfig.dev(appId: 'com.dev', apiKey: 'oc_dev');
      expect(config.baseUrl, 'https://dev.api.olympuscloud.ai/api/v1');
      expect(config.environment, OlympusEnvironment.development);
    });

    test('custom base URL', () {
      const config = OlympusConfig(
        appId: 'com.test',
        apiKey: 'key',
        baseUrl: 'https://custom.api.example.com',
      );
      expect(config.baseUrl, 'https://custom.api.example.com');
    });

    test('custom timeout', () {
      const config = OlympusConfig(
        appId: 'com.test',
        apiKey: 'key',
        timeout: Duration(seconds: 60),
      );
      expect(config.timeout, const Duration(seconds: 60));
    });
  });

  group('OlympusEnvironment', () {
    test('has all expected values', () {
      expect(OlympusEnvironment.values, hasLength(4));
      expect(OlympusEnvironment.values, contains(OlympusEnvironment.production));
      expect(OlympusEnvironment.values, contains(OlympusEnvironment.staging));
      expect(
          OlympusEnvironment.values, contains(OlympusEnvironment.development));
      expect(OlympusEnvironment.values, contains(OlympusEnvironment.sandbox));
    });
  });
}
