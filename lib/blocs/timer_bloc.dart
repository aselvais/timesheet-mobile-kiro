import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/time_log.dart';
import '../repositories/time_log_repository.dart';

part 'timer_event.dart';
part 'timer_state.dart';

/// Manages timer state for a single task.
///
/// Coordinates start/stop with [TimeLogRepository] and drives a periodic
/// 1-second ticker to emit elapsed time updates.
class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final TimeLogRepository _timeLogRepository;
  StreamSubscription<void>? _tickerSubscription;

  TimerBloc({required TimeLogRepository timeLogRepository})
      : _timeLogRepository = timeLogRepository,
        super(TimerIdle()) {
    on<StartTimerEvent>(_onStart);
    on<StopTimerEvent>(_onStop);
    on<TickEvent>(_onTick);
    on<ResumeTimerEvent>(_onResume);
  }

  Future<void> _onStart(
    StartTimerEvent event,
    Emitter<TimerState> emit,
  ) async {
    try {
      final existing = await _timeLogRepository.getActiveSession(event.taskId);
      if (existing != null) {
        emit(TimerError('Task already has an active session'));
        return;
      }

      final session = await _timeLogRepository.createSession(
        event.taskId,
        DateTime.now(),
      );

      emit(TimerRunning(
        activeSession: session,
        elapsed: Duration.zero,
      ));

      _tickerSubscription?.cancel();
      _tickerSubscription = Stream.periodic(const Duration(seconds: 1))
          .listen((_) => add(TickEvent()));
    } catch (e) {
      emit(TimerError(e.toString()));
      emit(TimerIdle());
    }
  }

  Future<void> _onStop(
    StopTimerEvent event,
    Emitter<TimerState> emit,
  ) async {
    try {
      _tickerSubscription?.cancel();
      _tickerSubscription = null;

      final closed = await _timeLogRepository.closeSession(
        event.sessionId,
        DateTime.now(),
      );

      emit(TimerStopped(closed));
    } catch (e) {
      emit(TimerError(e.toString()));
      emit(TimerIdle());
    }
  }

  void _onResume(ResumeTimerEvent event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    emit(TimerRunning(
      activeSession: event.session,
      elapsed: DateTime.now().difference(event.session.startTime),
    ));
    _tickerSubscription = Stream.periodic(const Duration(seconds: 1))
        .listen((_) => add(TickEvent()));
  }

  void _onTick(TickEvent event, Emitter<TimerState> emit) {
    final current = state;
    if (current is TimerRunning) {
      final elapsed = DateTime.now().difference(current.activeSession.startTime);
      emit(TimerRunning(activeSession: current.activeSession, elapsed: elapsed));
    }
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }
}
