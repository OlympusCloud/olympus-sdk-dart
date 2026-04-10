import '../http_client.dart';

/// Creator platform: posts, media, episodes, profile, analytics, team,
/// branding, calendar, AI content generation, social posts, and shows.
///
/// Routes: `/creator/*`, `/api/v1/posts/*`, `/api/v1/media/*`,
/// `/api/v1/episodes/*`.
///
/// Backed by the Rust Creator service (port 8004, 14 handler modules).
class OlympusCreatorService {
  OlympusCreatorService(this._http);

  final OlympusHttpClient _http;

  // ---------------------------------------------------------------------------
  // Posts
  // ---------------------------------------------------------------------------

  /// List posts (paginated, filterable by status and type).
  Future<Map<String, dynamic>> listPosts({
    String? status,
    String? contentType,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    return _http.get(
      '/api/v1/posts',
      queryParameters: {
        'status': ?status,
        'content_type': ?contentType,
        'search': ?search,
        'page': page,
        'page_size': pageSize,
      },
    );
  }

  /// Create a new post.
  Future<Map<String, dynamic>> createPost(Map<String, dynamic> post) async {
    return _http.post('/api/v1/posts', data: post);
  }

  /// Get a single post by ID.
  Future<Map<String, dynamic>> getPost(String postId) async {
    return _http.get('/api/v1/posts/$postId');
  }

  /// Update an existing post.
  Future<Map<String, dynamic>> updatePost(
    String postId,
    Map<String, dynamic> updates,
  ) async {
    return _http.put('/api/v1/posts/$postId', data: updates);
  }

  /// Delete a post.
  Future<void> deletePost(String postId) async {
    await _http.delete('/api/v1/posts/$postId');
  }

  /// Publish a post (optionally scheduled).
  Future<Map<String, dynamic>> publishPost(
    String postId, {
    List<String>? platforms,
    DateTime? scheduledAt,
  }) async {
    return _http.post(
      '/api/v1/posts/$postId/publish',
      data: {
        if (platforms != null) 'platforms': platforms,
        if (scheduledAt != null) 'scheduled_at': scheduledAt.toIso8601String(),
      },
    );
  }

  /// Schedule a post for future publishing.
  Future<Map<String, dynamic>> schedulePost(
    String postId,
    DateTime publishAt,
  ) async {
    return _http.post(
      '/api/v1/posts/$postId/schedule',
      data: {'publish_at': publishAt.toIso8601String()},
    );
  }

  /// Get version history for a post.
  Future<Map<String, dynamic>> getPostVersions(String postId) async {
    return _http.get('/api/v1/posts/$postId/versions');
  }

  // ---------------------------------------------------------------------------
  // Media
  // ---------------------------------------------------------------------------

  /// List media files (paginated, filterable).
  Future<Map<String, dynamic>> listMedia({
    String? mediaType,
    String? status,
    int page = 1,
    int pageSize = 50,
  }) async {
    return _http.get(
      '/creator/media',
      queryParameters: {
        'media_type': ?mediaType,
        'status': ?status,
        'page': page,
        'page_size': pageSize,
      },
    );
  }

  /// Initiate a media upload (returns presigned URL).
  Future<Map<String, dynamic>> initiateUpload({
    required String filename,
    required String mimeType,
    required int sizeBytes,
    String? altText,
  }) async {
    return _http.post(
      '/creator/media/upload',
      data: {
        'filename': filename,
        'mime_type': mimeType,
        'size_bytes': sizeBytes,
        if (altText != null) 'alt_text': altText,
      },
    );
  }

  /// Confirm upload completion.
  Future<Map<String, dynamic>> confirmUpload(
    String mediaId, {
    int? width,
    int? height,
    int? durationSeconds,
  }) async {
    return _http.post(
      '/creator/media/$mediaId/confirm',
      data: {
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        if (durationSeconds != null) 'duration_seconds': durationSeconds,
      },
    );
  }

  /// Delete a media file.
  Future<void> deleteMedia(String mediaId) async {
    await _http.delete('/creator/media/$mediaId');
  }

  /// Get storage usage stats.
  Future<Map<String, dynamic>> getStorageStats() async {
    return _http.get('/creator/media/storage');
  }

  // ---------------------------------------------------------------------------
  // Profile
  // ---------------------------------------------------------------------------

  /// Get creator profile.
  Future<Map<String, dynamic>> getProfile() async {
    return _http.get('/creator/profile');
  }

  /// Update creator profile.
  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> updates,
  ) async {
    return _http.put('/creator/profile', data: updates);
  }

  // ---------------------------------------------------------------------------
  // Analytics
  // ---------------------------------------------------------------------------

  /// Get analytics summary (reach, engagement, followers, revenue).
  Future<Map<String, dynamic>> getAnalyticsSummary({String period = '30d'}) async {
    return _http.get(
      '/creator/analytics/summary',
      queryParameters: {'period': period},
    );
  }

  /// Get per-content analytics.
  Future<Map<String, dynamic>> getContentAnalytics(String contentId) async {
    return _http.get('/creator/analytics/content/$contentId');
  }

  /// Get audience insights (demographics, locations).
  Future<Map<String, dynamic>> getAudienceInsights() async {
    return _http.get('/creator/analytics/audience');
  }

  /// Get per-platform analytics.
  Future<Map<String, dynamic>> getPlatformAnalytics() async {
    return _http.get('/creator/analytics/platforms');
  }

  // ---------------------------------------------------------------------------
  // AI Content Generation
  // ---------------------------------------------------------------------------

  /// Generate content using AI.
  Future<Map<String, dynamic>> generateContent({
    required String prompt,
    required String contentType,
    String? templateId,
    String? platform,
    String? tone,
  }) async {
    return _http.post(
      '/creator/ai/generate',
      data: {
        'prompt': prompt,
        'content_type': contentType,
        if (templateId != null) 'template_id': templateId,
        if (platform != null) 'platform': platform,
        if (tone != null) 'tone': tone,
      },
    );
  }

  /// List AI content templates.
  Future<Map<String, dynamic>> listAiTemplates() async {
    return _http.get('/creator/ai/templates');
  }

  /// Get AI generation history.
  Future<Map<String, dynamic>> getAiHistory() async {
    return _http.get('/creator/ai/history');
  }

  /// Get content suggestions.
  Future<Map<String, dynamic>> getContentSuggestions() async {
    return _http.get('/creator/ai/suggestions');
  }

  // ---------------------------------------------------------------------------
  // Team
  // ---------------------------------------------------------------------------

  /// List team members.
  Future<Map<String, dynamic>> listTeam() async {
    return _http.get('/creator/team');
  }

  /// Invite a team member.
  Future<Map<String, dynamic>> inviteTeamMember({
    required String email,
    required String role,
    String? displayName,
  }) async {
    return _http.post(
      '/creator/team/invite',
      data: {
        'email': email,
        'role': role,
        if (displayName != null) 'display_name': displayName,
      },
    );
  }

  /// Remove a team member.
  Future<void> removeTeamMember(String memberId) async {
    await _http.delete('/creator/team/$memberId');
  }

  // ---------------------------------------------------------------------------
  // Calendar Events
  // ---------------------------------------------------------------------------

  /// List calendar events.
  Future<Map<String, dynamic>> listCalendarEvents({
    DateTime? start,
    DateTime? end,
  }) async {
    return _http.get(
      '/creator/calendar/events',
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
    return _http.post('/creator/calendar/events', data: event);
  }

  /// Delete a calendar event.
  Future<void> deleteCalendarEvent(String eventId) async {
    await _http.delete('/creator/calendar/events/$eventId');
  }
}
