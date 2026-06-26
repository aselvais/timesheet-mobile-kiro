import '../models/tag.dart';

abstract class TagRepository {
  /// Returns all tags.
  Future<List<Tag>> getAllTags();

  /// Creates a new tag with [name] and [colorValue].
  Future<Tag> createTag(String name, int colorValue);

  /// Deletes a tag and all its task associations.
  Future<void> deleteTag(String tagId);

  /// Assigns a tag to a task.
  Future<void> addTagToTask(String taskId, String tagId);

  /// Removes a tag from a task.
  Future<void> removeTagFromTask(String taskId, String tagId);

  /// Returns all tags assigned to a task.
  Future<List<Tag>> getTagsForTask(String taskId);

  /// Returns all tags as a stream (reactive).
  Stream<List<Tag>> watchAllTags();
}
