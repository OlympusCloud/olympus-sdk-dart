import 'dart:convert';

import '../http_client.dart';

/// File storage operations backed by Cloudflare R2.
///
/// Routes: `/storage/*` (proxied to the media-storage worker).
class OlympusStorageService {
  OlympusStorageService(this._http);

  final OlympusHttpClient _http;

  /// Upload binary data to a path and return the public URL.
  ///
  /// [bytes] is the raw file content. [path] is the storage key
  /// (e.g., "images/menu/burger.webp").
  Future<String> upload(List<int> bytes, String path) async {
    final json = await _http.post('/storage/upload', data: {
      'path': path,
      'content': base64Encode(bytes),
    });
    return json['url'] as String? ?? '';
  }

  /// Get the public or signed URL for a stored object.
  Future<String> getUrl(String path) async {
    final json = await _http.get('/storage/url', queryParameters: {
      'path': path,
    });
    return json['url'] as String? ?? '';
  }

  /// Generate a pre-signed upload URL for direct client uploads.
  ///
  /// [expiresIn] is the validity duration in seconds (default: 3600).
  Future<String> presignUpload(
    String path, {
    Duration? expiresIn,
  }) async {
    final json = await _http.post('/storage/presign', data: {
      'path': path,
      if (expiresIn != null) 'expires_in': expiresIn.inSeconds,
    });
    return json['url'] as String? ?? json['presigned_url'] as String? ?? '';
  }

  /// Delete a stored object.
  Future<void> delete(String path) async {
    await _http.delete('/storage/objects/$path');
  }
}
