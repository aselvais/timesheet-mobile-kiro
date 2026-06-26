import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/blocs/task_bloc.dart';
import 'package:time_tracker/models/task.dart';
import 'package:time_tracker/models/task_summary.dart';
import 'package:time_tracker/repositories/task_repository.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class FakeTaskRepository implements TaskRepository {
  bool createTaskCalled = false;
  final StreamController<List<TaskSummary>> _controller =
      StreamController<List<TaskSummary>>.broadcast();

  void emitTasks(List<TaskSummary> tasks) => _controller.add(tasks);

  @override
  Future<List<Task>> getAllTasks() async => [];

  @override
  Future<Task> createTask(String label) async {
    createTaskCalled = true;
    final task = Task(
      id: 'fake-uuid',
      label: label,
      createdAt: DateTime.now(),
    );
    // Emit updated list after creation
    _controller.add([
      TaskSummary(
        task: task,
        totalDuration: Duration.zero,
        hasActiveSession: false,
      ),
    ]);
    return task;
  }

  @override
  Future<void> deleteTask(String taskId) async {}

  @override
  Stream<List<TaskSummary>> watchTasksWithTotals() => _controller.stream;

  Future<void> dispose() async => _controller.close();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TaskBloc', () {
    late FakeTaskRepository repo;
    late TaskBloc bloc;

    setUp(() {
      repo = FakeTaskRepository();
      bloc = TaskBloc(taskRepository: repo);
    });

    tearDown(() async {
      await bloc.close();
      await repo.dispose();
    });

    // -----------------------------------------------------------------------
    // Requirements 1.1 — valid label emits TasksLoaded
    // -----------------------------------------------------------------------
    test('CreateTaskEvent with valid label emits TasksLoaded', () async {
      // Subscribe to the stream first so emit.forEach is active
      bloc.add(LoadTasksEvent());
      await bloc.stream.firstWhere((s) => s is TasksLoading);

      // Seed the stream with an empty list so LoadTasksEvent emits TasksLoaded
      repo.emitTasks([]);
      await bloc.stream.firstWhere((s) => s is TasksLoaded);

      // Now create a task — the fake repo will emit an updated list
      bloc.add(CreateTaskEvent('Valid Label'));

      final state = await bloc.stream.firstWhere((s) => s is TasksLoaded);

      expect(state, isA<TasksLoaded>());
      expect((state as TasksLoaded).tasks, hasLength(1));
      expect(state.tasks.first.task.label, equals('Valid Label'));
      expect(repo.createTaskCalled, isTrue);
    });

    // -----------------------------------------------------------------------
    // Requirements 1.3 — empty label emits TaskError without calling repository
    // -----------------------------------------------------------------------
    test('CreateTaskEvent with empty label emits TaskError without calling repository',
        () async {
      final future = expectLater(
        bloc.stream,
        emitsThrough(
          predicate<TaskState>(
            (s) => s is TaskError && s.message == 'Task label cannot be empty',
          ),
        ),
      );

      bloc.add(CreateTaskEvent(''));
      await future;

      expect(repo.createTaskCalled, isFalse);
    });

    // -----------------------------------------------------------------------
    // Requirements 1.3 — label > 100 chars emits TaskError without calling repository
    // -----------------------------------------------------------------------
    test('CreateTaskEvent with label > 100 chars emits TaskError without calling repository',
        () async {
      final longLabel = 'a' * 101;

      final future = expectLater(
        bloc.stream,
        emitsThrough(
          predicate<TaskState>(
            (s) =>
                s is TaskError &&
                s.message == 'Task label must be 100 characters or fewer',
          ),
        ),
      );

      bloc.add(CreateTaskEvent(longLabel));
      await future;

      expect(repo.createTaskCalled, isFalse);
    });
  });
}
