import 'config.dart';
import 'http_client.dart';
import 'services/ads_service.dart';
import 'services/ai_service.dart';
import 'services/auth_service.dart';
import 'services/billing_service.dart';
import 'services/commerce_service.dart';
import 'services/connect_service.dart';
import 'services/data_service.dart';
import 'services/devices_service.dart';
import 'services/events_service.dart';
import 'services/gating_service.dart';
import 'services/genui_service.dart';
import 'services/health_service.dart';
import 'services/identity_service.dart';
import 'services/live_activity_service.dart';
import 'services/marketplace_service.dart';
import 'services/notify_service.dart';
import 'services/observe_service.dart';
import 'services/pay_service.dart';
import 'services/skills_service.dart';
import 'services/smart_home_service.dart';
import 'services/storage_service.dart';
import 'services/training_service.dart';
import 'services/vision_service.dart';
import 'services/voice_service.dart';
import 'services/wearable_service.dart';
import 'services/workflow_service.dart';

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
  OlympusAdsService? _ads;
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
  OlympusVoiceService? _voice;
  OlympusWorkflowService? _workflows;
  OlympusHealthService? _health;
  OlympusIdentityService? _identity;
  LiveActivityService? _liveActivity;
  OlympusSmartHomeService? _smartHome;
  OlympusSkillsService? _skills;
  OlympusTrainingService? _training;
  OlympusConnectService? _connect;
  OlympusVisionService? _vision;
  OlympusWearableService? _wearable;
  OlympusGenerativeUiService? _genui;

  /// Authentication, user management, and API keys.
  OlympusAuthService get auth => _auth ??= OlympusAuthService(_http);

  /// Orders, catalog, and commerce operations.
  OlympusCommerceService get commerce =>
      _commerce ??= OlympusCommerceService(_http);

  /// AI inference, agents, embeddings, and NLP.
  OlympusAiService get ai => _ai ??= OlympusAiService(_http);

  /// Ad mediation: placements, impressions, revenue reporting.
  OlympusAdsService get ads => _ads ??= OlympusAdsService(_http);

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

  /// Voice AI: agents, conversations, campaigns, phone numbers, and profiles.
  OlympusVoiceService get voice => _voice ??= OlympusVoiceService(_http);

  /// Workflow automation: create, manage, and execute workflows.
  OlympusWorkflowService get workflows =>
      _workflows ??= OlympusWorkflowService(_http);

  /// Health integrations: providers, sync, and insights.
  OlympusHealthService get health => _health ??= OlympusHealthService(_http);

  /// Olympus ID — global, cross-tenant identity & federation.
  OlympusIdentityService get identity =>
      _identity ??= OlympusIdentityService(_http);

  /// iOS Live Activities and Dynamic Island management.
  LiveActivityService get liveActivity =>
      _liveActivity ??= LiveActivityService();

  /// Smart home: platforms, devices, rooms, and control.
  OlympusSmartHomeService get smartHome =>
      _smartHome ??= OlympusSmartHomeService(_http);

  /// AI skills: browse, install, and manage voice AI skills.
  OlympusSkillsService get skills => _skills ??= OlympusSkillsService(_http);

  /// Training: FAQ, upsell rules, instructions, and knowledge base sync.
  OlympusTrainingService get training =>
      _training ??= OlympusTrainingService(_http);

  /// External connections: Google OAuth, Calendar, and Gmail.
  OlympusConnectService get connect =>
      _connect ??= OlympusConnectService(_http);

  /// Vision AI: product recognition, food recognition, 3D model
  /// generation, ghost-inventory detection, and camera surveillance.
  OlympusVisionService get vision => _vision ??= OlympusVisionService(_http);

  /// Wearable companion bridge — WearOS and watchOS (alerts, glanceables,
  /// voice commands).
  OlympusWearableService get wearable =>
      _wearable ??= OlympusWearableService();

  /// Self-Healing UI / Generative UI patch transport. Apps subscribe to
  /// `genui.events` and use `genui.getPatch(widgetId)` when rendering.
  OlympusGenerativeUiService get genui =>
      _genui ??= OlympusGenerativeUiService();

  // ---------------------------------------------------------------------------
  // Configuration accessors
  // ---------------------------------------------------------------------------

  /// The active SDK configuration.
  OlympusConfig get config => _config;

  /// The underlying HTTP client (for advanced usage).
  OlympusHttpClient get httpClient => _http;
}
