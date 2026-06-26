/// Represents a single time session associated with a [Task].
class TimeLog {
  /// Unique identifier (UUID v4).
  final String id;

  /// Foreign key referencing the associated Task.
  final String taskId;

  /// When the session started.
  final DateTime startTime;

  /// When the session ended; null means the session is still active.
  final DateTime? endTime;

  const TimeLog({
    required this.id,
    required this.taskId,
    required this.startTime,
    this.endTime,
  });

  /// Duration of the session, or null if the session is still active.
  Duration? get duration =>
      endTime != null ? endTime!.difference(startTime) : null;

  /// Whether this session is currently active (no end time set).
  bool get isActive => endTime == null;
}
