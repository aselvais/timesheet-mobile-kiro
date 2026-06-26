# Implementation Plan: Time Tracker

## Overview

Implement a Flutter time tracking app using a clean layered architecture (UI → Bloc → Repository → SQLite). Tasks progress from project setup and data models through persistence, state management, and UI screens, finishing with orphaned session recovery and error handling.

## Tasks

- [x] 1. Set up project structure, dependencies, and core interfaces
  - Initialize Flutter project with `flutter_bloc`, `drift`, `uuid`, `glados`, and `integration_test` packages in `pubspec.yaml`
  - Create directory structure: `lib/models/`, `lib/repositories/`, `lib/blocs/`, `lib/screens/`, `lib/widgets/`
  - Define abstract `TaskRepository` and `TimeLogRepository` interfaces in `lib/repositories/`
  - Define `TimerEvent`/`TimerState` and `TaskEvent`/`TaskState` sealed classes in `lib/blocs/`
  - _Requirements: 1.1, 2.1, 3.1, 6.1_

- [x] 2. Implement data models
  - [x] 2.1 Create `Task`, `TimeLog`, and `TaskSummary` model classes in `lib/models/`
    - Implement `TimeLog.duration` derived getter and `TimeLog.isActive` getter
    - Implement label validation logic (non-empty, ≤ 100 chars) as a standalone function or extension
    - _Requirements: 1.1, 1.3, 3.3_

  - [x] 2.2 Write property test for `Task` UUID uniqueness
    - **Property: Creating N tasks always results in N distinct UUIDs**
    - **Validates: Requirements 1.1**

  - [x] 2.3 Write property test for `TimeLog` duration correctness
    - **Property: ∀ closed TimeLog t: t.endTime > t.startTime ⟹ t.duration > Duration.zero**
    - **Validates: Requirements 3.3**

- [x] 3. Implement SQLite persistence with drift
  - [x] 3.1 Define drift table schemas for `tasks` and `time_logs` in `lib/data/database.dart`
    - `tasks`: id (TEXT PK), label (TEXT), created_at (INTEGER)
    - `time_logs`: id (TEXT PK), task_id (TEXT FK), start_time (INTEGER), end_time (INTEGER nullable)
    - Generate drift code and wire up `AppDatabase` singleton
    - _Requirements: 9.1_

  - [x] 3.2 Implement `DriftTaskRepository` satisfying `TaskRepository`
    - Implement `getAllTasks()`, `createTask(label)`, `deleteTask(taskId)` (cascade-delete associated logs)
    - Implement `watchTasksWithTotals()` using drift's `watchSingleOrNull` / `watch` with a SQL `GROUP BY` + `SUM` query
    - _Requirements: 1.1, 1.2, 1.4, 1.5, 6.2, 6.3, 6.4, 6.5_

  - [x] 3.3 Write unit tests for `DriftTaskRepository` using an in-memory drift database
    - Test `createTask` persists and returns a task with correct label and `createdAt ≈ now()`
    - Test `deleteTask` removes the task and all associated `TimeLog` records
    - Test `watchTasksWithTotals` emits correct `totalDuration` and `hasActiveSession` values
    - _Requirements: 1.1, 1.2, 1.4, 1.5, 6.2, 6.3_

  - [x] 3.4 Implement `DriftTimeLogRepository` satisfying `TimeLogRepository`
    - Implement `createSession(taskId, startTime)` — inserts row with `endTime = null`
    - Implement `closeSession(sessionId, endTime)` — updates row; no-op if already closed
    - Implement `getSessionsForTask(taskId)` and `getActiveSession(taskId)`
    - _Requirements: 2.2, 3.2, 3.3, 3.5, 5.1_

  - [x] 3.5 Write unit tests for `DriftTimeLogRepository` using an in-memory drift database
    - Test `createSession` inserts a row with `endTime == null`
    - Test `closeSession` sets `endTime` and verifies `endTime > startTime`
    - Test `closeSession` is a no-op when called on an already-closed session
    - Test `getActiveSession` returns null when no active session exists
    - _Requirements: 2.2, 3.2, 3.3, 3.5_

- [x] 4. Checkpoint — Ensure all repository tests pass
  - Run `flutter test` and confirm all model and repository tests pass before proceeding.

- [x] 5. Implement `TimerBloc`
  - [x] 5.1 Implement `TimerBloc` in `lib/blocs/timer_bloc.dart`
    - Handle `StartTimerEvent`: call `getActiveSession`; if one exists emit `TimerError("Task already has an active session")`; otherwise call `createSession` and start a 1-second `Stream.periodic` ticker
    - Handle `StopTimerEvent`: call `closeSession`, cancel ticker, emit `TimerStopped`
    - Handle `TickEvent`: compute `elapsed = now() - activeSession.startTime`, emit `TimerRunning(activeSession, elapsed)`
    - On database exception: emit `TimerError` and reset to `TimerIdle`
    - Cancel ticker in `close()` override
    - _Requirements: 2.1, 2.3, 2.4, 3.1, 3.4, 4.1, 4.2, 8.1_

  - [x] 5.2 Write unit tests for `TimerBloc` state transitions
    - Test idle → running → stopped → idle sequence
    - Test that starting a timer when one is active emits `TimerError`
    - Test that a database exception during start emits `TimerError` and state returns to `TimerIdle`
    - _Requirements: 2.1, 2.3, 3.1, 8.1_

  - [x] 5.3 Write property test for elapsed time monotonicity
    - **Property: ∀ elapsed duration d emitted during a running session: d == now() - session.startTime (monotonically non-decreasing across ticks)**
    - **Validates: Requirements 4.1, 4.2**

- [x] 6. Implement `TaskBloc`
  - [x] 6.1 Implement `TaskBloc` in `lib/blocs/task_bloc.dart`
    - Handle `LoadTasksEvent`: subscribe to `watchTasksWithTotals()` stream and emit `TasksLoaded` on each emission
    - Handle `CreateTaskEvent`: validate label; if invalid emit `TaskError` without calling repository; otherwise call `createTask` and reload
    - Handle `DeleteTaskEvent`: call `deleteTask` and reload
    - On database exception: emit `TaskError`
    - _Requirements: 1.1, 1.3, 1.4, 6.1, 8.3_

  - [x] 6.2 Write unit tests for `TaskBloc`
    - Test `CreateTaskEvent` with valid label emits `TasksLoaded`
    - Test `CreateTaskEvent` with empty label emits `TaskError` without calling repository
    - Test `CreateTaskEvent` with label > 100 chars emits `TaskError` without calling repository
    - _Requirements: 1.1, 1.3_

- [x] 7. Implement UI screens
  - [x] 7.1 Implement `TaskListScreen` in `lib/screens/task_list_screen.dart`
    - Display list of `TaskSummary` items showing label, formatted `totalDuration`, and active session indicator
    - Provide a FAB or button to trigger `CreateTaskEvent` with a text input dialog
    - Navigate to `TaskDetailScreen` on task tap
    - Show error snackbar on `TaskError` state
    - _Requirements: 1.3, 6.1, 6.3, 8.2_

  - [x] 7.2 Implement `TaskDetailScreen` in `lib/screens/task_detail_screen.dart`
    - Show Start/Stop button wired to `TimerBloc` events
    - Display live elapsed time from `TimerRunning` state
    - Show session history list from `TimeLogRepository.getSessionsForTask`; paginate at 50 records per page
    - Cancel ticker by closing/disposing `TimerBloc` on screen disposal
    - Show error snackbar on `TimerError` state
    - _Requirements: 2.1, 3.1, 4.1, 4.3, 4.4, 5.1, 5.2, 5.3, 8.2_

- [x] 8. Implement orphaned session recovery
  - [x] 8.1 Add orphaned session detection and recovery UI on app launch
    - On app startup, call `getActiveSession` for all tasks (or query all open sessions)
    - If any orphaned session is found, show a dialog prompting "Resume" or "Discard"
    - "Discard" path: call `TimeLogRepository` to delete the orphaned `TimeLog` record
    - "Resume" path: restore `TimerBloc` to `TimerRunning` state using the orphaned session's original `startTime`
    - _Requirements: 7.1, 7.2, 7.3_

  - [x] 8.2 Write unit tests for orphaned session recovery logic
    - Test that discard path deletes the TimeLog record
    - Test that resume path restores `TimerRunning` state with correct `startTime`
    - _Requirements: 7.2, 7.3_

- [x] 9. Wire everything together in `main.dart`
  - Initialise `AppDatabase` and provide repository implementations via `RepositoryProvider` / `MultiRepositoryProvider`
  - Provide `TaskBloc` and `TimerBloc` at appropriate widget tree levels
  - Set `TaskListScreen` as the home route and register `TaskDetailScreen` route
  - Trigger orphaned session check on app startup (before rendering the main screen)
  - _Requirements: 1.4, 6.4, 7.1, 9.1, 9.2_

- [x] 10. Final checkpoint — Ensure all tests pass
  - Run `flutter test` and confirm all unit and property tests pass.
  - Verify the app compiles and runs on a target platform with `flutter run`.

## Notes

- Tasks marked with `*` are optional and can be skipped for a faster MVP
- Each task references specific requirements for traceability
- Property tests use the `glados` package as specified in the design
- The drift package handles reactive streams via table watchers, satisfying requirement 6.4 without polling
