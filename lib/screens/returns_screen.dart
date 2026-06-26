import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/tag.dart';
import '../models/task.dart';
import '../models/time_log.dart';
import '../repositories/tag_repository.dart';
import '../repositories/task_repository.dart';
import '../repositories/time_log_repository.dart';
import '../services/report_export.dart';
import 'task_list_screen.dart' show formatDuration;

// ---------------------------------------------------------------------------
// Data helpers (shared with calendar)
// ---------------------------------------------------------------------------

DateTime dayOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
DateTime monthOnly(DateTime dt) => DateTime(dt.year, dt.month);

/// Per-task earnings for a single day.
class TaskDayEarning {
  final Task task;
  final Duration duration;
  final double? earnings;
  TaskDayEarning(this.task, this.duration, this.earnings);
}

class DayEarning {
  final DateTime date;
  final List<TaskDayEarning> tasks;
  DayEarning(this.date, this.tasks);
  double get totalEarnings =>
      tasks.fold(0.0, (s, t) => s + (t.earnings ?? 0.0));
  Duration get totalDuration =>
      tasks.fold(Duration.zero, (s, t) => s + t.duration);
  bool get hasEarnings => tasks.any((t) => t.earnings != null && t.earnings! > 0);
}

class MonthEarning {
  final DateTime month;
  final List<DayEarning> days;
  MonthEarning(this.month, this.days);
  double get totalEarnings =>
      days.fold(0.0, (s, d) => s + d.totalEarnings);
  Duration get totalDuration =>
      days.fold(Duration.zero, (s, d) => s + d.totalDuration);
}

String fmtMoney(double v) {
  if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(1)}k';
  return '\$${v.toStringAsFixed(2)}';
}

String fmtMonth(DateTime d) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return '${months[d.month - 1]} ${d.year}';
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class ReturnsScreen extends StatefulWidget {
  const ReturnsScreen({super.key});

  @override
  State<ReturnsScreen> createState() => ReturnsScreenState();
}

class ReturnsScreenState extends State<ReturnsScreen> {
  List<MonthEarning> _allMonths = [];
  List<Task> _tasks = [];
  Map<String, List<TimeLog>> _sessions = {};
  Map<String, List<Tag>> _taskTags = {};
  List<Tag> _allTags = [];
  String? _selectedTagId;
  bool _loading = true;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _load();
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) => _load());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void refresh() => _load();

  List<Task> get _filteredTasks {
    if (_selectedTagId == null) return _tasks;
    return _tasks.where((t) =>
        (_taskTags[t.id] ?? []).any((tag) => tag.id == _selectedTagId)).toList();
  }

  Map<String, List<TimeLog>> get _filteredSessions {
    final filtered = _filteredTasks;
    final ids = filtered.map((t) => t.id).toSet();
    return Map.fromEntries(
        _sessions.entries.where((e) => ids.contains(e.key)));
  }

  List<MonthEarning> get _filteredMonths {
    if (_selectedTagId == null) return _allMonths;
    final ids = _filteredTasks.map((t) => t.id).toSet();
    final result = <MonthEarning>[];
    for (final m in _allMonths) {
      final filteredDays = <DayEarning>[];
      for (final d in m.days) {
        final filteredTasks = d.tasks.where((t) => ids.contains(t.task.id)).toList();
        if (filteredTasks.isNotEmpty) {
          filteredDays.add(DayEarning(d.date, filteredTasks));
        }
      }
      if (filteredDays.isNotEmpty) {
        result.add(MonthEarning(m.month, filteredDays));
      }
    }
    return result;
  }

  Future<void> _showExportSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, 32 + MediaQuery.of(ctx).viewPadding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const Text('Export Report',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            const SizedBox(height: 6),
            Text('Choose format to download or share',
                style: TextStyle(
                    fontSize: 13, color: Colors.white.withOpacity(0.4))),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _ExportButton(
                    icon: Icons.picture_as_pdf,
                    label: 'PDF Report',
                    color: Colors.redAccent,
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      final entries = buildExportData(_filteredTasks, _filteredSessions);
                      final file = await exportPdf(entries);
                      await shareFile(file);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ExportButton(
                    icon: Icons.table_chart,
                    label: 'CSV Data',
                    color: const Color(0xFF00E5A0),
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      final entries = buildExportData(_filteredTasks, _filteredSessions);
                      final file = await exportCsv(entries);
                      await shareFile(file);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _load() async {
    final taskRepo = context.read<TaskRepository>();
    final timeLogRepo = context.read<TimeLogRepository>();
    final tagRepo = context.read<TagRepository>();

    final tasks = await taskRepo.getAllTasks();
    final tags = await tagRepo.getAllTags();
    final Map<String, List<TimeLog>> sessions = {};
    final Map<String, List<Tag>> taskTags = {};
    await Future.wait(tasks.map((t) async {
      sessions[t.id] = await timeLogRepo.getSessionsForTask(t.id);
      taskTags[t.id] = await tagRepo.getTagsForTask(t.id);
    }));
    _tasks = tasks;
    _sessions = sessions;
    _allTags = tags;
    _taskTags = taskTags;

    // day → taskId → duration
    final Map<DateTime, Map<String, Duration>> dayMap = {};
    for (final task in tasks) {
      for (final s in sessions[task.id] ?? []) {
        final start = s.startTime;
        final end = s.endTime ?? DateTime.now();
        var cursor = dayOnly(start);
        while (!cursor.isAfter(dayOnly(end))) {
          final ds = cursor.isAtSameMomentAs(dayOnly(start)) ? start : cursor;
          final de = cursor.isAtSameMomentAs(dayOnly(end))
              ? end
              : cursor.add(const Duration(days: 1));
          final dur = de.difference(ds);
          if (dur > Duration.zero) {
            dayMap.putIfAbsent(cursor, () => {});
            dayMap[cursor]![task.id] =
                (dayMap[cursor]![task.id] ?? Duration.zero) + dur;
          }
          cursor = cursor.add(const Duration(days: 1));
        }
      }
    }

    final taskById = {for (final t in tasks) t.id: t};
    final sortedDays = dayMap.keys.toList()..sort((a, b) => b.compareTo(a));

    final dayEarnings = sortedDays.map((day) {
      final byTask = dayMap[day]!;
      final taskList = byTask.entries
          .where((e) => taskById.containsKey(e.key))
          .map((e) {
            final task = taskById[e.key]!;
            final dur = e.value;
            final earn = task.earnings(dur);
            return TaskDayEarning(task, dur, earn);
          })
          .toList()
        ..sort((a, b) => (b.earnings ?? 0).compareTo(a.earnings ?? 0));
      return DayEarning(day, taskList);
    }).toList();

    // Group by month
    final Map<DateTime, List<DayEarning>> monthMap = {};
    for (final d in dayEarnings) {
      final m = monthOnly(d.date);
      monthMap.putIfAbsent(m, () => []).add(d);
    }
    final sortedMonths = monthMap.keys.toList()..sort((a, b) => b.compareTo(a));
    final months = sortedMonths
        .map((m) => MonthEarning(m, monthMap[m]!))
        .toList();

    if (mounted) setState(() { _allMonths = months; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final months = _filteredMonths;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Returns',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.5)),
                          const SizedBox(height: 4),
                          Text('Earnings based on hourly rates',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 14)),
                        ],
                      ),
                    ),
                    if (!_loading && months.isNotEmpty)
                      GestureDetector(
                        onTap: _showExportSheet,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.ios_share,
                              color: Color(0xFF6C63FF), size: 20),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Tag filter bar
            if (_allTags.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _allTags.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final tag = _allTags[i];
                      final selected = _selectedTagId == tag.id;
                      return GestureDetector(
                        onTap: () => setState(() =>
                            _selectedTagId = selected ? null : tag.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected ? tag.color.withOpacity(0.25) : tag.color.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected ? tag.color.withOpacity(0.7) : tag.color.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 7, height: 7,
                                  decoration: BoxDecoration(color: tag.color, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text(tag.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: selected ? tag.color : tag.color.withOpacity(0.7),
                                  )),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            if (_allTags.isNotEmpty) const SliverToBoxAdapter(child: SizedBox(height: 8)),
            if (_loading)
              const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()))
            else if (months.isEmpty)
              SliverFillRemaining(child: _emptyState())
            else ...[
              SliverToBoxAdapter(child: _buildSummaryCard()),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              for (final month in months) ...[
                SliverToBoxAdapter(child: _MonthSection(month: month)),
              ],
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final months = _filteredMonths;
    final totalEarnings =
        months.fold(0.0, (s, m) => s + m.totalEarnings);
    final totalDuration =
        months.fold(Duration.zero, (s, m) => s + m.totalDuration);
    final currentMonth = months.isNotEmpty ? months.first : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFB347).withOpacity(0.2),
            const Color(0xFF6C63FF).withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFFFFB347).withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('All time',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.5),
                  letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text(fmtMoney(totalEarnings),
              style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFFB347),
                  letterSpacing: -1)),
          Text(formatDuration(totalDuration),
              style: TextStyle(
                  fontSize: 14, color: Colors.white.withOpacity(0.4))),
          if (currentMonth != null) ...[
            const SizedBox(height: 16),
            Container(
                height: 1, color: Colors.white.withOpacity(0.08)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('This month',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.5))),
                  const SizedBox(height: 2),
                  Text(fmtMoney(currentMonth.totalEarnings),
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  Text(formatDuration(currentMonth.totalDuration),
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.4))),
                ]),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB347).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.attach_money,
                size: 40, color: Color(0xFFFFB347)),
          ),
          const SizedBox(height: 20),
          const Text('No earnings yet',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 8),
          Text('Set an hourly rate on a task to track earnings',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.4), fontSize: 14)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Month section
// ---------------------------------------------------------------------------

class _MonthSection extends StatefulWidget {
  final MonthEarning month;
  const _MonthSection({required this.month});

  @override
  State<_MonthSection> createState() => _MonthSectionState();
}

class _MonthSectionState extends State<_MonthSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.month;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month header
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fmtMonth(m.month),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        const SizedBox(height: 2),
                        Row(children: [
                          Text(formatDuration(m.totalDuration),
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.4),
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ])),
                          if (m.totalEarnings > 0) ...[
                            const SizedBox(width: 10),
                            Text(fmtMoney(m.totalEarnings),
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFFFB347))),
                          ],
                        ]),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 4),
            ...m.days.map((d) => _DayRow(day: d)),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Day row
// ---------------------------------------------------------------------------

class _DayRow extends StatelessWidget {
  final DayEarning day;
  const _DayRow({required this.day});

  String _label(DateTime d) {
    final now = dayOnly(DateTime.now());
    final yesterday = now.subtract(const Duration(days: 1));
    if (d == now) return 'Today';
    if (d == yesterday) return 'Yesterday';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday - 1]} ${d.day} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4, left: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A28),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_label(day.date),
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.8))),
              Row(children: [
                Text(formatDuration(day.totalDuration),
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.4),
                        fontFeatures: const [FontFeature.tabularFigures()])),
                if (day.totalEarnings > 0) ...[
                  const SizedBox(width: 10),
                  Text(fmtMoney(day.totalEarnings),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFFB347))),
                ],
              ]),
            ],
          ),
          const SizedBox(height: 8),
          ...day.tasks.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(t.task.label,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.5)),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Text(formatDuration(t.duration),
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.35),
                            fontFeatures: const [
                              FontFeature.tabularFigures()
                            ])),
                    if (t.earnings != null && t.earnings! > 0) ...[
                      const SizedBox(width: 8),
                      Text(fmtMoney(t.earnings!),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFB347))),
                    ],
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Export button widget
// ---------------------------------------------------------------------------

class _ExportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ExportButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }
}
