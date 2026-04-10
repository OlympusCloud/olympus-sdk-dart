import '../http_client.dart';

/// Business data access: revenue, staff, insights, comparisons.
///
/// Used primarily by consumer apps like Maximus to show business owner
/// dashboards. Routes: `/business/*`.
class OlympusBusinessService {
  OlympusBusinessService(this._http);

  final OlympusHttpClient _http;

  /// Get revenue summary across today/week/month/year periods.
  Future<Map<String, dynamic>> getRevenueSummary() async {
    return _http.get('/business/revenue/summary');
  }

  /// Get revenue trend data points for charting.
  /// Period: 7d, 30d, 90d, 1y.
  Future<Map<String, dynamic>> getRevenueTrends({String period = '30d'}) async {
    return _http.get(
      '/business/revenue/trends',
      queryParameters: {'period': period},
    );
  }

  /// Get top-selling items by revenue.
  Future<Map<String, dynamic>> getTopSellers({
    int limit = 10,
    String period = '30d',
  }) async {
    return _http.get(
      '/business/top-sellers',
      queryParameters: {'limit': limit, 'period': period},
    );
  }

  /// Get currently on-duty staff members.
  Future<Map<String, dynamic>> getOnDutyStaff({String? locationId}) async {
    return _http.get(
      '/business/staff/on-duty',
      queryParameters: {'location_id': ?locationId},
    );
  }

  /// Get AI-generated business insights.
  /// Category filter: revenue, staffing, inventory, customer.
  Future<Map<String, dynamic>> getInsights({String? category}) async {
    return _http.get(
      '/business/insights',
      queryParameters: {'category': ?category},
    );
  }

  /// Get period-over-period metric comparisons.
  Future<Map<String, dynamic>> getComparisons({
    String currentPeriod = 'this_month',
    String compareTo = 'last_month',
  }) async {
    return _http.get(
      '/business/comparisons',
      queryParameters: {
        'current_period': currentPeriod,
        'compare_to': compareTo,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Legacy tenant linking
  // ---------------------------------------------------------------------------

  /// List business tenants linked to the current user.
  Future<Map<String, dynamic>> listLinkedTenants() async {
    return _http.get('/business/tenants');
  }

  /// Link a business tenant to the current user.
  Future<Map<String, dynamic>> linkTenant(String tenantId) async {
    return _http.post('/business/tenants/$tenantId/link');
  }
}
