import '../http_client.dart';

/// Health integrations: connect health providers, sync data, and get insights.
///
/// Routes: `/health/*`.
class OlympusHealthService {
  OlympusHealthService(this._http);

  final OlympusHttpClient _http;

  /// List all health provider connections for the tenant.
  Future<List<Map<String, dynamic>>> listConnections() async {
    final json = await _http.get('/health/connections');
    final items =
        json['connections'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Get details for a single health connection.
  Future<Map<String, dynamic>> getConnection(String connectionId) async {
    return _http.get('/health/connections/$connectionId');
  }

  /// Initiate a connection to a health data provider.
  Future<Map<String, dynamic>> connectProvider(
    Map<String, dynamic> provider,
  ) async {
    return _http.post('/health/connections', data: provider);
  }

  /// Disconnect a health data provider.
  Future<void> disconnectProvider(String connectionId) async {
    await _http.delete('/health/connections/$connectionId');
  }

  /// Trigger an immediate sync for a health connection.
  Future<Map<String, dynamic>> syncNow(String connectionId) async {
    return _http.post('/health/connections/$connectionId/sync');
  }

  /// Get a summary of the user's health data.
  Future<Map<String, dynamic>> getSummary() async {
    return _http.get('/health/summary');
  }

  /// Get AI-powered health insights.
  Future<Map<String, dynamic>> getInsights() async {
    return _http.get('/health/insights');
  }
}
