import '../http_client.dart';

/// AI skills marketplace: browse, install, and manage voice AI skills.
///
/// Routes: `/skills/*`.
class OlympusSkillsService {
  OlympusSkillsService(this._http);

  final OlympusHttpClient _http;

  /// Browse available skills in the marketplace.
  Future<List<Map<String, dynamic>>> browseMarketplace({
    String? category,
    String? query,
    int? limit,
  }) async {
    final json = await _http.get(
      '/skills/marketplace',
      queryParameters: {'category': ?category, 'q': ?query, 'limit': ?limit},
    );
    final items =
        json['skills'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Get details for a single skill.
  Future<Map<String, dynamic>> getSkill(String skillId) async {
    return _http.get('/skills/$skillId');
  }

  /// Install a skill for the current tenant.
  Future<Map<String, dynamic>> install(String skillId) async {
    return _http.post('/skills/$skillId/install');
  }

  /// Uninstall a skill.
  Future<void> uninstall(String skillId) async {
    await _http.post('/skills/$skillId/uninstall');
  }

  /// List skills currently installed for the tenant.
  Future<List<Map<String, dynamic>>> listInstalled() async {
    final json = await _http.get('/skills/installed');
    final items =
        json['skills'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }
}
