import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../core/theme/app_colors.dart';
import '../data/pomodoro_settings.dart';
import '../data/stats_store.dart';

class PomodoroScreen extends StatefulWidget {
  final bool showBackButton;

  const PomodoroScreen({super.key, this.showBackButton = true});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  Timer? _timer;

  late int totalSeconds;
  late int remainingSeconds;

  bool isRunning = false;
  int currentSession = 1;
  bool isBreak = false;

  @override
  void initState() {
    super.initState();
    totalSeconds = PomodoroSettings.focusMinutes.value * 60;
    remainingSeconds = totalSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (isRunning) return;

    setState(() => isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        timer.cancel();

        setState(() {
          isRunning = false;

          if (!isBreak) {
            StatsStore.addStudyMinutes(PomodoroSettings.focusMinutes.value);

            isBreak = true;

            if (currentSession % PomodoroSettings.sessions.value == 0) {
              totalSeconds = PomodoroSettings.longBreak.value * 60;
            } else {
              totalSeconds = PomodoroSettings.shortBreak.value * 60;
            }

            remainingSeconds = totalSeconds;
          } else {
            isBreak = false;
            currentSession++;

            totalSeconds = PomodoroSettings.focusMinutes.value * 60;
            remainingSeconds = totalSeconds;
          }
        });
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();

    setState(() {
      isRunning = false;
      remainingSeconds = totalSeconds;
    });
  }

  String _formatTime() {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (totalSeconds == 0) return 0;
    return remainingSeconds / totalSeconds;
  }

  String get modeText {
    if (!isBreak) return 'Odak Modu';
    return currentSession % PomodoroSettings.sessions.value == 0 ? 'Uzun Mola' : 'Kısa Mola';
  }

  Color get activeColor {
    return isBreak ? const Color(0xFF45B87A) : AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(w * 0.055, w * 0.04, w * 0.055, w * 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(w),
              SizedBox(height: w * 0.065),
              _timerCard(w),
              SizedBox(height: w * 0.055),
              _sessionProgress(w),
              SizedBox(height: w * 0.055),
              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      w,
                      icon: Icons.track_changes_rounded,
                      title: 'Bugün',
                      value: '${StatsStore.todayMinutes.value} dk',
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: w * 0.035),
                  Expanded(
                    child: _infoCard(
                      w,
                      icon: Icons.local_fire_department_rounded,
                      title: 'Streak',
                      value: '${StatsStore.streak.value} gün',
                      color: const Color(0xFFE58A3A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(double w) {
    return Row(
      children: [
        if (widget.showBackButton) ...[
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.pop(context),
            child: Container(
              width: w * 0.11,
              height: w * 0.11,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.78),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white),
              ),
              child: Icon(Icons.arrow_back_rounded, size: w * 0.062, color: AppColors.textPrimary),
            ),
          ),
          SizedBox(width: w * 0.035),
        ],
        Expanded(
          child: Text(
            'Pomodoro',
            style: TextStyle(fontSize: w * 0.062, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.4),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pushNamed(context, '/pomodoro-settings'),
          child: Container(
            width: w * 0.11,
            height: w * 0.11,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.78),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white),
            ),
            child: Icon(Icons.tune_rounded, size: w * 0.058, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _timerCard(double w) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(w * 0.055, w * 0.055, w * 0.055, w * 0.055),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isBreak ? [const Color(0xFF45B87A), const Color(0xFF6BD39D)] : [const Color(0xFF5B8DEF), const Color(0xFF6FA4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(w * 0.08),
        boxShadow: [BoxShadow(color: activeColor.withOpacity(0.35), blurRadius: 28, offset: const Offset(0, 14))],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.019),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: Colors.white.withOpacity(0.28)),
            ),
            child: Text(
              modeText,
              style: TextStyle(color: Colors.white, fontSize: w * 0.034, fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(height: w * 0.055),
          CircularPercentIndicator(
            radius: w * 0.265,
            lineWidth: w * 0.032,
            percent: progress.clamp(0.0, 1.0),
            progressColor: Colors.white.withOpacity(0.92),
            backgroundColor: Colors.white.withOpacity(0.20),
            circularStrokeCap: CircularStrokeCap.round,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(),
                  style: TextStyle(fontSize: w * 0.098, fontWeight: FontWeight.w900, color: Colors.white, height: 1, letterSpacing: -0.8),
                ),
                SizedBox(height: w * 0.018),
                Text(
                  'Seans $currentSession/${PomodoroSettings.sessions.value}',
                  style: TextStyle(fontSize: w * 0.034, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.82)),
                ),
              ],
            ),
          ),
          SizedBox(height: w * 0.058),
          Row(
            children: [
              Expanded(
                child: _primaryControlButton(
                  w,
                  icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  label: isRunning ? 'Duraklat' : 'Başlat',
                  onTap: isRunning ? _pauseTimer : _startTimer,
                ),
              ),
              SizedBox(width: w * 0.035),
              _resetButton(w),
            ],
          ),
        ],
      ),
    );
  }

  Widget _primaryControlButton(double w, {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: w * 0.14,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(w * 0.045),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: activeColor, size: w * 0.07),
            SizedBox(width: w * 0.018),
            Text(
              label,
              style: TextStyle(color: activeColor, fontSize: w * 0.043, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resetButton(double w) {
    return GestureDetector(
      onTap: _resetTimer,
      child: Container(
        width: w * 0.14,
        height: w * 0.14,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.20),
          borderRadius: BorderRadius.circular(w * 0.045),
          border: Border.all(color: Colors.white.withOpacity(0.34)),
        ),
        child: Icon(Icons.restart_alt_rounded, size: w * 0.066, color: Colors.white.withOpacity(0.92)),
      ),
    );
  }

  Widget _sessionProgress(double w) {
    final total = PomodoroSettings.sessions.value;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(w * 0.045, w * 0.045, w * 0.045, w * 0.045),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.055),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.065), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seans İlerlemesi',
            style: TextStyle(fontSize: w * 0.041, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.2),
          ),
          SizedBox(height: w * 0.035),
          Row(
            children: List.generate(total, (index) {
              final active = index + 1 <= currentSession;

              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: w * 0.025,
                  margin: EdgeInsets.only(right: index == total - 1 ? 0 : w * 0.02),
                  decoration: BoxDecoration(color: active ? activeColor : const Color(0xFFE7EBF8), borderRadius: BorderRadius.circular(99)),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(double w, {required IconData icon, required String title, required String value, required Color color}) {
    return Container(
      height: w * 0.225,
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.035),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.052),
        boxShadow: [BoxShadow(color: color.withOpacity(0.12), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            width: w * 0.095,
            height: w * 0.095,
            decoration: BoxDecoration(color: color.withOpacity(0.13), borderRadius: BorderRadius.circular(w * 0.032)),
            child: Icon(icon, size: w * 0.052, color: color),
          ),
          SizedBox(width: w * 0.028),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: w * 0.031, color: AppColors.textSecondary, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: w * 0.012),
                Text(
                  value,
                  style: TextStyle(fontSize: w * 0.043, color: AppColors.textPrimary, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
