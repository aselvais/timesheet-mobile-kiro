/// Represents a named task label created by the user.
class Task {
  final String id;
  final String label;
  final DateTime createdAt;
  /// Hourly rate in the user's currency. Null means no rate configured.
  final double? hourlyRate;

  const Task({
    required this.id,
    required this.label,
    required this.createdAt,
    this.hourlyRate,
  });

  /// Earnings for a given duration at this task's hourly rate.
  double? earnings(Duration duration) {
    if (hourlyRate == null) return null;
    return hourlyRate! * duration.inSeconds / 3600.0;
  }
}
