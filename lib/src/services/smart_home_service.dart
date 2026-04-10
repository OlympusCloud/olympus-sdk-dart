import '../http_client.dart';

/// Smart home integration: platforms, devices, rooms, and device control.
///
/// Routes: `/smart-home/*`.
class OlympusSmartHomeService {
  OlympusSmartHomeService(this._http);

  final OlympusHttpClient _http;

  /// List connected smart home platforms (e.g., Hue, SmartThings, HomeKit).
  Future<List<Map<String, dynamic>>> listPlatforms() async {
    final json = await _http.get('/smart-home/platforms');
    final items =
        json['platforms'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  /// List all smart home devices across connected platforms.
  Future<List<Map<String, dynamic>>> listDevices({
    String? platformId,
    String? roomId,
  }) async {
    final json = await _http.get(
      '/smart-home/devices',
      queryParameters: {'platform_id': ?platformId, 'room_id': ?roomId},
    );
    final items =
        json['devices'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Get details for a single smart home device.
  Future<Map<String, dynamic>> getDevice(String deviceId) async {
    return _http.get('/smart-home/devices/$deviceId');
  }

  /// Send a control command to a device (e.g., on/off, brightness, color).
  Future<Map<String, dynamic>> controlDevice(
    String deviceId,
    Map<String, dynamic> command,
  ) async {
    return _http.post('/smart-home/devices/$deviceId/control', data: command);
  }

  /// List rooms with their associated devices.
  Future<List<Map<String, dynamic>>> listRooms() async {
    final json = await _http.get('/smart-home/rooms');
    final items =
        json['rooms'] as List<dynamic>? ?? json['data'] as List<dynamic>? ?? [];
    return items.cast<Map<String, dynamic>>();
  }

  // ---------------------------------------------------------------------------
  // Scenes (v0.3.0 — Issue #2569)
  // ---------------------------------------------------------------------------

  /// List automation scenes (e.g., "Good morning", "Movie night").
  Future<List<Map<String, dynamic>>> listScenes() async {
    final json = await _http.get('/smart-home/scenes');
    final items =
        json['scenes'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Activate a scene by ID.
  Future<Map<String, dynamic>> activateScene(String sceneId) async {
    return _http.post('/smart-home/scenes/$sceneId/activate');
  }

  /// Create a new scene with devices and actions.
  Future<Map<String, dynamic>> createScene(Map<String, dynamic> scene) async {
    return _http.post('/smart-home/scenes', data: scene);
  }

  /// Delete a scene.
  Future<void> deleteScene(String sceneId) async {
    await _http.delete('/smart-home/scenes/$sceneId');
  }

  // ---------------------------------------------------------------------------
  // Automations
  // ---------------------------------------------------------------------------

  /// List automation rules (trigger-action).
  Future<List<Map<String, dynamic>>> listAutomations() async {
    final json = await _http.get('/smart-home/automations');
    final items =
        json['automations'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items.cast<Map<String, dynamic>>();
  }

  /// Create a new automation rule.
  Future<Map<String, dynamic>> createAutomation(
    Map<String, dynamic> automation,
  ) async {
    return _http.post('/smart-home/automations', data: automation);
  }

  /// Delete an automation rule.
  Future<void> deleteAutomation(String automationId) async {
    await _http.delete('/smart-home/automations/$automationId');
  }
}
