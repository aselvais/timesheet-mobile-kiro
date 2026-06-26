import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/task_bloc.dart';
import '../models/tag.dart';
import '../models/task_summary.dart';
import '../repositories/tag_repository.dart';
import '../repositories/time_log_repository.dart';
import '../widgets/tag_chip.dart';
import 'app_shell.dart' show refreshAllTags;

/// Formats a [Duration] as HH:MM:SS.
String formatDuration(Duration d) {
  final h = d.inHours.toString().padLeft(2, '0');
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => TaskListScreenState();
}

class TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _selectedTagId;
  List<Tag> _allTags = [];

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasksEvent());
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.toLowerCase().trim());
    });
    _loadTags();
  }

  Future<void> _loadTags() async {
    final tags = await context.read<TagRepository>().getAllTags();
    if (mounted) setState(() => _allTags = tags);
  }

  void refreshTags() => _loadTags();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showCreateTaskSheet() async {
    final bloc = context.read<TaskBloc>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFF1E1E2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CreateTaskSheet(bloc: bloc),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<TaskBloc, TaskState>(
          listener: (context, state) {
            if (state is TaskError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          },
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Tasks',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (state is TasksLoaded)
                              Text(
                                () {
                                  var tasks = state.tasks;
                                  if (_query.isNotEmpty) tasks = tasks.where((s) => s.task.label.toLowerCase().contains(_query)).toList();
                                  if (_selectedTagId != null) tasks = tasks.where((s) => s.tags.any((t) => t.id == _selectedTagId)).toList();
                                  return '${tasks.length} task${tasks.length == 1 ? '' : 's'}';
                                }(),
                                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                              ),
                          ],
                        ),
                        _AddButton(onTap: _showCreateTaskSheet),
                      ],
                    ),
                  ),
                ),
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Search tasks…',
                        prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.3), size: 20),
                        suffixIcon: _query.isNotEmpty
                            ? GestureDetector(
                                onTap: () => _searchController.clear(),
                                child: Icon(Icons.close, color: Colors.white.withOpacity(0.3), size: 18),
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                if (state is TasksLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state is TasksLoaded && state.tasks.isEmpty)
                  SliverFillRemaining(child: _EmptyState(onTap: _showCreateTaskSheet))
                else if (state is TasksLoaded)
                  Builder(builder: (context) {
                    var filtered = _query.isEmpty
                        ? state.tasks
                        : state.tasks.where((s) => s.task.label.toLowerCase().contains(_query)).toList();
                    if (_selectedTagId != null) {
                      filtered = filtered.where((s) => s.tags.any((t) => t.id == _selectedTagId)).toList();
                    }

                    if (filtered.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'No tasks match "$_query"',
                            style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 15),
                          ),
                        ),
                      );
                    }

                    // Disable reordering while searching
                    if (_query.isNotEmpty) {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _TaskCard(summary: filtered[index]),
                          childCount: filtered.length,
                        ),
                      );
                    }

                    return SliverReorderableList(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final summary = filtered[index];
                        return ReorderableDelayedDragStartListener(
                          key: ValueKey(summary.task.id),
                          index: index,
                          child: _TaskCard(summary: summary),
                        );
                      },
                      onReorder: (oldIndex, newIndex) {
                        final reordered = List.of(filtered);
                        if (newIndex > oldIndex) newIndex--;
                        final item = reordered.removeAt(oldIndex);
                        reordered.insert(newIndex, item);
                        context.read<TaskBloc>().add(
                          ReorderTasksEvent(reordered.map((s) => s.task.id).toList()),
                        );
                      },
                    );
                  })
                else
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              ],
            );
          },
        ),
      ),
      floatingActionButton: null,
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.timer_outlined, size: 40, color: Color(0xFF6C63FF)),
          ),
          const SizedBox(height: 20),
          const Text(
            'No tasks yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to start tracking your time',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.add),
            label: const Text('Create your first task'),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatefulWidget {
  final TaskSummary summary;
  const _TaskCard({required this.summary});

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  Timer? _ticker;
  DateTime? _sessionStart;
  Duration _liveElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.summary.hasActiveSession) {
      _startTicker();
    }
  }

  @override
  void didUpdateWidget(_TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasActive = oldWidget.summary.hasActiveSession;
    final isActive = widget.summary.hasActiveSession;
    if (isActive && !wasActive) {
      _startTicker();
    } else if (!isActive && wasActive) {
      _stopTicker();
    }
  }

  Future<void> _startTicker() async {
    // Fetch the active session's startTime so we can compute elapsed accurately.
    try {
      final repo = context.read<TimeLogRepository>();
      final session = await repo.getActiveSession(widget.summary.task.id);
      if (session != null && mounted) {
        setState(() {
          _sessionStart = session.startTime;
          _liveElapsed = DateTime.now().difference(session.startTime);
        });
        _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted && _sessionStart != null) {
            setState(() => _liveElapsed = DateTime.now().difference(_sessionStart!));
          }
        });
      }
    } catch (_) {}
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
    _sessionStart = null;
    setState(() => _liveElapsed = Duration.zero);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<bool?> _confirmDelete(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text(
          'What would you like to do with the logged time for "${widget.summary.task.label}"?',
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.4))),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskBloc>().add(DeleteTaskEvent(widget.summary.task.id, keepLogs: true));
              Navigator.of(ctx).pop(true);
            },
            child: const Text('Delete, keep logs', style: TextStyle(color: Color(0xFF6C63FF))),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskBloc>().add(DeleteTaskEvent(widget.summary.task.id));
              Navigator.of(ctx).pop(true);
            },
            child: const Text('Delete everything', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.summary.hasActiveSession && _sessionStart != null;
    final accent = isActive ? const Color(0xFF00E5A0) : const Color(0xFF6C63FF);
    final displayDuration = isActive && _sessionStart != null
        ? widget.summary.totalDuration + _liveElapsed
        : widget.summary.totalDuration;

    return Dismissible(
      key: ValueKey(widget.summary.task.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await Navigator.pushNamed(context, '/task-detail', arguments: widget.summary.task);
            if (context.mounted) {
              context.read<TaskBloc>().add(LoadTasksEvent());
              refreshAllTags(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 8, 18),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isActive ? Icons.play_circle_filled : Icons.timer_outlined,
                    color: accent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.summary.task.label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (widget.summary.tags.isNotEmpty) ...[
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: widget.summary.tags
                              .map((t) => TagChip(tag: t, small: true))
                              .toList(),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Row(
                        children: [
                          Text(
                            formatDuration(displayDuration),
                            style: TextStyle(
                              fontSize: 13,
                              color: isActive
                                  ? const Color(0xFF00E5A0)
                                  : Colors.white.withOpacity(0.45),
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          if (isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E5A0).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'LIVE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF00E5A0),
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                          if (widget.summary.task.hourlyRate != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              () {
                                final e = widget.summary.task.earnings(displayDuration);
                                return e != null ? '\$${e.toStringAsFixed(0)}' : '';
                              }(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFFB347),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Drag handle
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(Icons.drag_handle, color: Colors.white.withOpacity(0.2), size: 22),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateTaskSheet extends StatefulWidget {
  final TaskBloc bloc;
  const _CreateTaskSheet({required this.bloc});

  @override
  State<_CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<_CreateTaskSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text.trim().isNotEmpty) {
      widget.bloc.add(CreateTaskEvent(_controller.text));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset + (bottomInset == 0 ? bottomPadding : 0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'New Task',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: 'What are you working on?'),
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              child: const Text('Create Task'),
            ),
          ),
        ],
      ),
    );
  }
}
