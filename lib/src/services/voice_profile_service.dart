import '../http_client.dart';
import '../models/voice_profile.dart';

/// Voice customization service (orderecho-ai #82).
///
/// Lets callers fetch and update the per-agent voice sliders
/// (pitch/rate/warmth/formality) plus the selected base voice without
/// touching the broader [OlympusVoiceService] surface area that owns
/// agent configuration, phone numbers, marketplace installs, etc.
///
/// Routes (proxied through the Go Gateway):
///
/// * `GET  /ether/voice/agents/{agentId}/profile`
/// * `PUT  /ether/voice/agents/{agentId}/profile`
/// * `POST /ether/voice/agents/{agentId}/profile/reset`
class OlympusVoiceProfileService {
  OlympusVoiceProfileService(this._http);

  final OlympusHttpClient _http;

  String _path(String agentId, [String suffix = '']) =>
      '/ether/voice/agents/$agentId/profile$suffix';

  /// Fetch the current voice profile for [agentId].
  ///
  /// Returns factory defaults for agents that don't yet have a profile.
  Future<VoiceProfile> getVoiceProfile(String agentId) async {
    final json = await _http.get(_path(agentId));
    return VoiceProfile.fromJson(json);
  }

  /// Partially update the voice profile for [agentId].
  ///
  /// Only the fields provided on [profile] (via [VoiceProfile.copyWith] for
  /// instance) that differ from the defaults are forwarded — the Python
  /// handler tolerates extra fields, but sending a minimal body keeps
  /// update latency snappy and audit logs readable.
  ///
  /// Values are clamped on both sides: locally via [VoiceProfile.clamped]
  /// so a bad slider can never leave the device, and server-side which
  /// returns HTTP 400 on out-of-range values as a defense-in-depth check.
  Future<VoiceProfile> updateVoiceProfile(
    String agentId,
    VoiceProfile profile,
  ) async {
    final clamped = profile.clamped();
    final body = <String, dynamic>{
      'voice_name': clamped.voiceName,
      'pitch': clamped.pitch,
      'rate': clamped.rate,
      'warmth': clamped.warmth,
      'formality': clamped.formality,
    };
    final json = await _http.put(_path(agentId), data: body);
    return VoiceProfile.fromJson(json);
  }

  /// Reset the profile to factory defaults.
  Future<VoiceProfile> resetVoiceProfile(String agentId) async {
    final json = await _http.post(_path(agentId, '/reset'));
    return VoiceProfile.fromJson(json);
  }
}
