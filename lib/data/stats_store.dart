import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_app/data/goal_store.dart';

class StatsStore {
  static const _totalKey = 'stats_total_minutes';
  static const _sessionKey = 'stats_session_count';
  static const _dailyKey = 'stats_daily_minutes';
  static const _taskMinutesKey = 'stats_task_minutes';
  static const _streakKey = 'stats_streak';
  static const _bestStreakKey = 'stats_best_streak';
  static const _lastGoalDateKey = 'stats_last_goal_date';

  static ValueNotifier<int> totalMinutes = ValueNotifier(0);
  static ValueNotifier<int> todayMinutes = ValueNotifier(0);
  static ValueNotifier<int> sessionCount = ValueNotifier(0);
  static ValueNotifier<int> streak = ValueNotifier(0);
  static ValueNotifier<int> bestStreak = ValueNotifier(0);
  static ValueNotifier<int> chartVersion = ValueNotifier(0);

  static Map<String, int> dailyMinutes = {};
  static Map<String, int> taskMinutes = {};
  static void addTaskStudyMinutes(String title, int minutes) {
    taskMinutes[title] = (taskMinutes[title] ?? 0) + minutes;
  }

  static String _dateKey(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String todayKey() => _dateKey(DateTime.now());

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    totalMinutes.value = prefs.getInt(_totalKey) ?? 0;
    sessionCount.value = prefs.getInt(_sessionKey) ?? 0;
    streak.value = prefs.getInt(_streakKey) ?? 0;
    bestStreak.value = prefs.getInt(_bestStreakKey) ?? 0;

    final rawDaily = prefs.getString(_dailyKey);
    if (rawDaily != null) {
      final decoded = jsonDecode(rawDaily) as Map;
      dailyMinutes = decoded.map((key, value) => MapEntry(key.toString(), value as int));
    }

    todayMinutes.value = dailyMinutes[todayKey()] ?? 0;
    await _checkStreakReset();
  }

  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_totalKey, totalMinutes.value);
    await prefs.setInt(_sessionKey, sessionCount.value);
    await prefs.setInt(_streakKey, streak.value);
    await prefs.setInt(_bestStreakKey, bestStreak.value);
    await prefs.setString(_dailyKey, jsonEncode(dailyMinutes));
    await prefs.setString(_taskMinutesKey, jsonEncode(taskMinutes));
  }

  static Future<void> _checkStreakReset() async {
    final prefs = await SharedPreferences.getInstance();

    final lastGoalDate = prefs.getString(_lastGoalDateKey);
    if (lastGoalDate == null) return;

    final today = todayKey();
    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));

    if (lastGoalDate != today && lastGoalDate != yesterday) {
      streak.value = 0;
      await prefs.setInt(_streakKey, 0);
    }
  }

  static Future<void> _updateStreakIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();

    final today = todayKey();
    final lastGoalDate = prefs.getString(_lastGoalDateKey);
    final goal = GoalStore.dailyGoalMinutes.value;

    if (todayMinutes.value < goal) return;
    if (lastGoalDate == today) return;

    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));

    if (lastGoalDate == yesterday) {
      streak.value += 1;
    } else {
      streak.value = 1;
    }

    if (streak.value > bestStreak.value) {
      bestStreak.value = streak.value;
    }

    await prefs.setString(_lastGoalDateKey, today);
  }

  static Future<void> addStudyMinutes(int minutes) async {
    if (minutes <= 0) return;

    final today = todayKey();

    totalMinutes.value += minutes;
    todayMinutes.value += minutes;
    sessionCount.value += 1;

    dailyMinutes[today] = (dailyMinutes[today] ?? 0) + minutes;

    await _updateStreakIfNeeded();

    chartVersion.value++;
    await _save();
  }

  static Future<void> removeStudyMinutes(int minutes) async {
    if (minutes <= 0) return;

    final today = todayKey();

    totalMinutes.value -= minutes;
    todayMinutes.value -= minutes;
    sessionCount.value -= 1;

    if (totalMinutes.value < 0) totalMinutes.value = 0;
    if (todayMinutes.value < 0) todayMinutes.value = 0;
    if (sessionCount.value < 0) sessionCount.value = 0;

    dailyMinutes[today] = (dailyMinutes[today] ?? 0) - minutes;

    if ((dailyMinutes[today] ?? 0) < 0) {
      dailyMinutes[today] = 0;
    }

    chartVersion.value++;
    await _save();
  }

  static List<double> getWeekChartData() {
    final now = DateTime.now();

    return List.generate(7, (index) {
      final day = now.subtract(Duration(days: 6 - index));
      final key = _dateKey(day);
      final minutes = dailyMinutes[key] ?? 0;

      return minutes / 60;
    });
  }

  static List<String> getWeekLabels() {
    const labels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    final now = DateTime.now();

    return List.generate(7, (index) {
      final day = now.subtract(Duration(days: 6 - index));
      return labels[day.weekday - 1];
    });
  }

  static List<double> getMonthChartData() {
    final now = DateTime.now();

    return List.generate(4, (index) {
      int total = 0;
      final startDay = now.subtract(Duration(days: (3 - index) * 7));

      for (int i = 0; i < 7; i++) {
        final day = startDay.add(Duration(days: i));
        final key = _dateKey(day);
        total += dailyMinutes[key] ?? 0;
      }

      return total / 60;
    });
  }

  static List<String> getMonthLabels() {
    return ['1H', '2H', '3H', '4H'];
  }
}
