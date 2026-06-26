# Requirements Document

## Introduction

A cross-platform mobile time tracking app built with Flutter that allows users to create named task labels and log time sessions against them. Users can start and stop timers per task, view individual session history, and see total accumulated time per task. All data is stored locally on-device using SQLite with no backend required.

## Glossary

- **Task**: A named label created by the user to categorize time sessions. Has a unique UUID, a label string, and a creation timestamp.
- **TimeLog**: A single time session record associated with a Task. Has a start time and an optional end time (null means the session is still active).
- **TaskSummary**: A derived view combining a Task with its total accumulated duration and active session status.
- **TimerBloc**: The state management component responsible for coordinating timer start/stop events and emitting timer state to the UI.
- **TaskBloc**: The state management component responsible for managing the task list, creation, and deletion.
- **TaskRepository**: The data access component responsible for CRUD operations on Task records.
- **TimeLogRepository**: The data access component responsible for managing TimeLog records (sessions).
- **Active Session**: A TimeLog record where endTime is null, indicating the timer is currently running.
- **Closed Session**: A TimeLog record where endTime is not null, indicating the timer has been stopped.
- **Ticker**: A periodic 1-second interval mechanism that drives elapsed time updates during an active session.
- **App**: The Flutter time tracking mobile application.

---

## Requirements

### Requirement 1: Task Management

**User Story:** As a user, I want to create and manage named task labels, so that I can organize my time tracking by activity.

#### Acceptance Criteria

1. WHEN a user submits a non-empty label of 100 characters or fewer, THE TaskRepository SHALL create a new Task with a unique UUID and persist it to the local database.
2. WHEN a task is created, THE TaskRepository SHALL set the task's createdAt field to the current time.
3. IF a user submits an empty label or a label exceeding 100 characters, THEN THE App SHALL reject the input and display an inline validation error without making any repository call.
4. THE TaskRepository SHALL provide a reactive stream that emits an updated list of TaskSummary records whenever the underlying task or session data changes.
5. WHEN a user deletes a task, THE TaskRepository SHALL remove the task and all associated TimeLog records from the local database.

---

### Requirement 2: Starting a Timer

**User Story:** As a user, I want to start a timer for a task, so that I can record when I begin working on it.

#### Acceptance Criteria

1. WHEN a user taps Start for a task with no active session, THE TimerBloc SHALL create a new TimeLog with the current time as startTime and endTime set to null, persist it via TimeLogRepository, and transition to TimerRunning state.
2. WHEN a new session is created, THE TimeLogRepository SHALL insert a TimeLog row with endTime equal to null into the local database and return the persisted TimeLog.
3. IF a user attempts to start a timer for a task that already has an active session, THEN THE TimerBloc SHALL emit a TimerError state with the message "Task already has an active session" and SHALL NOT create a new TimeLog.
4. WHEN the TimerBloc transitions to TimerRunning state, THE Ticker SHALL begin emitting tick events at 1-second intervals.

---

### Requirement 3: Stopping a Timer

**User Story:** As a user, I want to stop a running timer, so that I can record when I finish working on a task.

#### Acceptance Criteria

1. WHEN a user taps Stop for a task with an active session, THE TimerBloc SHALL close the session by setting endTime to the current time via TimeLogRepository and transition to TimerStopped state.
2. WHEN a session is closed, THE TimeLogRepository SHALL update the TimeLog row with the endTime value and return the updated TimeLog.
3. WHEN a session is closed, THE TimeLogRepository SHALL ensure the stored endTime is after the stored startTime.
4. WHEN the TimerBloc transitions to TimerStopped state, THE Ticker SHALL stop emitting tick events.
5. IF a stop operation is attempted on a session that is already closed, THEN THE TimeLogRepository SHALL treat the operation as a no-op or return an error without modifying any other session records.

---

### Requirement 4: Elapsed Time Display

**User Story:** As a user, I want to see the elapsed time updating in real time while a timer is running, so that I know how long I have been working.

#### Acceptance Criteria

1. WHILE a session is active, THE TimerBloc SHALL emit a TimerRunning state containing the updated elapsed duration on every Ticker tick.
2. WHEN a tick event is processed, THE TimerBloc SHALL compute elapsed time as the difference between the current time and the active session's startTime.
3. THE App SHALL display the elapsed duration to the user in the task detail screen while the timer is running.
4. WHEN the task detail screen is disposed, THE Ticker SHALL be cancelled to prevent unnecessary background processing.

---

### Requirement 5: Session History

**User Story:** As a user, I want to view the history of time sessions for a task, so that I can review when and how long I worked on it.

#### Acceptance Criteria

1. WHEN a user navigates to a task's detail screen, THE TimeLogRepository SHALL return all TimeLog records associated with that task.
2. THE App SHALL display each session's start time, end time, and duration in the session history view.
3. WHERE a task has more than 50 session records, THE App SHALL paginate the session list displaying 50 records per page.

---

### Requirement 6: Task List with Totals

**User Story:** As a user, I want to see all my tasks with their total accumulated time, so that I can understand how I have spent my time overall.

#### Acceptance Criteria

1. WHEN the task list screen loads, THE TaskBloc SHALL request all tasks with aggregated totals from TaskRepository and emit a TasksLoaded state containing a list of TaskSummary records.
2. THE TaskRepository SHALL compute each TaskSummary's totalDuration as the sum of durations of all closed sessions for that task, excluding any active session.
3. THE TaskRepository SHALL set hasActiveSession to true in a TaskSummary if and only if a TimeLog with endTime equal to null exists for that task.
4. WHEN underlying task or session data changes, THE TaskRepository's reactive stream SHALL emit an updated list of TaskSummary records reflecting the latest state.
5. THE App SHALL use SQL aggregation (GROUP BY and SUM) to compute totals rather than loading all session records into memory.

---

### Requirement 7: Orphaned Session Recovery

**User Story:** As a user, I want the app to handle sessions that were left open when the app was killed, so that my data is not lost or corrupted.

#### Acceptance Criteria

1. WHEN the App launches and an active session (endTime equal to null) is detected for any task, THE App SHALL present the user with a prompt to resume or discard the orphaned session.
2. IF a user chooses to discard an orphaned session, THEN THE TimeLogRepository SHALL delete the orphaned TimeLog record.
3. IF a user chooses to resume an orphaned session, THEN THE TimerBloc SHALL restore the TimerRunning state using the orphaned session's original startTime.

---

### Requirement 8: Error Handling

**User Story:** As a user, I want the app to handle errors gracefully, so that failures do not leave the app in an inconsistent state.

#### Acceptance Criteria

1. IF the local database throws an error during a write operation, THEN THE TimerBloc SHALL catch the exception, emit a TimerError state, and roll back the timer state to TimerIdle.
2. IF the local database throws an error during a write operation, THEN THE App SHALL display an error message to the user.
3. IF the local database throws an error during a task operation, THEN THE TaskBloc SHALL catch the exception and emit a TaskError state.

---

### Requirement 9: Local Persistence

**User Story:** As a user, I want all my data stored locally on my device, so that the app works without an internet connection and my data remains private.

#### Acceptance Criteria

1. THE App SHALL persist all Task and TimeLog records to a SQLite database stored in the app's private data directory on the device.
2. THE App SHALL operate fully without any network connection.
3. THE App SHALL NOT transmit any user data over a network connection.
