import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/task.dart';
import '../models/time_log.dart';

// ---------------------------------------------------------------------------
// Data structures for export
// ---------------------------------------------------------------------------

class ExportEntry {
  final String taskLabel;
  final double? hourlyRate;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final double? earnings;

  ExportEntry({
    required this.taskLabel,
    this.hourlyRate,
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.earnings,
  });
}

// ---------------------------------------------------------------------------
// Build export data
// ---------------------------------------------------------------------------

List<ExportEntry> buildExportData(
    List<Task> tasks, Map<String, List<TimeLog>> sessions) {
  final entries = <ExportEntry>[];
  final taskById = {for (final t in tasks) t.id: t};

  for (final task in tasks) {
    for (final s in sessions[task.id] ?? []) {
      if (s.endTime == null) continue; // skip active sessions
      final dur = s.endTime!.difference(s.startTime);
      final earn = task.hourlyRate != null
          ? task.hourlyRate! * dur.inSeconds / 3600.0
          : null;
      entries.add(ExportEntry(
        taskLabel: task.label,
        hourlyRate: task.hourlyRate,
        startTime: s.startTime,
        endTime: s.endTime!,
        duration: dur,
        earnings: earn,
      ));
    }
  }

  entries.sort((a, b) => b.startTime.compareTo(a.startTime));
  return entries;
}

// ---------------------------------------------------------------------------
// CSV export
// ---------------------------------------------------------------------------

Future<File> exportCsv(List<ExportEntry> entries) async {
  final buf = StringBuffer();
  buf.writeln('Task,Hourly Rate,Start,End,Duration (h),Earnings');

  final df = DateFormat('yyyy-MM-dd HH:mm');
  for (final e in entries) {
    final hours = e.duration.inSeconds / 3600.0;
    buf.writeln(
      '"${e.taskLabel}",${e.hourlyRate ?? ""},'
      '"${df.format(e.startTime)}","${df.format(e.endTime)}",'
      '${hours.toStringAsFixed(2)},${e.earnings?.toStringAsFixed(2) ?? ""}',
    );
  }

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/time_tracker_report.csv');
  await file.writeAsString(buf.toString());
  return file;
}

// ---------------------------------------------------------------------------
// PDF export
// ---------------------------------------------------------------------------

Future<File> exportPdf(List<ExportEntry> entries) async {
  final pdf = pw.Document();
  final df = DateFormat('yyyy-MM-dd HH:mm');
  final now = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // Summary
  final totalHours =
      entries.fold(0.0, (s, e) => s + e.duration.inSeconds / 3600.0);
  final totalEarnings =
      entries.fold(0.0, (s, e) => s + (e.earnings ?? 0.0));

  // Group by task for summary
  final byTask = <String, _TaskSummary>{};
  for (final e in entries) {
    byTask.putIfAbsent(
        e.taskLabel, () => _TaskSummary(e.taskLabel, e.hourlyRate));
    byTask[e.taskLabel]!.totalDuration += e.duration;
    byTask[e.taskLabel]!.totalEarnings += e.earnings ?? 0.0;
  }

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => [
        pw.Header(
          level: 0,
          child: pw.Text('Time Tracker Report',
              style: pw.TextStyle(
                  fontSize: 22, fontWeight: pw.FontWeight.bold)),
        ),
        pw.Text('Generated: $now'),
        pw.SizedBox(height: 20),
        // Summary table
        pw.Header(level: 1, text: 'Summary'),
        pw.Table.fromTextArray(
          headers: ['Task', 'Rate/h', 'Hours', 'Earnings'],
          data: byTask.values.map((t) {
            final h = t.totalDuration.inSeconds / 3600.0;
            return [
              t.label,
              t.rate != null ? '\$${t.rate!.toStringAsFixed(2)}' : '-',
              h.toStringAsFixed(2),
              t.totalEarnings > 0
                  ? '\$${t.totalEarnings.toStringAsFixed(2)}'
                  : '-',
            ];
          }).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerLeft,
        ),
        pw.SizedBox(height: 10),
        pw.Text(
            'Total: ${totalHours.toStringAsFixed(2)} hours | \$${totalEarnings.toStringAsFixed(2)}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 30),
        // Detail table
        pw.Header(level: 1, text: 'Session Details'),
        pw.Table.fromTextArray(
          headers: ['Task', 'Start', 'End', 'Hours', 'Earnings'],
          data: entries.map((e) {
            final h = e.duration.inSeconds / 3600.0;
            return [
              e.taskLabel,
              df.format(e.startTime),
              df.format(e.endTime),
              h.toStringAsFixed(2),
              e.earnings != null
                  ? '\$${e.earnings!.toStringAsFixed(2)}'
                  : '-',
            ];
          }).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerLeft,
        ),
      ],
    ),
  );

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/time_tracker_report.pdf');
  await file.writeAsBytes(await pdf.save());
  return file;
}

// ---------------------------------------------------------------------------
// Share
// ---------------------------------------------------------------------------

Future<void> shareFile(File file) async {
  await Share.shareXFiles(
    [XFile(file.path)],
    subject: 'Time Tracker Report',
  );
}

// ---------------------------------------------------------------------------
// Internal helper
// ---------------------------------------------------------------------------

class _TaskSummary {
  final String label;
  final double? rate;
  Duration totalDuration = Duration.zero;
  double totalEarnings = 0.0;
  _TaskSummary(this.label, this.rate);
}
