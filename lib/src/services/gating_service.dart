import '../http_client.dart';
import '../models/common.dart';

/// Feature gating and policy evaluation.
///
/// Wraps the Olympus Gating Engine (10-level policy hierarchy) via the Go API
/// Gateway.
/// Routes: `/policies/evaluate`, `/gating/*`, `/feature-flags/*`.
class OlympusGatingService {
  OlympusGatingService(this._http);

  final OlympusHttpClient _http;

  /// Check whether a feature key is enabled for the current context.
  Future<bool> isEnabled(String featureKey) async {
    final json = await _http.post(
      '/policies/evaluate',
      data: {'policy_key': featureKey},
    );
    return json['allowed'] as bool? ??
        json['enabled'] as bool? ??
        json['value'] == true;
  }

  /// Get the raw policy value for a key.
  ///
  /// Returns the server-resolved value, which may be a bool, int, String,
  /// or Map depending on the policy definition.
  Future<dynamic> getPolicy(String policyKey) async {
    final json = await _http.post(
      '/policies/evaluate',
      data: {'policy_key': policyKey},
    );
    return json['value'] ?? json['result'];
  }

  /// Evaluate a policy key with additional context parameters.
  ///
  /// The [context] map can include location_id, device_id, user_id, etc. to
  /// influence the 10-level policy resolution hierarchy.
  Future<PolicyResult> evaluate(
    String policyKey,
    Map<String, dynamic> context,
  ) async {
    final json = await _http.post(
      '/policies/evaluate',
      data: {'policy_key': policyKey, 'context': context},
    );
    return PolicyResult.fromJson(json);
  }

  /// Batch evaluate multiple policy keys at once.
  Future<Map<String, PolicyResult>> evaluateBatch(
    List<String> policyKeys, {
    Map<String, dynamic>? context,
  }) async {
    final json = await _http.post(
      '/policies/evaluate/batch',
      data: {'policy_keys': policyKeys, 'context': ?context},
    );
    final results = json['results'] as Map<String, dynamic>? ?? {};
    return results.map(
      (key, value) =>
          MapEntry(key, PolicyResult.fromJson(value as Map<String, dynamic>)),
    );
  }

  /// List feature flags for the tenant.
  Future<List<Map<String, dynamic>>> listFeatureFlags() async {
    final json = await _http.get('/feature-flags');
    final items =
        json['feature_flags'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }
}
