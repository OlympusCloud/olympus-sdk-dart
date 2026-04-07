/// Models for the Olympus Device Management (MDM) service.
library;

/// A managed device enrolled via MDM.
class Device {
  const Device({
    required this.id,
    this.name,
    this.status,
    this.profile,
    this.platform,
    this.osVersion,
    this.appVersion,
    this.locationId,
    this.lastSeen,
    this.enrolledAt,
  });

  final String id;
  final String? name;
  final String? status;
  final String? profile;
  final String? platform;
  final String? osVersion;
  final String? appVersion;
  final String? locationId;
  final DateTime? lastSeen;
  final DateTime? enrolledAt;

  factory Device.fromJson(Map<String, dynamic> json) => Device(
    id: json['id'] as String? ?? json['device_id'] as String? ?? '',
    name: json['name'] as String?,
    status: json['status'] as String?,
    profile: json['profile'] as String?,
    platform: json['platform'] as String?,
    osVersion: json['os_version'] as String?,
    appVersion: json['app_version'] as String?,
    locationId: json['location_id'] as String?,
    lastSeen: json['last_seen'] != null
        ? DateTime.parse(json['last_seen'] as String)
        : null,
    enrolledAt: json['enrolled_at'] != null
        ? DateTime.parse(json['enrolled_at'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    if (name != null) 'name': name,
    if (status != null) 'status': status,
    if (profile != null) 'profile': profile,
    if (platform != null) 'platform': platform,
    if (osVersion != null) 'os_version': osVersion,
    if (appVersion != null) 'app_version': appVersion,
    if (locationId != null) 'location_id': locationId,
    if (lastSeen != null) 'last_seen': lastSeen!.toIso8601String(),
    if (enrolledAt != null) 'enrolled_at': enrolledAt!.toIso8601String(),
  };

  bool get isOnline =>
      lastSeen != null && DateTime.now().difference(lastSeen!).inMinutes < 5;
}
