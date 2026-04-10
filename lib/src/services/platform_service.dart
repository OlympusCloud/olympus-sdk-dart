import '../http_client.dart';

/// Platform operations: tenant lifecycle, signup/cleanup workflows.
///
/// Routes: `/platform/signup`, `/platform/cleanup`, `/platform/tenants/*`.
///
/// Backed by the Rust Platform service (port 8002).
class OlympusPlatformService {
  OlympusPlatformService(this._http);

  final OlympusHttpClient _http;

  // ---------------------------------------------------------------------------
  // Tenant Signup (v0.3.0 — Issue #2845)
  // ---------------------------------------------------------------------------

  /// Execute automated tenant signup workflow.
  ///
  /// Provisions the tenant, creates admin user, seeds industry policies,
  /// and returns tenant credentials.
  Future<Map<String, dynamic>> signup({
    required String companyName,
    required String adminEmail,
    required String adminName,
    required String industry,
    int trialDays = 14,
  }) async {
    return _http.post(
      '/platform/signup',
      data: {
        'company_name': companyName,
        'admin_email': adminEmail,
        'admin_name': adminName,
        'industry': industry,
        'trial_days': trialDays,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Tenant Cleanup (v0.3.0 — Issue #2846)
  // ---------------------------------------------------------------------------

  /// Execute automated tenant cleanup workflow.
  ///
  /// Deprovisions the tenant with optional GDPR export and grace period
  /// for data deletion.
  Future<Map<String, dynamic>> cleanup({
    required String tenantId,
    required String reason,
    bool exportData = false,
    int gracePeriodDays = 30,
  }) async {
    return _http.post(
      '/platform/cleanup',
      data: {
        'tenant_id': tenantId,
        'reason': reason,
        'export_data': exportData,
        'grace_period_days': gracePeriodDays,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Tenant Lifecycle
  // ---------------------------------------------------------------------------

  /// Get tenant lifecycle status.
  Future<Map<String, dynamic>> getTenantStatus(String tenantId) async {
    return _http.get('/platform/tenants/$tenantId/lifecycle/status');
  }

  /// Get tenant health score.
  Future<Map<String, dynamic>> getTenantHealth(String tenantId) async {
    return _http.get('/platform/tenants/$tenantId/lifecycle/health');
  }

  /// Get onboarding progress.
  Future<Map<String, dynamic>> getOnboardingProgress(String tenantId) async {
    return _http.get('/platform/tenants/$tenantId/lifecycle/onboarding');
  }

  /// Update onboarding step.
  Future<Map<String, dynamic>> updateOnboardingStep(
    String tenantId,
    String stepKey, {
    required bool complete,
  }) async {
    return _http.put(
      '/platform/tenants/$tenantId/lifecycle/onboarding/steps/$stepKey',
      data: {'complete': complete},
    );
  }
}
