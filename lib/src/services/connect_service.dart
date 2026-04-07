import '../http_client.dart';

/// External service connections: Google OAuth, Calendar, and Gmail integration.
///
/// Routes: `/connect/*`.
class OlympusConnectService {
  OlympusConnectService(this._http);

  final OlympusHttpClient _http;

  /// Get the current Google account connection status.
  Future<Map<String, dynamic>> getGoogleStatus() async {
    return _http.get('/connect/google/status');
  }

  /// Initiate the Google OAuth authorization flow.
  ///
  /// Returns a map containing the authorization URL and state token.
  Future<Map<String, dynamic>> initiateGoogleAuth({
    List<String>? scopes,
  }) async {
    return _http.post('/connect/google/auth', data: {'scopes': ?scopes});
  }

  /// Get calendar events for the connected Google account.
  Future<List<Map<String, dynamic>>> getCalendarEvents({
    String? calendarId,
    String? from,
    String? to,
    int? limit,
  }) async {
    final json = await _http.get(
      '/connect/google/calendar/events',
      queryParameters: {
        'calendar_id': ?calendarId,
        'from': ?from,
        'to': ?to,
        'limit': ?limit,
      },
    );
    final items =
        json['events'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Update a calendar event.
  Future<Map<String, dynamic>> updateCalendarEvent(
    String eventId,
    Map<String, dynamic> event,
  ) async {
    return _http.put('/connect/google/calendar/events/$eventId', data: event);
  }

  /// Get the Gmail digest (summary of recent emails).
  Future<Map<String, dynamic>> getGmailDigest({int? limit}) async {
    return _http.get(
      '/connect/google/gmail/digest',
      queryParameters: {'limit': ?limit},
    );
  }
}
