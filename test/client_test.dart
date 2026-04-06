import 'package:olympus_sdk/olympus_sdk.dart';
import 'package:test/test.dart';

void main() {
  group('OlympusClient', () {
    test('constructor sets config', () {
      final client = OlympusClient(appId: 'com.test', apiKey: 'oc_key');
      expect(client.config.appId, 'com.test');
      expect(client.config.apiKey, 'oc_key');
      expect(client.config.environment, OlympusEnvironment.production);
    });

    test('fromConfig constructor', () {
      final config = OlympusConfig.sandbox(appId: 'com.sb', apiKey: 'oc_sb');
      final client = OlympusClient.fromConfig(config);
      expect(client.config.environment, OlympusEnvironment.sandbox);
      expect(client.config.appId, 'com.sb');
    });

    test('service accessors return same instance on repeat access', () {
      final client = OlympusClient(appId: 'com.test', apiKey: 'key');
      final auth1 = client.auth;
      final auth2 = client.auth;
      expect(identical(auth1, auth2), isTrue);
    });

    test('all 13 services are accessible', () {
      final client = OlympusClient(appId: 'com.test', apiKey: 'key');
      expect(client.auth, isA<OlympusAuthService>());
      expect(client.commerce, isA<OlympusCommerceService>());
      expect(client.ai, isA<OlympusAiService>());
      expect(client.pay, isA<OlympusPayService>());
      expect(client.notify, isA<OlympusNotifyService>());
      expect(client.events, isA<OlympusEventsService>());
      expect(client.data, isA<OlympusDataService>());
      expect(client.storage, isA<OlympusStorageService>());
      expect(client.marketplace, isA<OlympusMarketplaceService>());
      expect(client.billing, isA<OlympusBillingService>());
      expect(client.gating, isA<OlympusGatingService>());
      expect(client.devices, isA<OlympusDevicesService>());
      expect(client.observe, isA<OlympusObserveService>());
    });

    test('httpClient is accessible', () {
      final client = OlympusClient(appId: 'com.test', apiKey: 'key');
      expect(client.httpClient, isNotNull);
      expect(client.httpClient.config.appId, 'com.test');
    });

    test('different services are different instances', () {
      final client = OlympusClient(appId: 'com.test', apiKey: 'key');
      expect(identical(client.auth, client.commerce), isFalse);
    });
  });
}
