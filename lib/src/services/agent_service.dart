import '../http_client.dart';

/// LangGraph Agent service — chat, approval, content suggestions, upsell,
/// and OTA patch dispatch.
///
/// Wraps the Python agent_routes module via the Go API Gateway:
///   - `POST /api/v1/agent/chat`               — agent chat with intent
///                                                routing + RAG retrieval +
///                                                planning + (optional)
///                                                approval gate
///   - `POST /api/v1/agent/chat/phone`         — low-latency phone variant
///   - `POST /api/v1/agent/approve`            — approve/reject a paused
///                                                agent action
///   - `GET  /api/v1/agent/history/{session}`  — chat history for a session
///   - `GET  /api/v1/agent/status`             — agent runtime availability
///   - `POST /api/v1/agent/content/suggestion` — social content ideas + drafts
///   - `POST /api/v1/agent/upsell`             — cart-aware upsell ideas
///   - `POST /api/v1/agent/ota/push`           — push a self-healing UI
///                                                patch to tenant devices
///
/// All AI-backed endpoints flow through the AI usage middleware and
/// bill against the supplied tenant.
class OlympusAgentService {
  OlympusAgentService(this._http);

  final OlympusHttpClient _http;

  // ---------------------------------------------------------------------
  // Chat + approval
  // ---------------------------------------------------------------------

  /// Process a chat message through the LangGraph workflow.
  ///
  /// Returns a [AgentChatResponse]. When the workflow pauses for human
  /// approval, [AgentChatResponse.requiresApproval] is `true` and the
  /// caller should surface the [AgentChatResponse.approvalReason] to a
  /// reviewer, then call [approve] with the same `sessionId`.
  Future<AgentChatResponse> chat({
    required String message,
    required String tenantId,
    required String userId,
    required String sessionId,
    required String shellType,
    String? domain,
    int? complexity,
  }) async {
    final json = await _http.post(
      '/agent/chat',
      data: {
        'message': message,
        'tenant_id': tenantId,
        'user_id': userId,
        'session_id': sessionId,
        'shell_type': shellType,
        'domain': ?domain,
        'complexity': ?complexity,
      },
    );
    return AgentChatResponse.fromJson(json);
  }

  /// Low-latency variant of [chat] for phone/voice transcripts. Always
  /// runs through the simplified phone agent, regardless of [domain].
  Future<AgentChatResponse> chatPhone({
    required String message,
    required String tenantId,
    required String userId,
    required String sessionId,
  }) async {
    final json = await _http.post(
      '/agent/chat/phone',
      data: {
        'message': message,
        'tenant_id': tenantId,
        'user_id': userId,
        'session_id': sessionId,
        'shell_type': 'customer',
      },
    );
    return AgentChatResponse.fromJson(json);
  }

  /// Approve or reject a paused agent action. Resumes the LangGraph
  /// workflow from the human_approval node.
  Future<Map<String, dynamic>> approve({
    required String sessionId,
    required String threadId,
    required bool approved,
    required String approverId,
    String? reason,
  }) async {
    return await _http.post(
      '/agent/approve',
      data: {
        'session_id': sessionId,
        'thread_id': threadId,
        'approved': approved,
        'approver_id': approverId,
        'reason': ?reason,
      },
    );
  }

  /// Fetch the chat history for a session.
  Future<Map<String, dynamic>> getHistory(String sessionId) async {
    return await _http.get('/agent/history/$sessionId');
  }

  /// Check whether the LangGraph runtime is available on the server.
  Future<AgentRuntimeStatus> getStatus() async {
    final json = await _http.get('/agent/status');
    return AgentRuntimeStatus(
      available: json['available'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }

  // ---------------------------------------------------------------------
  // Content + upsell
  // ---------------------------------------------------------------------

  /// Generate social media content suggestions: ideas, per-platform drafts,
  /// and predicted performance analysis.
  Future<Map<String, dynamic>> suggestContent({
    required String topic,
    required List<String> platforms,
    required String tone,
    String? context,
    String? industry,
  }) async {
    return await _http.post(
      '/agent/content/suggestion',
      data: {
        'topic': topic,
        'platforms': platforms,
        'tone': tone,
        'context': ?context,
        'industry': ?industry,
      },
    );
  }

  /// Generate cart-aware upsell suggestions and rationale.
  Future<Map<String, dynamic>> generateUpsell({
    required List<Map<String, dynamic>> cartItems,
    required String userId,
    required String tenantId,
    required String sessionId,
  }) async {
    return await _http.post(
      '/agent/upsell',
      data: {
        'cart_items': cartItems,
        'user_id': userId,
        'tenant_id': tenantId,
        'session_id': sessionId,
      },
    );
  }

  // ---------------------------------------------------------------------
  // OTA self-healing UI patches
  // ---------------------------------------------------------------------

  /// Push an OTA UI patch to a tenant's active devices (Issue #2822).
  ///
  /// Used by ACOS agents for autonomous self-healing — when an agent
  /// detects a UI overflow or layout bug it can ship a patch to all
  /// connected sessions without a full app release.
  Future<Map<String, dynamic>> pushOtaPatch({
    required String tenantId,
    required Map<String, dynamic> patchDefinition,
    String? patchId,
  }) async {
    return await _http.post(
      '/agent/ota/push',
      data: {
        'tenant_id': tenantId,
        'patch_definition': patchDefinition,
        'patch_id': ?patchId,
      },
    );
  }
}

// ---------------------------------------------------------------------
// Response models
// ---------------------------------------------------------------------

/// Response from [OlympusAgentService.chat] / [OlympusAgentService.chatPhone].
class AgentChatResponse {
  const AgentChatResponse({
    required this.sessionId,
    required this.threadId,
    required this.requiresApproval,
    this.response,
    this.approvalReason,
  });

  /// Generated agent response text. May be `null` if the workflow paused
  /// before producing one.
  final String? response;

  /// Whether the workflow paused at the human_approval node.
  final bool requiresApproval;

  /// Human-readable reason the agent is asking for approval.
  final String? approvalReason;

  final String sessionId;

  /// LangGraph thread id — used to resume via [OlympusAgentService.approve].
  final String threadId;

  factory AgentChatResponse.fromJson(Map<String, dynamic> json) =>
      AgentChatResponse(
        response: json['response'] as String?,
        requiresApproval: json['requires_approval'] as bool? ?? false,
        approvalReason: json['approval_reason'] as String?,
        sessionId: json['session_id'] as String? ?? '',
        threadId: json['thread_id'] as String? ?? '',
      );
}

/// Status of the agent runtime on the server.
class AgentRuntimeStatus {
  const AgentRuntimeStatus({required this.available, required this.message});

  /// Whether LangGraph + the agents are loaded.
  final bool available;

  /// Human-readable status message ("LangGraph agent ready" or similar).
  final String message;
}
