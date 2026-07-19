import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';

class TaskStore {
  static final ValueNotifier<List<Map<String, dynamic>>> tasks = ValueNotifier<List<Map<String, dynamic>>>([]);

  static StreamSubscription<User?>? _authSubscription;
  static StreamSubscription<List<Map<String, dynamic>>>? _tasksSubscription;

  static Future<void> init() async {
    await _authSubscription?.cancel();

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _tasksSubscription?.cancel();
      _tasksSubscription = null;

      if (user == null) {
        tasks.value = [];
        return;
      }

      _listenToUserTasks();
    });
  }

  static void _listenToUserTasks() {
    _tasksSubscription = FirestoreService.getTasksStream().listen(
      (firestoreTasks) {
        tasks.value = firestoreTasks.map((task) {
          return {
            'id': task['id'],
            'title': task['title'] ?? 'Yeni Görev',
            'description': task['description'] ?? '',
            'duration': task['duration'] ?? '30 dk',
            'date': task['date'],
            'category': task['category'] ?? 'general',
            'iconCode': task['iconCode'] ?? Icons.assignment_rounded.codePoint,
            'iconBg': task['iconBg'] ?? 0xFFE5F4E8,
            'iconColor': task['iconColor'] ?? 0xFF69C26F,
            'isDone': task['isDone'] ?? false,
            'createdAt': task['createdAt'],
          };
        }).toList();
      },
      onError: (Object error) {
        debugPrint('Görevler alınırken hata oluştu: $error');
      },
    );
  }

  static Future<void> addTask(Map<String, dynamic> task) async {
    final newTask = Map<String, dynamic>.from(task);

    newTask.remove('id');

    await FirestoreService.addTask(newTask);
  }

  static Future<void> updateTask(int index, Map<String, dynamic> updatedTask) async {
    if (index < 0 || index >= tasks.value.length) {
      return;
    }

    final currentTask = tasks.value[index];

    final taskId = updatedTask['id']?.toString() ?? currentTask['id']?.toString();

    if (taskId == null || taskId.isEmpty) {
      return;
    }

    final taskData = Map<String, dynamic>.from(updatedTask);

    taskData['id'] = taskId;

    await FirestoreService.updateTask(taskId, taskData);
  }

  static Future<void> deleteTask(int index) async {
    if (index < 0 || index >= tasks.value.length) {
      return;
    }

    final taskId = tasks.value[index]['id']?.toString();

    if (taskId == null || taskId.isEmpty) {
      return;
    }

    await FirestoreService.deleteTask(taskId);
  }

  static Future<void> updateTasks(List<Map<String, dynamic>> updated) async {
    final oldTasks = [...tasks.value];

    final updatedIds = updated.map((task) => task['id']?.toString()).whereType<String>().where((id) => id.isNotEmpty).toSet();

    for (final oldTask in oldTasks) {
      final oldId = oldTask['id']?.toString();

      if (oldId != null && oldId.isNotEmpty && !updatedIds.contains(oldId)) {
        await FirestoreService.deleteTask(oldId);
      }
    }

    for (final task in updated) {
      final taskId = task['id']?.toString();

      if (taskId == null || taskId.isEmpty) {
        await FirestoreService.addTask(task);
      } else {
        await FirestoreService.updateTask(taskId, task);
      }
    }
  }

  static Future<void> deleteCompletedTasks() async {
    await FirestoreService.deleteCompletedTasks();
  }

  static Future<void> dispose() async {
    await _tasksSubscription?.cancel();
    await _authSubscription?.cancel();

    _tasksSubscription = null;
    _authSubscription = null;
  }
}
