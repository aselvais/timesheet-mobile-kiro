import '../models/time_log.dart';

/// Abstract interface for managing TimeLog (session) records.
abstract class TimeLogRepository {
  /// Creates a new open session for [taskId] starting at [startTime].
  ///
  /// Preconditions:
  /// - [taskId] references an existing Task
  /// - No TimeLog with [taskId] and endTime == null exists
  ///
  /// Postconditions:
  /// - Returns a [TimeLog] with endTime == null
  Future<TimeLog> createSession(String taskId, DateTime startTime);

  /// Closes the session identified by [sessionId] by setting [endTime].
  ///
  /// Preconditions:
  /// - Session with [sessionId] exists and endTime IS NULL
  /// - [endTime] > session.startTime
  ///
  /// Postconditions:
  /// - Returns the updated [TimeLog] with endTime set
  /// - If session is already closed, acts as a no-op or returns an error
  Future<TimeLog> closeSession(String sessionId, DateTime endTime);

  /// Returns all TimeLog records associated with [taskId].
  Future<List<TimeLog>> getSessionsForTask(String taskId);

  /// Returns the active (unclosed) session for [taskId], or null if none exists.
  Future<TimeLog?> getActiveSession(String taskId);

  /// Deletes the TimeLog record identified by [sessionId].
  Future<void> deleteSession(String sessionId);

  /// Updates the start and/or end time of an existing session.
  Future<TimeLog> updateSession(String sessionId, {DateTime? startTime, DateTime? endTime});

  /// Creates a fully closed session (manual time entry).
  Future<TimeLog> createClosedSession(String taskId, DateTime startTime, DateTime endTime);
}
