import 'dart:convert';

import '../http_client.dart';

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
    return _http.put('/voice-agents/$agentId/escalation-config', data: config);
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

  // ---------------------------------------------------------------------------
  // Self-service Agent CRUD (v0.4.0 — epic OlympusCloud/orderecho-ai#119)
  // ---------------------------------------------------------------------------
  // The methods below back the OrderEcho Agent Editor: list/clone/duplicate
  // agents, instantiate from templates, preview voices, manage personas, and
  // configure background ambiance — all so tenants never need a code change
  // to roll out a new restaurant or tweak a voice character.

  /// List all voice agents for the current tenant.
  ///
  /// Aliased to [listConfigs] for naming clarity in the Agent Editor; both
  /// hit the same `/voice-agents/configs` endpoint.
  Future<List<Map<String, dynamic>>> listAgents({int? page, int? limit}) =>
      listConfigs(page: page, limit: limit);

  /// Get a single agent by ID. Alias for [getConfig].
  Future<Map<String, dynamic>> getAgent(String agentId) => getConfig(agentId);

  /// Create a new voice agent.
  ///
  /// When [fromTemplateId] is set, the new agent is initialized from the
  /// referenced template (persona, voice, greeting, escalation, ambiance,
  /// voice overrides) and only top-level fields like [name] / [phoneNumber]
  /// / [locationId] need to be supplied. Otherwise the agent is created
  /// from scratch and all fields default to platform values.
  Future<Map<String, dynamic>> createAgent({
    String? fromTemplateId,
    String? name,
    String? voiceId,
    String? persona,
    String? greeting,
    String? phoneNumber,
    String? locationId,
    Map<String, dynamic>? ambianceConfig,
    Map<String, dynamic>? voiceOverrides,
    Map<String, dynamic>? businessHours,
    List<Map<String, dynamic>>? escalationRules,
  }) async {
    return _http.post(
      '/voice-agents/configs',
      data: {
        if (fromTemplateId != null) 'from_template_id': fromTemplateId,
        if (name != null) 'name': name,
        if (voiceId != null) 'voice_id': voiceId,
        if (persona != null) 'persona': persona,
        if (greeting != null) 'greeting': greeting,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (locationId != null) 'location_id': locationId,
        if (ambianceConfig != null) 'ambiance_config': ambianceConfig,
        if (voiceOverrides != null) 'voice_overrides': voiceOverrides,
        if (businessHours != null) 'business_hours': businessHours,
        if (escalationRules != null) 'escalation_rules': escalationRules,
      },
    );
  }

  /// Update mutable fields on an existing agent. Any non-null field is set;
  /// nulls are left unchanged on the server side.
  Future<Map<String, dynamic>> updateAgent(
    String agentId, {
    String? name,
    String? voiceId,
    String? persona,
    String? greeting,
    Map<String, dynamic>? ambianceConfig,
    Map<String, dynamic>? voiceOverrides,
    Map<String, dynamic>? businessHours,
    List<Map<String, dynamic>>? escalationRules,
    bool? isActive,
  }) async {
    return _http.put(
      '/voice-agents/configs/$agentId',
      data: {
        if (name != null) 'name': name,
        if (voiceId != null) 'voice_id': voiceId,
        if (persona != null) 'persona': persona,
        if (greeting != null) 'greeting': greeting,
        if (ambianceConfig != null) 'ambiance_config': ambianceConfig,
        if (voiceOverrides != null) 'voice_overrides': voiceOverrides,
        if (businessHours != null) 'business_hours': businessHours,
        if (escalationRules != null) 'escalation_rules': escalationRules,
        if (isActive != null) 'is_active': isActive,
      },
    );
  }

  /// Delete a voice agent. Alias for [deleteConfig].
  Future<void> deleteAgent(String agentId) => deleteConfig(agentId);

  /// Clone an existing agent. The new agent inherits persona, voice, greeting,
  /// escalation, ambiance and voice overrides from the source — only the
  /// name and phone number are reset.
  Future<Map<String, dynamic>> cloneAgent(
    String agentId, {
    String? newName,
    String? phoneNumber,
    String? locationId,
  }) async {
    return _http.post(
      '/voice-agents/configs/$agentId/clone',
      data: {
        if (newName != null) 'new_name': newName,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (locationId != null) 'location_id': locationId,
      },
    );
  }

  /// Generate a TTS preview clip for an agent so the editor can audition the
  /// current voice + persona without making a real call.
  ///
  /// Returns `{audio_url, audio_base64?, format, duration_ms}`. Useful for
  /// the Voice tab "preview" button in the Agent Editor.
  Future<Map<String, dynamic>> previewAgentVoice(
    String agentId, {
    required String sampleText,
    String? voiceId,
    Map<String, dynamic>? voiceOverrides,
  }) async {
    return _http.post(
      '/voice-agents/configs/$agentId/preview',
      data: {
        'sample_text': sampleText,
        if (voiceId != null) 'voice_id': voiceId,
        if (voiceOverrides != null) 'voice_overrides': voiceOverrides,
      },
    );
  }

  /// List the catalog of available Gemini Live voices (Aoede, Charon, Fenrir,
  /// Kore, Leda, Orus, Puck, Zephyr) plus any tenant-installed marketplace
  /// voices. Each entry includes a sample URL the editor can play inline.
  ///
  /// Use this in the Agent Editor's Voice tab to populate the voice picker.
  Future<List<Map<String, dynamic>>> listGeminiVoices({
    String? language,
  }) async {
    final json = await _http.get(
      '/voice/voices',
      queryParameters: {if (language != null) 'language': language},
    );
    final items =
        json['voices'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  // ---------------------------------------------------------------------------
  // Persona library
  // ---------------------------------------------------------------------------

  /// List curated voice personas. Filter by [category] (e.g.
  /// `hospitality_casual`, `hospitality_polished`, `retail_friendly`) or
  /// [industry] (e.g. `restaurant`, `bar`, `cafe`).
  Future<List<Map<String, dynamic>>> listPersonas({
    String? category,
    String? industry,
    bool? premiumOnly,
  }) async {
    final json = await _http.get(
      '/voice/personas',
      queryParameters: {
        if (category != null) 'category': category,
        if (industry != null) 'industry': industry,
        if (premiumOnly != null) 'premium_only': premiumOnly.toString(),
      },
    );
    final items =
        json['personas'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Get a single persona by ID or slug.
  Future<Map<String, dynamic>> getPersona(String idOrSlug) async {
    return _http.get('/voice/personas/$idOrSlug');
  }

  /// Apply a persona to an existing agent. Copies persona text, voice ID,
  /// and suggested voice overrides from the persona into the agent in one
  /// atomic update. Returns the updated agent.
  Future<Map<String, dynamic>> applyPersonaToAgent(
    String agentId,
    String personaIdOrSlug,
  ) async {
    return _http.post(
      '/voice-agents/configs/$agentId/apply-persona',
      data: {'persona': personaIdOrSlug},
    );
  }

  // ---------------------------------------------------------------------------
  // Templates (full agent templates — distinct from voice marketplace voices)
  // ---------------------------------------------------------------------------

  /// List voice agent templates. Use [scope] = `tenant` for the current
  /// tenant's private template library, `global` for the platform-wide
  /// shared library, or omit for both.
  Future<List<Map<String, dynamic>>> listAgentTemplates({String? scope}) async {
    final json = await _http.get(
      '/voice-agents/templates',
      queryParameters: {if (scope != null) 'scope': scope},
    );
    final items =
        json['templates'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Instantiate a new agent from an existing template.
  Future<Map<String, dynamic>> instantiateAgentTemplate(
    String templateId, {
    required String name,
    String? phoneNumber,
    String? locationId,
  }) async {
    return _http.post(
      '/voice-agents/templates/$templateId/instantiate',
      data: {
        'name': name,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (locationId != null) 'location_id': locationId,
      },
    );
  }

  /// Publish the current agent as a tenant- or globally-visible template.
  /// [scope] = `tenant` keeps it private, `global` requires platform approval.
  Future<Map<String, dynamic>> publishAgentAsTemplate(
    String agentId, {
    required String scope,
    String? description,
  }) async {
    return _http.post(
      '/voice-agents/configs/$agentId/publish-template',
      data: {
        'scope': scope,
        if (description != null) 'description': description,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Background ambiance
  // ---------------------------------------------------------------------------

  /// List the curated library of ambient beds (busy pizza place, quiet cafe,
  /// drive-thru, hotel lobby, etc.). Each entry includes a sample URL plus
  /// a recommended intensity (0..1).
  Future<List<Map<String, dynamic>>> listAmbianceLibrary({
    String? category,
  }) async {
    final json = await _http.get(
      '/voice/ambiance/library',
      queryParameters: {if (category != null) 'category': category},
    );
    final items =
        json['beds'] as List<dynamic>? ?? json['data'] as List<dynamic>? ?? [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Upload a custom ambient bed (mulaw 8kHz mono, looped, ~30 seconds).
  /// Returns `{r2_key, url, duration_ms}` for the uploaded asset.
  ///
  /// The [audioBytes] should be base64-encoded mulaw — the platform validates
  /// format on receipt and rejects anything that isn't loopable.
  Future<Map<String, dynamic>> uploadAmbianceBed(
    List<int> audioBytes, {
    required String name,
    String? timeOfDay,
    String? description,
  }) async {
    return _http.post(
      '/voice/ambiance/upload',
      data: {
        'name': name,
        'audio_base64': base64Encode(audioBytes),
        if (timeOfDay != null) 'time_of_day': timeOfDay,
        if (description != null) 'description': description,
      },
    );
  }

  /// Update an agent's ambiance configuration.
  Future<Map<String, dynamic>> updateAgentAmbiance(
    String agentId, {
    bool? enabled,
    double? intensity,
    String? defaultR2Key,
    Map<String, String>? timeOfDayVariants,
  }) async {
    return _http.patch(
      '/voice-agents/configs/$agentId/ambiance',
      data: {
        if (enabled != null) 'enabled': enabled,
        if (intensity != null) 'intensity': intensity,
        if (defaultR2Key != null) 'default_r2_key': defaultR2Key,
        if (timeOfDayVariants != null)
          'time_of_day_variants': timeOfDayVariants,
      },
    );
  }

  /// Update an agent's voice tuning overrides (pitch, speed, warmth, dialect).
  Future<Map<String, dynamic>> updateAgentVoiceOverrides(
    String agentId, {
    double? pitch,
    double? speed,
    double? warmth,
    String? regionalDialect,
  }) async {
    return _http.patch(
      '/voice-agents/configs/$agentId/voice-overrides',
      data: {
        if (pitch != null) 'pitch': pitch,
        if (speed != null) 'speed': speed,
        if (warmth != null) 'warmth': warmth,
        if (regionalDialect != null) 'regional_dialect': regionalDialect,
      },
    );
  }
}
