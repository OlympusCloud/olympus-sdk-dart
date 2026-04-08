import '../http_client.dart';
import '../models/identity_models.dart';

/// Olympus ID — global, cross-tenant identity & federation.
///
/// Wraps the Olympus Platform service (Rust) Identity handler via the
/// Go API Gateway. Routes:
///   - `POST /api/v1/platform/identities`        — get-or-create identity
///   - `POST /api/v1/platform/identities/links`  — link identity to a tenant
///
/// An [OlympusIdentity] is keyed by Firebase UID and represents one human
/// across every Olympus Cloud app. Use [getOrCreateFromFirebase] right after
/// a successful Firebase sign-in to materialize the global identity, then
/// [linkToTenant] when the user first transacts with a tenant so the global
/// identity can be cross-referenced with the tenant's commerce customer.
class OlympusIdentityService {
  OlympusIdentityService(this._http);

  final OlympusHttpClient _http;

  /// Get-or-create the global Olympus identity for a Firebase user.
  ///
  /// If an identity already exists for [firebaseUid] it is returned
  /// unchanged; the optional fields are only used when a new row has to
  /// be inserted. Safe to call on every sign-in — it is idempotent.
  Future<OlympusIdentity> getOrCreateFromFirebase({
    required String firebaseUid,
    String? email,
    String? phone,
    String? firstName,
    String? lastName,
    Map<String, dynamic>? globalPreferences,
  }) async {
    final json = await _http.post(
      '/platform/identities',
      data: {
        'firebase_uid': firebaseUid,
        'email': ?email,
        'phone': ?phone,
        'first_name': ?firstName,
        'last_name': ?lastName,
        'global_preferences': ?globalPreferences,
      },
    );
    return OlympusIdentity.fromJson(json);
  }

  /// Link a global identity to a tenant-scoped commerce customer.
  ///
  /// Should be called the first time a federated user transacts with a
  /// new tenant — typically immediately after the tenant's commerce
  /// service creates the per-tenant customer record. Safe to call again;
  /// the platform de-duplicates by `(olympus_id, tenant_id)`.
  Future<void> linkToTenant({
    required String olympusId,
    required String tenantId,
    required String commerceCustomerId,
  }) async {
    await _http.post(
      '/platform/identities/links',
      data: {
        'olympus_id': olympusId,
        'tenant_id': tenantId,
        'commerce_customer_id': commerceCustomerId,
      },
    );
  }
}
