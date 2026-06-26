import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../data/database.dart' as db show AppDatabase, appDatabase, TimeLogsCompanion, TimeLogData;
import '../models/time_log.dart';
import 'time_log_repository.dart';

/// Drift-backed implementation of [TimeLogRepository].
class DriftTimeLogRepository implements TimeLogRepository {
  final db.AppDatabase _db;
  final Uuid _uuid;

  DriftTimeLogRepository({db.AppDatabase? database, Uuid? uuid})
      : _db = database ?? db.appDatabase,
        _uuid = uuid ?? const Uuid();

  @override
  Future<TimeLog> createSession(String taskId, DateTime startTime) async {
    final id = _uuid.v4();
    final companion = db.TimeLogsCompanion.insert(
      id: id,
      taskId: taskId,
      startTime: startTime.millisecondsSinceEpoch,
      endTime: const Value.absent(),
    );
    await _db.into(_db.timeLogs).insert(companion);
    return TimeLog(id: id, taskId: taskId, startTime: startTime);
  }

  @override
  Future<TimeLog> closeSession(String sessionId, DateTime endTime) async {
    final row = await (_db.select(_db.timeLogs)
          ..where((tl) => tl.id.equals(sessionId)))
        .getSingle();

    // No-op if already closed.
    if (row.endTime != null) {
      return _timeLogFromRow(row);
    }

    await (_db.update(_db.timeLogs)..where((tl) => tl.id.equals(sessionId)))
        .write(db.TimeLogsCompanion(endTime: Value(endTime.millisecondsSinceEpoch)));

    final updated = await (_db.select(_db.timeLogs)
          ..where((tl) => tl.id.equals(sessionId)))
        .getSingle();
    return _timeLogFromRow(updated);
  }

  @override
  Future<List<TimeLog>> getSessionsForTask(String taskId) async {
    final rows = await (_db.select(_db.timeLogs)
          ..where((tl) => tl.taskId.equals(taskId))
          ..orderBy([(tl) => OrderingTerm.desc(tl.startTime)]))
        .get();
    return rows.map(_timeLogFromRow).toList();
  }

  @override
  Future<TimeLog?> getActiveSession(String taskId) async {
    final row = await (_db.select(_db.timeLogs)
          ..where((tl) => tl.taskId.equals(taskId) & tl.endTime.isNull())
          ..limit(1))
        .getSingleOrNull();
    return row != null ? _timeLogFromRow(row) : null;
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await (_db.delete(_db.timeLogs)
          ..where((tl) => tl.id.equals(sessionId)))
        .go();
  }

  @override
  Future<TimeLog> updateSession(String sessionId, {DateTime? startTime, DateTime? endTime}) async {
    final updates = <String, Expression>{};
    if (startTime != null) {
      updates['start_time'] = Variable<int>(startTime.millisecondsSinceEpoch);
    }
    if (endTime != null) {
      updates['end_time'] = Variable<int>(endTime.millisecondsSinceEpoch);
    }
    if (updates.isNotEmpty) {
      await (_db.update(_db.timeLogs)..where((tl) => tl.id.equals(sessionId)))
          .write(RawValuesInsertable(updates));
    }
    final row = await (_db.select(_db.timeLogs)
          ..where((tl) => tl.id.equals(sessionId)))
        .getSingle();
    return _timeLogFromRow(row);
  }

  @override
  Future<TimeLog> createClosedSession(String taskId, DateTime startTime, DateTime endTime) async {
    final id = _uuid.v4();
    final companion = db.TimeLogsCompanion.insert(
      id: id,
      taskId: taskId,
      startTime: startTime.millisecondsSinceEpoch,
      endTime: Value(endTime.millisecondsSinceEpoch),
    );
    await _db.into(_db.timeLogs).insert(companion);
    return TimeLog(id: id, taskId: taskId, startTime: startTime, endTime: endTime);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  TimeLog _timeLogFromRow(db.TimeLogData row) {
    return TimeLog(
      id: row.id,
      taskId: row.taskId,
      startTime: DateTime.fromMillisecondsSinceEpoch(row.startTime),
      endTime: row.endTime != null
          ? DateTime.fromMillisecondsSinceEpoch(row.endTime!)
          : null,
    );
  }
}
