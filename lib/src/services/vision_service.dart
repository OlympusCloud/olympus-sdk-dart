import 'dart:typed_data';

import '../http_client.dart';

/// Vision AI — image-based product, food, inventory, surveillance, and 3D
/// model generation.
///
/// Wraps the Olympus Vision Python service via the Go API Gateway.
/// Routes (all proxied to Python `/api/vision/*`):
///
///   - `POST /api/v1/vision/products/identify`            — Instant Catalog
///   - `POST /api/v1/vision/products/generate-3d`         — AR/WebXR model
///   - `POST /api/v1/vision/food/recognize`               — drive-thru plate
///   - `POST /api/v1/vision/inventory/detect-discrepancies`
///   - `POST /api/v1/vision/cameras`                      — register stream
///   - `GET  /api/v1/vision/cameras`                      — list streams
///   - `GET  /api/v1/vision/cameras/{id}/analytics`       — queue + wait time
///   - `GET  /api/v1/vision/surveillance/events`          — recent events
///   - `POST /api/v1/vision/drive-thru/analyze`           — vehicle / plate
///
/// All AI-backed endpoints (`identify`, `generate-3d`, `recognize`,
/// `detect-discrepancies`) are tracked via the `track_ai_usage` middleware
/// and bill against the caller's tenant.
class OlympusVisionService {
  OlympusVisionService(this._http);

  final OlympusHttpClient _http;

  // ---------------------------------------------------------------------
  // Product recognition & 3D model generation
  // ---------------------------------------------------------------------

  /// Identify a product from an image using the Instant Catalog model.
  ///
  /// Returns a free-form recognition payload (catalog matches, confidence,
  /// suggested SKU) shaped by `ProductRecognitionService.identify_product`.
  Future<Map<String, dynamic>> identifyProduct({
    required Uint8List image,
    required String tenantId,
    String filename = 'product.jpg',
    String contentType = 'image/jpeg',
  }) async {
    return await _http.uploadBytes(
      '/vision/products/identify',
      bytes: image,
      filename: filename,
      contentType: contentType,
      queryParameters: {'tenant_id': tenantId},
    );
  }

  /// Generate a 3D WebXR model from a 2D product image (Issue #2821).
  ///
  /// Used by retail/storefront surfaces to provide AR previews. The
  /// returned payload includes a public URL for the GLB/USDZ asset and
  /// status information from `ThreeDGeneratorService.generate_3d_from_image`.
  Future<Map<String, dynamic>> generate3dModel({
    required Uint8List image,
    required String productName,
    required String tenantId,
    String filename = 'product.jpg',
    String contentType = 'image/jpeg',
  }) async {
    return await _http.uploadBytes(
      '/vision/products/generate-3d',
      bytes: image,
      filename: filename,
      contentType: contentType,
      queryParameters: {
        'product_name': productName,
        'tenant_id': tenantId,
      },
    );
  }

  // ---------------------------------------------------------------------
  // Food recognition & drive-thru
  // ---------------------------------------------------------------------

  /// Recognize food items in a plate image. The image is also archived to
  /// tenant-scoped storage at `drive_thru/verification/{uuid}.jpg` so the
  /// recognized items can be audited later.
  Future<VisionRecognitionResult> recognizeFood({
    required Uint8List image,
    required String tenantId,
    String filename = 'plate.jpg',
    String contentType = 'image/jpeg',
  }) async {
    final json = await _http.uploadBytes(
      '/vision/food/recognize',
      bytes: image,
      filename: filename,
      contentType: contentType,
      queryParameters: {'tenant_id': tenantId},
    );
    return VisionRecognitionResult.fromJson(json);
  }

  /// Analyze a drive-thru lane image for vehicles and license plates.
  ///
  /// Returns a payload like `{vehicle_detected, license_plate, vehicle_type,
  /// color, confidence}`.
  Future<Map<String, dynamic>> analyzeDriveThruImage({
    required Uint8List image,
    String filename = 'lane.jpg',
    String contentType = 'image/jpeg',
  }) async {
    return await _http.uploadBytes(
      '/vision/drive-thru/analyze',
      bytes: image,
      filename: filename,
      contentType: contentType,
    );
  }

  // ---------------------------------------------------------------------
  // Inventory detection (Ghost Inventory)
  // ---------------------------------------------------------------------

  /// Detect inventory discrepancies by comparing a stock-room photo against
  /// expected on-hand quantities for [targetItems].
  Future<Map<String, dynamic>> detectInventoryDiscrepancies({
    required Uint8List image,
    required String tenantId,
    required String locationId,
    required List<String> targetItems,
    String filename = 'stock.jpg',
    String contentType = 'image/jpeg',
  }) async {
    return await _http.uploadBytes(
      '/vision/inventory/detect-discrepancies',
      bytes: image,
      filename: filename,
      contentType: contentType,
      queryParameters: {
        'tenant_id': tenantId,
        'location_id': locationId,
        // FastAPI repeats the parameter for list-typed Query, so the HTTP
        // client serializes a list as `target_items=a&target_items=b`.
        'target_items': targetItems,
      },
    );
  }

  // ---------------------------------------------------------------------
  // Camera management
  // ---------------------------------------------------------------------

  /// Register a new camera stream with the vision service. The camera will
  /// then be polled by the inference loop and become queryable via
  /// [getCameraAnalytics].
  Future<void> addCamera({
    required String cameraId,
    required String rtspUrl,
    required String name,
  }) async {
    await _http.post(
      '/vision/cameras',
      data: {
        'camera_id': cameraId,
        'rtsp_url': rtspUrl,
        'name': name,
      },
    );
  }

  /// List all cameras currently registered with the vision service.
  Future<List<CameraStream>> listCameras() async {
    final raw = await _http.getList('/vision/cameras');
    return raw
        .map((e) => CameraStream.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// Fetch live analytics (queue length, wait time) for a single camera.
  Future<CameraAnalytics> getCameraAnalytics(String cameraId) async {
    final json = await _http.get('/vision/cameras/$cameraId/analytics');
    return CameraAnalytics.fromJson(json);
  }

  // ---------------------------------------------------------------------
  // Surveillance events
  // ---------------------------------------------------------------------

  /// Get recent surveillance events (Safety, Security, Compliance) for a
  /// tenant. The newest [limit] events (1-100) are returned.
  Future<List<Map<String, dynamic>>> getSurveillanceEvents({
    required String tenantId,
    int limit = 50,
  }) async {
    final raw = await _http.getList(
      '/vision/surveillance/events',
      queryParameters: {'tenant_id': tenantId, 'limit': limit},
    );
    return raw.cast<Map<String, dynamic>>();
  }
}

/// Result returned by [OlympusVisionService.recognizeFood].
class VisionRecognitionResult {
  const VisionRecognitionResult({
    required this.verified,
    required this.items,
    required this.totalCount,
    this.imageUrl,
  });

  /// Whether the recognized items match the expected order.
  final bool verified;

  /// Per-item recognition results (label, confidence, bounding box).
  final List<Map<String, dynamic>> items;

  /// Total number of items detected.
  final int totalCount;

  /// Public URL of the archived image, if storage was configured.
  final String? imageUrl;

  factory VisionRecognitionResult.fromJson(Map<String, dynamic> json) =>
      VisionRecognitionResult(
        verified: json['verified'] as bool? ?? false,
        items: (json['items'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>(),
        totalCount: json['total_count'] as int? ?? 0,
        imageUrl: json['image_url'] as String?,
      );
}

/// A camera stream registered with the vision service.
class CameraStream {
  const CameraStream({required this.cameraId, required this.rtspUrl});

  final String cameraId;
  final String rtspUrl;

  factory CameraStream.fromJson(Map<String, dynamic> json) => CameraStream(
    cameraId: json['camera_id'] as String,
    rtspUrl: json['rtsp_url'] as String,
  );
}

/// Live analytics snapshot for a single camera.
class CameraAnalytics {
  const CameraAnalytics({
    required this.cameraId,
    required this.queueLength,
    required this.waitTime,
  });

  final String cameraId;

  /// Number of people / vehicles currently in the queue.
  final int queueLength;

  /// Estimated wait time in seconds.
  final double waitTime;

  factory CameraAnalytics.fromJson(Map<String, dynamic> json) =>
      CameraAnalytics(
        cameraId: json['camera_id'] as String,
        queueLength: json['queue_length'] as int? ?? 0,
        waitTime: (json['wait_time'] as num?)?.toDouble() ?? 0.0,
      );
}
