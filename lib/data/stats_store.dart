import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_app/data/goal_store.dart';

class StatsStore {
  StatsStore._();

  static const String _totalKey = 'stats_total_minutes';
  static const String _sessionKey = 'stats_session_count';
  static const String _dailyKey = 'stats_daily_minutes';
  static const String _taskMinutesKey = 'stats_task_minutes';
  static const String _streakKey = 'stats_streak';
  static const String _bestStreakKey = 'stats_best_streak';
  static const String _lastGoalDateKey = 'stats_last_goal_date';
  static const String _migrationKeyPrefix = 'stats_firestore_migrated_';

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static final ValueNotifier<int> totalMinutes = ValueNotifier<int>(0);
  static final ValueNotifier<int> todayMinutes = ValueNotifier<int>(0);
  static final ValueNotifier<int> sessionCount = ValueNotifier<int>(0);
  static final ValueNotifier<int> streak = ValueNotifier<int>(0);
  static final ValueNotifier<int> bestStreak = ValueNotifier<int>(0);
  static final ValueNotifier<int> chartVersion = ValueNotifier<int>(0);

  static Map<String, int> dailyMinutes = <String, int>{};
  static Map<String, int> taskMinutes = <String, int>{};

  static StreamSubscription<User?>? _authSubscription;
  static StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _statsSubscription;

  static bool _initialized = false;
  static String? _listeningUserId;

  static User? get _currentUser => _auth.currentUser;

  static DocumentReference<Map<String, dynamic>> _statsDocument(String userId) {
    return _firestore.collection('users').doc(userId).collection('appData').doc('stats');
  }

  static String _dateKey(DateTime date) {
    final String year = date.year.toString();
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String todayKey() => _dateKey(DateTime.now());

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _authSubscription?.cancel();

    _authSubscription = _auth.authStateChanges().listen(
      (User? user) async {
        if (user == null) {
          await _stopStatsListener();
          _resetMemory();
          return;
        }

        try {
          await _migrateLocalStatsIfNeeded(user.uid);
          await _startStatsListener(user.uid);
        } catch (error, stackTrace) {
          debugPrint('StatsStore başlatma hatası: $error');
          debugPrintStack(stackTrace: stackTrace);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('StatsStore auth dinleme hatası: $error');
        debugPrintStack(stackTrace: stackTrace);
      },
    );

    final User? user = _currentUser;
    if (user != null) {
      await _migrateLocalStatsIfNeeded(user.uid);
      await _startStatsListener(user.uid);
    }
  }

  static Future<void> _startStatsListener(String userId) async {
    if (_listeningUserId == userId && _statsSubscription != null) return;

    await _stopStatsListener();
    _listeningUserId = userId;

    _statsSubscription = _statsDocument(userId).snapshots().listen(
      (DocumentSnapshot<Map<String, dynamic>> snapshot) {
        if (!snapshot.exists) {
          _resetMemory();
          return;
        }

        _applySnapshotData(snapshot.data() ?? <String, dynamic>{});
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('İstatistikler alınırken hata oluştu: $error');
        debugPrintStack(stackTrace: stackTrace);
      },
    );
  }

  static Future<void> _stopStatsListener() async {
    await _statsSubscription?.cancel();
    _statsSubscription = null;
    _listeningUserId = null;
  }

  static void _applySnapshotData(Map<String, dynamic> data) {
    totalMinutes.value = _toInt(data['totalMinutes']);
    sessionCount.value = _toInt(data['sessionCount']);
    streak.value = _toInt(data['streak']);
    bestStreak.value = _toInt(data['bestStreak']);
    dailyMinutes = _toIntMap(data['dailyMinutes']);
    taskMinutes = _toIntMap(data['taskMinutes']);
    todayMinutes.value = dailyMinutes[todayKey()] ?? 0;
    chartVersion.value++;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static Map<String, int> _toIntMap(dynamic value) {
    if (value is! Map) return <String, int>{};

    final Map<String, int> result = <String, int>{};
    value.forEach((dynamic key, dynamic mapValue) {
      result[key.toString()] = _toInt(mapValue);
    });
    return result;
  }

  static void _resetMemory() {
    totalMinutes.value = 0;
    todayMinutes.value = 0;
    sessionCount.value = 0;
    streak.value = 0;
    bestStreak.value = 0;
    dailyMinutes = <String, int>{};
    taskMinutes = <String, int>{};
    chartVersion.value++;
  }

  static Future<void> _migrateLocalStatsIfNeeded(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String migrationKey = '$_migrationKeyPrefix$userId';

    if (prefs.getBool(migrationKey) == true) return;

    final DocumentReference<Map<String, dynamic>> document = _statsDocument(userId);
    final DocumentSnapshot<Map<String, dynamic>> existingSnapshot = await document.get();

    if (existingSnapshot.exists) {
      await prefs.setBool(migrationKey, true);
      return;
    }

    final int localTotalMinutes = prefs.getInt(_totalKey) ?? 0;
    final int localSessionCount = prefs.getInt(_sessionKey) ?? 0;
    final int localStreak = prefs.getInt(_streakKey) ?? 0;
    final int localBestStreak = prefs.getInt(_bestStreakKey) ?? 0;
    final String? localLastGoalDate = prefs.getString(_lastGoalDateKey);
    final Map<String, int> localDailyMinutes = _decodeStoredMap(prefs.getString(_dailyKey));
    final Map<String, int> localTaskMinutes = _decodeStoredMap(prefs.getString(_taskMinutesKey));

    final bool hasLocalData =
        localTotalMinutes > 0 ||
        localSessionCount > 0 ||
        localStreak > 0 ||
        localBestStreak > 0 ||
        localDailyMinutes.isNotEmpty ||
        localTaskMinutes.isNotEmpty;

    await document.set(<String, dynamic>{
      'totalMinutes': localTotalMinutes,
      'sessionCount': localSessionCount,
      'streak': localStreak,
      'bestStreak': localBestStreak,
      'dailyMinutes': localDailyMinutes,
      'taskMinutes': localTaskMinutes,
      'lastGoalDate': localLastGoalDate,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'migratedFromLocal': hasLocalData,
    });

    await prefs.setBool(migrationKey, true);
  }

  static Map<String, int> _decodeStoredMap(String? raw) {
    if (raw == null || raw.trim().isEmpty) return <String, int>{};

    try {
      return _toIntMap(jsonDecode(raw));
    } catch (_) {
      return <String, int>{};
    }
  }

  static User _requireUser() {
    final User? user = _currentUser;
    if (user == null) {
      throw StateError('İstatistik işlemi için kullanıcı giriş yapmış olmalı.');
    }
    return user;
  }

  static Future<void> addStudyMinutes(int minutes) async {
    if (minutes <= 0) return;

    final User user = _requireUser();
    final DocumentReference<Map<String, dynamic>> document = _statsDocument(user.uid);
    final String today = todayKey();
    final int goalMinutes = GoalStore.dailyGoalMinutes.value;

    await _firestore.runTransaction((Transaction transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await transaction.get(document);
      final Map<String, dynamic> data = snapshot.data() ?? <String, dynamic>{};

      final int oldTotal = _toInt(data['totalMinutes']);
      final int oldSessionCount = _toInt(data['sessionCount']);
      final int oldStreak = _toInt(data['streak']);
      final int oldBestStreak = _toInt(data['bestStreak']);
      final String? oldLastGoalDate = data['lastGoalDate']?.toString();
      final Map<String, int> oldDaily = _toIntMap(data['dailyMinutes']);
      final Map<String, int> oldTask = _toIntMap(data['taskMinutes']);

      oldDaily[today] = (oldDaily[today] ?? 0) + minutes;
      final int newTodayMinutes = oldDaily[today] ?? 0;

      int newStreak = oldStreak;
      int newBestStreak = oldBestStreak;
      String? newLastGoalDate = oldLastGoalDate;

      final String yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));

      if (oldLastGoalDate != null && oldLastGoalDate.isNotEmpty && oldLastGoalDate != today && oldLastGoalDate != yesterday) {
        newStreak = 0;
      }

      if (goalMinutes > 0 && newTodayMinutes >= goalMinutes && oldLastGoalDate != today) {
        newStreak = oldLastGoalDate == yesterday ? newStreak + 1 : 1;
        if (newStreak > newBestStreak) newBestStreak = newStreak;
        newLastGoalDate = today;
      }

      transaction.set(document, <String, dynamic>{
        'totalMinutes': oldTotal + minutes,
        'sessionCount': oldSessionCount + 1,
        'streak': newStreak,
        'bestStreak': newBestStreak,
        'dailyMinutes': oldDaily,
        'taskMinutes': oldTask,
        'lastGoalDate': newLastGoalDate,
        'updatedAt': FieldValue.serverTimestamp(),
        if (!snapshot.exists) 'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  static Future<void> removeStudyMinutes(int minutes) async {
    if (minutes <= 0) return;

    final User user = _requireUser();
    final DocumentReference<Map<String, dynamic>> document = _statsDocument(user.uid);
    final String today = todayKey();

    await _firestore.runTransaction((Transaction transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await transaction.get(document);
      final Map<String, dynamic> data = snapshot.data() ?? <String, dynamic>{};

      final Map<String, int> daily = _toIntMap(data['dailyMinutes']);
      daily[today] = ((daily[today] ?? 0) - minutes).clamp(0, 1 << 31).toInt();

      transaction.set(document, <String, dynamic>{
        'totalMinutes': (_toInt(data['totalMinutes']) - minutes).clamp(0, 1 << 31),
        'sessionCount': (_toInt(data['sessionCount']) - 1).clamp(0, 1 << 31),
        'dailyMinutes': daily,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  static Future<void> addTaskStudyMinutes(String title, int minutes) async {
    final String normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty || minutes <= 0) return;

    final User user = _requireUser();
    final DocumentReference<Map<String, dynamic>> document = _statsDocument(user.uid);

    await _firestore.runTransaction((Transaction transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await transaction.get(document);
      final Map<String, dynamic> data = snapshot.data() ?? <String, dynamic>{};
      final Map<String, int> tasks = _toIntMap(data['taskMinutes']);

      tasks[normalizedTitle] = (tasks[normalizedTitle] ?? 0) + minutes;

      transaction.set(document, <String, dynamic>{
        'taskMinutes': tasks,
        'updatedAt': FieldValue.serverTimestamp(),
        if (!snapshot.exists) 'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  static Future<void> removeTaskStudyMinutes(String title, int minutes) async {
    final String normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty || minutes <= 0) return;

    final User user = _requireUser();
    final DocumentReference<Map<String, dynamic>> document = _statsDocument(user.uid);

    await _firestore.runTransaction((Transaction transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await transaction.get(document);
      final Map<String, dynamic> data = snapshot.data() ?? <String, dynamic>{};
      final Map<String, int> tasks = _toIntMap(data['taskMinutes']);

      final int newValue = (tasks[normalizedTitle] ?? 0) - minutes;
      if (newValue <= 0) {
        tasks.remove(normalizedTitle);
      } else {
        tasks[normalizedTitle] = newValue;
      }

      transaction.set(document, <String, dynamic>{'taskMinutes': tasks, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    });
  }

  static List<double> getWeekChartData() {
    final DateTime now = DateTime.now();
    return List<double>.generate(7, (int index) {
      final DateTime day = now.subtract(Duration(days: 6 - index));
      return (dailyMinutes[_dateKey(day)] ?? 0) / 60.0;
    });
  }

  static List<String> getWeekLabels() {
    const List<String> labels = <String>['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    final DateTime now = DateTime.now();
    return List<String>.generate(7, (int index) {
      final DateTime day = now.subtract(Duration(days: 6 - index));
      return labels[day.weekday - 1];
    });
  }

  static List<double> getMonthChartData() {
    final DateTime now = DateTime.now();

    return List<double>.generate(4, (int index) {
      final int weeksAgo = 3 - index;
      final DateTime periodEnd = now.subtract(Duration(days: weeksAgo * 7));
      final DateTime periodStart = periodEnd.subtract(const Duration(days: 6));

      int total = 0;
      for (int i = 0; i < 7; i++) {
        final DateTime day = periodStart.add(Duration(days: i));
        total += dailyMinutes[_dateKey(day)] ?? 0;
      }

      return total / 60.0;
    });
  }

  static List<String> getMonthLabels() {
    return const <String>['4H önce', '3H önce', '2H önce', 'Bu hafta'];
  }

  static Future<void> refresh() async {
    final User user = _requireUser();
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _statsDocument(user.uid).get();

    if (!snapshot.exists) {
      _resetMemory();
      return;
    }

    _applySnapshotData(snapshot.data() ?? <String, dynamic>{});
  }

  static Future<void> dispose() async {
    await _stopStatsListener();
    await _authSubscription?.cancel();
    _authSubscription = null;
    _initialized = false;
  }
}
