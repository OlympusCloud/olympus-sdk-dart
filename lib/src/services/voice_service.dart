import 'dart:convert';

import '../http_client.dart';
import '../models/voice_option.dart';

/// Voice AI platform: agent configs, conversations, campaigns, phone numbers,
/// marketplace voices, calls, speaker profiles, analytics, and edge voice
/// pipeline (STT→Ether→TTS via CF Containers).
///
/// Routes: `/voice-agents/*`, `/voice/phone-numbers/*`, `/voice/marketplace/*`,
/// `/voice/calls/*`, `/voice/speaker/*`, `/voice/profiles/*`,
/// `/voice/process` (edge pipeline REST), `/ws/voice` (edge pipeline WebSocket).
class OlympusVoiceService {
  OlympusVoiceService(this._http);

  final OlympusHttpClient _http;

  /// In-memory cache for the voice library (#81).
  ///
  /// The voice catalog rarely changes (prebuilt Gemini voices), so we cache
  /// the response for the lifetime of the SDK instance to keep the voice
  /// picker snappy and reduce gateway calls. Call [clearVoiceLibraryCache]
  /// if you need to force a refetch.
  List<VoiceOption>? _voiceLibraryCache;

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
  // Voice Library (v0.3.1 — Issue #81)
  // ---------------------------------------------------------------------------

  /// List the 8 prebuilt Gemini Live voices available for phone agents.
  ///
  /// Each [VoiceOption] includes an `id`, display `name`, `gender`,
  /// marketing `description`, and a public `sampleUrl` pointing to a
  /// 5-second preview clip. The response is cached in-memory per SDK
  /// instance since the catalog rarely changes. Pass
  /// [forceRefresh]`: true` to bypass the cache.
  ///
  /// Routes to `GET /v1/voice/voices` which proxies to the Python
  /// `/api/ether/voice/voices` endpoint with 1-hour edge caching.
  Future<List<VoiceOption>> listVoices({bool forceRefresh = false}) async {
    if (!forceRefresh && _voiceLibraryCache != null) {
      return List<VoiceOption>.unmodifiable(_voiceLibraryCache!);
    }
    final json = await _http.get('/voice/voices');
    final items =
        json['voices'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        <dynamic>[];
    final voices = items
        .whereType<Map<String, dynamic>>()
        .map(VoiceOption.fromJson)
        .toList(growable: false);
    _voiceLibraryCache = voices;
    return List<VoiceOption>.unmodifiable(voices);
  }

  /// Clear the in-memory voice library cache.
  ///
  /// Forces the next [listVoices] call to refetch from the server. Useful
  /// during development / tests.
  void clearVoiceLibraryCache() {
    _voiceLibraryCache = null;
  }

  /// Update the voice used by a voice agent.
  ///
  /// Sets the Gemini Live voice name (e.g. `Kore`, `Aoede`, `Puck`) on the
  /// agent config. The platform persists the choice in
  /// `voice_agent_configs.voice_profile` and regenerates any cached
  /// greeting audio. The new voice takes effect on the next phone call.
  ///
  /// Routes to `PUT /v1/ether/voice/agents/{agentId}/voice` with body
  /// `{voice_name}`.
  Future<void> updateAgentVoice(String agentId, String voiceName) async {
    await _http.put(
      '/ether/voice/agents/$agentId/voice',
      data: {'voice_name': voiceName},
    );
  }

  /// Return the Gemini Live voice name currently assigned to [agentId].
  ///
  /// Falls back to `Kore` (the platform default) if the agent has no
  /// explicit voice_profile configured.
  ///
  /// Routes to `GET /v1/ether/voice/agents/{agentId}/voice`.
  Future<String> getAgentVoice(String agentId) async {
    final json = await _http.get('/ether/voice/agents/$agentId/voice');
    final name = json['voice_name'] ?? json['voiceName'];
    if (name is String && name.isNotEmpty) return name;
    return 'Kore';
  }

  // ---------------------------------------------------------------------------
  // Marketplace (Voices & Packs)
  // ---------------------------------------------------------------------------

  /// List available voices in the marketplace.
  ///
  /// This targets the community/paid voice marketplace
  /// (`/voice/marketplace/voices`). For the built-in 8 Gemini Live voices,
  /// use [listVoices] instead.
  Future<List<Map<String, dynamic>>> listMarketplaceVoices({
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

  // ---------------------------------------------------------------------------
  // Edge Voice Pipeline (CF Container — STT→Ether→TTS)
  // ---------------------------------------------------------------------------

  /// Process recorded audio through the full edge voice pipeline.
  ///
  /// Sends audio to the CF Container voice pipeline which runs:
  /// STT (Workers AI Whisper, FREE) → Ether classification → AI response → TTS.
  ///
  /// Returns `{transcript, response, audio_url, pipeline_ms}`.
  Future<Map<String, dynamic>> processAudio(
    List<int> audioBytes, {
    String? language,
    String? agentId,
    String? voiceId,
    String? sessionId,
  }) async {
    return _http.post(
      '/voice/process',
      data: {
        'audio': base64Encode(audioBytes),
        if (language != null) 'language': language,
        if (agentId != null) 'agent_id': agentId,
        if (voiceId != null) 'voice_id': voiceId,
        if (sessionId != null) 'session_id': sessionId,
      },
    );
  }

  /// Get the WebSocket URL for streaming voice interaction.
  ///
  /// The WebSocket endpoint at `/ws/voice` accepts:
  /// - `{type: "audio", data: "<base64>"}` — audio chunks
  /// - `{type: "barge_in"}` — interrupt current response
  /// - `{type: "ping"}` — keepalive
  ///
  /// And responds with:
  /// - `{type: "transcript", text: "..."}` — interim STT results
  /// - `{type: "response", text: "...", audio_url: "..."}` — AI response
  /// - `{type: "pong"}` — keepalive response
  ///
  /// Returns the full WebSocket URL based on the configured API base.
  String getVoiceWebSocketUrl({String? sessionId}) {
    final base = _http.config.baseUrl.replaceFirst('https://', 'wss://');
    final path = sessionId != null
        ? '/ws/voice?session_id=$sessionId'
        : '/ws/voice';
    return '$base$path';
  }

  /// Check edge voice pipeline health.
  Future<Map<String, dynamic>> pipelineHealth() async {
    return _http.get('/voice/pipeline/health');
  }

  // ---------------------------------------------------------------------------
  // Caller Profiles (v0.3.0 — Issue #2868)
  // ---------------------------------------------------------------------------

  /// Look up a caller profile by phone number for personalized voice AI.
  ///
  /// Returns preferences, order history, loyalty tier, and past interactions.
  Future<Map<String, dynamic>> getCallerProfile(String phoneNumber) async {
    return _http.get('/caller-profiles/$phoneNumber');
  }

  /// List all caller profiles for the current tenant (paginated).
  Future<Map<String, dynamic>> listCallerProfiles({
    int limit = 50,
    int offset = 0,
  }) async {
    return _http.get(
      '/caller-profiles',
      queryParameters: {'limit': limit, 'offset': offset},
    );
  }

  /// Create or update a caller profile.
  Future<Map<String, dynamic>> upsertCallerProfile(
    Map<String, dynamic> profile,
  ) async {
    return _http.post('/caller-profiles', data: profile);
  }

  /// Delete a caller profile.
  Future<void> deleteCallerProfile(String profileId) async {
    await _http.delete('/caller-profiles/$profileId');
  }

  /// Record an order for a caller (updates stats + loyalty points).
  Future<Map<String, dynamic>> recordCallerOrder(
    String phoneNumber,
    Map<String, dynamic> orderData,
  ) async {
    return _http.post('/caller-profiles/$phoneNumber/orders', data: orderData);
  }

  // ---------------------------------------------------------------------------
  // Escalation Config (v0.3.0 — Issue #2870)
  // ---------------------------------------------------------------------------

  /// Get voice agent escalation config (transfer targets, sentiment threshold).
  Future<Map<String, dynamic>> getEscalationConfig(String agentId) async {
    return _http.get('/voice-agents/$agentId/escalation-config');
  }

  /// Update voice agent escalation config.
  Future<Map<String, dynamic>> updateEscalationConfig(
    String agentId,
    Map<String, dynamic> config,
  ) async {
    return _http.put(
      '/voice-agents/$agentId/escalation-config',
      data: config,
    );
  }

  /// Get voice agent business hours.
  Future<Map<String, dynamic>> getBusinessHours(String agentId) async {
    return _http.get('/voice-agents/$agentId/business-hours');
  }

  /// Update voice agent business hours.
  Future<Map<String, dynamic>> updateBusinessHours(
    String agentId,
    Map<String, dynamic> hours,
  ) async {
    return _http.put('/voice-agents/$agentId/business-hours', data: hours);
  }
}
