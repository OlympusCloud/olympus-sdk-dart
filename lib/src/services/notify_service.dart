import '../http_client.dart';

/// Push, SMS, email, Slack, and in-app notifications.
///
/// Wraps the Olympus Notification service via the Go API Gateway.
/// Routes: `/notifications/*`, `/messaging/*`.
class OlympusNotifyService {
  OlympusNotifyService(this._http);

  final OlympusHttpClient _http;

  /// Send a push notification to a user's device(s).
  Future<void> push(String userId, String title, String body) async {
    await _http.post('/notifications/push', data: {
      'user_id': userId,
      'title': title,
      'body': body,
    });
  }

  /// Send an SMS message.
  Future<void> sms(String phone, String message) async {
    await _http.post('/messaging/sms', data: {
      'phone': phone,
      'message': message,
    });
  }

  /// Send an email.
  Future<void> email(String to, String subject, String html) async {
    await _http.post('/messaging/email', data: {
      'to': to,
      'subject': subject,
      'html': html,
    });
  }

  /// Send a Slack message to a channel.
  Future<void> slack(String channel, String message) async {
    await _http.post('/messaging/slack', data: {
      'channel': channel,
      'message': message,
    });
  }

  /// Send an in-app chat message to a user.
  Future<void> chat(String userId, String message) async {
    await _http.post('/notifications/chat', data: {
      'user_id': userId,
      'message': message,
    });
  }

  /// List notifications for the current user.
  Future<List<Map<String, dynamic>>> list({
    int? limit,
    bool? unreadOnly,
  }) async {
    final json = await _http.get('/notifications', queryParameters: {
      'limit': ?limit,
      'unread_only': ?unreadOnly,
    });
    final items = json['notifications'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Mark a notification as read.
  Future<void> markRead(String notificationId) async {
    await _http.patch('/notifications/$notificationId', data: {
      'read': true,
    });
  }
}
