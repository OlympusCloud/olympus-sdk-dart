import '../http_client.dart';
import '../models/auth_models.dart';

/// Authentication, user management, and API key operations.
///
/// Wraps the Olympus Auth service (Rust) via the Go API Gateway.
/// Routes: `/auth/*`, `/platform/users/*`.
class OlympusAuthService {
  OlympusAuthService(this._http);

  final OlympusHttpClient _http;

  /// Authenticate with email and password.
  ///
  /// On success the returned [AuthSession.accessToken] is automatically
  /// set on the HTTP client for subsequent requests.
  Future<AuthSession> login(String email, String password) async {
    final json = await _http.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final session = AuthSession.fromJson(json);
    _http.setAccessToken(session.accessToken);
    return session;
  }

  /// Initiate SSO login via an external provider (e.g., "google", "apple").
  ///
  /// Returns the session after the SSO callback completes.
  Future<AuthSession> loginSSO(String provider) async {
    final json = await _http.post('/auth/sso/initiate', data: {
      'provider': provider,
    });
    final session = AuthSession.fromJson(json);
    _http.setAccessToken(session.accessToken);
    return session;
  }

  /// Authenticate staff using a PIN code.
  Future<AuthSession> loginPin(String pin, {String? locationId}) async {
    final json = await _http.post('/auth/login/pin', data: {
      'pin': pin,
      'location_id': ?locationId,
    });
    final session = AuthSession.fromJson(json);
    _http.setAccessToken(session.accessToken);
    return session;
  }

  /// Get the currently authenticated user profile.
  Future<User> me() async {
    final json = await _http.get('/auth/me');
    return User.fromJson(json);
  }

  /// Refresh the access token using a refresh token.
  Future<AuthSession> refresh(String refreshToken) async {
    final json = await _http.post('/auth/refresh', data: {
      'refresh_token': refreshToken,
    });
    final session = AuthSession.fromJson(json);
    _http.setAccessToken(session.accessToken);
    return session;
  }

  /// Log out the current session.
  Future<void> logout() async {
    await _http.post('/auth/logout');
    _http.clearAccessToken();
  }

  /// Create a new user on the platform.
  Future<User> createUser({
    required String name,
    required String email,
    required String role,
    String? password,
  }) async {
    final json = await _http.post('/platform/users', data: {
      'name': name,
      'email': email,
      'role': role,
      'password': ?password,
    });
    return User.fromJson(json);
  }

  /// Assign a role to a user.
  Future<void> assignRole(String userId, String role) async {
    await _http.post('/platform/users/$userId/roles', data: {
      'role': role,
    });
  }

  /// Check whether a user has a specific permission.
  Future<bool> checkPermission(String userId, String permission) async {
    final json = await _http.get(
      '/platform/users/$userId/permissions/check',
      queryParameters: {'permission': permission},
    );
    return json['allowed'] as bool? ?? false;
  }

  /// Create a new API key for programmatic access.
  Future<ApiKey> createApiKey(String name, List<String> scopes) async {
    final json = await _http.post('/platform/tenants/me/api-keys', data: {
      'name': name,
      'scopes': scopes,
    });
    return ApiKey.fromJson(json);
  }

  /// Revoke an existing API key.
  Future<void> revokeApiKey(String keyId) async {
    await _http.delete('/platform/tenants/me/api-keys/$keyId');
  }
}
