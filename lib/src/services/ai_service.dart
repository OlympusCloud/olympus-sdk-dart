import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../http_client.dart';
import '../models/ai_models.dart';
import '../models/common.dart';

/// AI inference, agent orchestration, embeddings, and NLP.
///
/// Wraps the Olympus AI Gateway (Python) via the Go API Gateway.
/// Routes: `/ai/*`, `/agent/*`, `/translation/*`.
class OlympusAiService {
  OlympusAiService(this._http);

  final OlympusHttpClient _http;

  // ---------------------------------------------------------------------------
  // Chat / Completion
  // ---------------------------------------------------------------------------

  /// Send a single-turn prompt to the AI gateway.
  ///
  /// [tier] selects the model tier (T1-T6). Defaults to server-selected tier.
  ///
  /// [requiredCapabilities] activates capability-based routing (#2919). When
  /// set to a non-text capability set, the request bypasses the text tier
  /// selector and routes directly to the cheapest model matching the
  /// capabilities in the Ether catalog. Examples:
  ///   - `['image_generation']` → Flux Schnell (free) / DALL-E 3 / Imagen 4
  ///   - `['video_generation']` → Veo 3.1 / Kling 2.0 / Runway Gen-4
  ///   - `['medical_specialist', 'reasoning']` → Med-Gemini / Hippocratic
  ///   - `['legal_specialist']` → Harvey / Lexis+ AI
  ///   - `['agentic_coding']` → Codex GPT-5.4 / Qwen Coder / DeepSeek Coder
  ///   - `['world_model']` → Genie 3 / V-JEPA 2 / NVIDIA Cosmos
  ///   - `['robotics_control']` → Gemini Robotics / π0 / Figure Helix
  Future<AiResponse> query(
    String prompt, {
    String? tier,
    Map<String, dynamic>? context,
    List<String>? requiredCapabilities,
  }) async {
    final json = await _http.post(
      '/ai/chat',
      data: {
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'tier': ?tier,
        'context': ?context,
        'required_capabilities': ?requiredCapabilities,
      },
    );
    return AiResponse.fromJson(json);
  }

  /// Generate an image from a text prompt using the cheapest matching
  /// provider in the Ether catalog (Flux Schnell / DALL-E 3 / Imagen 4).
  ///
  /// Returns a map with `image_url` or `image_b64` depending on provider.
  Future<Map<String, dynamic>> generateImage(
    String prompt, {
    String? preferredProvider,
  }) async {
    return _http.post(
      '/ai/chat',
      data: {
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'required_capabilities': ['image_generation'],
        if (preferredProvider != null) 'preferred_provider': preferredProvider,
      },
    );
  }

  /// Generate a video from a text prompt using the cheapest matching
  /// provider (Veo / Kling / Pika / Luma / Hailuo). Returns async job
  /// reference — poll `/ai/video-jobs/:id` for completion.
  Future<Map<String, dynamic>> generateVideo(
    String prompt, {
    int? durationSeconds,
    String? preferredProvider,
  }) async {
    return _http.post(
      '/ai/chat',
      data: {
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'required_capabilities': ['video_generation'],
        if (durationSeconds != null) 'duration_seconds': durationSeconds,
        if (preferredProvider != null) 'preferred_provider': preferredProvider,
      },
    );
  }

  /// Call a vertical specialist model by capability (medical, legal,
  /// financial, scientific). Routes to Med-Gemini, Harvey, BloombergGPT,
  /// ESM-3, etc. based on the specialty flag.
  Future<AiResponse> specialistQuery(
    String prompt,
    String specialty, {
    String? context,
  }) async {
    final caps = <String>[
      'reasoning',
      switch (specialty) {
        'medical' => 'medical_specialist',
        'legal' => 'legal_specialist',
        'financial' => 'financial_specialist',
        'scientific' => 'scientific_specialist',
        _ => 'text',
      },
    ];
    final json = await _http.post(
      '/ai/chat',
      data: {
        'messages': [
          if (context != null) {'role': 'system', 'content': context},
          {'role': 'user', 'content': prompt},
        ],
        'required_capabilities': caps,
      },
    );
    return AiResponse.fromJson(json);
  }

  /// Multi-turn chat completion.
  ///
  /// [messages] is a list of `{role, content}` maps following the
  /// OpenAI-compatible format.
  Future<AiResponse> chat(
    List<Map<String, String>> messages, {
    String? model,
    bool stream = false,
  }) async {
    final json = await _http.post(
      '/ai/chat',
      data: {'messages': messages, 'model': ?model, 'stream': stream},
    );
    return AiResponse.fromJson(json);
  }

  /// Stream a prompt response chunk-by-chunk via SSE.
  ///
  /// Returns a broadcast [Stream] of content delta strings. The caller is
  /// responsible for listening and handling completion.
  Stream<String> stream(String prompt, {void Function(String chunk)? onChunk}) {
    final controller = StreamController<String>.broadcast();

    _streamRequest(prompt, controller, onChunk);

    return controller.stream;
  }

  Future<void> _streamRequest(
    String prompt,
    StreamController<String> controller,
    void Function(String chunk)? onChunk,
  ) async {
    try {
      final response = await _http.dio.post<ResponseBody>(
        '/ai/chat',
        data: {
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'stream': true,
        },
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data?.stream;
      if (stream == null) {
        controller.close();
        return;
      }

      await for (final chunk in stream.transform(
        StreamTransformer<Uint8List, String>.fromHandlers(
          handleData: (data, sink) => sink.add(utf8.decode(data)),
        ),
      )) {
        // SSE format: data: {...}\n\n
        for (final line in chunk.split('\n')) {
          if (line.startsWith('data: ') && line != 'data: [DONE]') {
            final payload = line.substring(6);
            try {
              final parsed = json.decode(payload) as Map<String, dynamic>;
              final content =
                  parsed['choices']?[0]?['delta']?['content'] as String? ??
                  parsed['content'] as String? ??
                  '';
              if (content.isNotEmpty) {
                onChunk?.call(content);
                controller.add(content);
              }
            } on FormatException {
              // Skip malformed SSE lines.
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
  // Agents
  // ---------------------------------------------------------------------------

  /// Invoke a LangGraph agent synchronously.
  Future<AgentResult> invokeAgent(
    String agentName,
    String task, {
    Map<String, dynamic>? params,
  }) async {
    final json = await _http.post(
      '/agent/invoke',
      data: {'agent': agentName, 'task': task, 'params': ?params},
    );
    return AgentResult.fromJson(json);
  }

  /// Create an asynchronous agent task.
  Future<AgentTask> createTask(
    String agent,
    String task, {
    bool? requiresApproval,
    bool? notifyOnComplete,
  }) async {
    final json = await _http.post(
      '/agent/tasks',
      data: {
        'agent': agent,
        'task': task,
        'requires_approval': ?requiresApproval,
        'notify_on_complete': ?notifyOnComplete,
      },
    );
    return AgentTask.fromJson(json);
  }

  /// Poll the status of an async agent task.
  Future<AgentTask> getTaskStatus(String taskId) async {
    final json = await _http.get('/agent/tasks/$taskId');
    return AgentTask.fromJson(json);
  }

  // ---------------------------------------------------------------------------
  // Embeddings & Search
  // ---------------------------------------------------------------------------

  /// Generate an embedding vector for [text].
  Future<List<double>> embed(String text) async {
    final json = await _http.post('/ai/embeddings', data: {'input': text});
    final data = json['data'] as List<dynamic>?;
    if (data != null && data.isNotEmpty) {
      final embedding = data[0]['embedding'] as List<dynamic>?;
      return embedding?.map((e) => (e as num).toDouble()).toList() ?? [];
    }
    final embedding = json['embedding'] as List<dynamic>?;
    return embedding?.map((e) => (e as num).toDouble()).toList() ?? [];
  }

  /// Semantic search over indexed content.
  Future<List<SearchResult>> search(
    String query, {
    String? index,
    int? limit,
  }) async {
    final json = await _http.post(
      '/ai/search',
      data: {'query': query, 'index': ?index, 'limit': ?limit},
    );
    final results = json['results'] as List<dynamic>? ?? [];
    return results
        .map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // NLP Utilities
  // ---------------------------------------------------------------------------

  /// Classify text into categories.
  Future<Classification> classify(String text) async {
    final json = await _http.post('/ai/classify', data: {'text': text});
    return Classification.fromJson(json);
  }

  /// Translate text to [targetLang] (ISO 639-1 code).
  Future<String> translate(String text, String targetLang) async {
    final json = await _http.post(
      '/translation/translate',
      data: {'text': text, 'target_language': targetLang},
    );
    return json['translated_text'] as String? ??
        json['translation'] as String? ??
        '';
  }

  /// Analyze sentiment of text.
  Future<SentimentResult> sentiment(String text) async {
    final json = await _http.post('/ai/sentiment', data: {'text': text});
    return SentimentResult.fromJson(json);
  }

  // ---------------------------------------------------------------------------
  // Speech
  // ---------------------------------------------------------------------------

  /// Speech-to-text: transcribe audio bytes.
  Future<String> stt(List<int> audioBytes) async {
    final json = await _http.post(
      '/ai/stt',
      data: {'audio': base64Encode(audioBytes)},
    );
    return json['text'] as String? ?? json['transcript'] as String? ?? '';
  }

  /// Text-to-speech: synthesize audio bytes from text.
  Future<List<int>> tts(String text, {String? voiceId}) async {
    final json = await _http.post(
      '/ai/tts',
      data: {'text': text, 'voice_id': ?voiceId},
    );
    final audioBase64 = json['audio'] as String?;
    if (audioBase64 != null) {
      return base64Decode(audioBase64);
    }
    return [];
  }

  // ---------------------------------------------------------------------------
  // RAG (Vectorize) — Issue #2724
  // ---------------------------------------------------------------------------

  /// Semantic search over a tenant's Vectorize knowledge base.
  ///
  /// [namespace] must be one of: `menu`, `knowledge`, `products`, `operations`,
  /// `sales`. Defaults to `knowledge`. [topK] bounds the number of matches
  /// returned (1-100). [minScore] filters matches below the given similarity.
  Future<Map<String, dynamic>> ragQuery(
    String query, {
    String? namespace,
    int? topK,
    double? minScore,
    Map<String, String>? filters,
  }) async {
    return _http.post(
      '/rag/query',
      data: {
        'query': query,
        'namespace': ?namespace,
        'top_k': ?topK,
        'min_score': ?minScore,
        'filters': ?filters,
      },
    );
  }

  /// Generate a vector embedding for [text] using the platform embedding model.
  ///
  /// Returns the raw response including `embedding`, `dimensions`, and `model`.
  Future<Map<String, dynamic>> ragEmbed(
    String text, {
    String? model,
  }) async {
    return _http.post(
      '/rag/embed',
      data: {'text': text, 'model': ?model},
    );
  }

  /// Index (upsert) a document into the tenant's Vectorize knowledge base.
  ///
  /// Returns the indexing result (id, namespace, status).
  Future<Map<String, dynamic>> ragIndex({
    required String namespace,
    required String id,
    required String text,
    Map<String, dynamic>? metadata,
  }) async {
    return _http.post(
      '/rag/index',
      data: {
        'namespace': namespace,
        'id': id,
        'text': text,
        'metadata': ?metadata,
      },
    );
  }

  /// List available RAG indexes for the authenticated tenant.
  Future<List<Map<String, dynamic>>> ragListIndexes({String? status}) async {
    final json = await _http.get(
      '/rag/indexes',
      queryParameters: {'status': ?status},
    );
    final items = json['indexes'] as List<dynamic>? ?? [];
    return items.cast<Map<String, dynamic>>();
  }

  // ---------------------------------------------------------------------------
  // Gemini Live — Issue #2728
  // ---------------------------------------------------------------------------

  /// Gemini Live accessor — real-time multimodal AI conversations.
  OlympusGeminiLive get geminiLive => OlympusGeminiLive(_http);
}

/// Gemini Live session management.
///
/// Real-time multimodal AI conversations via Vertex AI Gemini Live API.
/// Routes: `/gemini-live/*` (mounted at `/v1/gemini-live` by the Go gateway).
class OlympusGeminiLive {
  OlympusGeminiLive(this._http);

  final OlympusHttpClient _http;

  /// Create (start) a new Gemini Live session.
  ///
  /// Returns a session record that includes `session_id`, `websocket_url`,
  /// `status`, and any configuration echoed back by the server. Callers use
  /// the `websocket_url` to open the streaming connection.
  Future<Map<String, dynamic>> startSession({
    String? model,
    String? voice,
    String? language,
    List<String>? tools,
    Map<String, dynamic>? context,
  }) async {
    return _http.post(
      '/gemini-live/session',
      data: {
        'model': ?model,
        'voice': ?voice,
        'language': ?language,
        'tools': ?tools,
        'context': ?context,
      },
    );
  }

  /// Get the current status and metadata of a Gemini Live session.
  Future<Map<String, dynamic>> getSession(String sessionId) async {
    return _http.get('/gemini-live/session/$sessionId');
  }

  /// End an active Gemini Live session and release its resources.
  Future<void> endSession(String sessionId) async {
    await _http.delete('/gemini-live/session/$sessionId');
  }

  /// Update the configuration of an active Gemini Live session.
  ///
  /// Use this to change voice, language, or enabled tools mid-session.
  Future<Map<String, dynamic>> configureSession(
    String sessionId, {
    String? voice,
    String? language,
    List<String>? tools,
  }) async {
    return _http.post(
      '/gemini-live/session/$sessionId/config',
      data: {
        'voice': ?voice,
        'language': ?language,
        'tools': ?tools,
      },
    );
  }

  /// Convenience wrapper: [startSession] that also returns the WebSocket URL.
  ///
  /// Returns a tuple-like map with keys `session_id` and `websocket_url` that
  /// callers can pass directly to a streaming client.
  Future<Map<String, String>> stream({
    String? model,
    String? voice,
    String? language,
    List<String>? tools,
    Map<String, dynamic>? context,
  }) async {
    final json = await startSession(
      model: model,
      voice: voice,
      language: language,
      tools: tools,
      context: context,
    );
    return {
      'session_id': (json['session_id'] as String?) ?? '',
      'websocket_url': (json['websocket_url'] as String?) ?? '',
    };
  }
}
