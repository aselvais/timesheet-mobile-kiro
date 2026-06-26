import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../blocs/task_bloc.dart';
import '../data/database.dart';
import '../services/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  final AppSettings settings;
  const SettingsScreen({super.key, required this.settings});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _rateController;

  @override
  void initState() {
    super.initState();
    _rateController = TextEditingController(
      text: widget.settings.defaultHourlyRate?.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.settings;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5)),
              const SizedBox(height: 32),

              // Default hourly rate
              _SettingsCard(
                icon: Icons.attach_money,
                iconColor: const Color(0xFFFFB347),
                title: 'Default hourly rate',
                subtitle: s.defaultHourlyRate != null
                    ? '\$${s.defaultHourlyRate!.toStringAsFixed(2)}/h'
                    : 'Not set — new tasks won\'t have a rate',
                trailing: const Icon(Icons.chevron_right,
                    color: Colors.white24, size: 22),
                onTap: _showRateEditor,
              ),

              const SizedBox(height: 12),

              // Erase all data
              _SettingsCard(
                icon: Icons.delete_forever_outlined,
                iconColor: Colors.redAccent,
                title: 'Erase all data',
                subtitle: 'Delete all tasks, sessions, tags and settings',
                trailing: const Icon(Icons.chevron_right,
                    color: Colors.white24, size: 22),
                onTap: _confirmErase,
              ),

              const SizedBox(height: 32),

              Center(
                child: Text(
                  'Settings are saved automatically',
                  style: TextStyle(
                      fontSize: 12, color: Colors.white.withOpacity(0.3)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmErase() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Erase all data?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text(
          'This will permanently delete all tasks, time sessions, tags, '
          'and settings. This action cannot be undone.',
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel',
                style: TextStyle(color: Colors.white.withOpacity(0.4))),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Erase everything',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _eraseAllData();
    }
  }

  Future<void> _eraseAllData() async {
    // Delete all tables
    final db = appDatabase;
    await db.customStatement('DELETE FROM task_tags');
    await db.customStatement('DELETE FROM tags');
    await db.customStatement('DELETE FROM time_logs');
    await db.customStatement('DELETE FROM tasks');

    // Reset settings
    widget.settings.defaultHourlyRate = null;

    // Delete order file
    try {
      final dir = await getApplicationDocumentsDirectory();
      final orderFile = File(p.join(dir.path, 'task_order.json'));
      if (orderFile.existsSync()) await orderFile.delete();
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All data erased'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      // Reload tasks bloc
      context.read<TaskBloc>().add(LoadTasksEvent());
    }
  }

  Future<void> _showRateEditor() async {
    _rateController.text =
        widget.settings.defaultHourlyRate?.toStringAsFixed(2) ?? '';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFF1E1E2C),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom +
                MediaQuery.of(ctx).viewPadding.bottom + 24),
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
            const Text('Default hourly rate',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            const SizedBox(height: 6),
            Text(
                'Applied to new tasks by default. Leave empty to disable.',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.4))),
            const SizedBox(height: 16),
            TextField(
              controller: _rateController,
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
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final text = _rateController.text.trim();
                  final rate =
                      text.isEmpty ? null : double.tryParse(text);
                  setState(
                      () => widget.settings.defaultHourlyRate = rate);
                  Navigator.of(ctx).pop();
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.4))),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
