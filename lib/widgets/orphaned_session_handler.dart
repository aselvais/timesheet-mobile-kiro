import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/task.dart';
import '../models/time_log.dart';
import '../repositories/task_repository.dart';
import '../repositories/time_log_repository.dart';

/// Wraps the app's home screen and checks for orphaned sessions on startup.
///
/// An orphaned session is a [TimeLog] with `endTime == null` that was left open
/// when the app was previously killed. For each orphaned session found, a dialog
/// is shown prompting the user to Resume or Discard.
class OrphanedSessionHandler extends StatefulWidget {
  final Widget child;

  const OrphanedSessionHandler({super.key, required this.child});

  @override
  State<OrphanedSessionHandler> createState() => _OrphanedSessionHandlerState();
}

class _OrphanedSessionHandlerState extends State<OrphanedSessionHandler> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForOrphanedSessions();
    });
  }

  Future<void> _checkForOrphanedSessions() async {
    if (!mounted) return;

    final taskRepo = context.read<TaskRepository>();
    final timeLogRepo = context.read<TimeLogRepository>();

    final tasks = await taskRepo.getAllTasks();

    // Collect all orphaned sessions with their associated task.
    final orphans = <({Task task, TimeLog session})>[];
    for (final task in tasks) {
      final active = await timeLogRepo.getActiveSession(task.id);
      if (active != null) {
        orphans.add((task: task, session: active));
      }
    }

    // Show a dialog for each orphaned session sequentially.
    for (final orphan in orphans) {
      if (!mounted) return;
      await _showOrphanDialog(orphan.task, orphan.session);
    }
  }

  Future<void> _showOrphanDialog(Task task, TimeLog session) async {
    if (!mounted) return;

    final timeLogRepo = context.read<TimeLogRepository>();

    final choice = await showDialog<_OrphanChoice>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _OrphanedSessionDialog(task: task, session: session),
    );

    if (choice == _OrphanChoice.discard) {
      await timeLogRepo.deleteSession(session.id);
    } else if (choice == _OrphanChoice.resume) {
      if (mounted) {
        Navigator.of(context).pushNamed('/task-detail', arguments: task);
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

enum _OrphanChoice { resume, discard }

class _OrphanedSessionDialog extends StatelessWidget {
  final Task task;
  final TimeLog session;

  const _OrphanedSessionDialog({required this.task, required this.session});

  @override
  Widget build(BuildContext context) {
    final startFormatted = _formatDateTime(session.startTime);

    return AlertDialog(
      title: const Text('Unfinished Session'),
      content: Text(
        'Task "${task.label}" has an open session that started at $startFormatted. '
        'Would you like to resume or discard it?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(_OrphanChoice.discard),
          child: const Text('Discard'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_OrphanChoice.resume),
          child: const Text('Resume'),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final y = dt.year.toString();
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$y-$mo-$d $h:$mi';
  }
}
