import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/tag.dart';
import '../models/task.dart';
import '../models/time_log.dart';
import '../repositories/tag_repository.dart';
import '../repositories/task_repository.dart';
import '../repositories/time_log_repository.dart';
import 'app_shell.dart' show refreshAllTags;
import 'task_list_screen.dart' show formatDuration;

// ---------------------------------------------------------------------------
// Data helpers
// ---------------------------------------------------------------------------

class _DayEntry {
  final DateTime date;
  final List<_TaskDayTotal> totals;
  _DayEntry(this.date, this.totals);
}

class _TaskDayTotal {
  final Task task;
  final Duration total;
  final List<Tag> tags;
  _TaskDayTotal(this.task, this.total, this.tags);
}

DateTime _dayOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  List<_DayEntry> _allDays = [];
  List<Tag> _allTags = [];
  String? _selectedTagId;
  bool _loading = true;
  Timer? _ticker;

  // Task id → tags cache
  Map<String, List<Tag>> _taskTagsCache = {};

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

  void refreshTags() {
    _loadTags();
    _load();
  }

  Future<void> _loadTags() async {
    final tags = await context.read<TagRepository>().getAllTags();
    if (mounted) setState(() => _allTags = tags);
  }

  Future<void> _load() async {
    final taskRepo = context.read<TaskRepository>();
    final timeLogRepo = context.read<TimeLogRepository>();
    final tagRepo = context.read<TagRepository>();

    final tasks = await taskRepo.getAllTasks();
    final tags = await tagRepo.getAllTags();

    final allSessions = <String, List<TimeLog>>{};
    final taskTags = <String, List<Tag>>{};
    await Future.wait(tasks.map((t) async {
      allSessions[t.id] = await timeLogRepo.getSessionsForTask(t.id);
      taskTags[t.id] = await tagRepo.getTagsForTask(t.id);
    }));

    final Map<DateTime, Map<String, Duration>> dayMap = {};

    for (final task in tasks) {
      for (final session in allSessions[task.id] ?? []) {
        final start = session.startTime;
        final end = session.endTime ?? DateTime.now();
        var cursor = _dayOnly(start);
        while (!cursor.isAfter(_dayOnly(end))) {
          final dayStart = cursor.isAtSameMomentAs(_dayOnly(start)) ? start : cursor;
          final dayEnd = cursor.isAtSameMomentAs(_dayOnly(end))
              ? end
              : cursor.add(const Duration(days: 1));
          final dur = dayEnd.difference(dayStart);
          if (dur > Duration.zero) {
            dayMap.putIfAbsent(cursor, () => {});
            dayMap[cursor]![task.id] =
                (dayMap[cursor]![task.id] ?? Duration.zero) + dur;
          }
          cursor = cursor.add(const Duration(days: 1));
        }
      }
    }

    final sortedDays = dayMap.keys.toList()..sort((a, b) => b.compareTo(a));
    final taskById = {for (final t in tasks) t.id: t};

    final days = sortedDays.map((day) {
      final totalsMap = dayMap[day]!;
      final totals = totalsMap.entries
          .where((e) => taskById.containsKey(e.key))
          .map((e) => _TaskDayTotal(taskById[e.key]!, e.value, taskTags[e.key] ?? []))
          .toList()
        ..sort((a, b) => b.total.compareTo(a.total));
      return _DayEntry(day, totals);
    }).toList();

    if (mounted) {
      setState(() {
        _allDays = days;
        _allTags = tags;
        _taskTagsCache = taskTags;
        _loading = false;
      });
    }
  }

  List<_DayEntry> get _filteredDays {
    if (_selectedTagId == null) return _allDays;
    // Filter: only show tasks that have the selected tag
    final filtered = <_DayEntry>[];
    for (final day in _allDays) {
      final totals = day.totals.where((t) => t.tags.any((tg) => tg.id == _selectedTagId)).toList();
      if (totals.isNotEmpty) filtered.add(_DayEntry(day.date, totals));
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final days = _filteredDays;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Text(
                  'Timeline',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
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
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (days.isEmpty)
              SliverFillRemaining(child: _emptyState())
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _DayCard(entry: days[i]),
                  childCount: days.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_today_outlined, size: 36, color: Color(0xFF6C63FF)),
          ),
          const SizedBox(height: 20),
          Text(_selectedTagId != null ? 'No entries for this tag' : 'No history yet',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 8),
          Text(_selectedTagId != null ? 'Try selecting a different tag' : 'Start tracking tasks to see your timeline',
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Day card
// ---------------------------------------------------------------------------

class _DayCard extends StatelessWidget {
  final _DayEntry entry;
  const _DayCard({required this.entry});

  String _label(DateTime d) {
    final now = _dayOnly(DateTime.now());
    final yesterday = now.subtract(const Duration(days: 1));
    if (d == now) return 'Today';
    if (d == yesterday) return 'Yesterday';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    final wd = days[d.weekday - 1];
    return '$wd ${d.day} ${months[d.month - 1]}';
  }

  Duration get _dayTotal =>
      entry.totals.fold(Duration.zero, (s, t) => s + t.total);

  double get _dayEarnings =>
      entry.totals.fold(0.0, (s, t) => s + (t.task.earnings(t.total) ?? 0.0));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                Text(_label(entry.date),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(width: 8),
                Text(formatDuration(_dayTotal),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.35),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    )),
                const Spacer(),
                if (_dayEarnings > 0)
                  Text(
                    '\$${_dayEarnings.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFB347)),
                  ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                for (int i = 0; i < entry.totals.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: Colors.white.withOpacity(0.05)),
                  _TaskRow(item: entry.totals[i], dayTotal: _dayTotal),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Task row inside a day card
// ---------------------------------------------------------------------------

class _TaskRow extends StatelessWidget {
  final _TaskDayTotal item;
  final Duration dayTotal;
  const _TaskRow({required this.item, required this.dayTotal});

  Color _taskColor(String label) {
    const palette = [
      Color(0xFF6C63FF), Color(0xFF00E5A0), Color(0xFFFF6B6B),
      Color(0xFFFFB347), Color(0xFF4FC3F7), Color(0xFFCE93D8),
      Color(0xFF80CBC4), Color(0xFFFFD54F),
    ];
    return palette[label.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final fraction = dayTotal.inSeconds > 0
        ? item.total.inSeconds / dayTotal.inSeconds
        : 0.0;
    final color = _taskColor(item.task.label);

    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(context, '/task-detail', arguments: item.task);
        refreshAllTags(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 8, height: 8,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(item.task.label,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                      overflow: TextOverflow.ellipsis),
                ),
                Text(formatDuration(item.total),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.7),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    )),
                Builder(builder: (context) {
                  final earn = item.task.earnings(item.total);
                  if (earn == null || earn <= 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text('\$${earn.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFB347))),
                  );
                }),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction.clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: Colors.white.withOpacity(0.06),
                valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
