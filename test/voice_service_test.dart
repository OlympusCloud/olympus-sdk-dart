import 'package:dio/dio.dart';
import 'package:olympus_sdk/olympus_sdk.dart';
import 'package:olympus_sdk/src/http_client.dart';
import 'package:test/test.dart';

/// Intercepts outbound HTTP and returns canned responses so we can assert
/// on the path/method/body of each VoiceService call without touching a real
/// server. Call [enqueue] in order; every Dio request pops the next response.
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
  group('OlympusVoiceService — voice library (#81)', () {
    late _FakeTransport transport;
    late OlympusVoiceService voice;

    setUp(() {
      transport = _FakeTransport();
      voice = OlympusVoiceService(_buildHttpClient(transport));
    });

    test('listVoices decodes 8-voice catalog into VoiceOption models', () async {
      transport.enqueue({
        'voices': [
          {
            'id': 'Kore',
            'name': 'Kore',
            'gender': 'female',
            'description': 'Warm, professional, versatile default',
            'sample_url':
                'https://pub.r2.dev/orderechoai-voice-samples-dev/samples/Kore.mp3',
          },
          {
            'id': 'Puck',
            'name': 'Puck',
            'gender': 'male',
            'description': 'Energetic and playful',
            'sample_url':
                'https://pub.r2.dev/orderechoai-voice-samples-dev/samples/Puck.mp3',
          },
        ],
      });

      final voices = await voice.listVoices();

      expect(voices, hasLength(2));
      expect(voices.first, isA<VoiceOption>());
      expect(voices.first.id, 'Kore');
      expect(voices.first.name, 'Kore');
      expect(voices.first.gender, 'female');
      expect(voices.first.sampleUrl, contains('Kore.mp3'));
      expect(voices[1].id, 'Puck');

      // Verify the request hit the platform voice library endpoint.
      expect(transport.requests, hasLength(1));
      expect(transport.requests.single.method, 'GET');
      expect(transport.requests.single.path, '/voice/voices');
    });

    test('listVoices caches the catalog in memory by default', () async {
      transport.enqueue({
        'voices': [
          {
            'id': 'Kore',
            'name': 'Kore',
            'gender': 'female',
            'description': 'default',
            'sample_url': 'https://x/Kore.mp3',
          },
        ],
      });

      final first = await voice.listVoices();
      final second = await voice.listVoices();

      expect(first, equals(second));
      // Only one network round-trip — the second call hit the cache.
      expect(transport.requests, hasLength(1));
    });

    test('listVoices(forceRefresh: true) bypasses the cache', () async {
      transport
        ..enqueue({
          'voices': [
            {
              'id': 'Kore',
              'name': 'Kore',
              'gender': 'female',
              'description': 'default',
              'sample_url': 'https://x/Kore.mp3',
            },
          ],
        })
        ..enqueue({
          'voices': [
            {
              'id': 'Aoede',
              'name': 'Aoede',
              'gender': 'female',
              'description': 'bright',
              'sample_url': 'https://x/Aoede.mp3',
            },
          ],
        });

      final first = await voice.listVoices();
      final refreshed = await voice.listVoices(forceRefresh: true);

      expect(first.single.id, 'Kore');
      expect(refreshed.single.id, 'Aoede');
      expect(transport.requests, hasLength(2));
    });

    test('clearVoiceLibraryCache forces the next call to refetch', () async {
      transport
        ..enqueue({'voices': <Map<String, dynamic>>[]})
        ..enqueue({'voices': <Map<String, dynamic>>[]});

      await voice.listVoices();
      voice.clearVoiceLibraryCache();
      await voice.listVoices();

      expect(transport.requests, hasLength(2));
    });

    test('updateAgentVoice PUTs to the agent voice route with body', () async {
      transport.enqueue({'ok': true});

      await voice.updateAgentVoice('agent_123', 'Puck');

      expect(transport.requests, hasLength(1));
      final req = transport.requests.single;
      expect(req.method, 'PUT');
      expect(req.path, '/ether/voice/agents/agent_123/voice');
      expect(req.data, {'voice_name': 'Puck'});
    });

    test('getAgentVoice returns the configured voice name', () async {
      transport.enqueue({'voice_name': 'Leda'});

      final name = await voice.getAgentVoice('agent_abc');

      expect(name, 'Leda');
      expect(transport.requests.single.method, 'GET');
      expect(transport.requests.single.path, '/ether/voice/agents/agent_abc/voice');
    });

    test('getAgentVoice falls back to Kore when server returns empty', () async {
      transport.enqueue({'voice_name': ''});
      final name = await voice.getAgentVoice('agent_abc');
      expect(name, 'Kore');
    });

    test('getAgentVoice falls back to Kore when field is missing', () async {
      transport.enqueue(<String, dynamic>{});
      final name = await voice.getAgentVoice('agent_abc');
      expect(name, 'Kore');
    });
  });

  group('VoiceOption', () {
    test('fromJson parses canonical server shape', () {
      final v = VoiceOption.fromJson({
        'id': 'Charon',
        'name': 'Charon',
        'gender': 'male',
        'description': 'Deep and authoritative',
        'sample_url': 'https://x/Charon.mp3',
      });
      expect(v.id, 'Charon');
      expect(v.gender, 'male');
      expect(v.sampleUrl, 'https://x/Charon.mp3');
    });

    test('fromJson also accepts camelCase sampleUrl', () {
      final v = VoiceOption.fromJson({
        'id': 'Zephyr',
        'name': 'Zephyr',
        'gender': 'neutral',
        'description': 'crisp',
        'sampleUrl': 'https://x/Zephyr.mp3',
      });
      expect(v.sampleUrl, 'https://x/Zephyr.mp3');
    });

    test('toJson round-trips', () {
      const v = VoiceOption(
        id: 'Fenrir',
        name: 'Fenrir',
        gender: 'male',
        description: 'Strong and confident',
        sampleUrl: 'https://x/Fenrir.mp3',
      );
      final round = VoiceOption.fromJson(v.toJson());
      expect(round, v);
    });

    test('equality is value-based', () {
      const a = VoiceOption(
        id: 'Kore',
        name: 'Kore',
        gender: 'female',
        description: 'd',
        sampleUrl: 'u',
      );
      const b = VoiceOption(
        id: 'Kore',
        name: 'Kore',
        gender: 'female',
        description: 'd',
        sampleUrl: 'u',
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });
}
