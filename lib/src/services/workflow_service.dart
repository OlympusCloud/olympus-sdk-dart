import '../http_client.dart';

/// Workflow automation: create, manage, and execute workflows.
///
/// Routes: `/workflows/*`.
class OlympusWorkflowService {
  OlympusWorkflowService(this._http);

  final OlympusHttpClient _http;

  /// List all workflows for the tenant.
  Future<List<Map<String, dynamic>>> list({int? page, int? limit}) async {
    final json = await _http.get(
      '/workflows',
      queryParameters: {'page': ?page, 'limit': ?limit},
    );
    final items =
        json['workflows'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Get a single workflow by ID.
  Future<Map<String, dynamic>> get(String workflowId) async {
    return _http.get('/workflows/$workflowId');
  }

  /// Create a new workflow.
  Future<Map<String, dynamic>> create(Map<String, dynamic> workflow) async {
    return _http.post('/workflows', data: workflow);
  }

  /// Update an existing workflow.
  Future<Map<String, dynamic>> update(
    String workflowId,
    Map<String, dynamic> workflow,
  ) async {
    return _http.put('/workflows/$workflowId', data: workflow);
  }

  /// Delete a workflow.
  Future<void> delete(String workflowId) async {
    await _http.delete('/workflows/$workflowId');
  }

  /// List executions (runs) for a workflow.
  Future<List<Map<String, dynamic>>> listExecutions(
    String workflowId, {
    int? page,
    int? limit,
  }) async {
    final json = await _http.get(
      '/workflows/$workflowId/executions',
      queryParameters: {'page': ?page, 'limit': ?limit},
    );
    final items =
        json['executions'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Execute (run) a workflow by ID.
  ///
  /// Returns the execution record. When [async] is true the API responds
  /// with a pending execution that the caller can poll via [getExecution].
  Future<Map<String, dynamic>> execute(
    String workflowId, {
    Map<String, dynamic>? input,
    bool async = false,
  }) async {
    return _http.post(
      '/workflows/$workflowId/execute',
      data: {'input': ?input, 'async': async},
    );
  }

  /// Create a top-level execution runtime record (SDK-friendly variant).
  ///
  /// Mirrors `POST /v1/workflows/executions` — equivalent to `execute` but
  /// using the top-level runtime endpoint rather than the nested one.
  Future<Map<String, dynamic>> createExecution({
    required String workflowId,
    Map<String, dynamic>? input,
    bool async = false,
  }) async {
    return _http.post(
      '/workflows/executions',
      data: {
        'workflow_id': workflowId,
        'input': ?input,
        'async': async,
      },
    );
  }

  /// Get a single execution by ID.
  Future<Map<String, dynamic>> getExecution(String executionId) async {
    return _http.get('/workflows/executions/$executionId');
  }
}
