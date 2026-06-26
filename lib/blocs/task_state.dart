part of 'task_bloc.dart';

/// Base sealed class for all task-related states.
sealed class TaskState {}

/// Tasks are being loaded from the repository.
class TasksLoading extends TaskState {}

/// Tasks have been loaded successfully.
class TasksLoaded extends TaskState {
  final List<TaskSummary> tasks;
  TasksLoaded(this.tasks);
}

/// An error occurred during a task operation.
class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
}
