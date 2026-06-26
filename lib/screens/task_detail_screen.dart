import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/timer_bloc.dart';
import '../models/tag.dart';
import '../models/task.dart';
import '../models/time_log.dart';
import '../repositories/tag_repository.dart';
import '../repositories/task_repository.dart';
import '../repositories/time_log_repository.dart';
import '../widgets/tag_chip.dart';
import 'app_shell.dart' show refreshAllTags;
import 'task_list_screen.dart' show formatDuration;

String formatEarnings(double amount) {
  if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(1)}k';
  return '\$${amount.toStringAsFixed(2)}';
}

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final task = ModalRoute.of(context)!.settings.arguments as Task;
    return BlocProvider(
      create: (context) => TimerBloc(
          timeLogRepository: context.read<TimeLogRepository>()),
      child: _TaskDetailView(task: task),
    );
  }
}

class _TaskDetailView extends StatefulWidget {
  final Task task;
  const _TaskDetailView({required this.task});

  @override
  State<_TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<_TaskDetailView> {
  List<TimeLog> _sessions = [];
  List<Tag> _tags = [];
  double? _hourlyRate;
  int _page = 1;
  bool _hasMore = false;
  bool _loadingSessions = false;
  static const int _pageSize = 50;

  @override
  void initState() {
    super.initState();
    _hourlyRate = widget.task.hourlyRate;
    _loadSessions();
    _loadTags();
    _checkForActiveSession();
  }

  Future<void> _checkForActiveSession() async {
    final repo = context.read<TimeLogRepository>();
    final active = await repo.getActiveSession(widget.task.id);
    if (active != null && mounted) {
      context.read<TimerBloc>().add(ResumeTimerEvent(active));
    }
  }

  Future<void> _loadTags() async {
    final tags = await context
        .read<TagRepository>()
        .getTagsForTask(widget.task.id);
    if (mounted) setState(() => _tags = tags);
  }

  Future<void> _loadSessions({bool reset = false}) async {
    if (_loadingSessions) return;
    setState(() => _loadingSessions = true);
    try {
      final repo = context.read<TimeLogRepository>();
      final all = await repo.getSessionsForTask(widget.task.id);
      if (reset) _page = 1;
      final total = all.length;
      final end = _page * _pageSize;
      setState(() {
        _sessions = all.take(end < total ? end : total).toList();
        _hasMore = total > end;
        _loadingSessions = false;
      });
    } catch (_) {
      setState(() => _loadingSessions = false);
    }
  }

  void _loadMore() {
    setState(() => _page++);
    _loadSessions();
  }

  Future<void> _showAddTagSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFF1E1E2C),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _TagManagerSheet(
        taskId: widget.task.id,
        tagRepo: context.read<TagRepository>(),
        currentTags: _tags,
        onChanged: _loadTags,
      ),
    );
  }

  Future<void> _showRateEditor() async {
    final controller = TextEditingController(
      text: _hourlyRate != null ? _hourlyRate!.toStringAsFixed(2) : '',
    );
    final taskRepo = context.read<TaskRepository>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFF1E1E2C),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).viewPadding.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            const Text('Hourly rate',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            const SizedBox(height: 6),
            Text('Set a rate to track earnings for this task.',
                style:
                    TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.4))),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5), fontSize: 18),
                hintText: '0.00  (leave empty to remove)',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final text = controller.text.trim();
                  final rate =
                      text.isEmpty ? null : double.tryParse(text);
                  await taskRepo.updateHourlyRate(widget.task.id, rate);
                  if (mounted) setState(() => _hourlyRate = rate);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: const Text('Save rate'),
              ),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
  }

  Future<void> _showAddSessionSheet() async {
    final repo = context.read<TimeLogRepository>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFF1E1E2C),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _SessionEditorSheet(
        taskId: widget.task.id,
        repo: repo,
        onSaved: () => _loadSessions(reset: true),
      ),
    );
  }

  Future<void> _showEditSessionSheet(TimeLog session) async {
    final repo = context.read<TimeLogRepository>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFF1E1E2C),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _SessionEditorSheet(
        taskId: widget.task.id,
        repo: repo,
        existing: session,
        onSaved: () => _loadSessions(reset: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<TimerBloc, TimerState>(
        listener: (context, state) {
          if (state is TimerError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ));
          }
          if (state is TimerStopped) _loadSessions(reset: true);
        },
        builder: (context, state) {
          final isRunning = state is TimerRunning;
          return CustomScrollView(
            slivers: [
              _buildAppBar(context, isRunning),
              SliverToBoxAdapter(
                child: _TimerHero(
                  task: widget.task,
                  state: state,
                  tags: _tags,
                  onAddTag: _showAddTagSheet,
                  hourlyRate: _hourlyRate,
                  onSetRate: _showRateEditor,
                ),
              ),
              SliverToBoxAdapter(child: _buildSessionsHeader()),
              _buildSessionsList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isRunning) {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: const Color(0xFF12121A),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(widget.task.label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis),
      actions: [
        if (isRunning)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5A0).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('● LIVE',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF00E5A0),
                      letterSpacing: 0.5)),
            ),
          ),
      ],
    );
  }

  Widget _buildSessionsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
      child: Row(children: [
        Text('Sessions',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.9))),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20)),
          child: Text('${_sessions.length}',
              style: TextStyle(
                  fontSize: 12, color: Colors.white.withOpacity(0.5))),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _showAddSessionSheet,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.add, size: 14, color: Color(0xFF6C63FF)),
              SizedBox(width: 4),
              Text('Add',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6C63FF))),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildSessionsList() {
    if (_loadingSessions && _sessions.isEmpty) {
      return const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()));
    }
    if (_sessions.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text('No sessions yet',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.3), fontSize: 15)),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == _sessions.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: _loadingSessions
                  ? const Center(child: CircularProgressIndicator())
                  : TextButton(
                      onPressed: _loadMore,
                      child: const Text('Load more')),
            );
          }
          return _SessionRow(
            session: _sessions[index],
            index: index,
            onTap: _sessions[index].isActive
                ? null
                : () => _showEditSessionSheet(_sessions[index]),
          );
        },
        childCount: _sessions.length + (_hasMore ? 1 : 0),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Timer Hero
// ---------------------------------------------------------------------------

class _TimerHero extends StatelessWidget {
  final Task task;
  final TimerState state;
  final List<Tag> tags;
  final VoidCallback onAddTag;
  final double? hourlyRate;
  final VoidCallback onSetRate;

  const _TimerHero({
    required this.task,
    required this.state,
    required this.tags,
    required this.onAddTag,
    required this.hourlyRate,
    required this.onSetRate,
  });

  @override
  Widget build(BuildContext context) {
    final isRunning = state is TimerRunning;
    final isStopped = state is TimerStopped;
    final elapsed = isRunning ? (state as TimerRunning).elapsed : Duration.zero;
    final accent = isRunning ? const Color(0xFF00E5A0) : const Color(0xFF6C63FF);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isRunning
              ? const Color(0xFF00E5A0).withOpacity(0.3)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            formatDuration(elapsed),
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w800,
              color: isRunning ? const Color(0xFF00E5A0) : Colors.white,
              letterSpacing: -2,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onSetRate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: hourlyRate != null
                    ? const Color(0xFFFFB347).withOpacity(0.12)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: hourlyRate != null
                      ? const Color(0xFFFFB347).withOpacity(0.3)
                      : Colors.white.withOpacity(0.08),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.attach_money,
                      size: 13,
                      color: hourlyRate != null
                          ? const Color(0xFFFFB347)
                          : Colors.white.withOpacity(0.3)),
                  const SizedBox(width: 4),
                  Text(
                    () {
                      if (hourlyRate == null) return 'Set rate';
                      final e = task.earnings(elapsed);
                      return e != null ? '${formatEarnings(e)} earned' : 'Set rate';
                    }(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: hourlyRate != null
                          ? const Color(0xFFFFB347)
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isRunning
                ? 'Timer running'
                : isStopped
                    ? 'Session saved'
                    : 'Ready to track',
            style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.35),
                letterSpacing: 0.3),
          ),
          const SizedBox(height: 28),
          if (isRunning)
            _TimerButton(
              label: 'Stop',
              icon: Icons.stop_rounded,
              color: Colors.redAccent,
              onTap: () => context.read<TimerBloc>().add(
                    StopTimerEvent(
                        (state as TimerRunning).activeSession.id),
                  ),
            )
          else
            _TimerButton(
              label: 'Start',
              icon: Icons.play_arrow_rounded,
              color: accent,
              onTap: () =>
                  context.read<TimerBloc>().add(StartTimerEvent(task.id)),
            ),
          const SizedBox(height: 20),
          if (tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: tags.map((t) => TagChip(tag: t)).toList(),
              ),
            ),
          GestureDetector(
            onTap: onAddTag,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.label_outline,
                      size: 14, color: Colors.white.withOpacity(0.5)),
                  const SizedBox(width: 6),
                  Text(
                    tags.isEmpty ? 'Add tag' : 'Manage tags',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Timer Button
// ---------------------------------------------------------------------------

class _TimerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TimerButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Session Row
// ---------------------------------------------------------------------------

class _SessionRow extends StatelessWidget {
  final TimeLog session;
  final int index;
  final VoidCallback? onTap;

  const _SessionRow(
      {required this.session, required this.index, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = session.isActive;
    final duration = session.duration;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(14),
          border: isActive
              ? Border.all(
                  color:
                      const Color(0xFF00E5A0).withOpacity(0.3),
                  width: 1)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF00E5A0).withOpacity(0.12)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? const Color(0xFF00E5A0)
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_fmt(session.startTime),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(
                    session.endTime != null
                        ? '→ ${_fmt(session.endTime!)}'
                        : '→ now',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.35)),
                  ),
                ],
              ),
            ),
            if (duration != null)
              Text(formatDuration(duration),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFeatures: [FontFeature.tabularFigures()]))
            else
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFF00E5A0).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('LIVE',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00E5A0),
                        letterSpacing: 1)),
              ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$mo-$d  $h:$m';
  }
}

// ---------------------------------------------------------------------------
// Session Editor Sheet
// ---------------------------------------------------------------------------

class _SessionEditorSheet extends StatefulWidget {
  final String taskId;
  final TimeLogRepository repo;
  final TimeLog? existing;
  final VoidCallback onSaved;

  const _SessionEditorSheet({
    required this.taskId,
    required this.repo,
    this.existing,
    required this.onSaved,
  });

  @override
  State<_SessionEditorSheet> createState() => _SessionEditorSheetState();
}

class _SessionEditorSheetState extends State<_SessionEditorSheet> {
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final start = widget.existing?.startTime ??
        now.subtract(const Duration(hours: 1));
    final end = widget.existing?.endTime ?? now;
    _startDate = DateTime(start.year, start.month, start.day);
    _startTime = TimeOfDay(hour: start.hour, minute: start.minute);
    _endDate = DateTime(end.year, end.month, end.day);
    _endTime = TimeOfDay(hour: end.hour, minute: end.minute);
  }

  DateTime _combine(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => isStart ? _startDate = picked : _endDate = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
        context: context,
        initialTime: isStart ? _startTime : _endTime);
    if (picked != null) setState(() => isStart ? _startTime = picked : _endTime = picked);
  }

  Future<void> _save() async {
    final start = _combine(_startDate, _startTime);
    final end = _combine(_endDate, _endTime);
    if (!end.isAfter(start)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('End time must be after start time'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    setState(() => _saving = true);
    if (_isEdit) {
      await widget.repo
          .updateSession(widget.existing!.id, startTime: start, endTime: end);
    } else {
      await widget.repo.createClosedSession(widget.taskId, start, end);
    }
    widget.onSaved();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete session',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text('This will permanently remove this time entry.',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Cancel',
                  style: TextStyle(color: Colors.white.withOpacity(0.4)))),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.repo.deleteSession(widget.existing!.id);
      widget.onSaved();
      if (mounted) Navigator.of(context).pop();
    }
  }

  String _fmtDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).viewPadding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
              child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_isEdit ? 'Edit session' : 'Add session',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              if (_isEdit)
                GestureDetector(
                  onTap: _delete,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.delete_outline,
                          size: 14, color: Colors.redAccent),
                      SizedBox(width: 4),
                      Text('Delete',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.redAccent)),
                    ]),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Start',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.5))),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: _PickerButton(
                    label: _fmtDate(_startDate),
                    icon: Icons.calendar_today,
                    onTap: () => _pickDate(true))),
            const SizedBox(width: 12),
            Expanded(
                child: _PickerButton(
                    label: _fmtTime(_startTime),
                    icon: Icons.access_time,
                    onTap: () => _pickTime(true))),
          ]),
          const SizedBox(height: 16),
          Text('End',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.5))),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: _PickerButton(
                    label: _fmtDate(_endDate),
                    icon: Icons.calendar_today,
                    onTap: () => _pickDate(false))),
            const SizedBox(width: 12),
            Expanded(
                child: _PickerButton(
                    label: _fmtTime(_endTime),
                    icon: Icons.access_time,
                    onTap: () => _pickTime(false))),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving
                  ? 'Saving…'
                  : (_isEdit ? 'Save changes' : 'Add session')),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _PickerButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A3C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Icon(icon, size: 16, color: Colors.white.withOpacity(0.4)),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white)),
        ]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tag Manager Sheet
// ---------------------------------------------------------------------------

class _TagManagerSheet extends StatefulWidget {
  final String taskId;
  final TagRepository tagRepo;
  final List<Tag> currentTags;
  final VoidCallback onChanged;

  const _TagManagerSheet({
    required this.taskId,
    required this.tagRepo,
    required this.currentTags,
    required this.onChanged,
  });

  @override
  State<_TagManagerSheet> createState() => _TagManagerSheetState();
}

class _TagManagerSheetState extends State<_TagManagerSheet> {
  List<Tag> _allTags = [];
  late Set<String> _assignedIds;
  bool _showCreate = false;
  final _nameController = TextEditingController();
  Color _pickedColor = const Color(0xFF6C63FF);

  static const _palette = [
    Color(0xFF6C63FF), Color(0xFF00E5A0), Color(0xFFFF6B6B),
    Color(0xFFFFB347), Color(0xFF4FC3F7), Color(0xFFCE93D8),
    Color(0xFF80CBC4), Color(0xFFFFD54F), Color(0xFFEF9A9A),
    Color(0xFFA5D6A7),
  ];

  @override
  void initState() {
    super.initState();
    _assignedIds = widget.currentTags.map((t) => t.id).toSet();
    _loadTags();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadTags() async {
    final tags = await widget.tagRepo.getAllTags();
    if (mounted) setState(() => _allTags = tags);
  }

  Future<void> _toggle(Tag tag) async {
    if (_assignedIds.contains(tag.id)) {
      await widget.tagRepo.removeTagFromTask(widget.taskId, tag.id);
      setState(() => _assignedIds.remove(tag.id));
    } else {
      await widget.tagRepo.addTagToTask(widget.taskId, tag.id);
      setState(() => _assignedIds.add(tag.id));
    }
    widget.onChanged();
  }

  Future<void> _createTag() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final tag = await widget.tagRepo.createTag(name, _pickedColor.value);
    await widget.tagRepo.addTagToTask(widget.taskId, tag.id);
    _nameController.clear();
    setState(() { _assignedIds.add(tag.id); _showCreate = false; });
    await _loadTags();
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).viewPadding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
              child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tags',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              GestureDetector(
                onTap: () => setState(() => _showCreate = !_showCreate),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(_showCreate ? Icons.close : Icons.add,
                        size: 14, color: const Color(0xFF6C63FF)),
                    const SizedBox(width: 4),
                    Text(_showCreate ? 'Cancel' : 'New tag',
                        style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6C63FF),
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ],
          ),
          if (_showCreate) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'Tag name'),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _palette
                  .map((c) => GestureDetector(
                        onTap: () => setState(() => _pickedColor = c),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: _pickedColor == c
                                ? Border.all(
                                    color: Colors.white, width: 2.5)
                                : null,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _createTag,
                style: FilledButton.styleFrom(
                    backgroundColor: _pickedColor),
                child: const Text('Create & assign'),
              ),
            ),
          ],
          if (_allTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allTags.map((tag) {
                final assigned = _assignedIds.contains(tag.id);
                return GestureDetector(
                  onTap: () => _toggle(tag),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: assigned
                          ? tag.color.withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: assigned
                            ? tag.color.withOpacity(0.5)
                            : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: tag.color, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(tag.name,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: assigned
                                  ? tag.color
                                  : Colors.white.withOpacity(0.5))),
                      if (assigned) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.check, size: 12, color: tag.color),
                      ],
                    ]),
                  ),
                );
              }).toList(),
            ),
          ] else if (!_showCreate)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('No tags yet. Create one above.',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 14)),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
