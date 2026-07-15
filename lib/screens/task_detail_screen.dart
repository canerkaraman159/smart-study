import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:study_app/data/stats_store.dart';
import '../core/theme/app_colors.dart';
import '../main.dart';
import '../data/stats_store.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE7E7E7);
  static const Color noteBoxColor = Color(0xFFE7F3FF);

  Timer? _timer;
  bool isRunning = false;

  late int totalSeconds;
  late int remainingSeconds;

  String title = 'Matematik Çalış';
  String duration = '30 dk';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final task = ModalRoute.of(context)?.settings.arguments as Map?;
    title = task?['title'] ?? 'Matematik Çalış';
    duration = task?['duration'] ?? '30 dk';

    final minutes = int.tryParse(duration.split(' ')[0]) ?? 30;

    totalSeconds = minutes * 60;
    remainingSeconds = totalSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (isRunning) return;

    setState(() {
      isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer.cancel();

        final studiedMinutes = (totalSeconds / 60).round();

        StatsStore.addTaskStudyMinutes(title, studiedMinutes);

        setState(() {
          isRunning = false;
        });
      }
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
      remainingSeconds = totalSeconds;
    });
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (totalSeconds == 0) return 0;
    return remainingSeconds / totalSeconds;
  }

  String get remainingText {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    if (minutes == 0 && seconds == 0) {
      return 'tamamlandı';
    }

    if (minutes == 0) {
      return '$seconds sn kaldı';
    }

    return '$minutes dk kaldı';
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: w * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: w * 0.045),

              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, size: w * 0.075, color: AppColors.textPrimary),
                  ),
                  SizedBox(width: w * 0.035),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: w * 0.054, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1),
                      ),
                      SizedBox(height: w * 0.012),
                      Text(
                        '$duration  Odak Seansı',
                        style: TextStyle(fontSize: w * 0.032, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: w * 0.085),

              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(w * 0.065, w * 0.075, w * 0.065, w * 0.055),
                decoration: _cardDecoration(w),
                child: Column(
                  children: [
                    Text(
                      _formatTime(remainingSeconds),
                      style: TextStyle(
                        fontSize: w * 0.145,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF070720),
                        letterSpacing: 1.3,
                        height: 1,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),

                    SizedBox(height: w * 0.06),

                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              minHeight: 6,
                              backgroundColor: const Color(0xFFE1E1E1),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                        ),
                        SizedBox(width: w * 0.025),
                        Text(
                          remainingText,
                          style: TextStyle(fontSize: w * 0.034, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),

                    SizedBox(height: w * 0.055),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: isRunning ? _pauseTimer : _startTimer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 5,
                                shadowColor: Colors.black26,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              ),
                              child: Text(
                                isRunning ? 'Duraklat' : 'Başlat',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: w * 0.03),
                        SizedBox(
                          width: 54,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _resetTimer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE9EEFF),
                              foregroundColor: AppColors.primary,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            child: const Icon(Icons.restart_alt_rounded),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: w * 0.04),

                    Container(width: double.infinity, height: 1, color: const Color(0xFFE5E5E5)),

                    SizedBox(height: w * 0.04),

                    Text(
                      remainingSeconds == 0 ? '✅ Görev süresi tamamlandı' : '⚡ Hedefe odaklan, devam et',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: w * 0.037, letterSpacing: 1.1, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              SizedBox(height: w * 0.08),

              _infoCard(
                w,
                title: 'Görev Detayı',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$title görevi üzerinde çalışılacak.',
                      style: TextStyle(fontSize: w * 0.039, color: AppColors.textSecondary, height: 1.35),
                    ),
                    SizedBox(height: w * 0.04),
                    Row(
                      children: [
                        _tagChip(w, icon: Icons.menu_book_outlined, iconColor: AppColors.primary, bgColor: const Color(0xFFE5E9FF), text: title),
                        SizedBox(width: w * 0.025),
                        _tagChip(w, icon: Icons.access_time_outlined, iconColor: AppColors.primary, bgColor: const Color(0xFFE5E9FF), text: duration),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: w * 0.075),

              _infoCard(
                w,
                title: 'Notlar',
                leadingIcon: Icons.subject_rounded,
                leadingIconColor: const Color(0xFF69B6FF),
                leadingBgColor: const Color(0xFFD9ECFF),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: w * 0.04),
                  decoration: BoxDecoration(color: noteBoxColor, borderRadius: BorderRadius.circular(w * 0.04)),
                  child: Text(
                    'Limit sorularını tekrar çöz',
                    style: TextStyle(fontSize: w * 0.038, color: AppColors.textSecondary, height: 1.25),
                  ),
                ),
              ),

              SizedBox(height: w * 0.075),

              _infoCard(
                w,
                title: 'Pomodoro ile çalış',
                titleIcon: '⏱',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'İstersen bu görevi Pomodoro tekniği ile de çalışabilirsin.',
                      style: TextStyle(fontSize: w * 0.038, color: AppColors.textSecondary, height: 1.35),
                    ),
                    SizedBox(height: w * 0.055),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.pomodoro);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text(
                          'Pomodoro Başlat',
                          style: TextStyle(fontSize: w * 0.047, fontWeight: FontWeight.w700, color: Colors.white, height: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: w * 0.08),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration(double w) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(w * 0.06),
      border: Border.all(color: borderColor, width: 1),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 12, offset: const Offset(0, 4))],
    );
  }

  Widget _infoCard(
    double w, {
    required String title,
    Widget? child,
    IconData? leadingIcon,
    Color? leadingIconColor,
    Color? leadingBgColor,
    String? titleIcon,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.045),
      decoration: _cardDecoration(w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leadingIcon != null)
            Row(
              children: [
                Container(
                  width: w * 0.09,
                  height: w * 0.09,
                  decoration: BoxDecoration(color: leadingBgColor ?? const Color(0xFFE5E5E5), borderRadius: BorderRadius.circular(w * 0.02)),
                  child: Icon(leadingIcon, color: leadingIconColor ?? AppColors.textPrimary, size: w * 0.06),
                ),
                SizedBox(width: w * 0.03),
                Text(
                  title,
                  style: TextStyle(fontSize: w * 0.046, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1),
                ),
              ],
            )
          else
            Row(
              children: [
                if (titleIcon != null) ...[Text(titleIcon, style: TextStyle(fontSize: w * 0.05)), SizedBox(width: w * 0.018)],
                Text(
                  title,
                  style: TextStyle(fontSize: w * 0.046, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1),
                ),
              ],
            ),

          SizedBox(height: w * 0.035),

          if (child != null) child,
        ],
      ),
    );
  }

  Widget _tagChip(double w, {required IconData icon, required Color iconColor, required Color bgColor, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.028, vertical: w * 0.018),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(w * 0.03)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: w * 0.04, color: iconColor),
          SizedBox(width: w * 0.012),
          Text(
            text,
            style: TextStyle(fontSize: w * 0.03, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
