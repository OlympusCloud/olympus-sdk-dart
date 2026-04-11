/// Voice customization profile model (GH orderecho-ai#82).
library;

/// Hard-coded bounds for the 4 tunable sliders. Mirrors the server-side
/// clamp in `voice_profile.py`.
class VoiceProfileBounds {
  const VoiceProfileBounds._();

  static const double pitchMin = 0.5;
  static const double pitchMax = 2.0;
  static const double rateMin = 0.5;
  static const double rateMax = 2.0;
  static const double warmthMin = 0.0;
  static const double warmthMax = 1.0;
  static const double formalityMin = 0.0;
  static const double formalityMax = 1.0;
}

/// A tenant's tunable voice agent personality.
///
/// Four sliders dial in the energy of a chosen base voice without the
/// cost of voice cloning:
///
/// * [pitch] / [rate] — 0.5–2.0, neutral at 1.0. Applied to cached TTS via
///   SSML prosody tags. Gemini Live does not natively honour them at the
///   realtime layer today — the bridge passes them through to any cached
///   phrases it mixes into the stream.
/// * [warmth] / [formality] — 0.0–1.0. Injected into the voice persona
///   preamble so Gemini Live biases its vocabulary/tone accordingly.
class VoiceProfile {
  const VoiceProfile({
    required this.agentId,
    this.tenantId,
    this.voiceName = 'Kore',
    this.pitch = 1.0,
    this.rate = 1.0,
    this.warmth = 0.7,
    this.formality = 0.5,
  });

  /// Agent the profile belongs to.
  final String agentId;

  /// Owning tenant; the gateway sets this from the JWT, so clients can
  /// usually leave it null when writing.
  final String? tenantId;

  /// Gemini / marketplace voice id (e.g. `Kore`, `Puck`, ``en-US-Wavenet-D``).
  final String voiceName;

  /// Vocal pitch multiplier (0.5–2.0).
  final double pitch;

  /// Playback speed multiplier (0.5–2.0).
  final double rate;

  /// Warmth hint (0.0–1.0). Higher = more casual/friendly.
  final double warmth;

  /// Formality hint (0.0–1.0). Higher = more professional.
  final double formality;

  /// Default profile — matches the server-side defaults.
  static const VoiceProfile defaults = VoiceProfile(agentId: '');

  /// Deserialize a profile from the Python API response.
  factory VoiceProfile.fromJson(Map<String, dynamic> json) => VoiceProfile(
    agentId: (json['agent_id'] as String?) ?? '',
    tenantId: json['tenant_id'] as String?,
    voiceName: (json['voice_name'] as String?) ?? 'Kore',
    pitch: (json['pitch'] as num?)?.toDouble() ?? 1.0,
    rate: (json['rate'] as num?)?.toDouble() ?? 1.0,
    warmth: (json['warmth'] as num?)?.toDouble() ?? 0.7,
    formality: (json['formality'] as num?)?.toDouble() ?? 0.5,
  );

  /// Serialize for a PUT request. Only non-null fields are sent so the
  /// server can apply partial updates.
  Map<String, dynamic> toJson() => {
    'agent_id': agentId,
    if (tenantId != null) 'tenant_id': tenantId,
    'voice_name': voiceName,
    'pitch': pitch,
    'rate': rate,
    'warmth': warmth,
    'formality': formality,
  };

  /// Return a copy with any subset of fields overridden.
  VoiceProfile copyWith({
    String? agentId,
    String? tenantId,
    String? voiceName,
    double? pitch,
    double? rate,
    double? warmth,
    double? formality,
  }) {
    return VoiceProfile(
      agentId: agentId ?? this.agentId,
      tenantId: tenantId ?? this.tenantId,
      voiceName: voiceName ?? this.voiceName,
      pitch: pitch ?? this.pitch,
      rate: rate ?? this.rate,
      warmth: warmth ?? this.warmth,
      formality: formality ?? this.formality,
    );
  }

  /// Clamp every numeric field into the documented valid range. Useful
  /// before sending a value to the API or rendering a slider for a
  /// legacy profile that predates this model.
  VoiceProfile clamped() {
    double clamp(double v, double lo, double hi) {
      if (v.isNaN) return (lo + hi) / 2.0;
      if (v < lo) return lo;
      if (v > hi) return hi;
      return v;
    }

    return VoiceProfile(
      agentId: agentId,
      tenantId: tenantId,
      voiceName: voiceName,
      pitch: clamp(pitch, VoiceProfileBounds.pitchMin, VoiceProfileBounds.pitchMax),
      rate: clamp(rate, VoiceProfileBounds.rateMin, VoiceProfileBounds.rateMax),
      warmth:
          clamp(warmth, VoiceProfileBounds.warmthMin, VoiceProfileBounds.warmthMax),
      formality: clamp(
        formality,
        VoiceProfileBounds.formalityMin,
        VoiceProfileBounds.formalityMax,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VoiceProfile &&
        other.agentId == agentId &&
        other.tenantId == tenantId &&
        other.voiceName == voiceName &&
        other.pitch == pitch &&
        other.rate == rate &&
        other.warmth == warmth &&
        other.formality == formality;
  }

  @override
  int get hashCode => Object.hash(
    agentId,
    tenantId,
    voiceName,
    pitch,
    rate,
    warmth,
    formality,
  );

  @override
  String toString() =>
      'VoiceProfile(agentId: $agentId, voiceName: $voiceName, '
      'pitch: $pitch, rate: $rate, warmth: $warmth, formality: $formality)';
}
