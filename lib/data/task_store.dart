import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskStore {
  static const _storageKey = 'saved_tasks';

  static final ValueNotifier<List<Map<String, dynamic>>> tasks = ValueNotifier(_defaultTasks());

  static List<Map<String, dynamic>> _defaultTasks() {
    return [
      {
        'title': 'Matematik Çalış',
        'duration': '30 dk',
        'iconCode': Icons.calculate_outlined.codePoint,
        'iconBg': 0xFFD8DFFF,
        'iconColor': 0xFF7C89E8,
        'isDone': false,
      },
      {
        'title': 'Fen Bilgisi Tekrar',
        'duration': '30 dk',
        'iconCode': Icons.science_outlined.codePoint,
        'iconBg': 0xFFD7F0D8,
        'iconColor': 0xFF69C26F,
        'isDone': false,
      },
    ];
  }

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final raw = prefs.getString(_storageKey);

      if (raw == null) {
        tasks.value = _defaultTasks();
        return;
      }

      final decoded = jsonDecode(raw) as List;

      tasks.value = decoded.map((e) {
        final task = Map<String, dynamic>.from(e);

        return {
          'title': task['title'] ?? 'Yeni Görev',
          'duration': task['duration'] ?? '30 dk',
          'iconCode': task['iconCode'] ?? Icons.book_outlined.codePoint,
          'iconBg': task['iconBg'] ?? 0xFFE5F4E8,
          'iconColor': task['iconColor'] ?? 0xFF69C26F,
          'isDone': task['isDone'] ?? false,
        };
      }).toList();
    } catch (e) {
      await prefs.remove(_storageKey);
      tasks.value = _defaultTasks();
    }
  }

  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_storageKey, jsonEncode(tasks.value));
  }

  static Future<void> addTask(Map<String, dynamic> task) async {
    tasks.value = [task, ...tasks.value];

    await _save();
  }

  static Future<void> updateTasks(List<Map<String, dynamic>> updated) async {
    tasks.value = [...updated];

    await _save();
  }

  static Future<void> deleteCompletedTasks() async {
    tasks.value = tasks.value.where((t) => t['isDone'] != true).toList();

    await _save();
  }
}
