import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:time_tracker/data/database.dart';
import 'package:time_tracker/repositories/drift_task_repository.dart';

void main() {
  late AppDatabase db;
  late DriftTaskRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftTaskRepository(database: db);
  });

  tearDown(() async {
    await db.close();
  });

  // ---------------------------------------------------------------------------
  // createTask
  // ---------------------------------------------------------------------------

  group('createTask', () {
    /// Validates: Requirements 1.1, 1.2
    test('persists a task with the correct label', () async {
      final task = await repo.createTask('My Task');

      expect(task.label, equals('My Task'));

      final rows = await db.select(db.tasks).get();
      expect(rows.length, equals(1));
      expect(rows.first.id, equals(task.id));
      expect(rows.first.label, equals('My Task'));
    });

    /// Validates: Requirements 1.2
    test('sets createdAt close to now()', () async {
      final before = DateTime.now();
      final task = await repo.createTask('Timed Task');
      final after = DateTime.now();

      expect(
        task.createdAt.isAfter(before.subtract(const Duration(seconds: 2))),
        isTrue,
        reason: 'createdAt should be at or after test start',
      );
      expect(
        task.createdAt.isBefore(after.add(const Duration(seconds: 2))),
        isTrue,
        reason: 'createdAt should be at or before test end',
      );
    });

    /// Validates: Requirements 1.1
    test('returns a task with a non-empty UUID id', () async {
      final task = await repo.createTask('UUID Task');
      expect(task.id, isNotEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // deleteTask
  // ---------------------------------------------------------------------------

  group('deleteTask', () {
    /// Validates: Requirements 1.5
    test('removes the task row from the database', () async {
      final task = await repo.createTask('To Delete');

      await repo.deleteTask(task.id);

      final rows = await db.select(db.tasks).get();
      expect(rows, isEmpty);
    });

    /// Validates: Requirements 1.5
    test('cascade-deletes all associated TimeLog records', () async {
      final task = await repo.createTask('Task With Logs');
      final logId = const Uuid().v4();

      // Insert a time_log directly for this task.
      await db.into(db.timeLogs).insert(
            TimeLogsCompanion.insert(
              id: logId,
              taskId: task.id,
              startTime: DateTime.now().millisecondsSinceEpoch,
              endTime: const Value.absent(),
            ),
          );

      // Verify the log exists before deletion.
      final logsBefore = await db.select(db.timeLogs).get();
      expect(logsBefore.length, equals(1));

      await repo.deleteTask(task.id);

      // Both task and time_log should be gone.
      final tasksAfter = await db.select(db.tasks).get();
      final logsAfter = await db.select(db.timeLogs).get();

      expect(tasksAfter, isEmpty);
      expect(logsAfter, isEmpty);
    });

    /// Validates: Requirements 1.5
    test('only deletes logs belonging to the deleted task', () async {
      final taskA = await repo.createTask('Task A');
      final taskB = await repo.createTask('Task B');
      final logId = const Uuid().v4();

      await db.into(db.timeLogs).insert(
            TimeLogsCompanion.insert(
              id: logId,
              taskId: taskA.id,
              startTime: DateTime.now().millisecondsSinceEpoch,
              endTime: const Value.absent(),
            ),
          );

      await repo.deleteTask(taskA.id);

      final remainingTasks = await db.select(db.tasks).get();
      final remainingLogs = await db.select(db.timeLogs).get();

      expect(remainingTasks.length, equals(1));
      expect(remainingTasks.first.id, equals(taskB.id));
      expect(remainingLogs, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // watchTasksWithTotals
  // ---------------------------------------------------------------------------

  group('watchTasksWithTotals', () {
    /// Validates: Requirements 6.2
    test('emits correct totalDuration as sum of closed sessions', () async {
      final task = await repo.createTask('Timed Task');
      final now = DateTime.now().millisecondsSinceEpoch;

      // Session 1: 30 seconds
      await db.into(db.timeLogs).insert(
            TimeLogsCompanion.insert(
              id: const Uuid().v4(),
              taskId: task.id,
              startTime: now,
              endTime: Value(now + 30000),
            ),
          );

      // Session 2: 60 seconds
      await db.into(db.timeLogs).insert(
            TimeLogsCompanion.insert(
              id: const Uuid().v4(),
              taskId: task.id,
              startTime: now + 60000,
              endTime: Value(now + 120000),
            ),
          );

      final summaries = await repo.watchTasksWithTotals().first;

      expect(summaries.length, equals(1));
      expect(summaries.first.totalDuration, equals(const Duration(seconds: 90)));
    });

    /// Validates: Requirements 6.3
    test('sets hasActiveSession true when an open session exists', () async {
      final task = await repo.createTask('Active Task');
      final now = DateTime.now().millisecondsSinceEpoch;

      // One active session (endTime null).
      await db.into(db.timeLogs).insert(
            TimeLogsCompanion.insert(
              id: const Uuid().v4(),
              taskId: task.id,
              startTime: now,
              endTime: const Value.absent(),
            ),
          );

      final summaries = await repo.watchTasksWithTotals().first;

      expect(summaries.length, equals(1));
      expect(summaries.first.hasActiveSession, isTrue);
    });

    /// Validates: Requirements 6.2, 6.3
    test('excludes active session duration from totalDuration', () async {
      final task = await repo.createTask('Mixed Task');
      final now = DateTime.now().millisecondsSinceEpoch;

      // Closed session: 45 seconds.
      await db.into(db.timeLogs).insert(
            TimeLogsCompanion.insert(
              id: const Uuid().v4(),
              taskId: task.id,
              startTime: now,
              endTime: Value(now + 45000),
            ),
          );

      // Active session (should not contribute to totalDuration).
      await db.into(db.timeLogs).insert(
            TimeLogsCompanion.insert(
              id: const Uuid().v4(),
              taskId: task.id,
              startTime: now + 60000,
              endTime: const Value.absent(),
            ),
          );

      final summaries = await repo.watchTasksWithTotals().first;

      expect(summaries.first.totalDuration, equals(const Duration(seconds: 45)));
      expect(summaries.first.hasActiveSession, isTrue);
    });

    /// Validates: Requirements 6.2, 6.3
    test('emits zero duration and no active session for a task with no logs',
        () async {
      await repo.createTask('Empty Task');

      final summaries = await repo.watchTasksWithTotals().first;

      expect(summaries.length, equals(1));
      expect(summaries.first.totalDuration, equals(Duration.zero));
      expect(summaries.first.hasActiveSession, isFalse);
    });

    /// Validates: Requirements 1.4
    test('emits updated list when a new task is created', () async {
      await repo.createTask('First');

      final stream = repo.watchTasksWithTotals();
      final first = await stream.first;
      expect(first.length, equals(1));

      await repo.createTask('Second');

      final second = await repo.watchTasksWithTotals().first;
      expect(second.length, equals(2));
    });
  });
}
