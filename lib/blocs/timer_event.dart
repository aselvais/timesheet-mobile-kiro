part of 'timer_bloc.dart';

/// Base sealed class for all timer-related events.
sealed class TimerEvent {}

/// Fired when the user taps Start for a task.
class StartTimerEvent extends TimerEvent {
  final String taskId;
  StartTimerEvent(this.taskId);
}

/// Fired when the user taps Stop for a running session.
class StopTimerEvent extends TimerEvent {
  final String sessionId;
  StopTimerEvent(this.sessionId);
}

/// Fired by the internal 1-second ticker while a session is active.
class TickEvent extends TimerEvent {}

/// Fired on app launch to resume an orphaned session without creating a new one.
class ResumeTimerEvent extends TimerEvent {
  final TimeLog session;
  ResumeTimerEvent(this.session);
}
