/// Models for the Olympus Observe (telemetry) service.
library;

/// Handle returned when starting a distributed trace span.
///
/// Call [end] to close the span and record its duration.
class TraceHandle {
  TraceHandle({
    required this.name,
    required this.traceId,
    required this.startedAt,
    this.onEnd,
  });

  final String name;
  final String traceId;
  final DateTime startedAt;

  /// Callback invoked by [end] to report the completed span.
  final Future<void> Function(TraceHandle handle, Duration duration)? onEnd;

  DateTime? _endedAt;

  /// The time the span ended, or null if still active.
  DateTime? get endedAt => _endedAt;

  /// The elapsed duration, measured from start to now (if active) or to end.
  Duration get elapsed => (_endedAt ?? DateTime.now()).difference(startedAt);

  /// End this trace span and report its duration.
  Future<void> end() async {
    _endedAt = DateTime.now();
    final duration = _endedAt!.difference(startedAt);
    await onEnd?.call(this, duration);
  }
}
