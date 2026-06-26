import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Help',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Text('Everything you need to know',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 14)),
                  ],
                ),
              ),
            ),
            for (final section in _sections) ...[
              SliverToBoxAdapter(
                child: _SectionHeader(title: section.title),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _FaqItem(item: section.items[i]),
                  childCount: section.items.length,
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------

class _FaqData {
  final String question;
  final String answer;
  final IconData icon;
  const _FaqData(this.question, this.answer, this.icon);
}

class _SectionData {
  final String title;
  final List<_FaqData> items;
  const _SectionData(this.title, this.items);
}

const _sections = [
  // ---- Tasks ----
  _SectionData('Tasks', [
    _FaqData(
      'How do I create a task?',
      'Tap the + button in the top-right corner of the Tasks screen. '
      'Type a name (up to 100 characters) and tap "Create Task".',
      Icons.add_circle_outline,
    ),
    _FaqData(
      'How do I search for a task?',
      'Use the search field on the Tasks screen. Start typing and the '
      'list filters in real time. Tap × to clear.',
      Icons.search,
    ),
    _FaqData(
      'How do I reorder tasks?',
      'Long-press the drag handle (≡) on the right side of a task card '
      'and drag it to the desired position. The order is saved automatically.',
      Icons.drag_handle,
    ),
    _FaqData(
      'How do I delete a task?',
      'Swipe a task card to the left. A dialog will ask if you want to '
      '"Delete everything" (task + all sessions) or "Delete, keep logs" '
      '(removes the label but keeps session history).',
      Icons.delete_outline,
    ),
  ]),

  // ---- Tags ----
  _SectionData('Tags', [
    _FaqData(
      'How do tags work?',
      'Tags let you categorize tasks with a name and a color. '
      'Open a task detail and tap "Add tag" below the timer to manage tags.',
      Icons.label_outline,
    ),
    _FaqData(
      'How do I create a new tag?',
      'In the tag sheet, tap "New tag", enter a name, pick a color, '
      'and tap "Create & assign". The tag is immediately assigned.',
      Icons.new_label_outlined,
    ),
    _FaqData(
      'How do I filter by tag?',
      'On both the Tasks and Timeline screens, a tag bar appears at '
      'the top. Tap a tag to filter; tap again to clear.',
      Icons.filter_alt_outlined,
    ),
  ]),

  // ---- Timer & Sessions ----
  _SectionData('Timer & Sessions', [
    _FaqData(
      'How do I start tracking time?',
      'Tap a task to open its detail screen, then press the green '
      '"Start" button. Elapsed time updates every second.',
      Icons.play_circle_outline,
    ),
    _FaqData(
      'How do I stop the timer?',
      'Press the red "Stop" button. The session saves automatically '
      'with its start and end time.',
      Icons.stop_circle_outlined,
    ),
    _FaqData(
      'Can I add time manually?',
      'Yes. On the task detail screen, tap "Add" next to the Sessions '
      'header. Pick a start and end date/time to log time after the fact.',
      Icons.more_time,
    ),
    _FaqData(
      'Can I edit or delete a session?',
      'Tap any closed session to open the editor. Change start/end times '
      'and tap "Save changes", or use the "Delete" button to remove it.',
      Icons.edit_outlined,
    ),
    _FaqData(
      'Can I run multiple timers at once?',
      'Only one timer per task at a time. Stop the current session '
      'before starting a new one on the same task.',
      Icons.timer_off_outlined,
    ),
    _FaqData(
      'What if the app is killed while timing?',
      'On next launch, a prompt appears to Resume (restores the timer '
      'from the original start time) or Discard the orphaned session.',
      Icons.restore_outlined,
    ),
  ]),

  // ---- Timeline ----
  _SectionData('Timeline', [
    _FaqData(
      'What does the Timeline show?',
      'All your logged time grouped by day, with per-task breakdowns, '
      'progress bars, and earnings (when an hourly rate is set). '
      'Tap any task row to jump to its detail screen.',
      Icons.calendar_month_outlined,
    ),
    _FaqData(
      'Can I filter the timeline?',
      'Yes — use the tag bar at the top to show only entries for '
      'tasks with a specific tag.',
      Icons.filter_alt_outlined,
    ),
  ]),

  // ---- Hourly Rate & Returns ----
  _SectionData('Hourly Rate & Returns', [
    _FaqData(
      'How do I set an hourly rate?',
      'Open a task detail and tap the "\$ Set rate" badge below the timer. '
      'Enter your rate (e.g. 50.00) and tap "Save rate". Earnings are '
      'automatically calculated as rate × hours worked.',
      Icons.attach_money,
    ),
    _FaqData(
      'Where do I see my earnings?',
      'The Returns tab shows total earnings all-time and this month, '
      'with expandable monthly breakdowns showing daily and per-task earnings. '
      'The Timeline also shows earnings next to each day and task.',
      Icons.account_balance_wallet_outlined,
    ),
    _FaqData(
      'Are earnings recalculated when I change the rate?',
      'Yes. When you update a task\'s hourly rate, all screens (Timeline, '
      'Returns) recalculate earnings using the new rate the next time they '
      'refresh — which happens when you navigate back from the detail screen.',
      Icons.refresh,
    ),
  ]),

  // ---- Export ----
  _SectionData('Export & Share', [
    _FaqData(
      'How do I export a report?',
      'On the Returns screen, tap the share icon (top-right). Choose either '
      '"PDF Report" for a formatted document with summary and detail tables, '
      'or "CSV Data" for raw spreadsheet data.',
      Icons.ios_share,
    ),
    _FaqData(
      'How do I send a report?',
      'After choosing PDF or CSV, the native share sheet opens. You can send '
      'the file via email, WhatsApp, AirDrop, Google Drive, or any other app '
      'installed on your device.',
      Icons.share_outlined,
    ),
  ]),

  // ---- General ----
  _SectionData('General', [
    _FaqData(
      'Is my data stored online?',
      'No. Everything is stored locally on your device in a SQLite database. '
      'Nothing is transmitted over the network. Your data is private and '
      'works fully offline.',
      Icons.lock_outline,
    ),
    _FaqData(
      'How is total time calculated?',
      'The total on the Tasks screen is the sum of all completed sessions. '
      'A live session is shown separately and added to the total only when stopped.',
      Icons.calculate_outlined,
    ),
  ]),
];

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.white.withOpacity(0.45),
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FAQ item widget
// ---------------------------------------------------------------------------

class _FaqItem extends StatefulWidget {
  final _FaqData item;
  const _FaqItem({required this.item});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _rotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _expanded
              ? const Color(0xFF252535)
              : const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(16),
          border: _expanded
              ? Border.all(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                  width: 1)
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(widget.item.icon,
                            color: const Color(0xFF6C63FF), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.item.question,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      RotationTransition(
                        turns: _rotation,
                        child: Icon(Icons.keyboard_arrow_down,
                            color: Colors.white.withOpacity(0.4), size: 22),
                      ),
                    ],
                  ),
                  if (_expanded) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(left: 48),
                      child: Text(
                        widget.item.answer,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
