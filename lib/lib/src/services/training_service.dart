import '../http_client.dart';

/// Voice AI training: FAQ management, upsell rules, custom instructions,
/// and knowledge base synchronization.
///
/// Routes: `/training/*`.
class OlympusTrainingService {
  OlympusTrainingService(this._http);

  final OlympusHttpClient _http;

  // ---------------------------------------------------------------------------
  // FAQ
  // ---------------------------------------------------------------------------

  /// List all FAQ entries for the tenant.
  Future<List<Map<String, dynamic>>> listFaq({int? page, int? limit}) async {
    final json = await _http.get(
      '/training/faq',
      queryParameters: {'page': ?page, 'limit': ?limit},
    );
    final items =
        json['faqs'] as List<dynamic>? ?? json['data'] as List<dynamic>? ?? [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Create a new FAQ entry.
  Future<Map<String, dynamic>> createFaq(Map<String, dynamic> faq) async {
    return _http.post('/training/faq', data: faq);
  }

  /// Update an existing FAQ entry.
  Future<Map<String, dynamic>> updateFaq(
    String faqId,
    Map<String, dynamic> faq,
  ) async {
    return _http.put('/training/faq/$faqId', data: faq);
  }

  /// Delete a FAQ entry.
  Future<void> deleteFaq(String faqId) async {
    await _http.delete('/training/faq/$faqId');
  }

  // ---------------------------------------------------------------------------
  // Upsell Rules
  // ---------------------------------------------------------------------------

  /// List all upsell rules for the tenant.
  Future<List<Map<String, dynamic>>> listUpsellRules({
    int? page,
    int? limit,
  }) async {
    final json = await _http.get(
      '/training/upsell-rules',
      queryParameters: {'page': ?page, 'limit': ?limit},
    );
    final items =
        json['rules'] as List<dynamic>? ?? json['data'] as List<dynamic>? ?? [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Create a new upsell rule.
  Future<Map<String, dynamic>> createUpsellRule(
    Map<String, dynamic> rule,
  ) async {
    return _http.post('/training/upsell-rules', data: rule);
  }

  /// Toggle an upsell rule on or off.
  Future<Map<String, dynamic>> toggleUpsellRule(
    String ruleId, {
    required bool enabled,
  }) async {
    return _http.patch(
      '/training/upsell-rules/$ruleId',
      data: {'enabled': enabled},
    );
  }

  /// Delete an upsell rule.
  Future<void> deleteUpsellRule(String ruleId) async {
    await _http.delete('/training/upsell-rules/$ruleId');
  }

  // ---------------------------------------------------------------------------
  // Instructions
  // ---------------------------------------------------------------------------

  /// Get the current custom instructions for the voice agent.
  Future<Map<String, dynamic>> getInstructions() async {
    return _http.get('/training/instructions');
  }

  /// Save custom instructions for the voice agent.
  Future<Map<String, dynamic>> saveInstructions(
    Map<String, dynamic> instructions,
  ) async {
    return _http.put('/training/instructions', data: instructions);
  }

  // ---------------------------------------------------------------------------
  // Sync & Indexing
  // ---------------------------------------------------------------------------

  /// Get the current training/indexing status.
  Future<Map<String, dynamic>> getStatus() async {
    return _http.get('/training/status');
  }

  /// Trigger a sync from the menu/catalog to the training knowledge base.
  Future<Map<String, dynamic>> syncFromMenu() async {
    return _http.post('/training/sync-from-menu');
  }

  /// Trigger a full reindex of all training data.
  Future<Map<String, dynamic>> reindexAll() async {
    return _http.post('/training/reindex');
  }
}
