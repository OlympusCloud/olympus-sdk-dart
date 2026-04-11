/// Olympus Cloud SDK -- The AI Business Operating System
///
/// Official Dart SDK for building apps on Olympus Cloud.
/// Provides typed access to all platform services.
///
/// ```dart
/// import 'package:olympus_sdk/olympus_sdk.dart';
///
/// final oc = OlympusClient(
///   appId: 'com.my-app',
///   apiKey: Platform.environment['OLYMPUS_API_KEY']!,
/// );
///
/// // Create an order
/// final order = await oc.commerce.createOrder(
///   items: [OrderItem(catalogId: 'burger', qty: 2, price: 1299)],
///   source: 'pos',
/// );
///
/// // Ask AI
/// final answer = await oc.ai.query('What are our top sellers today?');
/// ```
library;

export 'src/client.dart';
export 'src/config.dart';
export 'src/http_client.dart'
    show
        OlympusApiError,
        OlympusAuthExpiredError,
        TokenStore,
        InMemoryTokenStore;
export 'src/models/models.dart';
export 'src/services/ads_service.dart';
export 'src/services/agent_service.dart';
export 'src/services/agent_workflow_service.dart';
export 'src/services/ai_service.dart';
export 'src/services/auth_service.dart';
export 'src/services/billing_service.dart';
export 'src/services/business_service.dart';
export 'src/services/commerce_service.dart';
export 'src/services/connect_service.dart';
export 'src/services/creator_service.dart';
export 'src/services/data_service.dart';
export 'src/services/developer_service.dart';
export 'src/services/devices_service.dart';
export 'src/services/ether_service.dart';
export 'src/services/events_service.dart';
export 'src/services/gating_service.dart';
export 'src/services/genui_service.dart';
export 'src/services/health_service.dart';
export 'src/services/identity_service.dart';
export 'src/services/live_activity_service.dart';
export 'src/services/marketplace_service.dart';
export 'src/services/maximus_service.dart';
export 'src/services/notify_service.dart';
export 'src/services/observe_service.dart';
export 'src/services/pay_service.dart';
export 'src/services/platform_service.dart';
export 'src/services/pos_service.dart';
export 'src/services/skills_service.dart';
export 'src/services/smart_home_service.dart';
export 'src/services/storage_service.dart';
export 'src/services/training_service.dart';
export 'src/services/vision_service.dart';
export 'src/services/voice_service.dart';
export 'src/services/wearable_service.dart';
export 'src/services/webhook_service.dart';
export 'src/services/workflow_service.dart';
