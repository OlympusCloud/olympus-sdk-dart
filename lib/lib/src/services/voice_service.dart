import '../http_client.dart';

/// Voice AI platform: agent configs, conversations, campaigns, phone numbers,
/// marketplace voices, calls, speaker profiles, and analytics.
///
/// Routes: `/voice-agents/*`, `/voice/phone-numbers/*`, `/voice/marketplace/*`,
/// `/voice/calls/*`, `/voice/speaker/*`, `/voice/profiles/*`.
class OlympusVoiceService {
  OlympusVoiceService(this._http);

  final OlympusHttpClient _http;

  // ---------------------------------------------------------------------------
  // Agents
  // ---------------------------------------------------------------------------

  /// List all voice agent configurations.
  Future<List<Map<String, dynamic>>> listConfigs({
    int? page,
    int? limit,
  }) async {
    final json = await _http.get(
      '/voice-agents/configs',
      queryParameters: {'page': ?page, 'limit': ?limit},
    );
    final items =
        json['configs'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Get a single voice agent configuration.
  Future<Map<String, dynamic>> getConfig(String configId) async {
    return _http.get('/voice-agents/configs/$configId');
  }

  /// Create a new voice agent configuration.
  Future<Map<String, dynamic>> createConfig(Map<String, dynamic> config) async {
    return _http.post('/voice-agents/configs', data: config);
  }

  /// Update an existing voice agent configuration.
  Future<Map<String, dynamic>> updateConfig(
    String configId,
    Map<String, dynamic> config,
  ) async {
    return _http.put('/voice-agents/configs/$configId', data: config);
  }

  /// Delete a voice agent configuration.
  Future<void> deleteConfig(String configId) async {
    await _http.delete('/voice-agents/configs/$configId');
  }

  /// List available agent templates.
  Future<List<Map<String, dynamic>>> listTemplates() async {
    final json = await _http.get('/voice-agents/templates');
    final items =
        json['templates'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  // ---------------------------------------------------------------------------
  // Conversations
  // ---------------------------------------------------------------------------

  /// List voice conversations with optional filters.
  Future<List<Map<String, dynamic>>> listConversations({
    String? agentId,
    String? status,
    int? page,
    int? limit,
  }) async {
    final json = await _http.get(
      '/voice-agents/conversations',
      queryParameters: {
        'agent_id': ?agentId,
        'status': ?status,
        'page': ?page,
        'limit': ?limit,
      },
    );
    final items =
        json['conversations'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Get a single conversation with its transcript and metadata.
  Future<Map<String, dynamic>> getConversation(String conversationId) async {
    return _http.get('/voice-agents/conversations/$conversationId');
  }

  // ---------------------------------------------------------------------------
  // Analytics
  // ---------------------------------------------------------------------------

  /// Get voice analytics (call volume, duration, sentiment, etc.).
  Future<Map<String, dynamic>> getAnalytics({
    String? agentId,
    String? from,
    String? to,
  }) async {
    return _http.get(
      '/voice-agents/analytics',
      queryParameters: {'agent_id': ?agentId, 'from': ?from, 'to': ?to},
    );
  }

  // ---------------------------------------------------------------------------
  // Campaigns
  // ---------------------------------------------------------------------------

  /// List outbound voice campaigns.
  Future<List<Map<String, dynamic>>> listCampaigns({
    int? page,
    int? limit,
  }) async {
    final json = await _http.get(
      '/voice-agents/campaigns',
      queryParameters: {'page': ?page, 'limit': ?limit},
    );
    final items =
        json['campaigns'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Get a single campaign by ID.
  Future<Map<String, dynamic>> getCampaign(String campaignId) async {
    return _http.get('/voice-agents/campaigns/$campaignId');
  }

  /// Create a new outbound campaign.
  Future<Map<String, dynamic>> createCampaign(
    Map<String, dynamic> campaign,
  ) async {
    return _http.post('/voice-agents/campaigns', data: campaign);
  }

  /// Update an existing campaign.
  Future<Map<String, dynamic>> updateCampaign(
    String campaignId,
    Map<String, dynamic> campaign,
  ) async {
    return _http.put('/voice-agents/campaigns/$campaignId', data: campaign);
  }

  /// Delete a campaign.
  Future<void> deleteCampaign(String campaignId) async {
    await _http.delete('/voice-agents/campaigns/$campaignId');
  }

  // ---------------------------------------------------------------------------
  // Phone Numbers
  // ---------------------------------------------------------------------------

  /// List provisioned phone numbers.
  Future<List<Map<String, dynamic>>> listNumbers({
    int? page,
    int? limit,
  }) async {
    final json = await _http.get(
      '/voice/phone-numbers',
      queryParameters: {'page': ?page, 'limit': ?limit},
    );
    final items =
        json['numbers'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Get details for a single phone number.
  Future<Map<String, dynamic>> getNumber(String numberId) async {
    return _http.get('/voice/phone-numbers/$numberId');
  }

  /// Provision a new phone number.
  Future<Map<String, dynamic>> provisionNumber(
    Map<String, dynamic> request,
  ) async {
    return _http.post('/voice/phone-numbers/provision', data: request);
  }

  /// Release a provisioned phone number.
  Future<void> releaseNumber(String numberId) async {
    await _http.delete('/voice/phone-numbers/$numberId');
  }

  /// Assign a phone number to a voice agent.
  Future<Map<String, dynamic>> assignNumber(
    String numberId,
    String agentId,
  ) async {
    return _http.post(
      '/voice/phone-numbers/$numberId/assign',
      data: {'agent_id': agentId},
    );
  }

  /// Search available phone numbers by area code or pattern.
  Future<List<Map<String, dynamic>>> searchNumbers({
    String? areaCode,
    String? contains,
    String? country,
    int? limit,
  }) async {
    final json = await _http.get(
      '/voice/phone-numbers/search',
      queryParameters: {
        'area_code': ?areaCode,
        'contains': ?contains,
        'country': ?country,
        'limit': ?limit,
      },
    );
    final items =
        json['numbers'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Initiate a number port-in request.
  Future<Map<String, dynamic>> portNumber(
    Map<String, dynamic> portRequest,
  ) async {
    return _http.post('/voice/phone-numbers/port', data: portRequest);
  }

  /// Get the status of a port-in request.
  Future<Map<String, dynamic>> getPortStatus(String portId) async {
    return _http.get('/voice/phone-numbers/port/$portId');
  }

  /// Cancel a pending port-in request.
  Future<void> cancelPort(String portId) async {
    await _http.delete('/voice/phone-numbers/port/$portId');
  }

  // ---------------------------------------------------------------------------
  // Marketplace (Voices & Packs)
  // ---------------------------------------------------------------------------

  /// List available voices in the marketplace.
  Future<List<Map<String, dynamic>>> listVoices({
    String? language,
    String? gender,
    int? limit,
  }) async {
    final json = await _http.get(
      '/voice/marketplace/voices',
      queryParameters: {
        'language': ?language,
        'gender': ?gender,
        'limit': ?limit,
      },
    );
    final items =
        json['voices'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Get voices installed for the current tenant.
  Future<List<Map<String, dynamic>>> getMyVoices() async {
    final json = await _http.get('/voice/marketplace/my-voices');
    final items =
        json['voices'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  /// List voice packs (bundles of voices).
  Future<List<Map<String, dynamic>>> listPacks({int? limit}) async {
    final json = await _http.get(
      '/voice/marketplace/packs',
      queryParameters: {'limit': ?limit},
    );
    final items =
        json['packs'] as List<dynamic>? ?? json['data'] as List<dynamic>? ?? [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Get a single voice pack by ID.
  Future<Map<String, dynamic>> getPack(String packId) async {
    return _http.get('/voice/marketplace/packs/$packId');
  }

  /// Install a voice pack for the current tenant.
  Future<Map<String, dynamic>> installPack(String packId) async {
    return _http.post('/voice/marketplace/packs/$packId/install');
  }

  // ---------------------------------------------------------------------------
  // Calls
  // ---------------------------------------------------------------------------

  /// End an active call by ID.
  Future<void> endCall(String callId) async {
    await _http.post('/voice/calls/$callId/end');
  }

  // ---------------------------------------------------------------------------
  // Speaker
  // ---------------------------------------------------------------------------

  /// Get the speaker profile for a given speaker ID.
  Future<Map<String, dynamic>> getSpeakerProfile(String speakerId) async {
    return _http.get('/voice/speaker/$speakerId');
  }

  /// Enroll a new speaker for voice recognition.
  Future<Map<String, dynamic>> enrollSpeaker(
    Map<String, dynamic> enrollment,
  ) async {
    return _http.post('/voice/speaker/enroll', data: enrollment);
  }

  /// Add custom words or phrases for a speaker's vocabulary.
  Future<void> addWords(String speakerId, List<String> words) async {
    await _http.post('/voice/speaker/$speakerId/words', data: {'words': words});
  }

  // ---------------------------------------------------------------------------
  // Profiles
  // ---------------------------------------------------------------------------

  /// List voice profiles for the tenant.
  Future<List<Map<String, dynamic>>> listProfiles({
    int? page,
    int? limit,
  }) async {
    final json = await _http.get(
      '/voice/profiles',
      queryParameters: {'page': ?page, 'limit': ?limit},
    );
    final items =
        json['profiles'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Get a single voice profile by ID.
  Future<Map<String, dynamic>> getProfile(String profileId) async {
    return _http.get('/voice/profiles/$profileId');
  }

  /// Create a new voice profile.
  Future<Map<String, dynamic>> createProfile(
    Map<String, dynamic> profile,
  ) async {
    return _http.post('/voice/profiles', data: profile);
  }

  /// Update an existing voice profile.
  Future<Map<String, dynamic>> updateProfile(
    String profileId,
    Map<String, dynamic> profile,
  ) async {
    return _http.put('/voice/profiles/$profileId', data: profile);
  }
}
