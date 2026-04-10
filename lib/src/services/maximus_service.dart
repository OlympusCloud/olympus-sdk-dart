import '../http_client.dart';

/// Maximus consumer AI assistant: voice queries, calendar, email,
/// subscription billing.
///
/// Routes: `/maximus/voice/*`, `/maximus/calendar/*`, `/maximus/email/*`,
/// `/maximus/plans`, `/maximus/usage/*`, `/maximus/subscribe`.
class OlympusMaximusService {
  OlympusMaximusService(this._http);

  final OlympusHttpClient _http;

  // ---------------------------------------------------------------------------
  // Voice (v0.3.0 — Issue #2567)
  // ---------------------------------------------------------------------------

  /// Process a voice query. Returns AI response + TTS config.
  Future<Map<String, dynamic>> voiceQuery(String text) async {
    return _http.post('/maximus/voice/query', data: {'text': text});
  }

  /// Get wake word detection config.
  Future<Map<String, dynamic>> getWakeWordConfig() async {
    return _http.get('/maximus/voice/wake-word/config');
  }

  /// Submit a voice sample for speaker adaptation.
  Future<Map<String, dynamic>> adaptSpeaker(
    Map<String, dynamic> sample,
  ) async {
    return _http.post('/maximus/voice/speaker/adapt', data: sample);
  }

  /// Get recent voice conversation history.
  Future<Map<String, dynamic>> getConversationHistory({int limit = 20}) async {
    return _http.get(
      '/maximus/voice/conversation/history',
      queryParameters: {'limit': limit},
    );
  }

  // ---------------------------------------------------------------------------
  // Calendar (v0.3.0 — Issue #2568)
  // ---------------------------------------------------------------------------

  /// List calendar events in a date range.
  Future<Map<String, dynamic>> listCalendarEvents({
    DateTime? start,
    DateTime? end,
  }) async {
    return _http.get(
      '/maximus/calendar/events',
      queryParameters: {
        'start': ?start?.toIso8601String(),
        'end': ?end?.toIso8601String(),
      },
    );
  }

  /// Create a calendar event.
  Future<Map<String, dynamic>> createCalendarEvent(
    Map<String, dynamic> event,
  ) async {
    return _http.post('/maximus/calendar/events', data: event);
  }

  /// Delete a calendar event.
  Future<void> deleteCalendarEvent(String eventId) async {
    await _http.delete('/maximus/calendar/events/$eventId');
  }

  /// Get free/busy availability.
  Future<Map<String, dynamic>> getAvailability({
    DateTime? start,
    DateTime? end,
  }) async {
    return _http.get(
      '/maximus/calendar/availability',
      queryParameters: {
        'start': ?start?.toIso8601String(),
        'end': ?end?.toIso8601String(),
      },
    );
  }

  /// Trigger calendar sync with Google/Outlook.
  Future<Map<String, dynamic>> syncCalendar({required String provider}) async {
    return _http.post(
      '/maximus/calendar/sync',
      data: {'provider': provider},
    );
  }

  // ---------------------------------------------------------------------------
  // Email (v0.3.0 — Issue #2568)
  // ---------------------------------------------------------------------------

  /// List inbox messages.
  Future<Map<String, dynamic>> listInbox({
    int limit = 50,
    String? cursor,
    String? label,
    bool unreadOnly = false,
  }) async {
    return _http.get(
      '/maximus/email/inbox',
      queryParameters: {
        'limit': limit,
        'cursor': ?cursor,
        'label': ?label,
        'unread_only': unreadOnly,
      },
    );
  }

  /// Get a full email thread.
  Future<Map<String, dynamic>> getEmailThread(String threadId) async {
    return _http.get('/maximus/email/threads/$threadId');
  }

  /// Send an email.
  Future<Map<String, dynamic>> sendEmail({
    required List<String> to,
    required String subject,
    required String body,
    List<String>? cc,
    List<String>? bcc,
    bool html = false,
    String? replyToThreadId,
  }) async {
    return _http.post(
      '/maximus/email/send',
      data: {
        'to': to,
        'subject': subject,
        'body': body,
        if (cc != null) 'cc': cc,
        if (bcc != null) 'bcc': bcc,
        'html': html,
        if (replyToThreadId != null) 'reply_to_thread_id': replyToThreadId,
      },
    );
  }

  /// Save an email draft.
  Future<Map<String, dynamic>> saveDraft(Map<String, dynamic> draft) async {
    return _http.post('/maximus/email/draft', data: draft);
  }

  // ---------------------------------------------------------------------------
  // Billing (v0.3.0 — Issue #2571)
  // ---------------------------------------------------------------------------

  /// List available Maximus subscription plans.
  /// Plans: free, pro ($9.99), premium ($19.99), business ($29.99).
  Future<Map<String, dynamic>> listPlans() async {
    return _http.get('/maximus/plans');
  }

  /// Get current usage for a tenant's Maximus subscription.
  Future<Map<String, dynamic>> getUsage(String tenantId) async {
    return _http.get('/maximus/usage/$tenantId');
  }

  /// Subscribe to a Maximus plan.
  Future<Map<String, dynamic>> subscribe(String planId) async {
    return _http.post('/maximus/subscribe', data: {'plan_id': planId});
  }
}
