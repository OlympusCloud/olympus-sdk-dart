/// Shared types used across all Olympus SDK services.
library;

/// Paginated response wrapper for list endpoints.
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.data,
    required this.pagination,
  });

  final List<T> data;
  final Pagination pagination;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final items = (json['data'] as List<dynamic>?)
            ?.map((e) => fromJsonT(e as Map<String, dynamic>))
            .toList() ??
        [];
    return PaginatedResponse(
      data: items,
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : Pagination(
              page: json['page'] as int? ?? 1,
              perPage: json['per_page'] as int? ?? items.length,
              total: json['total'] as int? ?? items.length,
              totalPages: json['total_pages'] as int? ?? 1,
            ),
    );
  }
}

/// Pagination metadata returned by list endpoints.
class Pagination {
  const Pagination({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int perPage;
  final int total;
  final int totalPages;

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        page: json['page'] as int? ?? 1,
        perPage: json['per_page'] as int? ?? 20,
        total: json['total'] as int? ?? 0,
        totalPages: json['total_pages'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'page': page,
        'per_page': perPage,
        'total': total,
        'total_pages': totalPages,
      };

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}

/// Standard API response wrapper.
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.requestId,
  });

  final bool success;
  final T? data;
  final String? error;
  final String? requestId;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) =>
      ApiResponse(
        success: json['success'] as bool? ?? true,
        data: json['data'] != null
            ? fromJsonT(json['data'] as Map<String, dynamic>)
            : null,
        error: json['error'] as String?,
        requestId: json['request_id'] as String?,
      );

  /// Construct from a raw JSON map where the data is the map itself
  /// (i.e., no wrapping envelope).
  factory ApiResponse.fromRawJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) =>
      ApiResponse(
        success: true,
        data: fromJsonT(json),
        requestId: json['request_id'] as String?,
      );
}

/// Webhook registration returned by the events service.
class WebhookRegistration {
  const WebhookRegistration({
    required this.id,
    required this.url,
    required this.events,
    this.secret,
    this.createdAt,
  });

  final String id;
  final String url;
  final List<String> events;
  final String? secret;
  final DateTime? createdAt;

  factory WebhookRegistration.fromJson(Map<String, dynamic> json) =>
      WebhookRegistration(
        id: json['id'] as String,
        url: json['url'] as String,
        events: (json['events'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        secret: json['secret'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'events': events,
        if (secret != null) 'secret': secret,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };
}

/// Generic search result returned by data and AI search operations.
class SearchResult {
  const SearchResult({
    required this.id,
    required this.score,
    this.content,
    this.metadata,
  });

  final String id;
  final double score;
  final String? content;
  final Map<String, dynamic>? metadata;

  factory SearchResult.fromJson(Map<String, dynamic> json) => SearchResult(
        id: json['id'] as String,
        score: (json['score'] as num?)?.toDouble() ?? 0.0,
        content: json['content'] as String?,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'score': score,
        if (content != null) 'content': content,
        if (metadata != null) 'metadata': metadata,
      };
}

/// Policy evaluation result returned by the gating service.
class PolicyResult {
  const PolicyResult({
    required this.allowed,
    this.value,
    this.reason,
  });

  final bool allowed;
  final dynamic value;
  final String? reason;

  factory PolicyResult.fromJson(Map<String, dynamic> json) => PolicyResult(
        allowed: json['allowed'] as bool? ?? false,
        value: json['value'],
        reason: json['reason'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'allowed': allowed,
        if (value != null) 'value': value,
        if (reason != null) 'reason': reason,
      };
}
