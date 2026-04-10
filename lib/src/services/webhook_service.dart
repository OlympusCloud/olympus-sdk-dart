import '../http_client.dart';

/// Webhook management: register endpoints, view delivery status, and manage
/// retry policies.
///
/// Webhooks are delivered via Cloudflare Queue with HMAC-SHA256 signatures,
/// exponential backoff retry (1s, 5s, 30s, 5m), and dead letter queue
/// for permanently failed deliveries.
///
/// Routes: `/webhooks/*` (Go Gateway → CF Queue → tenant endpoint).
class OlympusWebhookService {
  OlympusWebhookService(this._http);

  final OlympusHttpClient _http;

  // ---------------------------------------------------------------------------
  // Webhook Endpoints (registration)
  // ---------------------------------------------------------------------------

  /// List all registered webhook endpoints for the tenant.
  Future<List<Map<String, dynamic>>> listEndpoints({
    int? page,
    int? limit,
  }) async {
    final json = await _http.get(
      '/webhooks/endpoints',
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
    );
    final items =
        json['endpoints'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Get a single webhook endpoint by ID.
  Future<Map<String, dynamic>> getEndpoint(String endpointId) async {
    return _http.get('/webhooks/endpoints/$endpointId');
  }

  /// Register a new webhook endpoint.
  ///
  /// [url] is the HTTPS URL to deliver events to.
  /// [events] is a list of event types to subscribe to (e.g., `order.created`,
  /// `payment.completed`, `voice.call.ended`).
  /// [secret] is an optional shared secret for HMAC signature verification.
  /// If omitted, the platform generates one.
  Future<Map<String, dynamic>> createEndpoint({
    required String url,
    required List<String> events,
    String? description,
    String? secret,
  }) async {
    return _http.post(
      '/webhooks/endpoints',
      data: {
        'url': url,
        'events': events,
        if (description != null) 'description': description,
        if (secret != null) 'secret': secret,
      },
    );
  }

  /// Update a webhook endpoint (URL, events, or status).
  Future<Map<String, dynamic>> updateEndpoint(
    String endpointId,
    Map<String, dynamic> updates,
  ) async {
    return _http.put('/webhooks/endpoints/$endpointId', data: updates);
  }

  /// Delete a webhook endpoint.
  Future<void> deleteEndpoint(String endpointId) async {
    await _http.delete('/webhooks/endpoints/$endpointId');
  }

  /// Rotate the signing secret for an endpoint.
  ///
  /// Returns the new secret. The old secret remains valid for 24 hours
  /// to allow for graceful migration.
  Future<Map<String, dynamic>> rotateSecret(String endpointId) async {
    return _http.post('/webhooks/endpoints/$endpointId/rotate-secret');
  }

  // ---------------------------------------------------------------------------
  // Delivery Status
  // ---------------------------------------------------------------------------

  /// List recent deliveries for an endpoint.
  ///
  /// Returns delivery attempts with status, response code, latency, and
  /// any error messages.
  Future<List<Map<String, dynamic>>> listDeliveries(
    String endpointId, {
    String? status,
    int? page,
    int? limit,
  }) async {
    final json = await _http.get(
      '/webhooks/endpoints/$endpointId/deliveries',
      queryParameters: {
        if (status != null) 'status': status,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
    );
    final items =
        json['deliveries'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Get details for a specific delivery attempt.
  Future<Map<String, dynamic>> getDelivery(
    String endpointId,
    String deliveryId,
  ) async {
    return _http.get(
      '/webhooks/endpoints/$endpointId/deliveries/$deliveryId',
    );
  }

  /// Retry a failed delivery.
  Future<Map<String, dynamic>> retryDelivery(
    String endpointId,
    String deliveryId,
  ) async {
    return _http.post(
      '/webhooks/endpoints/$endpointId/deliveries/$deliveryId/retry',
    );
  }

  // ---------------------------------------------------------------------------
  // Event Types
  // ---------------------------------------------------------------------------

  /// List all available webhook event types.
  Future<List<Map<String, dynamic>>> listEventTypes() async {
    final json = await _http.get('/webhooks/event-types');
    final items =
        json['event_types'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  // ---------------------------------------------------------------------------
  // Testing
  // ---------------------------------------------------------------------------

  /// Send a test event to a webhook endpoint.
  ///
  /// Useful for verifying endpoint connectivity and signature validation.
  Future<Map<String, dynamic>> sendTest(
    String endpointId, {
    String? eventType,
  }) async {
    return _http.post(
      '/webhooks/endpoints/$endpointId/test',
      data: {if (eventType != null) 'event_type': eventType},
    );
  }
}
