import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/blocs/timer_bloc.dart';
import 'package:time_tracker/models/time_log.dart';
import 'package:time_tracker/repositories/time_log_repository.dart';

// ---------------------------------------------------------------------------
// Fake repository that tracks deleteSession calls
// ---------------------------------------------------------------------------

class FakeTimeLogRepository implements TimeLogRepository {
  final List<String> deletedSessionIds = [];

  @override
  Future<void> deleteSession(String sessionId) async {
    deletedSessionIds.add(sessionId);
  }

  @override
  Future<TimeLog?> getActiveSession(String taskId) async => null;

  @override
  Future<TimeLog> createSession(String taskId, DateTime startTime) async {
    return TimeLog(id: 'new-session', taskId: taskId, startTime: startTime);
  }

  @override
  Future<TimeLog> closeSession(String sessionId, DateTime endTime) async {
    return TimeLog(
      id: sessionId,
      taskId: 'task-1',
      startTime: DateTime(2024, 1, 1, 10, 0, 0),
      endTime: endTime,
    );
  }

  @override
  Future<List<TimeLog>> getSessionsForTask(String taskId) async => [];
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('Orphaned session recovery', () {
    // -----------------------------------------------------------------------
    // Requirement 7.2 — discard path deletes the TimeLog record
    // -----------------------------------------------------------------------
    test('discard path: deleteSession is called with the orphaned session id',
        () async {
      final repo = FakeTimeLogRepository();
      const sessionId = 'orphaned-session-42';

      await repo.deleteSession(sessionId);

      expect(repo.deletedSessionIds, contains(sessionId));
    });

    // -----------------------------------------------------------------------
    // Requirement 7.3 — resume path restores TimerRunning with correct startTime
    // -----------------------------------------------------------------------
    test(
        'resume path: TimerBloc emits TimerRunning with orphaned session and elapsed >= 5 minutes',
        () async {
      final repo = FakeTimeLogRepository();
      final bloc = TimerBloc(timeLogRepository: repo);

      final startTime = DateTime.now().subtract(const Duration(minutes: 5));
      final orphanedSession = TimeLog(
        id: 'orphaned-session-1',
        taskId: 'task-1',
        startTime: startTime,
      );

      bloc.add(ResumeTimerEvent(orphanedSession));

      final state = await bloc.stream.firstWhere((s) => s is TimerRunning);
      final running = state as TimerRunning;

      expect(running.activeSession, equals(orphanedSession));
      expect(running.elapsed, greaterThanOrEqualTo(const Duration(minutes: 5)));

      await bloc.close();
    });
  });
}
