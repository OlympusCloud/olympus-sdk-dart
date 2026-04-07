import '../http_client.dart';
import '../models/commerce_models.dart';
import '../models/common.dart';

/// Order management, catalog operations, and commerce workflows.
///
/// Wraps the Olympus Commerce service (Rust) via the Go API Gateway.
/// Routes: `/commerce/*`, `/central-menu/*`.
class OlympusCommerceService {
  OlympusCommerceService(this._http);

  final OlympusHttpClient _http;

  // ---------------------------------------------------------------------------
  // Orders
  // ---------------------------------------------------------------------------

  /// Create a new order.
  ///
  /// [items] is the list of line items. [source] identifies the originating
  /// channel (e.g., "pos", "kiosk", "online", "drive_thru").
  Future<Order> createOrder({
    required List<OrderItem> items,
    required String source,
    String? tableId,
    String? customerId,
  }) async {
    final json = await _http.post('/commerce/orders', data: {
      'items': items.map((e) => e.toJson()).toList(),
      'source': source,
      'table_id': ?tableId,
      'customer_id': ?customerId,
    });
    return Order.fromJson(json);
  }

  /// Add an item to an existing order.
  Future<void> addItemToOrder(String orderId, Map<String, dynamic> item) async {
    await _http.post('/commerce/orders/$orderId/items', data: item);
  }

  /// Retrieve a single order by ID.
  Future<Order> getOrder(String orderId) async {
    final json = await _http.get('/commerce/orders/$orderId');
    return Order.fromJson(json);
  }

  /// List orders with optional filters and pagination.
  Future<PaginatedResponse<Order>> getOrders({
    int? page,
    int? limit,
    String? status,
  }) async {
    final json = await _http.get('/commerce/orders', queryParameters: {
      'page': ?page,
      'limit': ?limit,
      'status': ?status,
    });
    return PaginatedResponse.fromJson(json, Order.fromJson);
  }

  /// Update the status of an order (e.g., "preparing", "ready", "completed").
  Future<Order> updateOrderStatus(String orderId, String status) async {
    final json = await _http.patch('/commerce/orders/$orderId/status', data: {
      'status': status,
    });
    return Order.fromJson(json);
  }

  /// Cancel an order with a reason.
  Future<void> cancelOrder(String orderId, String reason) async {
    await _http.post('/commerce/orders/$orderId/cancel', data: {
      'reason': reason,
    });
  }

  // ---------------------------------------------------------------------------
  // Catalog
  // ---------------------------------------------------------------------------

  /// Create a new catalog item (menu item, product, etc.).
  Future<CatalogItem> createCatalogItem({
    required String name,
    required int price,
    String? category,
    List<CatalogModifier>? modifiers,
    String? description,
    String? imageUrl,
  }) async {
    final json = await _http.post('/central-menu/items', data: {
      'name': name,
      'price': price,
      'category': ?category,
      'modifiers': ?modifiers?.map((e) => e.toJson()).toList(),
      'description': ?description,
      'image_url': ?imageUrl,
    });
    return CatalogItem.fromJson(json);
  }

  /// Retrieve the catalog, optionally filtered by category.
  Future<List<CatalogItem>> getCatalog({String? categoryId}) async {
    final json = await _http.get('/central-menu/items', queryParameters: {
      'category_id': ?categoryId,
    });
    final items = json['items'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items
        .map((e) => CatalogItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get a single catalog item by ID.
  Future<CatalogItem> getCatalogItem(String itemId) async {
    final json = await _http.get('/central-menu/items/$itemId');
    return CatalogItem.fromJson(json);
  }

  /// Update an existing catalog item.
  Future<CatalogItem> updateCatalogItem(
    String itemId, {
    String? name,
    int? price,
    String? category,
    String? description,
    bool? available,
  }) async {
    final json = await _http.patch('/central-menu/items/$itemId', data: {
      'name': ?name,
      'price': ?price,
      'category': ?category,
      'description': ?description,
      'available': ?available,
    });
    return CatalogItem.fromJson(json);
  }

  /// Delete a catalog item.
  Future<void> deleteCatalogItem(String itemId) async {
    await _http.delete('/central-menu/items/$itemId');
  }
}
