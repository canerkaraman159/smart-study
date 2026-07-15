import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalStore {
  static const _dailyGoalKey = 'daily_goal_minutes';

  static ValueNotifier<int> dailyGoalMinutes = ValueNotifier(120);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    dailyGoalMinutes.value = prefs.getInt(_dailyGoalKey) ?? 120;
  }

  static Future<void> saveDailyGoal(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyGoalKey, minutes);

    dailyGoalMinutes.value = minutes;
  }
}
