import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/database.dart' as db show AppDatabase, appDatabase;
import '../models/tag.dart';
import 'tag_repository.dart';

class DriftTagRepository implements TagRepository {
  final db.AppDatabase _db;
  final Uuid _uuid;

  DriftTagRepository({db.AppDatabase? database, Uuid? uuid})
      : _db = database ?? db.appDatabase,
        _uuid = uuid ?? const Uuid();

  Tag _tagFromRow(QueryRow r) => Tag(
        id: r.read<String>('id'),
        name: r.read<String>('name'),
        color: Color(r.read<int>('color_value')),
      );

  @override
  Future<List<Tag>> getAllTags() async {
    final rows = await _db.customSelect(
      'SELECT id, name, color_value FROM tags ORDER BY name ASC',
      readsFrom: {_db.tags},
    ).get();
    return rows.map(_tagFromRow).toList();
  }

  @override
  Stream<List<Tag>> watchAllTags() {
    return _db.customSelect(
      'SELECT id, name, color_value FROM tags ORDER BY name ASC',
      readsFrom: {_db.tags},
    ).watch().map((rows) => rows.map(_tagFromRow).toList());
  }

  @override
  Future<Tag> createTag(String name, int colorValue) async {
    final id = _uuid.v4();
    await _db.customStatement(
      'INSERT INTO tags (id, name, color_value) VALUES (?, ?, ?)',
      [id, name, colorValue],
    );
    return Tag(id: id, name: name, color: Color(colorValue));
  }

  @override
  Future<void> deleteTag(String tagId) async {
    await _db.customStatement('DELETE FROM tags WHERE id = ?', [tagId]);
  }

  @override
  Future<void> addTagToTask(String taskId, String tagId) async {
    await _db.customStatement(
      'INSERT OR IGNORE INTO task_tags (task_id, tag_id) VALUES (?, ?)',
      [taskId, tagId],
    );
  }

  @override
  Future<void> removeTagFromTask(String taskId, String tagId) async {
    await _db.customStatement(
      'DELETE FROM task_tags WHERE task_id = ? AND tag_id = ?',
      [taskId, tagId],
    );
  }

  @override
  Future<List<Tag>> getTagsForTask(String taskId) async {
    final rows = await _db.customSelect(
      'SELECT tg.id, tg.name, tg.color_value FROM tags tg '
      'INNER JOIN task_tags tt ON tt.tag_id = tg.id '
      'WHERE tt.task_id = ? ORDER BY tg.name ASC',
      variables: [Variable.withString(taskId)],
      readsFrom: {_db.tags, _db.taskTags},
    ).get();
    return rows.map(_tagFromRow).toList();
  }
}
