import '../http_client.dart';

/// AI Agent Workflow Orchestration — tenant-scoped multi-agent pipelines.
///
/// Wraps the Go workflow engine at `backend/go/internal/workflows/` (#2915)
/// via the gateway routes `/agent-workflows/*`. Distinct from the
/// marketplace template workflows at `OlympusWorkflowService` (`/workflows/*`).
///
/// A workflow is a directed acyclic graph (DAG) of agent nodes where each
/// node calls an agent registered in the tenant's agent registry. Edges
/// define data flow between nodes. Triggers can be manual, cron-based, or
/// event-driven (order.created, inventory.low, customer.feedback, etc.).
///
/// Routes:
///   - `POST   /agent-workflows`                   — create workflow
///   - `GET    /agent-workflows`                   — list workflows (paginated)
///   - `GET    /agent-workflows/usage`             — monthly usage vs limits
///   - `GET    /agent-workflows/:id`               — detail
///   - `PUT    /agent-workflows/:id`               — update
///   - `DELETE /agent-workflows/:id`               — soft-delete (archive)
///   - `POST   /agent-workflows/:id/execute`       — manual trigger
///   - `GET    /agent-workflows/:id/executions`   — execution history
///   - `POST   /agent-workflows/:id/schedule`      — set cron schedule
///   - `DELETE /agent-workflows/:id/schedule`      — remove schedule
///   - `GET    /agent-workflow-executions/:exec_id` — execution detail
///
/// Auth: requires one of `tenant_admin`, `platform_admin`, `system_admin`,
/// `super_admin`, `workflow_manager` roles.
class OlympusAgentWorkflowService {
  OlympusAgentWorkflowService(this._http);

  final OlympusHttpClient _http;

  // ---------------------------------------------------------------------------
  // CRUD
  // ---------------------------------------------------------------------------

  /// List workflows for the current tenant. Optional filter by status
  /// (`draft`, `active`, `paused`, `archived`).
  Future<List<Map<String, dynamic>>> list({String? status, int? limit}) async {
    final json = await _http.get(
      '/agent-workflows',
      queryParameters: {'status': ?status, 'limit': ?limit},
    );
    final items =
        json['workflows'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Get a single workflow by ID with its full DAG schema.
  Future<Map<String, dynamic>> get(String workflowId) async {
    return _http.get('/agent-workflows/$workflowId');
  }

  /// Create a new workflow.
  ///
  /// [schema] is the DAG definition with `nodes` (agent steps) and
  /// `edges` (data flow). [triggers] defines how the workflow is launched:
  /// `{type: 'cron', config: {cron_expression: '0 9 * * *'}}` or
  /// `{type: 'event', config: {event_type: 'order.created'}}`.
  Future<Map<String, dynamic>> create({
    required String name,
    String? description,
    required Map<String, dynamic> schema,
    List<Map<String, dynamic>>? triggers,
  }) async {
    return _http.post(
      '/agent-workflows',
      data: {
        'name': name,
        if (description != null) 'description': description,
        'schema': schema,
        if (triggers != null) 'triggers': triggers,
      },
    );
  }

  /// Update an existing workflow. Pass only fields to change.
  Future<Map<String, dynamic>> update(
    String workflowId,
    Map<String, dynamic> updates,
  ) async {
    return _http.put('/agent-workflows/$workflowId', data: updates);
  }

  /// Soft-delete (archive) a workflow.
  Future<void> delete(String workflowId) async {
    await _http.delete('/agent-workflows/$workflowId');
  }

  // ---------------------------------------------------------------------------
  // Execution
  // ---------------------------------------------------------------------------

  /// Manually trigger a workflow execution with optional input payload.
  /// Returns the execution ID — poll `getExecution()` for results.
  Future<Map<String, dynamic>> execute(
    String workflowId, {
    Map<String, dynamic>? input,
  }) async {
    return _http.post(
      '/agent-workflows/$workflowId/execute',
      data: {if (input != null) 'input': input},
    );
  }

  /// List execution history for a workflow.
  Future<List<Map<String, dynamic>>> listExecutions(
    String workflowId, {
    String? status,
    int? limit,
  }) async {
    final json = await _http.get(
      '/agent-workflows/$workflowId/executions',
      queryParameters: {'status': ?status, 'limit': ?limit},
    );
    final items =
        json['executions'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Get full execution detail including per-step results.
  Future<Map<String, dynamic>> getExecution(String executionId) async {
    return _http.get('/agent-workflow-executions/$executionId');
  }

  // ---------------------------------------------------------------------------
  // Scheduling
  // ---------------------------------------------------------------------------

  /// Set or update the cron schedule for a workflow.
  /// [cronExpression] follows standard cron syntax: `minute hour day month weekday`.
  Future<Map<String, dynamic>> setSchedule(
    String workflowId,
    String cronExpression,
  ) async {
    return _http.post(
      '/agent-workflows/$workflowId/schedule',
      data: {'cron_expression': cronExpression},
    );
  }

  /// Remove the cron schedule from a workflow (keeps the workflow but
  /// disables automatic execution).
  Future<void> removeSchedule(String workflowId) async {
    await _http.delete('/agent-workflows/$workflowId/schedule');
  }

  // ---------------------------------------------------------------------------
  // Usage metering
  // ---------------------------------------------------------------------------

  /// Get current month usage vs tenant tier limits.
  /// Free tier: 100 executions, 1000 agent messages, 10k D1 queries per month.
  Future<Map<String, dynamic>> usage() async {
    return _http.get('/agent-workflows/usage');
  }
}
