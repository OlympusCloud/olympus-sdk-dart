import '../http_client.dart';

/// The Ether — Agent Control Plane (ACP) for edge AI and agent orchestration.
///
/// Provides direct access to edge-deployed AI services:
/// - Edge classification via Python Worker (`/ether/classify`)
/// - Fast T1 inference via Ether Fast Worker (`/ether/fast`)
/// - Embeddings generation (`/ether/embed`)
/// - Sentiment analysis (`/ether/sentiment`)
/// - Language detection (`/ether/language`)
/// - Full analysis (classify + sentiment + language in one call)
/// - TTS cache lookup (`/ether/tts-cache`)
/// - OCR analysis (`/ether/ocr-analyze`)
///
/// All edge classification runs on FREE Workers AI models ($0 cost).
class OlympusEtherService {
  OlympusEtherService(this._http);

  final OlympusHttpClient _http;

  // ---------------------------------------------------------------------------
  // Edge Classification (Python Worker — FREE Workers AI)
  // ---------------------------------------------------------------------------

  /// Classify a query into domain, intent, complexity, and confidence.
  ///
  /// Uses the edge Python Worker with Llama 3.2 1B (FREE).
  /// Returns `{domain, intent, complexity, confidence, model, source}`.
  Future<Map<String, dynamic>> classify(
    String query, {
    String? shellType,
    int? turnCount,
  }) async {
    return _http.post(
      '/ether/classify',
      data: {
        'query': query,
        if (shellType != null || turnCount != null)
          'context': {
            if (shellType != null) 'shell_type': shellType,
            if (turnCount != null) 'turn_count': turnCount,
          },
      },
    );
  }

  /// Analyze sentiment of text using DistilBERT (FREE).
  ///
  /// Returns `{sentiment: [{label, score}], model, source}`.
  Future<Map<String, dynamic>> sentiment(String text) async {
    return _http.post('/ether/sentiment', data: {'query': text});
  }

  /// Detect language using Gemma 3 12B (FREE, 140+ languages).
  ///
  /// Returns `{language: "en", model, source}`.
  Future<Map<String, dynamic>> detectLanguage(String text) async {
    return _http.post('/ether/language', data: {'query': text});
  }

  /// Full analysis: classify + sentiment + language in one call.
  ///
  /// Returns merged result with all fields.
  Future<Map<String, dynamic>> fullAnalysis(
    String query, {
    String? shellType,
    int? turnCount,
  }) async {
    return _http.post(
      '/ether/full',
      data: {
        'query': query,
        if (shellType != null || turnCount != null)
          'context': {
            if (shellType != null) 'shell_type': shellType,
            if (turnCount != null) 'turn_count': turnCount,
          },
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Ether Fast (T1 Edge AI Worker)
  // ---------------------------------------------------------------------------

  /// Fast T1 inference at the edge via Workers AI.
  ///
  /// For quick, low-latency AI responses that don't need full Ether routing.
  Future<Map<String, dynamic>> fast(
    String query, {
    String? model,
    int? maxTokens,
    double? temperature,
  }) async {
    return _http.post(
      '/ether/fast',
      data: {
        'query': query,
        if (model != null) 'model': model,
        if (maxTokens != null) 'max_tokens': maxTokens,
        if (temperature != null) 'temperature': temperature,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Embeddings
  // ---------------------------------------------------------------------------

  /// Generate an embedding vector at the edge.
  ///
  /// Returns the embedding result including vector, dimensions, and model.
  Future<Map<String, dynamic>> embed(
    String text, {
    String? model,
  }) async {
    return _http.post(
      '/ether/embed',
      data: {'text': text, if (model != null) 'model': model},
    );
  }

  // ---------------------------------------------------------------------------
  // TTS Cache
  // ---------------------------------------------------------------------------

  /// Look up a cached TTS audio URL by text hash.
  ///
  /// Returns `{url, cached}` if found, or generates new audio.
  Future<Map<String, dynamic>> ttsCache(
    String text, {
    String? voiceId,
    String? language,
  }) async {
    return _http.post(
      '/ether/tts-cache',
      data: {
        'text': text,
        if (voiceId != null) 'voice_id': voiceId,
        if (language != null) 'language': language,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // OCR
  // ---------------------------------------------------------------------------

  /// Analyze an image via OCR at the edge.
  Future<Map<String, dynamic>> ocrAnalyze(
    String imageUrl, {
    String? mode,
  }) async {
    return _http.post(
      '/ether/ocr-analyze',
      data: {'image_url': imageUrl, if (mode != null) 'mode': mode},
    );
  }

  // ---------------------------------------------------------------------------
  // Context
  // ---------------------------------------------------------------------------

  /// Get conversation context for a session.
  Future<Map<String, dynamic>> getContext(String contextId) async {
    return _http.get('/ether/context/$contextId');
  }

  // ---------------------------------------------------------------------------
  // Health
  // ---------------------------------------------------------------------------

  /// Check Ether edge service health.
  Future<Map<String, dynamic>> health() async {
    return _http.get('/ether/health');
  }
}
