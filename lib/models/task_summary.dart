import 'tag.dart';
import 'task.dart';

/// A derived view combining a [Task] with its aggregated session data.
class TaskSummary {
  final Task task;
  final Duration totalDuration;
  final bool hasActiveSession;
  final List<Tag> tags;

  const TaskSummary({
    required this.task,
    required this.totalDuration,
    required this.hasActiveSession,
    this.tags = const [],
  });
}
