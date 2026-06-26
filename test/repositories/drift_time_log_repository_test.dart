import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

import 'package:time_tracker/data/database.dart';
import 'package:time_tracker/repositories/drift_time_log_repository.dart';

void main() {
  late AppDatabase db;
  late DriftTimeLogRepository repo;

  /// Helper: insert a task row so FK constraints are satisfied.
  Future<String> insertTask() async {
    const taskId = 'task-001';
    await db.into(db.tasks).insert(
          TasksCompanion.insert(
            id: taskId,
            label: 'Test Task',
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
    return taskId;
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftTimeLogRepository(database: db);
  });

  tearDown(() async {
    await db.close();
  });

  // ---------------------------------------------------------------------------
  // createSession
  // ---------------------------------------------------------------------------

  group('createSession', () {
    /// Validates: Requirements 2.2
    test('inserts a row with endTime == null and isActive == true', () async {
      final taskId = await insertTask();
      final startTime = DateTime(2024, 1, 1, 10, 0, 0);

      final timeLog = await repo.createSession(taskId, startTime);

      // Returned model should have no endTime and be active.
      expect(timeLog.endTime, isNull);
      expect(timeLog.isActive, isTrue);
      expect(timeLog.taskId, equals(taskId));
      expect(timeLog.startTime, equals(startTime));

      // Verify the DB row also has null endTime.
      final rows = await db.select(db.timeLogs).get();
      expect(rows.length, equals(1));
      expect(rows.first.id, equals(timeLog.id));
      expect(rows.first.endTime, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // closeSession
  // ---------------------------------------------------------------------------

  group('closeSession', () {
    /// Validates: Requirements 3.2, 3.3
    test('sets endTime and endTime > startTime', () async {
      final taskId = await insertTask();
      final startTime = DateTime(2024, 1, 1, 10, 0, 0);
      final endTime = startTime.add(const Duration(minutes: 1));

      final created = await repo.createSession(taskId, startTime);
      final closed = await repo.closeSession(created.id, endTime);

      expect(closed.endTime, equals(endTime));
      expect(closed.endTime!.isAfter(closed.startTime), isTrue);
      expect(closed.isActive, isFalse);

      // Verify the DB row has the endTime persisted.
      final rows = await db.select(db.timeLogs).get();
      expect(rows.first.endTime,
          equals(endTime.millisecondsSinceEpoch));
    });

    /// Validates: Requirements 3.5
    test('is a no-op when called on an already-closed session', () async {
      final taskId = await insertTask();
      final startTime = DateTime(2024, 1, 1, 10, 0, 0);
      final firstEnd = startTime.add(const Duration(minutes: 1));
      final secondEnd = startTime.add(const Duration(minutes: 5));

      final created = await repo.createSession(taskId, startTime);
      final firstClose = await repo.closeSession(created.id, firstEnd);
      final secondClose = await repo.closeSession(created.id, secondEnd);

      // Second call should return the same endTime as the first (no overwrite).
      expect(secondClose.endTime, equals(firstClose.endTime));
      expect(secondClose.endTime, equals(firstEnd));

      // Only one row in DB, still with the original endTime.
      final rows = await db.select(db.timeLogs).get();
      expect(rows.length, equals(1));
      expect(rows.first.endTime, equals(firstEnd.millisecondsSinceEpoch));
    });
  });

  // ---------------------------------------------------------------------------
  // getActiveSession
  // ---------------------------------------------------------------------------

  group('getActiveSession', () {
    /// Validates: Requirements 2.2, 3.2
    test('returns null when no active session exists for a task', () async {
      final taskId = await insertTask();

      final result = await repo.getActiveSession(taskId);

      expect(result, isNull);
    });

    /// Validates: Requirements 3.2
    test('returns null after the only session has been closed', () async {
      final taskId = await insertTask();
      final startTime = DateTime(2024, 1, 1, 10, 0, 0);
      final endTime = startTime.add(const Duration(minutes: 1));

      final created = await repo.createSession(taskId, startTime);
      await repo.closeSession(created.id, endTime);

      final result = await repo.getActiveSession(taskId);

      expect(result, isNull);
    });
  });
}
