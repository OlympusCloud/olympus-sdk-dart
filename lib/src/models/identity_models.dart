/// Models for the Olympus ID (global identity & federation) service.
///
/// An [OlympusIdentity] is a global, cross-tenant identity that represents
/// a single human (consumer or operator) across every app on the platform.
/// It is keyed by Firebase UID and may be linked to one or more
/// tenant-scoped commerce customers via [IdentityLink].
library;

/// Global identity representing a consumer or business operator across
/// all Olympus Cloud apps. Backed by `platform_olympus_identities` in
/// Spanner; created on first Firebase sign-in and reused thereafter.
class OlympusIdentity {
  const OlympusIdentity({
    required this.id,
    required this.firebaseUid,
    required this.createdAt,
    required this.updatedAt,
    this.email,
    this.phone,
    this.firstName,
    this.lastName,
    this.globalPreferences,
    this.stripeCustomerId,
  });

  /// Server-assigned global identity UUID. Stable across tenants.
  final String id;

  /// Firebase Auth UID. Unique per signed-in user.
  final String firebaseUid;

  final String? email;
  final String? phone;
  final String? firstName;
  final String? lastName;

  /// Free-form JSON for cross-app preferences (theme, locale, accessibility).
  final Map<String, dynamic>? globalPreferences;

  /// Cross-tenant Stripe customer ID, used by Olympus Pay for federated
  /// checkout flows.
  final String? stripeCustomerId;

  final DateTime createdAt;
  final DateTime updatedAt;

  factory OlympusIdentity.fromJson(Map<String, dynamic> json) =>
      OlympusIdentity(
        id: json['id'] as String,
        firebaseUid: json['firebase_uid'] as String,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        firstName: json['first_name'] as String?,
        lastName: json['last_name'] as String?,
        globalPreferences: json['global_preferences'] as Map<String, dynamic>?,
        stripeCustomerId: json['stripe_customer_id'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'firebase_uid': firebaseUid,
    if (email != null) 'email': email,
    if (phone != null) 'phone': phone,
    if (firstName != null) 'first_name': firstName,
    if (lastName != null) 'last_name': lastName,
    if (globalPreferences != null) 'global_preferences': globalPreferences,
    if (stripeCustomerId != null) 'stripe_customer_id': stripeCustomerId,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

/// A binding between an [OlympusIdentity] and a tenant-scoped commerce
/// customer. One Olympus identity can have many links — one per tenant
/// the user has done business with.
class IdentityLink {
  const IdentityLink({
    required this.olympusId,
    required this.tenantId,
    required this.commerceCustomerId,
    required this.linkedAt,
  });

  /// The global identity this link belongs to.
  final String olympusId;

  /// Tenant the user has a relationship with.
  final String tenantId;

  /// Tenant-scoped commerce customer record.
  final String commerceCustomerId;

  /// When the link was first established.
  final DateTime linkedAt;

  factory IdentityLink.fromJson(Map<String, dynamic> json) => IdentityLink(
    olympusId: json['olympus_id'] as String,
    tenantId: json['tenant_id'] as String,
    commerceCustomerId: json['commerce_customer_id'] as String,
    linkedAt: DateTime.parse(json['linked_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'olympus_id': olympusId,
    'tenant_id': tenantId,
    'commerce_customer_id': commerceCustomerId,
    'linked_at': linkedAt.toIso8601String(),
  };
}
