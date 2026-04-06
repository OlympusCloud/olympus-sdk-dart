import 'package:olympus_sdk/olympus_sdk.dart';
import 'package:test/test.dart';

void main() {
  group('Pagination', () {
    test('fromJson parses all fields', () {
      final p = Pagination.fromJson({
        'page': 2,
        'per_page': 25,
        'total': 100,
        'total_pages': 4,
      });
      expect(p.page, 2);
      expect(p.perPage, 25);
      expect(p.total, 100);
      expect(p.totalPages, 4);
    });

    test('fromJson uses defaults for missing fields', () {
      final p = Pagination.fromJson({});
      expect(p.page, 1);
      expect(p.perPage, 20);
      expect(p.total, 0);
      expect(p.totalPages, 0);
    });

    test('toJson roundtrip', () {
      const p = Pagination(page: 3, perPage: 10, total: 50, totalPages: 5);
      final json = p.toJson();
      expect(json['page'], 3);
      expect(json['per_page'], 10);
      expect(json['total'], 50);
      expect(json['total_pages'], 5);
    });

    test('hasNextPage and hasPreviousPage', () {
      const first = Pagination(page: 1, perPage: 10, total: 30, totalPages: 3);
      expect(first.hasNextPage, isTrue);
      expect(first.hasPreviousPage, isFalse);

      const last = Pagination(page: 3, perPage: 10, total: 30, totalPages: 3);
      expect(last.hasNextPage, isFalse);
      expect(last.hasPreviousPage, isTrue);

      const middle =
          Pagination(page: 2, perPage: 10, total: 30, totalPages: 3);
      expect(middle.hasNextPage, isTrue);
      expect(middle.hasPreviousPage, isTrue);
    });
  });

  group('PaginatedResponse', () {
    test('fromJson parses data and pagination', () {
      final response =
          PaginatedResponse<Map<String, dynamic>>.fromJson({
        'data': [
          {'id': '1'},
          {'id': '2'},
        ],
        'pagination': {
          'page': 1,
          'per_page': 10,
          'total': 2,
          'total_pages': 1,
        },
      }, (json) => json);

      expect(response.data, hasLength(2));
      expect(response.pagination.total, 2);
    });

    test('fromJson handles missing data', () {
      final response =
          PaginatedResponse<Map<String, dynamic>>.fromJson({}, (json) => json);
      expect(response.data, isEmpty);
    });
  });

  group('ApiResponse', () {
    test('fromJson parses success response', () {
      final response = ApiResponse<Map<String, dynamic>>.fromJson({
        'success': true,
        'data': {'id': '123', 'name': 'Test'},
        'request_id': 'req-abc',
      }, (json) => json);

      expect(response.success, isTrue);
      expect(response.data?['id'], '123');
      expect(response.requestId, 'req-abc');
    });

    test('fromJson handles null data', () {
      final response = ApiResponse<Map<String, dynamic>>.fromJson({
        'success': false,
        'error': 'Not found',
      }, (json) => json);

      expect(response.success, isFalse);
      expect(response.data, isNull);
      expect(response.error, 'Not found');
    });

    test('fromRawJson wraps entire map as data', () {
      final response = ApiResponse<Map<String, dynamic>>.fromRawJson({
        'id': '123',
        'name': 'Test',
      }, (json) => json);

      expect(response.success, isTrue);
      expect(response.data?['id'], '123');
    });
  });

  group('WebhookRegistration', () {
    test('fromJson parses all fields', () {
      final reg = WebhookRegistration.fromJson({
        'id': 'wh-001',
        'url': 'https://example.com/webhook',
        'events': ['order.created', 'order.updated'],
        'secret': 'whsec_abc',
        'created_at': '2026-03-28T10:00:00Z',
      });

      expect(reg.id, 'wh-001');
      expect(reg.url, 'https://example.com/webhook');
      expect(reg.events, hasLength(2));
      expect(reg.secret, 'whsec_abc');
      expect(reg.createdAt, isNotNull);
    });

    test('fromJson handles missing optional fields', () {
      final reg = WebhookRegistration.fromJson({
        'id': 'wh-002',
        'url': 'https://example.com/hook',
        'events': <String>[],
      });

      expect(reg.secret, isNull);
      expect(reg.createdAt, isNull);
    });

    test('toJson roundtrip', () {
      final reg = WebhookRegistration(
        id: 'wh-003',
        url: 'https://example.com/hook',
        events: ['order.created'],
        secret: 'sec',
        createdAt: DateTime.utc(2026, 3, 28),
      );
      final json = reg.toJson();
      expect(json['id'], 'wh-003');
      expect(json['events'], hasLength(1));
      expect(json['secret'], 'sec');
      expect(json.containsKey('created_at'), isTrue);
    });

    test('toJson omits null optional fields', () {
      const reg = WebhookRegistration(
        id: 'wh-004',
        url: 'https://example.com',
        events: [],
      );
      final json = reg.toJson();
      expect(json.containsKey('secret'), isFalse);
      expect(json.containsKey('created_at'), isFalse);
    });
  });

  group('SearchResult', () {
    test('fromJson parses all fields', () {
      final result = SearchResult.fromJson({
        'id': 'doc-1',
        'score': 0.95,
        'content': 'Found content',
        'metadata': {'source': 'menu'},
      });
      expect(result.id, 'doc-1');
      expect(result.score, 0.95);
      expect(result.content, 'Found content');
      expect(result.metadata?['source'], 'menu');
    });

    test('fromJson defaults score to 0', () {
      final result = SearchResult.fromJson({'id': 'x'});
      expect(result.score, 0.0);
      expect(result.content, isNull);
    });

    test('toJson omits nulls', () {
      const result = SearchResult(id: 'x', score: 0.5);
      final json = result.toJson();
      expect(json.containsKey('content'), isFalse);
      expect(json.containsKey('metadata'), isFalse);
    });
  });

  group('PolicyResult', () {
    test('fromJson parses all fields', () {
      final result = PolicyResult.fromJson({
        'allowed': true,
        'value': 42,
        'reason': 'Plan allows it',
      });
      expect(result.allowed, isTrue);
      expect(result.value, 42);
      expect(result.reason, 'Plan allows it');
    });

    test('fromJson defaults allowed to false', () {
      final result = PolicyResult.fromJson({});
      expect(result.allowed, isFalse);
    });

    test('toJson includes allowed, omits null optionals', () {
      const result = PolicyResult(allowed: true);
      final json = result.toJson();
      expect(json['allowed'], isTrue);
      expect(json.containsKey('value'), isFalse);
      expect(json.containsKey('reason'), isFalse);
    });
  });
}
