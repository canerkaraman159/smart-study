import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../data/stats_store.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  Timer? _timer;

  bool _isInitialized = false;
  bool isRunning = false;
  bool isCompleted = false;

  late int totalSeconds;
  late int remainingSeconds;

  String title = 'Görev';
  String description = '';
  String duration = '30 dk';
  String category = 'Genel';

  Color subjectColor = AppColors.primary;
  IconData subjectIcon = Icons.assignment_rounded;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInitialized) return;
    _isInitialized = true;

    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is Map) {
      title = arguments['title']?.toString() ?? 'Görev';
      description = arguments['description']?.toString() ?? '';
      duration = arguments['duration']?.toString() ?? '30 dk';
      category = _categoryTitle(arguments['category']?.toString() ?? 'general');

      final rawColor = arguments['subjectColor'];
      if (rawColor is Color) {
        subjectColor = rawColor;
      } else if (rawColor is int) {
        subjectColor = Color(rawColor);
      }

      final rawIconCode = arguments['iconCode'];
      if (rawIconCode is int) {
        subjectIcon = IconData(rawIconCode, fontFamily: 'MaterialIcons');
      }
    }

    final minutes = int.tryParse(RegExp(r'\d+').firstMatch(duration)?.group(0) ?? '') ?? 30;

    totalSeconds = minutes * 60;
    remainingSeconds = totalSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _categoryTitle(String value) {
    switch (value) {
      case 'math':
        return 'Matematik';
      case 'science':
        return 'Fen';
      case 'language':
        return 'Dil';
      case 'software':
        return 'Yazılım';
      case 'reading':
        return 'Okuma';
      default:
        return 'Genel';
    }
  }

  void _startTimer() {
    if (isRunning || isCompleted) return;

    setState(() {
      isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
        return;
      }

      timer.cancel();

      final studiedMinutes = (totalSeconds / 60).round();
      StatsStore.addTaskStudyMinutes(title, studiedMinutes);

      setState(() {
        isRunning = false;
        isCompleted = true;
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();

    setState(() {
      isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();

    setState(() {
      isRunning = false;
      isCompleted = false;
      remainingSeconds = totalSeconds;
    });
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours == 0) {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (totalSeconds == 0) return 0;
    return 1 - (remainingSeconds / totalSeconds);
  }

  String get remainingText {
    if (isCompleted || remainingSeconds == 0) {
      return 'Görev tamamlandı';
    }

    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    if (minutes == 0) {
      return '$seconds sn kaldı';
    }

    return '$minutes dk kaldı';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 22),
              _buildTimerCard(),
              const SizedBox(height: 18),
              _buildTaskInfoCard(),
              const SizedBox(height: 18),
              _buildStatusCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.82),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 24),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(color: subjectColor.withOpacity(0.14), borderRadius: BorderRadius.circular(15)),
          child: Icon(subjectIcon, color: subjectColor, size: 23),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.textPrimary, height: 1.05, letterSpacing: -0.25),
              ),
              const SizedBox(height: 5),
              Text(
                '$duration • $category',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE7EAF2)),
        boxShadow: [BoxShadow(color: const Color(0xFF5B8DEF).withOpacity(0.13), blurRadius: 20, offset: const Offset(0, 9))],
      ),
      child: Column(
        children: [
          Text(
            _formatTime(remainingSeconds),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Color(0xFF17172A),
              height: 1,
              letterSpacing: 0.5,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 9,
              backgroundColor: const Color(0xFFE8ECF7),
              valueColor: AlwaysStoppedAnimation<Color>(subjectColor),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              remainingText,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isCompleted ? const Color(0xFF45B87A) : AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: isCompleted ? null : (isRunning ? _pauseTimer : _startTimer),
                    icon: Icon(isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 22),
                    label: Text(isRunning ? 'Duraklat' : 'Başlat', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: subjectColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: subjectColor.withOpacity(0.45),
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 52,
                height: 50,
                child: ElevatedButton(
                  onPressed: _resetTimer,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    backgroundColor: subjectColor.withOpacity(0.12),
                    foregroundColor: subjectColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                  ),
                  child: const Icon(Icons.restart_alt_rounded, size: 23),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskInfoCard() {
    final hasDescription = description.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Görev Bilgileri',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          _infoRow(icon: subjectIcon, label: 'Görev', value: title, color: subjectColor),
          const SizedBox(height: 13),
          _infoRow(icon: Icons.schedule_rounded, label: 'Süre', value: duration, color: AppColors.primary),
          const SizedBox(height: 13),
          _infoRow(icon: Icons.category_rounded, label: 'Kategori', value: category, color: const Color(0xFF8B5CF6)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF5F7FC), borderRadius: BorderRadius.circular(17)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.notes_rounded, size: 19, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasDescription ? description : 'Bu görev için açıklama eklenmemiş.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: hasDescription ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFE7F8EF) : const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isCompleted ? const Color(0xFFC9EFD9) : const Color(0xFFD7E4FF)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted ? const Color(0xFFD1F2DF) : const Color(0xFFDCE8FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isCompleted ? Icons.check_rounded : Icons.insights_rounded,
              color: isCompleted ? const Color(0xFF45B87A) : AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isCompleted ? '$duration görev bazlı odak sürene eklendi.' : 'Sayaç tamamlandığında çalışma süren istatistiklere eklenecek.',
              style: const TextStyle(fontSize: 13, height: 1.35, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({required IconData icon, required String label, required String value, required Color color}) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: color.withOpacity(0.13), borderRadius: BorderRadius.circular(13)),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 66,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE7EAF2)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 5))],
    );
  }
}
