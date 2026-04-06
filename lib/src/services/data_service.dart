import '../http_client.dart';
import '../models/common.dart';

/// Data query, CRUD, and search operations.
///
/// Provides a high-level data access layer over the Olympus platform.
/// Routes: `/commerce/*`, `/ai/search`.
class OlympusDataService {
  OlympusDataService(this._http);

  final OlympusHttpClient _http;

  /// Execute a read-only SQL query against the platform data layer.
  ///
  /// Returns rows as a list of column-name-keyed maps.
  Future<List<Map<String, dynamic>>> query(
    String sql, {
    Map<String, dynamic>? params,
  }) async {
    final json = await _http.post('/data/query', data: {
      'sql': sql,
      'params': ?params,
    });
    final rows = json['rows'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return rows.cast<Map<String, dynamic>>();
  }

  /// Insert a record into a table.
  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> record,
  ) async {
    final json = await _http.post('/data/$table', data: record);
    return json;
  }

  /// Update a record by ID.
  Future<Map<String, dynamic>> update(
    String table,
    String id,
    Map<String, dynamic> fields,
  ) async {
    final json = await _http.patch('/data/$table/$id', data: fields);
    return json;
  }

  /// Delete a record by ID.
  Future<void> delete(String table, String id) async {
    await _http.delete('/data/$table/$id');
  }

  /// Full-text / semantic search across indexed data.
  Future<List<SearchResult>> search(
    String query, {
    String? scope,
    int? limit,
  }) async {
    final json = await _http.post('/ai/search', data: {
      'query': query,
      'scope': ?scope,
      'limit': ?limit,
    });
    final results = json['results'] as List<dynamic>? ?? [];
    return results
        .map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
