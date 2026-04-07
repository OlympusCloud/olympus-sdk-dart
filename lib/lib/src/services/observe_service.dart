import '../http_client.dart';
import '../models/observe_models.dart';

/// Client-side observability: event logging, error reporting, tracing, and
/// user identification.
///
/// Routes: `/monitoring/client/*`, `/analytics/*`.
class OlympusObserveService {
  OlympusObserveService(this._http);

  final OlympusHttpClient _http;

  /// Log a custom analytics event.
  Future<void> logEvent(String name, Map<String, dynamic> properties) async {
    await _http.post(
      '/monitoring/client/events',
      data: {
        'event': name,
        'properties': properties,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Report a client-side error.
  Future<void> logError(Object error, {Map<String, dynamic>? context}) async {
    await _http.post(
      '/monitoring/client/errors',
      data: {
        'error': error.toString(),
        'stack_trace': error is Error ? error.stackTrace?.toString() : null,
        'context': ?context,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Start a client-side trace span.
  ///
  /// Call [TraceHandle.end] to close the span and report its duration
  /// to the server.
  Future<TraceHandle> startTrace(String name) async {
    final traceId =
        '${DateTime.now().millisecondsSinceEpoch}-${name.hashCode.abs()}';

    return TraceHandle(
      name: name,
      traceId: traceId,
      startedAt: DateTime.now(),
      onEnd: (handle, duration) async {
        await _http.post(
          '/monitoring/client/traces',
          data: {
            'trace_id': handle.traceId,
            'name': handle.name,
            'duration_ms': duration.inMilliseconds,
            'started_at': handle.startedAt.toIso8601String(),
            'ended_at': handle.endedAt?.toIso8601String(),
          },
        );
      },
    );
  }

  /// Identify the current user for analytics attribution.
  Future<void> setUser(
    String userId, {
    Map<String, dynamic>? properties,
  }) async {
    await _http.post(
      '/monitoring/client/identify',
      data: {'user_id': userId, 'properties': ?properties},
    );
  }
}
