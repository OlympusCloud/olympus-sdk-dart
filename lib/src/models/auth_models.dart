/// Models for the Olympus Auth service.
library;

/// Authenticated session returned after login or SSO.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    this.refreshToken,
    this.userId,
    this.tenantId,
    this.roles,
  });

  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String? refreshToken;
  final String? userId;
  final String? tenantId;
  final List<String>? roles;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        accessToken: json['access_token'] as String,
        tokenType: json['token_type'] as String? ?? 'Bearer',
        expiresIn: json['expires_in'] as int? ?? 3600,
        refreshToken: json['refresh_token'] as String?,
        userId: json['user_id'] as String?,
        tenantId: json['tenant_id'] as String?,
        roles: (json['roles'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'token_type': tokenType,
        'expires_in': expiresIn,
        if (refreshToken != null) 'refresh_token': refreshToken,
        if (userId != null) 'user_id': userId,
        if (tenantId != null) 'tenant_id': tenantId,
        if (roles != null) 'roles': roles,
      };
}

/// A platform user.
class User {
  const User({
    required this.id,
    required this.email,
    this.name,
    this.roles,
    this.tenantId,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String? name;
  final List<String>? roles;
  final String? tenantId;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String?,
        roles: (json['roles'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        tenantId: json['tenant_id'] as String?,
        status: json['status'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        if (name != null) 'name': name,
        if (roles != null) 'roles': roles,
        if (tenantId != null) 'tenant_id': tenantId,
        if (status != null) 'status': status,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };
}

/// An API key for programmatic access.
class ApiKey {
  const ApiKey({
    required this.id,
    required this.name,
    this.key,
    this.scopes,
    this.createdAt,
    this.expiresAt,
  });

  final String id;
  final String name;

  /// Only present on creation response.
  final String? key;
  final List<String>? scopes;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  factory ApiKey.fromJson(Map<String, dynamic> json) => ApiKey(
        id: json['id'] as String,
        name: json['name'] as String,
        key: json['key'] as String?,
        scopes: (json['scopes'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        expiresAt: json['expires_at'] != null
            ? DateTime.parse(json['expires_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (key != null) 'key': key,
        if (scopes != null) 'scopes': scopes,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
      };
}
