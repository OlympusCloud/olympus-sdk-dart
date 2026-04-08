import 'dart:async';

import 'package:flutter/services.dart';

/// Wearable companion bridge — WearOS and watchOS (Issue #2825).
///
/// Talks to the native side via the `com.olympus.sdk/wearable` MethodChannel.
/// External apps that ship a wearable companion register Java/Kotlin and
/// Swift handlers under that channel name.
///
/// Unlike the foundation copy in
/// `olympus_foundation/.../wearable_communication_service.dart`, this version
/// has no Riverpod dependency so it can be consumed by pure Flutter apps
/// that use a different state-management library (or none).
class OlympusWearableService {
  OlympusWearableService() {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  static const MethodChannel _channel =
      MethodChannel('com.olympus.sdk/wearable');

  final StreamController<String> _voiceCommands =
      StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _actions =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of voice commands captured on the wearable. Apps wire this into
  /// their existing voice intent pipeline (e.g. "Hey Maximus, bump table 12").
  Stream<String> get voiceCommands => _voiceCommands.stream;

  /// Stream of structured action payloads from wearable button taps.
  Stream<Map<String, dynamic>> get actions => _actions.stream;

  /// Send an alert to the wearable with an optional haptic pattern.
  ///
  /// [hapticPattern] is one of `critical`, `warning`, or `info`. Native
  /// implementations choose the actual vibration profile.
  Future<void> sendAlert({
    required String title,
    required String message,
    String? hapticPattern,
  }) async {
    try {
      await _channel.invokeMethod('sendAlert', {
        'title': title,
        'message': message,
        'hapticPattern': ?hapticPattern,
      });
    } on PlatformException catch (_) {
      // Wearable not connected or unsupported — silently drop.
    }
  }

  /// Update the glanceable state on the wearable (e.g. order count, status).
  Future<void> updateGlanceableState(Map<String, dynamic> state) async {
    try {
      await _channel.invokeMethod('updateState', state);
    } on PlatformException catch (_) {
      // Wearable not connected or unsupported — silently drop.
    }
  }

  /// List currently connected wearables. Returns an empty list when none
  /// are paired or the platform doesn't support wearable enumeration.
  Future<List<String>> listConnected() async {
    try {
      final raw = await _channel.invokeMethod<List<dynamic>>('listConnected');
      return (raw ?? const []).cast<String>();
    } on PlatformException catch (_) {
      return const [];
    }
  }

  /// Close the underlying stream controllers. Call when the host app is
  /// shutting down or the user signs out.
  Future<void> dispose() async {
    await _voiceCommands.close();
    await _actions.close();
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onVoiceCommand':
        if (!_voiceCommands.isClosed) {
          _voiceCommands.add(call.arguments as String);
        }
        return null;
      case 'onAction':
        if (!_actions.isClosed) {
          final args = (call.arguments as Map).cast<String, dynamic>();
          _actions.add(args);
        }
        return null;
      default:
        return null;
    }
  }
}
