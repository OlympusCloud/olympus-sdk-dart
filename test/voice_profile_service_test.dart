import 'package:dio/dio.dart';
import 'package:olympus_sdk/olympus_sdk.dart';
import 'package:olympus_sdk/src/http_client.dart';
import 'package:test/test.dart';

/// Intercepts outbound HTTP and returns canned responses so we can assert
/// on the path/method/body of each call without touching a real server.
/// Follows the pattern established by `voice_service_test.dart` so the two
/// files can live side-by-side without sharing any state.
class _FakeTransport extends Interceptor {
  _FakeTransport();

  final List<Response<dynamic>> _responses = [];
  final List<RequestOptions> requests = [];

  void enqueue(dynamic body, {int statusCode = 200}) {
    _responses.add(
      Response<dynamic>(
        requestOptions: RequestOptions(path: ''),
        data: body,
        statusCode: statusCode,
      ),
    );
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requests.add(options);
    if (_responses.isEmpty) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'no response enqueued for ${options.path}',
        ),
      );
      return;
    }
    final next = _responses.removeAt(0);
    handler.resolve(
      Response<dynamic>(
        requestOptions: options,
        data: next.data,
        statusCode: next.statusCode,
      ),
    );
  }
}

OlympusHttpClient _buildHttpClient(_FakeTransport transport) {
  final client = OlympusHttpClient(
    const OlympusConfig(
      appId: 'com.test',
      apiKey: 'oc_test_key',
      baseUrl: 'https://unit-test.local/api/v1',
    ),
  );
  client.dio.interceptors.add(transport);
  return client;
}

void main() {
  group('VoiceProfile model (#82)', () {
    test('fromJson fills defaults for missing fields', () {
      final profile = VoiceProfile.fromJson({'agent_id': 'agent-1'});
      expect(profile.agentId, 'agent-1');
      expect(profile.voiceName, 'Kore');
      expect(profile.pitch, 1.0);
      expect(profile.rate, 1.0);
      expect(profile.warmth, 0.7);
      expect(profile.formality, 0.5);
    });

    test('fromJson accepts int values for numeric fields', () {
      final profile = VoiceProfile.fromJson({
        'agent_id': 'a',
        'pitch': 1,
        'rate': 2,
        'warmth': 0,
        'formality': 1,
      });
      expect(profile.pitch, 1.0);
      expect(profile.rate, 2.0);
      expect(profile.warmth, 0.0);
      expect(profile.formality, 1.0);
    });

    test('toJson roundtrips every field', () {
      const profile = VoiceProfile(
        agentId: 'agent-1',
        tenantId: 'tenant-1',
        voiceName: 'Puck',
        pitch: 1.2,
        rate: 0.9,
        warmth: 0.8,
        formality: 0.3,
      );
      final json = profile.toJson();
      expect(json['agent_id'], 'agent-1');
      expect(json['tenant_id'], 'tenant-1');
      expect(json['voice_name'], 'Puck');
      expect(json['pitch'], 1.2);
      expect(json['rate'], 0.9);
      expect(json['warmth'], 0.8);
      expect(json['formality'], 0.3);
    });

    test('clamped() pulls out-of-range values back into bounds', () {
      const wild = VoiceProfile(
        agentId: 'a',
        pitch: 3.5,
        rate: -0.5,
        warmth: 1.9,
        formality: -0.1,
      );
      final safe = wild.clamped();
      expect(safe.pitch, VoiceProfileBounds.pitchMax);
      expect(safe.rate, VoiceProfileBounds.rateMin);
      expect(safe.warmth, VoiceProfileBounds.warmthMax);
      expect(safe.formality, VoiceProfileBounds.formalityMin);
    });

    test('copyWith overrides only the provided fields', () {
      const profile = VoiceProfile(agentId: 'a');
      final updated = profile.copyWith(pitch: 1.5, voiceName: 'Zephyr');
      expect(updated.pitch, 1.5);
      expect(updated.voiceName, 'Zephyr');
      expect(updated.rate, profile.rate);
      expect(updated.warmth, profile.warmth);
      expect(updated.formality, profile.formality);
    });

    test('equality treats identical instances as equal', () {
      const a = VoiceProfile(agentId: 'x', pitch: 1.2);
      const b = VoiceProfile(agentId: 'x', pitch: 1.2);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('OlympusVoiceProfileService (#82)', () {
    late _FakeTransport transport;
    late OlympusVoiceProfileService service;

    setUp(() {
      transport = _FakeTransport();
      service = OlympusVoiceProfileService(_buildHttpClient(transport));
    });

    test('getVoiceProfile hits the expected path', () async {
      transport.enqueue({
        'agent_id': 'agent-1',
        'tenant_id': 'tenant-1',
        'voice_name': 'Kore',
        'pitch': 1.1,
        'rate': 0.95,
        'warmth': 0.6,
        'formality': 0.4,
      });
      final profile = await service.getVoiceProfile('agent-1');
      expect(transport.requests.single.method, 'GET');
      expect(
        transport.requests.single.path,
        '/ether/voice/agents/agent-1/profile',
      );
      expect(profile.agentId, 'agent-1');
      expect(profile.voiceName, 'Kore');
      expect(profile.pitch, 1.1);
      expect(profile.rate, 0.95);
      expect(profile.warmth, 0.6);
      expect(profile.formality, 0.4);
    });

    test('updateVoiceProfile sends clamped values and returns the response',
        () async {
      transport.enqueue({
        'agent_id': 'agent-1',
        'voice_name': 'Puck',
        'pitch': 1.8,
        'rate': 1.5,
        'warmth': 0.9,
        'formality': 0.2,
      });
      const pending = VoiceProfile(
        agentId: 'agent-1',
        voiceName: 'Puck',
        pitch: 5.0, // wildly out of range — should be clamped client-side.
        rate: 1.5,
        warmth: 0.9,
        formality: 0.2,
      );
      final saved = await service.updateVoiceProfile('agent-1', pending);

      expect(transport.requests.single.method, 'PUT');
      expect(
        transport.requests.single.path,
        '/ether/voice/agents/agent-1/profile',
      );
      final body = transport.requests.single.data as Map<String, dynamic>;
      // Pitch was 5.0 → clamped to 2.0 before sending.
      expect(body['pitch'], VoiceProfileBounds.pitchMax);
      expect(body['rate'], 1.5);
      expect(body['warmth'], 0.9);
      expect(body['formality'], 0.2);
      expect(body['voice_name'], 'Puck');

      expect(saved.voiceName, 'Puck');
      expect(saved.pitch, 1.8);
    });

    test('resetVoiceProfile POSTs to the reset sub-path', () async {
      transport.enqueue({
        'agent_id': 'agent-1',
        'voice_name': 'Kore',
        'pitch': 1.0,
        'rate': 1.0,
        'warmth': 0.7,
        'formality': 0.5,
      });
      final reset = await service.resetVoiceProfile('agent-1');
      expect(transport.requests.single.method, 'POST');
      expect(
        transport.requests.single.path,
        '/ether/voice/agents/agent-1/profile/reset',
      );
      expect(reset.pitch, 1.0);
      expect(reset.rate, 1.0);
      expect(reset.warmth, 0.7);
      expect(reset.formality, 0.5);
    });

    test('client.voiceProfile accessor returns the lazy singleton', () {
      final oc = OlympusClient(appId: 'com.test', apiKey: 'key');
      expect(oc.voiceProfile, isA<OlympusVoiceProfileService>());
      expect(identical(oc.voiceProfile, oc.voiceProfile), isTrue);
    });
  });
}
