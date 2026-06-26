import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/task_summary.dart';
import '../repositories/task_repository.dart';

part 'task_event.dart';
part 'task_state.dart';

/// Manages task list state: loading, creation, and deletion.
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;
  StreamSubscription<List<TaskSummary>>? _tasksSubscription;

  TaskBloc({required TaskRepository taskRepository})
      : _taskRepository = taskRepository,
        super(TasksLoading()) {
    on<LoadTasksEvent>(_onLoad);
    on<CreateTaskEvent>(_onCreate);
    on<DeleteTaskEvent>(_onDelete);
    on<ReorderTasksEvent>(_onReorder);
  }

  Future<void> _onLoad(
    LoadTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(TasksLoading());
    try {
      await emit.forEach<List<TaskSummary>>(
        _taskRepository.watchTasksWithTotals(),
        onData: (tasks) => TasksLoaded(tasks),
        onError: (_, __) => TaskError('Failed to load tasks'),
      );
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onCreate(
    CreateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    final trimmed = event.label.trim();
    if (trimmed.isEmpty) {
      emit(TaskError('Task label cannot be empty'));
      return;
    }
    if (trimmed.length > 100) {
      emit(TaskError('Task label must be 100 characters or fewer'));
      return;
    }

    try {
      await _taskRepository.createTask(trimmed);
      // The watchTasksWithTotals stream will emit the updated list automatically.
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      if (event.keepLogs) {
        await _taskRepository.deleteTaskKeepLogs(event.taskId);
      } else {
        await _taskRepository.deleteTask(event.taskId);
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onReorder(
    ReorderTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    // Apply new order immediately to current state so UI updates instantly
    final current = state;
    if (current is TasksLoaded) {
      final indexed = {for (final s in current.tasks) s.task.id: s};
      final reordered = event.orderedIds
          .where(indexed.containsKey)
          .map((id) => indexed[id]!)
          .toList();
      // Append any tasks not in the ordered list
      for (final s in current.tasks) {
        if (!event.orderedIds.contains(s.task.id)) reordered.add(s);
      }
      emit(TasksLoaded(reordered));
    }
    // Persist in background — don't await so UI isn't blocked
    _taskRepository.reorderTasks(event.orderedIds).ignore();
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
