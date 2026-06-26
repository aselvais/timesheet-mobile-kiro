import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../data/database.dart' as db show AppDatabase, appDatabase, TasksCompanion, TaskData;
import '../models/tag.dart';
import '../models/task.dart';
import '../models/task_summary.dart';
import '../repositories/tag_repository.dart';
import 'task_repository.dart';

/// Drift-backed implementation of [TaskRepository].
class DriftTaskRepository implements TaskRepository {
  final db.AppDatabase _db;
  final Uuid _uuid;
  TagRepository? tagRepository;

  List<String> _orderCache = [];
  bool _orderLoaded = false;

  DriftTaskRepository({db.AppDatabase? database, Uuid? uuid})
      : _db = database ?? db.appDatabase,
        _uuid = uuid ?? const Uuid();

  // ---------------------------------------------------------------------------
  // Sort order
  // ---------------------------------------------------------------------------

  Future<File> _orderFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'task_order.json'));
  }

  Future<List<String>> _loadOrder() async {
    if (_orderLoaded) return _orderCache;
    try {
      final f = await _orderFile();
      if (f.existsSync()) {
        _orderCache = List<String>.from(jsonDecode(await f.readAsString()) as List);
      }
    } catch (_) {}
    _orderLoaded = true;
    return _orderCache;
  }

  Future<void> _saveOrder(List<String> ids) async {
    _orderCache = List.of(ids);
    try {
      final f = await _orderFile();
      await f.writeAsString(jsonEncode(ids));
    } catch (_) {}
  }

  List<TaskSummary> _applySortOrder(List<TaskSummary> summaries, List<String> order) {
    if (order.isEmpty) return summaries;
    final indexed = {for (final s in summaries) s.task.id: s};
    final sorted = <TaskSummary>[];
    for (final id in order) {
      if (indexed.containsKey(id)) sorted.add(indexed.remove(id)!);
    }
    sorted.addAll(indexed.values);
    return sorted;
  }

  // ---------------------------------------------------------------------------
  // TaskRepository
  // ---------------------------------------------------------------------------

  @override
  Future<List<Task>> getAllTasks() async {
    final rows = await _db.customSelect(
      'SELECT id, label, created_at, hourly_rate FROM tasks ORDER BY created_at ASC',
      readsFrom: {_db.tasks},
    ).get();
    return rows.map((r) => Task(
      id: r.read<String>('id'),
      label: r.read<String>('label'),
      createdAt: DateTime.fromMillisecondsSinceEpoch(r.read<int>('created_at')),
      hourlyRate: r.readNullable<double>('hourly_rate'),
    )).toList();
  }

  @override
  Future<Task> createTask(String label) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _db.into(_db.tasks).insert(
      db.TasksCompanion.insert(id: id, label: label, createdAt: now.millisecondsSinceEpoch),
    );
    return Task(id: id, label: label, createdAt: now);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await (_db.delete(_db.tasks)..where((t) => t.id.equals(taskId))).go();
    await _saveOrder((await _loadOrder())..remove(taskId));
  }

  @override
  Future<void> deleteTaskKeepLogs(String taskId) async {
    await _db.customStatement(
      'UPDATE time_logs SET task_id = ? WHERE task_id = ?',
      ['', taskId],
    );
    await (_db.delete(_db.tasks)..where((t) => t.id.equals(taskId))).go();
    await _saveOrder((await _loadOrder())..remove(taskId));
  }

  @override
  Future<void> reorderTasks(List<String> orderedIds) async {
    _orderCache = List.of(orderedIds);
    _orderLoaded = true;
    await _saveOrder(orderedIds);
  }

  @override
  Future<void> updateHourlyRate(String taskId, double? hourlyRate) async {
    if (hourlyRate != null) {
      await _db.customStatement(
        'UPDATE tasks SET hourly_rate = ? WHERE id = ?',
        [hourlyRate, taskId],
      );
    } else {
      await _db.customStatement(
        'UPDATE tasks SET hourly_rate = NULL WHERE id = ?',
        [taskId],
      );
    }
  }

  @override
  Stream<List<TaskSummary>> watchTasksWithTotals() {
    final query = _db.customSelect(
      '''
      SELECT
        t.id            AS task_id,
        t.label         AS task_label,
        t.created_at    AS task_created_at,
        t.hourly_rate   AS task_hourly_rate,
        COALESCE(SUM(CASE WHEN tl.end_time IS NOT NULL
                          THEN tl.end_time - tl.start_time
                          ELSE 0 END), 0) AS total_duration_ms,
        COALESCE(MAX(CASE WHEN tl.id IS NOT NULL AND tl.end_time IS NULL
                          THEN 1 ELSE 0 END), 0) AS has_active
      FROM tasks t
      LEFT JOIN time_logs tl ON tl.task_id = t.id
      GROUP BY t.id, t.label, t.created_at, t.hourly_rate
      ORDER BY t.created_at ASC
      ''',
      readsFrom: {_db.tasks, _db.timeLogs},
    );

    return query.watch().asyncMap((rows) async {
      final summaries = rows.map(_summaryFromRow).toList();
      final order = await _loadOrder();
      final sorted = _applySortOrder(summaries, order);
      if (tagRepository != null) {
        final enriched = <TaskSummary>[];
        for (final s in sorted) {
          final tags = await tagRepository!.getTagsForTask(s.task.id);
          enriched.add(TaskSummary(
            task: s.task,
            totalDuration: s.totalDuration,
            hasActiveSession: s.hasActiveSession,
            tags: tags,
          ));
        }
        return enriched;
      }
      return sorted;
    });
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Task _taskFromRow(db.TaskData row) => Task(
        id: row.id,
        label: row.label,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
        hourlyRate: null, // populated via watchTasksWithTotals query
      );

  TaskSummary _summaryFromRow(QueryRow row) {
    final task = Task(
      id: row.read<String>('task_id'),
      label: row.read<String>('task_label'),
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.read<int>('task_created_at')),
      hourlyRate: row.readNullable<double>('task_hourly_rate'),
    );
    return TaskSummary(
      task: task,
      totalDuration: Duration(milliseconds: row.read<int>('total_duration_ms')),
      hasActiveSession: row.read<int>('has_active') == 1,
    );
  }
}
