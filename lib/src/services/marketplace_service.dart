import '../http_client.dart';
import '../models/marketplace_models.dart';

/// Olympus Marketplace: discover, install, and manage third-party apps.
///
/// Routes: `/marketplace/*` (Algolia-powered discovery + Spanner install state).
class OlympusMarketplaceService {
  OlympusMarketplaceService(this._http);

  final OlympusHttpClient _http;

  /// List available marketplace apps with optional filters.
  Future<List<MarketplaceApp>> listApps({
    String? category,
    String? industry,
    String? query,
    int? limit,
  }) async {
    final json = await _http.get(
      '/marketplace/apps',
      queryParameters: {
        'category': ?category,
        'industry': ?industry,
        'q': ?query,
        'limit': ?limit,
      },
    );
    final items =
        json['apps'] as List<dynamic>? ?? json['data'] as List<dynamic>? ?? [];
    return items
        .map((e) => MarketplaceApp.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get details for a single marketplace app.
  Future<MarketplaceApp> getApp(String appId) async {
    final json = await _http.get('/marketplace/apps/$appId');
    return MarketplaceApp.fromJson(json);
  }

  /// Install a marketplace app for the current tenant.
  Future<Installation> install(String appId) async {
    final json = await _http.post('/marketplace/apps/$appId/install');
    return Installation.fromJson(json);
  }

  /// Uninstall a marketplace app.
  Future<void> uninstall(String appId) async {
    await _http.post('/marketplace/apps/$appId/uninstall');
  }

  /// List apps currently installed for the tenant.
  Future<List<Installation>> getInstalled() async {
    final json = await _http.get('/marketplace/installed');
    final items =
        json['installations'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items
        .map((e) => Installation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Submit a review for a marketplace app.
  Future<void> review(String appId, int rating, String text) async {
    await _http.post(
      '/marketplace/apps/$appId/reviews',
      data: {'rating': rating, 'text': text},
    );
  }

  /// Multi-tenant marketplace checkout — issue #2819.
  ///
  /// Lets a single agent (typically a marketplace concierge or aggregator)
  /// place orders against multiple tenants in one call. The Go gateway
  /// fans out to the per-tenant Commerce service, returns the resulting
  /// orders, and lists any tenants whose order failed.
  ///
  /// Returns the raw envelope:
  ///
  /// ```dart
  /// {
  ///   "agent_id": "agent_123",
  ///   "orders":   [ ... ],     // successful CreateOrder responses
  ///   "failed":   [ "tenant_x" ], // tenant ids where the order failed
  ///   "status":   "completed" | "partially_completed" | "failed"
  /// }
  /// ```
  Future<Map<String, dynamic>> multiTenantCheckout({
    required String agentId,
    required String userId,
    required List<MultiTenantOrderPayload> orders,
    Map<String, dynamic>? metadata,
  }) async {
    return await _http.post(
      '/marketplace/checkout',
      data: {
        'agent_id': agentId,
        'user_id': userId,
        'orders': orders.map((o) => o.toJson()).toList(),
        'metadata': ?metadata,
      },
    );
  }
}

/// One tenant's slice of a multi-tenant marketplace checkout.
class MultiTenantOrderPayload {
  const MultiTenantOrderPayload({
    required this.tenantId,
    required this.restaurantId,
    required this.items,
    this.orderType,
  });

  /// Tenant the order is placed against.
  final String tenantId;

  /// Restaurant / location within the tenant.
  final String restaurantId;

  /// Order line items in the same shape Commerce's CreateOrderItemRequest
  /// uses (catalog id, quantity, modifiers, notes, etc.).
  final List<Map<String, dynamic>> items;

  /// Order type — `dine_in`, `takeout`, `delivery`, etc. Optional;
  /// defaults to whatever the Commerce service defaults to.
  final String? orderType;

  Map<String, dynamic> toJson() => {
    'tenant_id': tenantId,
    'restaurant_id': restaurantId,
    'items': items,
    'order_type': ?orderType,
  };
}
