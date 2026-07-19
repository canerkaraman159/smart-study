import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'data/goal_store.dart';
import 'data/pomodoro_settings.dart';
import 'data/stats_store.dart';
import 'data/task_store.dart';
import 'screens/add_task_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/pomodoro_screen.dart';
import 'screens/pomodoro_settings.dart';
import 'screens/profile_screen.dart';
import 'screens/report_issue_page.dart';
import 'screens/splash_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/task_detail_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await TaskStore.init();
  await PomodoroSettings.init();
  await GoalStore.init();
  await StatsStore.init();

  runApp(const SmartStudyApp());
}

class SmartStudyApp extends StatelessWidget {
  const SmartStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Study',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),

        AppRoutes.home: (context) => const MainNavigationScreen(),

        AppRoutes.addTask: (context) => const AddTaskScreen(),
        AppRoutes.pomodoro: (context) => const PomodoroScreen(),
        AppRoutes.pomodoroSettings: (context) => const PomodoroSettingsScreen(),
        AppRoutes.profile: (context) => const ProfileSettingsPage(),
        AppRoutes.reportIssue: (context) => const ReportIssuePage(),
        AppRoutes.stats: (context) => const StatsScreen(),
        AppRoutes.taskDetail: (context) => const TaskDetailScreen(),
      },
    );
  }
}

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const addTask = '/add-task';
  static const pomodoro = '/pomodoro';
  static const pomodoroSettings = '/pomodoro-settings';
  static const profile = '/profile';
  static const reportIssue = '/report-issue';
  static const stats = '/stats';
  static const taskDetail = '/task-detail';
}
