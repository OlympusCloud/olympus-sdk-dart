import 'config.dart';
import 'http_client.dart';
import 'services/ai_service.dart';
import 'services/auth_service.dart';
import 'services/billing_service.dart';
import 'services/commerce_service.dart';
import 'services/data_service.dart';
import 'services/devices_service.dart';
import 'services/events_service.dart';
import 'services/gating_service.dart';
import 'services/marketplace_service.dart';
import 'services/notify_service.dart';
import 'services/observe_service.dart';
import 'services/pay_service.dart';
import 'services/storage_service.dart';

/// Main entry point for the Olympus Cloud SDK.
///
/// Provides typed access to all platform services. Create a single instance
/// per application:
///
/// ```dart
/// final oc = OlympusClient(
///   appId: 'com.my-restaurant',
///   apiKey: 'oc_live_...',
/// );
///
/// // Authenticate
/// final session = await oc.auth.login('user@example.com', 'password');
///
/// // Create an order
/// final order = await oc.commerce.createOrder(
///   items: [OrderItem(catalogId: 'burger-01', qty: 2, price: 1299)],
///   source: 'pos',
/// );
///
/// // Ask AI
/// final answer = await oc.ai.query('What sold best this week?');
/// ```
class OlympusClient {
  /// Create a client for production.
  OlympusClient({
    required String appId,
    required String apiKey,
    OlympusConfig? config,
  }) : _config = config ?? OlympusConfig(appId: appId, apiKey: apiKey) {
    _http = OlympusHttpClient(_config);
  }

  /// Create a client from a pre-built config (sandbox, dev, etc.).
  OlympusClient.fromConfig(this._config) {
    _http = OlympusHttpClient(_config);
  }

  final OlympusConfig _config;
  late final OlympusHttpClient _http;

  // ---------------------------------------------------------------------------
  // Service accessors (lazy-initialized singletons)
  // ---------------------------------------------------------------------------

  OlympusAuthService? _auth;
  OlympusCommerceService? _commerce;
  OlympusAiService? _ai;
  OlympusPayService? _pay;
  OlympusNotifyService? _notify;
  OlympusEventsService? _events;
  OlympusDataService? _data;
  OlympusStorageService? _storage;
  OlympusMarketplaceService? _marketplace;
  OlympusBillingService? _billing;
  OlympusGatingService? _gating;
  OlympusDevicesService? _devices;
  OlympusObserveService? _observe;

  /// Authentication, user management, and API keys.
  OlympusAuthService get auth => _auth ??= OlympusAuthService(_http);

  /// Orders, catalog, and commerce operations.
  OlympusCommerceService get commerce =>
      _commerce ??= OlympusCommerceService(_http);

  /// AI inference, agents, embeddings, and NLP.
  OlympusAiService get ai => _ai ??= OlympusAiService(_http);

  /// Payments, refunds, balance, and payouts.
  OlympusPayService get pay => _pay ??= OlympusPayService(_http);

  /// Push, SMS, email, Slack, and in-app notifications.
  OlympusNotifyService get notify => _notify ??= OlympusNotifyService(_http);

  /// Real-time events and webhook management.
  OlympusEventsService get events => _events ??= OlympusEventsService(_http);

  /// Data query, CRUD, and search.
  OlympusDataService get data => _data ??= OlympusDataService(_http);

  /// File storage (upload, download, presign).
  OlympusStorageService get storage =>
      _storage ??= OlympusStorageService(_http);

  /// Marketplace: discover, install, and manage apps.
  OlympusMarketplaceService get marketplace =>
      _marketplace ??= OlympusMarketplaceService(_http);

  /// Subscription billing, invoices, and usage.
  OlympusBillingService get billing =>
      _billing ??= OlympusBillingService(_http);

  /// Feature gating and policy evaluation.
  OlympusGatingService get gating => _gating ??= OlympusGatingService(_http);

  /// Device management (MDM): enrollment, kiosk, updates, wipe.
  OlympusDevicesService get devices =>
      _devices ??= OlympusDevicesService(_http);

  /// Client-side observability: events, errors, traces.
  OlympusObserveService get observe =>
      _observe ??= OlympusObserveService(_http);

  // ---------------------------------------------------------------------------
  // Configuration accessors
  // ---------------------------------------------------------------------------

  /// The active SDK configuration.
  OlympusConfig get config => _config;

  /// The underlying HTTP client (for advanced usage).
  OlympusHttpClient get httpClient => _http;
}
