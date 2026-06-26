import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/blocs/timer_bloc.dart';
import 'package:time_tracker/models/time_log.dart';
import 'package:time_tracker/repositories/time_log_repository.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class FakeTimeLogRepository implements TimeLogRepository {
  TimeLog? activeSessionResult;
  TimeLog? createSessionResult;
  bool throwOnCreate = false;
  bool throwOnClose = false;

  @override
  Future<TimeLog?> getActiveSession(String taskId) async {
    return activeSessionResult;
  }

  @override
  Future<TimeLog> createSession(String taskId, DateTime startTime) async {
    if (throwOnCreate) throw Exception('DB write error');
    return createSessionResult!;
  }

  @override
  Future<TimeLog> closeSession(String sessionId, DateTime endTime) async {
    if (throwOnClose) throw Exception('DB close error');
    return TimeLog(
      id: sessionId,
      taskId: 'task-1',
      startTime: DateTime(2024, 1, 1, 10, 0, 0),
      endTime: endTime,
    );
  }

  @override
  Future<List<TimeLog>> getSessionsForTask(String taskId) async => [];

  @override
  Future<void> deleteSession(String sessionId) async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

TimeLog fakeSession({String? id, String? taskId, DateTime? startTime}) =>
    TimeLog(
      id: id ?? 'session-1',
      taskId: taskId ?? 'task-1',
      startTime: startTime ?? DateTime(2024, 1, 1, 10, 0, 0),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TimerBloc state transitions', () {
    late FakeTimeLogRepository repo;
    late TimerBloc bloc;

    setUp(() {
      repo = FakeTimeLogRepository();
      bloc = TimerBloc(timeLogRepository: repo);
    });

    tearDown(() async {
      await bloc.close();
    });

    // -----------------------------------------------------------------------
    // Requirement 2.1, 3.1 — idle → running → stopped → idle sequence
    // -----------------------------------------------------------------------
    test('idle → running → stopped sequence', () async {
      final session = fakeSession();
      repo.activeSessionResult = null;
      repo.createSessionResult = session;

      // Collect states emitted after the initial idle state
      final states = <TimerState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(StartTimerEvent('task-1'));
      // Wait for TimerRunning to be emitted
      await bloc.stream.firstWhere((s) => s is TimerRunning);

      bloc.add(StopTimerEvent('session-1'));
      // Wait for TimerStopped to be emitted
      await bloc.stream.firstWhere((s) => s is TimerStopped);

      await subscription.cancel();

      expect(states.any((s) => s is TimerRunning), isTrue);
      expect(states.any((s) => s is TimerStopped), isTrue);

      final running = states.whereType<TimerRunning>().first;
      expect(running.activeSession.id, equals('session-1'));

      final stopped = states.whereType<TimerStopped>().first;
      expect(stopped.completedSession.endTime, isNotNull);
    });

    // -----------------------------------------------------------------------
    // Requirement 2.3 — duplicate active session emits TimerError
    // -----------------------------------------------------------------------
    test('starting a timer when one is active emits TimerError', () async {
      repo.activeSessionResult = fakeSession(); // existing active session

      final future = expectLater(
        bloc.stream,
        emitsThrough(
          predicate<TimerState>(
            (s) =>
                s is TimerError &&
                s.message == 'Task already has an active session',
          ),
        ),
      );

      bloc.add(StartTimerEvent('task-1'));
      await future;
    });

    // -----------------------------------------------------------------------
    // Requirement 8.1 — DB exception during start emits TimerError then TimerIdle
    // -----------------------------------------------------------------------
    test(
        'database exception during start emits TimerError then returns to TimerIdle',
        () async {
      repo.activeSessionResult = null;
      repo.throwOnCreate = true;

      final states = <TimerState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(StartTimerEvent('task-1'));

      // Wait until we see TimerIdle after the error
      await bloc.stream.firstWhere((s) => s is TimerIdle);

      await subscription.cancel();

      expect(states.any((s) => s is TimerError), isTrue);
      expect(states.last, isA<TimerIdle>());
    });
  });
}
