import 'dart:async';

/// Generative UI / Self-Healing UI OTA bridge (Issue #2822).
///
/// External apps subscribe to this service to receive server-driven UI
/// patches dispatched over WebSocket by the Olympus ACOS agents and
/// generative UI service. A patch is a JSON definition keyed by a stable
/// `widget_id` that the host app honors when rendering.
///
/// Unlike the foundation copy in
/// `olympus_foundation/.../generative_ui_service.dart`, this version is a
/// pure transport — it does not depend on Riverpod or Flutter widgets, so
/// it can be wrapped by any state-management library or used from
/// pure-Dart isolates that consume Olympus events.
///
/// Typical wiring:
///
/// ```dart
/// final genui = OlympusGenerativeUiService();
/// // Hook your existing WebSocket consumer:
/// websocket.messages.listen((msg) {
///   final data = jsonDecode(msg);
///   if (data['type'] == 'ota_patch') {
///     genui.applyPatch(data['patch_id'], data['definition']);
///   }
/// });
/// // Then anywhere in the UI:
/// final patch = genui.getPatch('order_card');
/// if (patch != null) { /* render with overrides */ }
/// ```
class OlympusGenerativeUiService {
  OlympusGenerativeUiService();

  final Map<String, Map<String, dynamic>> _activePatches = {};
  final StreamController<GenuiPatchEvent> _events =
      StreamController<GenuiPatchEvent>.broadcast();

  /// Stream of patch events (apply / clear). Subscribe to drive UI rebuilds.
  Stream<GenuiPatchEvent> get events => _events.stream;

  /// Apply a UI patch for a specific widget. Replaces any existing patch
  /// with the same [widgetId].
  void applyPatch(String widgetId, Map<String, dynamic> definition) {
    _activePatches[widgetId] = definition;
    if (!_events.isClosed) {
      _events.add(GenuiPatchEvent.applied(widgetId, definition));
    }
  }

  /// Look up the active patch for [widgetId]. Returns `null` if no patch
  /// is currently applied — callers should fall back to their static UI.
  Map<String, dynamic>? getPatch(String widgetId) => _activePatches[widgetId];

  /// Snapshot of every active patch keyed by widget id.
  Map<String, Map<String, dynamic>> get activePatches =>
      Map.unmodifiable(_activePatches);

  /// Clear a single patch. Used when a fix is rolled back from the
  /// control plane.
  void clearPatch(String widgetId) {
    final removed = _activePatches.remove(widgetId);
    if (removed != null && !_events.isClosed) {
      _events.add(GenuiPatchEvent.cleared(widgetId));
    }
  }

  /// Clear every active patch (e.g. on logout or app reset).
  void clearAll() {
    final ids = List<String>.from(_activePatches.keys);
    _activePatches.clear();
    if (!_events.isClosed) {
      for (final id in ids) {
        _events.add(GenuiPatchEvent.cleared(id));
      }
    }
  }

  /// Close the event stream. Call on shutdown.
  Future<void> dispose() async {
    _activePatches.clear();
    await _events.close();
  }
}

/// Patch event emitted by [OlympusGenerativeUiService.events].
class GenuiPatchEvent {
  const GenuiPatchEvent._(this.widgetId, this.definition, this.isCleared);

  /// An apply event — [definition] is the new patch contents.
  factory GenuiPatchEvent.applied(
    String widgetId,
    Map<String, dynamic> definition,
  ) =>
      GenuiPatchEvent._(widgetId, definition, false);

  /// A clear event — the patch with [widgetId] was removed.
  factory GenuiPatchEvent.cleared(String widgetId) =>
      GenuiPatchEvent._(widgetId, const {}, true);

  /// Stable widget identifier the patch targets.
  final String widgetId;

  /// Patch definition. Empty when [isCleared] is true.
  final Map<String, dynamic> definition;

  /// Whether this event represents a patch removal.
  final bool isCleared;
}
