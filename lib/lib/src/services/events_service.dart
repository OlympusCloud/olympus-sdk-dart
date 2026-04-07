import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../http_client.dart';
import '../models/common.dart';

/// Real-time event subscriptions, webhooks, and event publishing.
///
/// WebSocket connections use the `/ws-hub` endpoint for real-time events.
/// HTTP routes: `/platform/tenants/me/webhooks/*`.
class OlympusEventsService {
  OlympusEventsService(this._http);

  final OlympusHttpClient _http;

  // ---------------------------------------------------------------------------
  // WebSocket subscriptions
  // ---------------------------------------------------------------------------

  /// Subscribe to a real-time event type via WebSocket.
  ///
  /// The returned [StreamSubscription] forwards events to [callback].
  /// Caller is responsible for cancelling the subscription when no longer
  /// needed.
  StreamSubscription<Map<String, dynamic>> subscribe(
    String eventType,
    void Function(Map<String, dynamic> data) callback,
  ) {
    final controller = StreamController<Map<String, dynamic>>.broadcast();

    _connectWebSocket(eventType, controller);

    return controller.stream.listen(callback);
  }

  Future<void> _connectWebSocket(
    String eventType,
    StreamController<Map<String, dynamic>> controller,
  ) async {
    try {
      final response = await _http.dio.get<ResponseBody>(
        '/events/stream',
        queryParameters: {'event': eventType},
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data?.stream;
      if (stream == null) {
        await controller.close();
        return;
      }

      final decoded = stream.map((bytes) => utf8.decode(bytes));
      await for (final chunk in decoded) {
        for (final line in chunk.split('\n')) {
          if (line.startsWith('data: ')) {
            try {
              final data =
                  json.decode(line.substring(6)) as Map<String, dynamic>;
              controller.add(data);
            } on FormatException {
              // Skip malformed events.
            }
          }
        }
      }
    } catch (e) {
      controller.addError(e);
    } finally {
      await controller.close();
    }
  }

  // ---------------------------------------------------------------------------
  // Event publishing
  // ---------------------------------------------------------------------------

  /// Publish an event to the platform event bus.
  Future<void> publish(String eventType, Map<String, dynamic> data) async {
    await _http.post(
      '/events/publish',
      data: {'event_type': eventType, 'data': data},
    );
  }

  // ---------------------------------------------------------------------------
  // Webhooks
  // ---------------------------------------------------------------------------

  /// Register a webhook endpoint for one or more event types.
  Future<WebhookRegistration> webhookRegister(
    String url,
    List<String> events,
  ) async {
    final json = await _http.post(
      '/platform/tenants/me/webhooks',
      data: {'url': url, 'events': events},
    );
    return WebhookRegistration.fromJson(json);
  }

  /// Send a test webhook payload for a given event type.
  Future<void> webhookTest(String eventType) async {
    await _http.post(
      '/platform/tenants/me/webhooks/test',
      data: {'event_type': eventType},
    );
  }

  /// Replay a previously delivered event by its ID.
  Future<void> webhookReplay(String eventId) async {
    await _http.post(
      '/platform/tenants/me/webhooks/replay',
      data: {'event_id': eventId},
    );
  }

  /// List registered webhooks.
  Future<List<WebhookRegistration>> listWebhooks() async {
    final json = await _http.get('/platform/tenants/me/webhooks');
    final items =
        json['webhooks'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items
        .map((e) => WebhookRegistration.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Delete a registered webhook.
  Future<void> webhookDelete(String webhookId) async {
    await _http.delete('/platform/tenants/me/webhooks/$webhookId');
  }
}
