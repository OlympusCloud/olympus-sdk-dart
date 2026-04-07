/// Configuration for the Olympus Cloud SDK.
class OlympusConfig {
  const OlympusConfig({
    required this.appId,
    required this.apiKey,
    this.baseUrl = 'https://api.olympuscloud.ai/api/v1',
    this.timeout = const Duration(seconds: 30),
    this.environment = OlympusEnvironment.production,
  });

  /// Your app's unique identifier (e.g., 'com.restaurant-revolution').
  final String appId;

  /// API key for authentication.
  final String apiKey;

  /// Base URL for the Olympus Cloud API.
  final String baseUrl;

  /// Request timeout.
  final Duration timeout;

  /// Environment (production, staging, sandbox).
  final OlympusEnvironment environment;

  /// Create a sandbox config for testing.
  factory OlympusConfig.sandbox({
    required String appId,
    required String apiKey,
  }) => OlympusConfig(
    appId: appId,
    apiKey: apiKey,
    baseUrl: 'https://sandbox.api.olympuscloud.ai/api/v1',
    environment: OlympusEnvironment.sandbox,
  );

  /// Create a dev config.
  factory OlympusConfig.dev({required String appId, required String apiKey}) =>
      OlympusConfig(
        appId: appId,
        apiKey: apiKey,
        baseUrl: 'https://dev.api.olympuscloud.ai/api/v1',
        environment: OlympusEnvironment.development,
      );

  /// Create a staging config.
  factory OlympusConfig.staging({
    required String appId,
    required String apiKey,
  }) => OlympusConfig(
    appId: appId,
    apiKey: apiKey,
    baseUrl: 'https://staging.api.olympuscloud.ai/api/v1',
    environment: OlympusEnvironment.staging,
  );
}

enum OlympusEnvironment { production, staging, development, sandbox }
