import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PomodoroSettings {
  static const _focusKey = 'pomodoro_focus';
  static const _shortBreakKey = 'pomodoro_short_break';
  static const _longBreakKey = 'pomodoro_long_break';
  static const _sessionsKey = 'pomodoro_sessions';

  static ValueNotifier<int> focusMinutes = ValueNotifier(25);
  static ValueNotifier<int> shortBreak = ValueNotifier(5);
  static ValueNotifier<int> longBreak = ValueNotifier(15);
  static ValueNotifier<int> sessions = ValueNotifier(4);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    focusMinutes.value = prefs.getInt(_focusKey) ?? 25;
    shortBreak.value = prefs.getInt(_shortBreakKey) ?? 5;
    longBreak.value = prefs.getInt(_longBreakKey) ?? 15;
    sessions.value = prefs.getInt(_sessionsKey) ?? 4;
  }

  static Future<void> save({required int focus, required int short, required int long, required int sessionCount}) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_focusKey, focus);
    await prefs.setInt(_shortBreakKey, short);
    await prefs.setInt(_longBreakKey, long);
    await prefs.setInt(_sessionsKey, sessionCount);

    focusMinutes.value = focus;
    shortBreak.value = short;
    longBreak.value = long;
    sessions.value = sessionCount;
  }
}
