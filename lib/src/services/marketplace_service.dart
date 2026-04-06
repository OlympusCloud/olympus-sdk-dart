import '../http_client.dart';
import '../models/marketplace_models.dart';

/// Olympus Marketplace: discover, install, and manage third-party apps.
///
/// Routes: `/marketplace/*` (Algolia-powered discovery + Spanner install state).
class OlympusMarketplaceService {
  OlympusMarketplaceService(this._http);

  final OlympusHttpClient _http;

  /// List available marketplace apps with optional filters.
  Future<List<MarketplaceApp>> listApps({
    String? category,
    String? industry,
    String? query,
    int? limit,
  }) async {
    final json = await _http.get('/marketplace/apps', queryParameters: {
      'category': ?category,
      'industry': ?industry,
      'q': ?query,
      'limit': ?limit,
    });
    final items =
        json['apps'] as List<dynamic>? ?? json['data'] as List<dynamic>? ?? [];
    return items
        .map((e) => MarketplaceApp.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get details for a single marketplace app.
  Future<MarketplaceApp> getApp(String appId) async {
    final json = await _http.get('/marketplace/apps/$appId');
    return MarketplaceApp.fromJson(json);
  }

  /// Install a marketplace app for the current tenant.
  Future<Installation> install(String appId) async {
    final json = await _http.post('/marketplace/apps/$appId/install');
    return Installation.fromJson(json);
  }

  /// Uninstall a marketplace app.
  Future<void> uninstall(String appId) async {
    await _http.post('/marketplace/apps/$appId/uninstall');
  }

  /// List apps currently installed for the tenant.
  Future<List<Installation>> getInstalled() async {
    final json = await _http.get('/marketplace/installed');
    final items = json['installations'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items
        .map((e) => Installation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Submit a review for a marketplace app.
  Future<void> review(String appId, int rating, String text) async {
    await _http.post('/marketplace/apps/$appId/reviews', data: {
      'rating': rating,
      'text': text,
    });
  }
}
