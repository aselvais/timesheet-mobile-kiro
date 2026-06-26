part of 'task_bloc.dart';

/// Base sealed class for all task-related events.
sealed class TaskEvent {}

/// Fired when the task list screen loads or needs a refresh.
class LoadTasksEvent extends TaskEvent {}

/// Fired when the user submits a new task label.
class CreateTaskEvent extends TaskEvent {
  final String label;
  CreateTaskEvent(this.label);
}

/// Fired when the user deletes a task.
class DeleteTaskEvent extends TaskEvent {
  final String taskId;
  final bool keepLogs;
  DeleteTaskEvent(this.taskId, {this.keepLogs = false});
}

/// Fired when the user reorders tasks via drag and drop.
class ReorderTasksEvent extends TaskEvent {
  final List<String> orderedIds;
  ReorderTasksEvent(this.orderedIds);
}
