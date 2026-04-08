import '../http_client.dart';

/// Ad mediation helpers — Issue #2729.
///
/// Provides SDK access to the Go Gateway's ad mediation endpoints:
///   - Placement CRUD
///   - Impression logging
///   - Revenue reporting
///
/// Routes: `/ads/*`.
class OlympusAdsService {
  OlympusAdsService(this._http);

  final OlympusHttpClient _http;

  // ---------------------------------------------------------------------------
  // Placements
  // ---------------------------------------------------------------------------

  /// Create a new ad placement.
  ///
  /// [format] must be one of: `banner`, `interstitial`, `native`, `rewarded`,
  /// `mrec`. [providers] is a list of provider configurations (name, ad_unit_id,
  /// priority, enabled).
  Future<Map<String, dynamic>> createPlacement({
    required String name,
    required String format,
    String? position,
    List<Map<String, dynamic>>? providers,
  }) async {
    return _http.post(
      '/ads/placements',
      data: {
        'name': name,
        'format': format,
        'position': ?position,
        'providers': ?providers,
      },
    );
  }

  /// List ad placements for the authenticated tenant.
  Future<List<Map<String, dynamic>>> listPlacements({
    int? limit,
    int? offset,
  }) async {
    final json = await _http.get(
      '/ads/placements',
      queryParameters: {'limit': ?limit, 'offset': ?offset},
    );
    final items = json['placements'] as List<dynamic>? ?? [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Get a single ad placement by ID.
  Future<Map<String, dynamic>> getPlacement(String placementId) async {
    return _http.get('/ads/placements/$placementId');
  }

  /// Update an existing ad placement.
  Future<Map<String, dynamic>> updatePlacement(
    String placementId, {
    String? name,
    String? format,
    String? position,
    List<Map<String, dynamic>>? providers,
    bool? active,
  }) async {
    return _http.put(
      '/ads/placements/$placementId',
      data: {
        'name': ?name,
        'format': ?format,
        'position': ?position,
        'providers': ?providers,
        'active': ?active,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Impressions
  // ---------------------------------------------------------------------------

  /// Log an ad impression (or click/view) for revenue attribution.
  ///
  /// [eventType] defaults to `impression` when not provided. Pass `click` or
  /// `view` for click-through or view-through tracking.
  Future<Map<String, dynamic>> recordImpression({
    required String placementId,
    required String providerName,
    String? adUnitId,
    double revenue = 0,
    String? currency,
    String? eventType,
  }) async {
    return _http.post(
      '/ads/impressions',
      data: {
        'placement_id': placementId,
        'provider_name': providerName,
        'ad_unit_id': ?adUnitId,
        'revenue': revenue,
        'currency': ?currency,
        'event_type': ?eventType,
      },
    );
  }

  /// Convenience: record a click event for a placement.
  Future<Map<String, dynamic>> recordClick({
    required String placementId,
    required String providerName,
    String? adUnitId,
    double revenue = 0,
    String? currency,
  }) async {
    return recordImpression(
      placementId: placementId,
      providerName: providerName,
      adUnitId: adUnitId,
      revenue: revenue,
      currency: currency,
      eventType: 'click',
    );
  }

  // ---------------------------------------------------------------------------
  // Revenue
  // ---------------------------------------------------------------------------

  /// Get an ad revenue summary for the authenticated tenant.
  ///
  /// [start] and [end] are ISO date strings (YYYY-MM-DD) bounding the report
  /// window. When omitted, the server defaults to the last 30 days.
  Future<Map<String, dynamic>> getRevenue({
    String? start,
    String? end,
  }) async {
    return _http.get(
      '/ads/revenue',
      queryParameters: {'start': ?start, 'end': ?end},
    );
  }

  /// Alias for [listPlacements] — returns the current ad configuration for
  /// this tenant. Use this when you want a compact "does this tenant have ads
  /// enabled?" check and a list of available placements.
  Future<Map<String, dynamic>> getConfig() async {
    final json = await _http.get('/ads/placements');
    return <String, dynamic>{
      'placements': json['placements'] ?? <dynamic>[],
      'total': json['total'] ?? 0,
    };
  }
}
