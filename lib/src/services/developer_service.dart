import '../http_client.dart';

/// Developer Platform: API key management, sandboxes, DevBox provisioning,
/// canary deployments.
///
/// Routes: `/developers/*`, `/devbox/*`.
class OlympusDeveloperService {
  OlympusDeveloperService(this._http);

  final OlympusHttpClient _http;

  // ---------------------------------------------------------------------------
  // API Keys (v0.3.0 — Issue #2835)
  // ---------------------------------------------------------------------------

  /// Create a new API key. The raw key is returned only once.
  Future<Map<String, dynamic>> createApiKey(
    String developerId, {
    required String appId,
    required String name,
    List<String>? scopes,
    int? expiresInDays,
  }) async {
    return _http.post(
      '/developers/$developerId/keys',
      data: {
        'app_id': appId,
        'name': name,
        if (scopes != null) 'scopes': scopes,
        if (expiresInDays != null) 'expires_in': expiresInDays,
      },
    );
  }

  /// List API keys for a developer (masked — only prefix visible).
  Future<Map<String, dynamic>> listApiKeys(String developerId) async {
    return _http.get('/developers/$developerId/keys');
  }

  /// Revoke an API key.
  Future<void> revokeApiKey(String developerId, String keyId) async {
    await _http.delete('/developers/$developerId/keys/$keyId');
  }

  /// Rotate an API key (revoke old + create new).
  Future<Map<String, dynamic>> rotateApiKey(
    String developerId,
    String keyId,
  ) async {
    return _http.post('/developers/$developerId/keys/$keyId/rotate');
  }

  // ---------------------------------------------------------------------------
  // DevBox Sandboxes (v0.3.0 — Issue #2834)
  // ---------------------------------------------------------------------------

  /// Provision a DevBox sandbox for a developer.
  Future<Map<String, dynamic>> provisionDevBox({
    required String developerId,
    required String apiKey,
    String template = 'olympus-sdk-typescript',
  }) async {
    return _http.post(
      '/devbox/provision',
      data: {
        'developer_id': developerId,
        'api_key': apiKey,
        'template': template,
      },
    );
  }

  /// Get DevBox session info.
  Future<Map<String, dynamic>> getDevBoxSession(String sessionId) async {
    return _http.get('/devbox/$sessionId');
  }

  /// Terminate a DevBox session.
  Future<void> terminateDevBox(String sessionId) async {
    await _http.delete('/devbox/$sessionId');
  }

  /// List current collaborators in a DevBox session.
  Future<Map<String, dynamic>> listCollaborators(String sessionId) async {
    return _http.get('/devbox/$sessionId/collaborators');
  }

  /// Invite a collaborator to a DevBox session.
  Future<Map<String, dynamic>> inviteCollaborator(
    String sessionId, {
    required String email,
    String permissions = 'edit',
  }) async {
    return _http.post(
      '/devbox/$sessionId/invite',
      data: {'email': email, 'permissions': permissions},
    );
  }

  // ---------------------------------------------------------------------------
  // Canary Deployments (v0.3.0 — Issue #2829)
  // ---------------------------------------------------------------------------

  /// Deploy an app version as a canary (default 10% traffic).
  Future<Map<String, dynamic>> deployApp(
    String developerId,
    String appId, {
    required String version,
    int canaryPercent = 10,
    bool autoPromote = false,
  }) async {
    return _http.post(
      '/developers/$developerId/apps/$appId/deploy',
      data: {
        'version': version,
        'canary_percent': canaryPercent,
        'auto_promote': autoPromote,
      },
    );
  }

  /// List deployments for an app.
  Future<Map<String, dynamic>> listDeployments(
    String developerId,
    String appId,
  ) async {
    return _http.get('/developers/$developerId/apps/$appId/deployments');
  }

  /// Promote a canary to 100% traffic.
  Future<Map<String, dynamic>> promoteDeployment(
    String developerId,
    String appId,
    String deployId,
  ) async {
    return _http.post(
      '/developers/$developerId/apps/$appId/deployments/$deployId/promote',
    );
  }

  /// Roll back to the previous version.
  Future<Map<String, dynamic>> rollbackDeployment(
    String developerId,
    String appId,
    String deployId,
  ) async {
    return _http.post(
      '/developers/$developerId/apps/$appId/deployments/$deployId/rollback',
    );
  }
}
