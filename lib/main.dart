import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/task_bloc.dart';
import 'data/database.dart';
import 'repositories/drift_tag_repository.dart';
import 'repositories/drift_task_repository.dart';
import 'repositories/drift_time_log_repository.dart';
import 'repositories/tag_repository.dart';
import 'repositories/task_repository.dart';
import 'repositories/time_log_repository.dart';
import 'screens/app_shell.dart';
import 'screens/task_detail_screen.dart';
import 'widgets/orphaned_session_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Make the system nav bar transparent and let Flutter handle the padding
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFF1A1A26),
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final db = appDatabase;
  final tagRepo = DriftTagRepository(database: db);
  final taskRepo = DriftTaskRepository(database: db)
    ..tagRepository = tagRepo;
  final timeLogRepo = DriftTimeLogRepository(database: db);
  runApp(TimeTrackerApp(taskRepo: taskRepo, timeLogRepo: timeLogRepo, tagRepo: tagRepo));
}

class TimeTrackerApp extends StatelessWidget {
  final TaskRepository taskRepo;
  final TimeLogRepository timeLogRepo;
  final TagRepository tagRepo;

  const TimeTrackerApp({
    super.key,
    required this.taskRepo,
    required this.timeLogRepo,
    required this.tagRepo,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TaskRepository>.value(value: taskRepo),
        RepositoryProvider<TimeLogRepository>.value(value: timeLogRepo),
        RepositoryProvider<TagRepository>.value(value: tagRepo),
      ],
      child: BlocProvider(
        create: (_) => TaskBloc(taskRepository: taskRepo),
        child: MaterialApp(
          title: 'Time Tracker',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(),
          home: const OrphanedSessionHandler(child: AppShell()),
          routes: {'/task-detail': (_) => const TaskDetailScreen()},
        ),
      ),
    );
  }

  ThemeData _buildTheme() {
    const seed = Color(0xFF6C63FF);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
        surface: const Color(0xFF12121A),
        surfaceContainerHighest: const Color(0xFF1E1E2C),
      ),
      scaffoldBackgroundColor: const Color(0xFF12121A),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E2C),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF12121A),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: seed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(160, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A3C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF2A2A3C), thickness: 1),
    );
  }
}
