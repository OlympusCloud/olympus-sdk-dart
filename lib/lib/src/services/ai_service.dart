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
  Future<AiResponse> query(
    String prompt, {
    String? tier,
    Map<String, dynamic>? context,
  }) async {
    final json = await _http.post(
      '/ai/chat',
      data: {
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'tier': ?tier,
        'context': ?context,
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
}
