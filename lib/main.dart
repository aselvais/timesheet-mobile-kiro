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
import 'services/app_settings.dart';
import 'widgets/orphaned_session_handler.dart';

final appSettings = AppSettings();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appSettings.load();

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

  runApp(TimeTrackerApp(
    taskRepo: taskRepo,
    timeLogRepo: timeLogRepo,
    tagRepo: tagRepo,
    settings: appSettings,
  ));
}

class TimeTrackerApp extends StatelessWidget {
  final TaskRepository taskRepo;
  final TimeLogRepository timeLogRepo;
  final TagRepository tagRepo;
  final AppSettings settings;

  const TimeTrackerApp({
    super.key,
    required this.taskRepo,
    required this.timeLogRepo,
    required this.tagRepo,
    required this.settings,
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
        create: (_) => TaskBloc(taskRepository: taskRepo, settings: settings),
        child: ListenableBuilder(
          listenable: settings,
          builder: (context, _) => MaterialApp(
            title: 'Time Tracker',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(Brightness.light),
            darkTheme: _buildTheme(Brightness.dark),
            themeMode: settings.isDark ? ThemeMode.dark : ThemeMode.light,
            home: OrphanedSessionHandler(child: AppShell(settings: settings)),
            routes: {'/task-detail': (_) => const TaskDetailScreen()},
          ),
        ),
      ),
    );
  }

  static ThemeData _buildTheme(Brightness brightness) {
    const seed = Color(0xFF6C63FF);
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: brightness,
        surface: isDark ? const Color(0xFF12121A) : Colors.grey.shade50,
        surfaceContainerHighest: isDark ? const Color(0xFF1E1E2C) : Colors.white,
      ),
      scaffoldBackgroundColor: isDark ? const Color(0xFF12121A) : Colors.grey.shade50,
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        elevation: isDark ? 0 : 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF12121A) : Colors.grey.shade50,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
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
        fillColor: isDark ? const Color(0xFF2A2A3C) : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(
            color: isDark ? Colors.white.withOpacity(0.3) : Colors.black38),
      ),
      dividerTheme: DividerThemeData(
          color: isDark ? const Color(0xFF2A2A3C) : Colors.grey.shade200,
          thickness: 1),
    );
  }
}
