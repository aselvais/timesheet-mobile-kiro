part of 'timer_bloc.dart';

/// Base sealed class for all timer-related states.
sealed class TimerState {}

/// The timer is not running; no active session.
class TimerIdle extends TimerState {}

/// The timer is running for [activeSession]; [elapsed] is updated each tick.
class TimerRunning extends TimerState {
  final TimeLog activeSession;
  final Duration elapsed;

  TimerRunning({required this.activeSession, required this.elapsed});
}

/// The timer has just been stopped; [completedSession] holds the closed record.
class TimerStopped extends TimerState {
  final TimeLog completedSession;
  TimerStopped(this.completedSession);
}

/// An error occurred during a timer operation.
class TimerError extends TimerState {
  final String message;
  TimerError(this.message);
}
