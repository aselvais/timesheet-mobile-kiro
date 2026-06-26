import '../models/task.dart';
import '../models/task_summary.dart';

/// Abstract interface for CRUD operations on Task records.
abstract class TaskRepository {
  /// Returns all tasks stored in the local database.
  Future<List<Task>> getAllTasks();

  /// Creates a new task with the given [label] and persists it.
  ///
  /// Preconditions:
  /// - [label].trim() is non-empty
  /// - [label].length <= 100
  Future<Task> createTask(String label);

  /// Deletes the task identified by [taskId] and all associated TimeLog records.
  Future<void> deleteTask(String taskId);

  /// Deletes the task but keeps all associated TimeLog records (orphaned).
  Future<void> deleteTaskKeepLogs(String taskId);

  /// Persists a new sort order for tasks (list of task ids in order).
  Future<void> reorderTasks(List<String> orderedIds);

  /// Updates the hourly rate for a task. Pass null to clear the rate.
  Future<void> updateHourlyRate(String taskId, double? hourlyRate);

  /// Returns a reactive stream that emits an updated list of [TaskSummary]
  /// records whenever the underlying task or session data changes.
  Stream<List<TaskSummary>> watchTasksWithTotals();
}
