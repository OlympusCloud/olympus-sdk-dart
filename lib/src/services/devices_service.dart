import '../http_client.dart';
import '../models/device_models.dart';

/// Mobile Device Management (MDM): enrollment, kiosk mode, updates, and wipe.
///
/// Routes: `/platform/device/*`, `/diagnostics/*`.
class OlympusDevicesService {
  OlympusDevicesService(this._http);

  final OlympusHttpClient _http;

  /// Enroll a device with a profile.
  ///
  /// [deviceId] is the hardware identifier. [profile] specifies the device
  /// role (e.g., "kiosk", "pos_terminal", "kds", "signage").
  Future<Device> enroll(String deviceId, String profile) async {
    final json = await _http.post(
      '/auth/devices/register',
      data: {'device_id': deviceId, 'profile': profile},
    );
    return Device.fromJson(json);
  }

  /// Set a device to kiosk mode, locking it to a specific application.
  Future<void> setKioskMode(String deviceId, String appId) async {
    await _http.post(
      '/platform/device-policies/$deviceId/kiosk',
      data: {'app_id': appId, 'enabled': true},
    );
  }

  /// Push an OTA update to a device group.
  Future<void> pushUpdate(String deviceGroupId, String version) async {
    await _http.post(
      '/platform/device-policies/updates',
      data: {'device_group_id': deviceGroupId, 'target_version': version},
    );
  }

  /// Remote wipe a device (factory reset).
  Future<void> wipe(String deviceId) async {
    await _http.post('/platform/device-policies/$deviceId/wipe');
  }

  /// List enrolled devices for the tenant.
  Future<List<Device>> listDevices({String? locationId}) async {
    final json = await _http.get(
      '/diagnostics/devices',
      queryParameters: {'location_id': ?locationId},
    );
    final items =
        json['devices'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items
        .map((e) => Device.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get device details by ID.
  Future<Device> getDevice(String deviceId) async {
    final json = await _http.get('/diagnostics/devices/$deviceId');
    return Device.fromJson(json);
  }
}
