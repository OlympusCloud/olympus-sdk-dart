/// Voice library model — represents a single Gemini Live prebuilt voice
/// that can be assigned to a voice agent.
///
/// Issue #81 — Voice library API + SDK voice selection. The platform
/// exposes 8 Gemini Live voices (Kore, Aoede, Leda, Puck, Charon, Fenrir,
/// Orus, Zephyr) each with a 5-second audio sample so tenants can preview
/// before selecting.
class VoiceOption {
  /// Stable identifier for the voice (matches Gemini Live `voice_name`).
  final String id;

  /// Human-readable display name.
  final String name;

  /// Voice gender: `female`, `male`, or `neutral`.
  final String gender;

  /// Short marketing description (e.g. "Warm, professional, versatile default").
  final String description;

  /// Public R2 URL to a 5-second audio sample (mp3).
  final String sampleUrl;

  const VoiceOption({
    required this.id,
    required this.name,
    required this.gender,
    required this.description,
    required this.sampleUrl,
  });

  /// Deserialize from the platform API JSON shape
  /// `{id, name, gender, description, sample_url}`.
  factory VoiceOption.fromJson(Map<String, dynamic> json) {
    return VoiceOption(
      id: (json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      gender: (json['gender'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      sampleUrl: (json['sample_url'] ?? json['sampleUrl'] ?? '') as String,
    );
  }

  /// Serialize back to a JSON map matching the platform API shape.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'gender': gender,
        'description': description,
        'sample_url': sampleUrl,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VoiceOption &&
        other.id == id &&
        other.name == name &&
        other.gender == gender &&
        other.description == description &&
        other.sampleUrl == sampleUrl;
  }

  @override
  int get hashCode =>
      Object.hash(id, name, gender, description, sampleUrl);

  @override
  String toString() =>
      'VoiceOption(id: $id, name: $name, gender: $gender)';
}
