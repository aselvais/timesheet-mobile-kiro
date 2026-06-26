import 'package:flutter/material.dart';

import 'calendar_screen.dart';
import 'help_screen.dart';
import 'returns_screen.dart';
import 'settings_screen.dart';
import 'task_list_screen.dart';
import '../services/app_settings.dart';

class AppShell extends StatefulWidget {
  final AppSettings settings;
  const AppShell({super.key, required this.settings});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  int _index = 0;

  final _taskListKey = GlobalKey<TaskListScreenState>();
  final _calendarKey = GlobalKey<CalendarScreenState>();
  final _returnsKey = GlobalKey<ReturnsScreenState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      TaskListScreen(key: _taskListKey),
      CalendarScreen(key: _calendarKey),
      ReturnsScreen(key: _returnsKey),
      const HelpScreen(),
      SettingsScreen(settings: widget.settings),
    ];
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void refreshAllTags() {
    _taskListKey.currentState?.refreshTags();
    _calendarKey.currentState?.refreshTags();
  }

  void refreshAll() {
    refreshAllTags();
    _returnsKey.currentState?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return _AppShellScope(
      shell: this,
      child: Scaffold(
        body: IndexedStack(index: _index, children: _pages),
        bottomNavigationBar: _BottomNav(
          index: _index,
          onTap: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}

class _AppShellScope extends InheritedWidget {
  final _AppShellState shell;
  const _AppShellScope({required this.shell, required super.child});

  static _AppShellState? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AppShellScope>()?.shell;

  @override
  bool updateShouldNotify(_AppShellScope oldWidget) => false;
}

void refreshAllTags(BuildContext context) {
  _AppShellScope.maybeOf(context)?.refreshAll();
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A26),
        border: Border(top: BorderSide(color: Color(0xFF2A2A3C), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.timer_outlined, activeIcon: Icons.timer,
                  label: 'Tasks', selected: index == 0, onTap: () => onTap(0)),
              _NavItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month,
                  label: 'Timeline', selected: index == 1, onTap: () => onTap(1)),
              _NavItem(icon: Icons.attach_money_outlined, activeIcon: Icons.attach_money,
                  label: 'Returns', selected: index == 2, onTap: () => onTap(2)),
              _NavItem(icon: Icons.help_outline, activeIcon: Icons.help,
                  label: 'Help', selected: index == 3, onTap: () => onTap(3)),
              _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings,
                  label: 'Settings', selected: index == 4, onTap: () => onTap(4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF6C63FF);
    final color = selected ? accent : Colors.white.withOpacity(0.35);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? accent.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? activeIcon : icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    color: color,
                    letterSpacing: 0.2)),
          ],
        ),
      ),
    );
  }
}
