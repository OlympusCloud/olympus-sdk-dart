import 'dart:convert';

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
  /// Returns rows as a list of column-name-keyed maps. Defensively
  /// normalizes the backend's row shape: PGAdapter, Spanner, ClickHouse,
  /// and edge workers all serialize "row" slightly differently — some
  /// return `Map<String, dynamic>`, some return `Map<dynamic, dynamic>`,
  /// and some send each row as a JSON-encoded `String`. A naive
  /// `rows.cast<Map<String, dynamic>>()` is lazy and explodes at first
  /// access with `type 'String' is not a subtype of type
  /// 'Map<String, dynamic>?'`. We materialize + normalize here so callers
  /// can safely call `.first` and similar without crashing the screen.
  Future<List<Map<String, dynamic>>> query(
    String sql, {
    Map<String, dynamic>? params,
  }) async {
    final json = await _http.post(
      '/data/query',
      data: {'sql': sql, 'params': ?params},
    );
    final rawRows =
        json['rows'] as List<dynamic>? ?? json['data'] as List<dynamic>? ?? [];
    return rawRows.map(_normalizeRow).toList();
  }

  /// Coerce an arbitrary row value into a `Map<String, dynamic>`.
  /// Never throws — falls back to an empty map on unrecognized shapes.
  static Map<String, dynamic> _normalizeRow(dynamic row) {
    if (row == null) return <String, dynamic>{};
    if (row is Map<String, dynamic>) return row;
    if (row is Map) {
      return row.map((k, v) => MapEntry(k.toString(), v));
    }
    if (row is String && row.isNotEmpty) {
      try {
        final decoded = jsonDecode(row);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) {
          return decoded.map((k, v) => MapEntry(k.toString(), v));
        }
      } catch (_) {
        // Fall through — return empty map rather than crash the caller.
      }
    }
    return <String, dynamic>{};
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
    final json = await _http.post(
      '/ai/search',
      data: {'query': query, 'scope': ?scope, 'limit': ?limit},
    );
    final results = json['results'] as List<dynamic>? ?? [];
    return results
        .map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
