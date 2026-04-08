import 'package:flutter/services.dart';

/// Service for managing iOS Live Activities and Dynamic Island (Issue #2824)
class LiveActivityService {
  static const MethodChannel _channel = MethodChannel('com.olympus.sdk/live_activity');

  /// Start a new Live Activity for order tracking
  Future<String?> startOrderActivity({
    required String orderId,
    required String status,
    required String estimatedReadyTime,
    required double progress,
  }) async {
    try {
      final String? activityId = await _channel.invokeMethod('startOrderActivity', {
        'orderId': orderId,
        'status': status,
        'estimatedReadyTime': estimatedReadyTime,
        'progress': progress,
      });
      return activityId;
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print("Failed to start Live Activity: '${e.message}'.");
      return null;
    }
  }

  /// Update an existing Live Activity
  Future<void> updateOrderActivity({
    required String activityId,
    required String status,
    required String estimatedReadyTime,
    required double progress,
  }) async {
    try {
      await _channel.invokeMethod('updateOrderActivity', {
        'activityId': activityId,
        'status': status,
        'estimatedReadyTime': estimatedReadyTime,
        'progress': progress,
      });
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print("Failed to update Live Activity: '${e.message}'.");
    }
  }

  /// Stop a Live Activity
  Future<void> stopActivity(String activityId) async {
    try {
      await _channel.invokeMethod('stopActivity', {
        'activityId': activityId,
      });
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print("Failed to stop Live Activity: '${e.message}'.");
    }
  }
}
