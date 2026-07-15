import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme/app_colors.dart';
import '../data/stats_store.dart';
import '../data/task_store.dart';
import '../data/goal_store.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String selectedRange = 'Bu Hafta';

  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE8E8E8);

  int _durationToMinutes(String duration) {
    final match = RegExp(r'\d+').firstMatch(duration);
    return int.tryParse(match?.group(0) ?? '') ?? 30;
  }

  String _formatMinutes(int total) {
    final h = total ~/ 60;
    final m = total % 60;
    return '${h} sa ${m} dk';
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(w * 0.06, w * 0.04, w * 0.06, w * 0.12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(w),
              SizedBox(height: w * 0.08),
              _topCard(w),
              SizedBox(height: w * 0.075),
              _goalProgressCard(w),
              SizedBox(height: w * 0.075),
              _chartCard(w),
              SizedBox(height: w * 0.075),
              _streakCard(w),
              SizedBox(height: w * 0.075),
              _taskFocusCard(w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(double w) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, size: w * 0.07, color: AppColors.textPrimary),
        ),
        SizedBox(width: w * 0.03),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "İstatistikler",
              style: TextStyle(fontSize: w * 0.055, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1),
            ),
            SizedBox(height: w * 0.01),
            Text(
              "Odak performansın",
              style: TextStyle(fontSize: w * 0.034, color: AppColors.textSecondary, fontWeight: FontWeight.w400, height: 1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _topCard(double w) {
    return ValueListenableBuilder<int>(
      valueListenable: StatsStore.totalMinutes,
      builder: (context, totalMinutes, _) {
        return ValueListenableBuilder<int>(
          valueListenable: StatsStore.sessionCount,
          builder: (context, sessionCount, _) {
            return ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: TaskStore.tasks,
              builder: (context, tasks, _) {
                final completedTaskCount = tasks.where((task) => task['isDone'] == true).length;

                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.055, w * 0.04, w * 0.05),
                  decoration: BoxDecoration(color: const Color(0xFFAFC9FA), borderRadius: BorderRadius.circular(w * 0.045)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.access_time_outlined, size: w * 0.062, color: Colors.black),
                          SizedBox(width: w * 0.02),
                          Text(
                            _formatMinutes(totalMinutes),
                            style: TextStyle(fontSize: w * 0.06, fontWeight: FontWeight.w500, color: Colors.black, height: 1),
                          ),
                        ],
                      ),
                      SizedBox(height: w * 0.055),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: w * 0.045, vertical: w * 0.04),
                        decoration: BoxDecoration(color: const Color(0xFFEAF2FF).withOpacity(0.75), borderRadius: BorderRadius.circular(w * 0.035)),
                        child: Row(
                          children: [
                            Expanded(
                              child: _smallSummary(w, icon: "🔥", title: "$sessionCount pomodoro", subtitle: "tamamlandı"),
                            ),
                            Container(width: 1, height: w * 0.09, color: const Color(0xFFD3DCEA)),
                            Expanded(
                              child: _smallSummary(
                                w,
                                materialIcon: Icons.check_box_rounded,
                                iconColor: AppColors.primary,
                                title: "$completedTaskCount görev",
                                subtitle: "bitirildi",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _goalProgressCard(double w) {
    return ValueListenableBuilder<int>(
      valueListenable: StatsStore.todayMinutes,
      builder: (context, todayMinutes, _) {
        return ValueListenableBuilder<int>(
          valueListenable: GoalStore.dailyGoalMinutes,
          builder: (context, goalMinutes, _) {
            final progress = goalMinutes == 0 ? 0.0 : todayMinutes / goalMinutes;
            final percent = (progress.clamp(0.0, 1.0) * 100).toInt();

            return Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(w * 0.045, w * 0.045, w * 0.045, w * 0.045),
              decoration: _cardDecoration(w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("🎯", style: TextStyle(fontSize: w * 0.052)),
                      SizedBox(width: w * 0.025),
                      Expanded(
                        child: Text(
                          "Günlük Hedef",
                          style: TextStyle(fontSize: w * 0.043, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                      ),
                      Text(
                        "%$percent",
                        style: TextStyle(fontSize: w * 0.038, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ],
                  ),
                  SizedBox(height: w * 0.035),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: w * 0.025,
                      backgroundColor: const Color(0xFFE4E8F8),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  SizedBox(height: w * 0.03),
                  Text(
                    "$todayMinutes / $goalMinutes dk tamamlandı",
                    style: TextStyle(fontSize: w * 0.032, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _chartCard(double w) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.05, w * 0.04, w * 0.045),
      decoration: _cardDecoration(w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedRange,
                style: TextStyle(fontSize: w * 0.048, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() => selectedRange = value);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'Bu Hafta', child: Text('Bu Hafta')),
                  PopupMenuItem(value: 'Bu Ay', child: Text('Bu Ay')),
                ],
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: w * 0.014),
                  decoration: BoxDecoration(color: const Color(0xFFF1F1F1), borderRadius: BorderRadius.circular(w * 0.04)),
                  child: Row(
                    children: [
                      Text(
                        selectedRange,
                        style: TextStyle(fontSize: w * 0.033, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(width: w * 0.008),
                      Icon(Icons.keyboard_arrow_down, size: w * 0.045, color: AppColors.textPrimary),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: w * 0.06),
          ValueListenableBuilder<int>(
            valueListenable: StatsStore.chartVersion,
            builder: (context, _, __) {
              final chartData = selectedRange == 'Bu Hafta' ? StatsStore.getWeekChartData() : StatsStore.getMonthChartData();

              final labels = selectedRange == 'Bu Hafta' ? StatsStore.getWeekLabels() : StatsStore.getMonthLabels();

              final maxValue = chartData.isEmpty ? 0.0 : chartData.reduce((a, b) => a > b ? a : b);
              final maxY = maxValue == 0 ? 1.0 : maxValue * 1.15;
              final todayIndex = DateTime.now().weekday - 1;
              final hasData = chartData.any((value) => value > 0);

              if (!hasData) {
                return SizedBox(
                  height: w * 0.42,
                  child: Center(
                    child: Text(
                      "Henüz veri yok",
                      style: TextStyle(fontSize: w * 0.035, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: w * 0.42,
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    minY: 0,
                    alignment: BarChartAlignment.spaceAround,
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: false),
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: w * 0.09,
                          interval: maxY <= 2 ? 0.5 : 1,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const SizedBox();

                            return Padding(
                              padding: EdgeInsets.only(right: w * 0.01),
                              child: Text(
                                "${value.toStringAsFixed(value < 1 ? 1 : 0)} sa",
                                style: TextStyle(fontSize: w * 0.026, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: w * 0.08,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();

                            if (index < 0 || index >= labels.length) {
                              return const SizedBox();
                            }

                            return Padding(
                              padding: EdgeInsets.only(top: w * 0.015),
                              child: Text(
                                labels[index],
                                style: TextStyle(fontSize: w * 0.033, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(chartData.length, (i) {
                      final isSelected = selectedRange == 'Bu Hafta' ? i == todayIndex : i == chartData.length - 1;

                      return _bar(i, chartData[i], selected: isSelected);
                    }),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _streakCard(double w) {
    return ValueListenableBuilder<int>(
      valueListenable: StatsStore.streak,
      builder: (context, streak, _) {
        return ValueListenableBuilder<int>(
          valueListenable: StatsStore.bestStreak,
          builder: (context, bestStreak, _) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: w * 0.045, vertical: w * 0.045),
              decoration: _cardDecoration(w),
              child: Row(
                children: [
                  Text("🔥", style: TextStyle(fontSize: w * 0.055)),
                  SizedBox(width: w * 0.025),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$streak gün üst üste odaklandın",
                          style: TextStyle(fontSize: w * 0.043, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.1),
                        ),
                        SizedBox(height: w * 0.012),
                        Text(
                          streak == 0 ? "Günlük hedefi tamamlayınca seri başlar" : "Rekorun: $bestStreak gün",
                          style: TextStyle(fontSize: w * 0.03, color: AppColors.textSecondary, fontWeight: FontWeight.w400, height: 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _taskFocusCard(double w) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: TaskStore.tasks,
      builder: (context, tasks, _) {
        final sortedTasks = [...tasks];

        sortedTasks.sort((a, b) {
          final aMin = _durationToMinutes(a['duration'] ?? '30 dk');
          final bMin = _durationToMinutes(b['duration'] ?? '30 dk');
          return bMin.compareTo(aMin);
        });

        final visibleTasks = sortedTasks.take(4).toList();

        final maxDuration = visibleTasks.isEmpty
            ? 1
            : visibleTasks.map((task) => StatsStore.taskMinutes[task['title']] ?? 0).reduce((a, b) => a > b ? a : b);

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(w * 0.045, w * 0.055, w * 0.045, w * 0.06),
          decoration: _cardDecoration(w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("🏅", style: TextStyle(fontSize: w * 0.052)),
                  SizedBox(width: w * 0.025),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Görev Bazlı Odak Süresi",
                          style: TextStyle(fontSize: w * 0.041, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1),
                        ),
                        SizedBox(height: w * 0.012),
                        Text(
                          "Bu hafta en çok odaklandığın görevler",
                          style: TextStyle(fontSize: w * 0.029, color: AppColors.textSecondary, fontWeight: FontWeight.w400, height: 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: w * 0.045),
              Container(height: 1, color: const Color(0xFFEDEDED)),
              SizedBox(height: w * 0.045),
              if (visibleTasks.isEmpty)
                Text(
                  "Henüz görev yok.",
                  style: TextStyle(fontSize: w * 0.035, color: AppColors.textSecondary),
                )
              else
                for (int i = 0; i < visibleTasks.length; i++) ...[
                  _taskFocusRow(
                    w,
                    icon: IconData(visibleTasks[i]['iconCode'] ?? Icons.book_outlined.codePoint, fontFamily: 'MaterialIcons'),
                    title: visibleTasks[i]['title'] ?? 'Yeni Görev',
                    duration: '${StatsStore.taskMinutes[visibleTasks[i]['title']] ?? 0} dk',
                    progress: (StatsStore.taskMinutes[visibleTasks[i]['title']] ?? 0) / maxDuration,
                    iconBg: Color(visibleTasks[i]['iconBg'] ?? 0xFFE5F4E8),
                    iconColor: Color(visibleTasks[i]['iconColor'] ?? 0xFF69C26F),
                  ),
                  if (i != visibleTasks.length - 1) SizedBox(height: w * 0.055),
                ],
            ],
          ),
        );
      },
    );
  }

  BoxDecoration _cardDecoration(double w) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(w * 0.045),
      border: Border.all(color: borderColor, width: 1),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
    );
  }

  Widget _smallSummary(double w, {String? icon, IconData? materialIcon, Color? iconColor, required String title, required String subtitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null)
          Text(icon, style: TextStyle(fontSize: w * 0.045))
        else
          Icon(materialIcon, color: iconColor ?? AppColors.primary, size: w * 0.05),
        SizedBox(width: w * 0.02),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: w * 0.037, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1),
            ),
            SizedBox(height: w * 0.01),
            Text(
              subtitle,
              style: TextStyle(fontSize: w * 0.026, color: AppColors.textSecondary, fontWeight: FontWeight.w400, height: 1),
            ),
          ],
        ),
      ],
    );
  }

  static BarChartGroupData _bar(int x, double y, {bool selected = false}) {
    return BarChartGroupData(
      x: x,
      barsSpace: 0,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 28,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
          color: selected ? AppColors.primary : const Color(0xFFC7DCFA).withOpacity(0.6),
        ),
      ],
    );
  }

  Widget _taskFocusRow(
    double w, {
    required IconData icon,
    required String title,
    required String duration,
    required double progress,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: w * 0.075,
              height: w * 0.075,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(w * 0.018)),
              child: Icon(icon, size: w * 0.045, color: iconColor),
            ),
            SizedBox(width: w * 0.03),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: w * 0.034, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1),
              ),
            ),
            Text(
              duration,
              style: TextStyle(fontSize: w * 0.029, color: AppColors.textSecondary, fontWeight: FontWeight.w500, height: 1),
            ),
          ],
        ),
        SizedBox(height: w * 0.024),
        ClipRRect(
          borderRadius: BorderRadius.circular(w * 0.018),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: w * 0.017,
            backgroundColor: const Color(0xFFE0E0E0),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
