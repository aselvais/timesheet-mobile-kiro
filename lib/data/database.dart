import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

@DataClassName('TaskData')
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get label => text()();
  IntColumn get createdAt => integer()();
  /// Hourly rate in user's currency (nullable — no rate set means free/untracked).
  RealColumn get hourlyRate => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TimeLogData')
class TimeLogs extends Table {
  TextColumn get id => text()();
  TextColumn get taskId =>
      text().references(Tasks, #id, onDelete: KeyAction.cascade)();
  IntColumn get startTime => integer()();
  IntColumn get endTime => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TagData')
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  /// Color stored as ARGB integer.
  IntColumn get colorValue => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TaskTagData')
class TaskTags extends Table {
  TextColumn get taskId =>
      text().references(Tasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {taskId, tagId};
}

@DriftDatabase(tables: [Tasks, TimeLogs, Tags, TaskTags])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.database.customStatement('''
        CREATE TABLE IF NOT EXISTS tasks (
          id TEXT NOT NULL PRIMARY KEY,
          label TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          hourly_rate REAL
        )
      ''');
      await m.database.customStatement('''
        CREATE TABLE IF NOT EXISTS time_logs (
          id TEXT NOT NULL PRIMARY KEY,
          task_id TEXT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
          start_time INTEGER NOT NULL,
          end_time INTEGER
        )
      ''');
      await m.database.customStatement('''
        CREATE TABLE IF NOT EXISTS tags (
          id TEXT NOT NULL PRIMARY KEY,
          name TEXT NOT NULL,
          color_value INTEGER NOT NULL
        )
      ''');
      await m.database.customStatement('''
        CREATE TABLE IF NOT EXISTS task_tags (
          task_id TEXT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
          tag_id TEXT NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
          PRIMARY KEY (task_id, tag_id)
        )
      ''');
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.database.customStatement(
          'CREATE TABLE IF NOT EXISTS tags (id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, color_value INTEGER NOT NULL)',
        );
        await m.database.customStatement(
          'CREATE TABLE IF NOT EXISTS task_tags (task_id TEXT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE, tag_id TEXT NOT NULL REFERENCES tags(id) ON DELETE CASCADE, PRIMARY KEY (task_id, tag_id))',
        );
      }
      if (from < 3) {
        await m.database.customStatement(
          'ALTER TABLE tasks ADD COLUMN hourly_rate REAL',
        );
      }
    },
    beforeOpen: (details) async {
      // Ensure schema is always correct regardless of creation path
      await customStatement('PRAGMA foreign_keys = ON');
      // Ensure all tables exist (safe for both fresh and migrated DBs)
      await customStatement('''
        CREATE TABLE IF NOT EXISTS tasks (
          id TEXT NOT NULL PRIMARY KEY,
          label TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          hourly_rate REAL
        )
      ''');
      await customStatement('''
        CREATE TABLE IF NOT EXISTS time_logs (
          id TEXT NOT NULL PRIMARY KEY,
          task_id TEXT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
          start_time INTEGER NOT NULL,
          end_time INTEGER
        )
      ''');
      await customStatement('''
        CREATE TABLE IF NOT EXISTS tags (
          id TEXT NOT NULL PRIMARY KEY,
          name TEXT NOT NULL,
          color_value INTEGER NOT NULL
        )
      ''');
      await customStatement('''
        CREATE TABLE IF NOT EXISTS task_tags (
          task_id TEXT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
          tag_id TEXT NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
          PRIMARY KEY (task_id, tag_id)
        )
      ''');
      // Ensure hourly_rate column exists (ALTER is no-op if already present)
      try {
        await customStatement('ALTER TABLE tasks ADD COLUMN hourly_rate REAL');
      } catch (_) {
        // Column already exists — ignore
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'time_tracker.db'));
    return NativeDatabase.createInBackground(file);
  });
}

AppDatabase? _instance;

AppDatabase get appDatabase {
  _instance ??= AppDatabase();
  return _instance!;
}
