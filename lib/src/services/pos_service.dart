import '../http_client.dart';

/// POS integration: voice AI to POS order routing, menu sync.
///
/// Supports Square, Toast, and Clover POS systems (auto-detected from tenant).
/// Routes: `/pos/voice-order`, `/pos/{tenant_id}/sync-menu`,
/// `/pos/voice-orders/{order_id}`.
class OlympusPosService {
  OlympusPosService(this._http);

  final OlympusHttpClient _http;

  /// Submit a voice-parsed order to the tenant's POS system.
  /// Returns order ID, POS system, and estimated ready time.
  Future<Map<String, dynamic>> submitVoiceOrder({
    required String tenantId,
    required String locationId,
    required List<Map<String, dynamic>> items,
    String? customerPhone,
    String? customerName,
    String fulfillment = 'pickup',
    String? notes,
    String? callId,
  }) async {
    return _http.post(
      '/pos/voice-order',
      data: {
        'tenant_id': tenantId,
        'location_id': locationId,
        'items': items,
        if (customerPhone != null) 'customer_phone': customerPhone,
        if (customerName != null) 'customer_name': customerName,
        'fulfillment': fulfillment,
        if (notes != null) 'notes': notes,
        if (callId != null) 'call_id': callId,
      },
    );
  }

  /// Trigger a menu sync from POS to voice AI knowledge base.
  /// Ensures the voice agent has the latest menu/pricing.
  Future<Map<String, dynamic>> syncMenu(String tenantId) async {
    return _http.post('/pos/$tenantId/sync-menu');
  }

  /// Get the status of a voice-submitted order.
  Future<Map<String, dynamic>> getOrderStatus(String orderId) async {
    return _http.get('/pos/voice-orders/$orderId');
  }
}
