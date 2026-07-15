import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_app/main.dart';
import '../core/theme/app_colors.dart';
import '../data/task_store.dart';
import '../data/stats_store.dart';
import '../data/goal_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentRoute = AppRoutes.home;

  Future<void> _openAddTask() async {
    final result = await Navigator.pushNamed(context, AppRoutes.addTask);

    if (result != null && result is Map) {
      final title = result['title'] ?? 'Yeni Görev';
      final iconData = _getTaskIconData(title);

      TaskStore.addTask({
        'title': title,
        'duration': result['duration'] ?? '30 dk',
        'iconCode': iconData['iconCode'],
        'iconBg': iconData['iconBg'],
        'iconColor': iconData['iconColor'],
        'isDone': false,
      });
    }
  }

  Map<String, int> _getTaskIconData(String title) {
    final lower = title.toLowerCase();

    if (lower.contains('mat') || lower.contains('math')) {
      return {'iconCode': Icons.calculate_rounded.codePoint, 'iconBg': 0xFFE7EDFF, 'iconColor': 0xFF5B8DEF};
    }

    if (lower.contains('ingilizce') || lower.contains('english') || lower.contains('dil')) {
      return {'iconCode': Icons.language_rounded.codePoint, 'iconBg': 0xFFF1E8FF, 'iconColor': 0xFF8B5CF6};
    }

    if (lower.contains('fen') || lower.contains('science') || lower.contains('fizik') || lower.contains('kimya') || lower.contains('biyoloji')) {
      return {'iconCode': Icons.science_rounded.codePoint, 'iconBg': 0xFFE2F8EC, 'iconColor': 0xFF45B87A};
    }

    if (lower.contains('tarih') || lower.contains('history')) {
      return {'iconCode': Icons.history_edu_rounded.codePoint, 'iconBg': 0xFFE2F8EC, 'iconColor': 0xFF45B87A};
    }

    if (lower.contains('sosyal')) {
      return {'iconCode': Icons.article_rounded.codePoint, 'iconBg': 0xFFFFE9D2, 'iconColor': 0xFFE58A3A};
    }

    return {'iconCode': Icons.menu_book_rounded.codePoint, 'iconBg': 0xFFEFF2F7, 'iconColor': 0xFF6B7280};
  }

  int _durationToMinutes(String duration) {
    final match = RegExp(r'\d+').firstMatch(duration);
    return int.tryParse(match?.group(0) ?? '') ?? 30;
  }

  void _toggleTaskDone(List<Map<String, dynamic>> currentTasks, int index) {
    setState(() {
      final updatedTasks = [...currentTasks];

      final wasDone = updatedTasks[index]['isDone'] == true;
      final minutes = _durationToMinutes(updatedTasks[index]['duration']);

      updatedTasks[index]['isDone'] = !wasDone;

      if (!wasDone) {
        StatsStore.addStudyMinutes(minutes);
      } else {
        StatsStore.removeStudyMinutes(minutes);
      }

      updatedTasks.sort((a, b) {
        if (a['isDone'] == b['isDone']) return 0;
        return a['isDone'] == true ? 1 : -1;
      });

      TaskStore.updateTasks(updatedTasks);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 22),
              _buildHeroCard(),
              const SizedBox(height: 18),
              _buildQuickRow(context),
              const SizedBox(height: 22),
              _buildTasksSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white),
                ),
                child: const Icon(Icons.menu_rounded, size: 25, color: AppColors.textPrimary),
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text('SMART STUDY', style: GoogleFonts.kaiseiOpti(fontSize: 15, letterSpacing: 2.2, color: const Color(0xFF7A7A86))),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          child: Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.78),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.person_outline_rounded, size: 27, color: Color(0xFF6B7280)),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    final today = StatsStore.todayMinutes.value;
    final goal = GoalStore.dailyGoalMinutes.value;
    final progress = goal == 0 ? 0.0 : (today / goal).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF5B8DEF), Color(0xFF6FA4FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF5B8DEF).withOpacity(0.32), blurRadius: 24, offset: const Offset(0, 12))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hoş geldin 👋',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, height: 1),
          ),
          const SizedBox(height: 8),
          Text(
            'Bugün hedeflerine odaklanalım.',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.82)),
          ),
          const SizedBox(height: 24),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$today',
                  style: const TextStyle(fontSize: 46, fontWeight: FontWeight.w900, color: Colors.white, height: 0.95),
                ),
                TextSpan(
                  text: ' / $goal dk',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.85)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: Colors.white.withOpacity(0.18),

              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${(progress * 100).toInt()}% tamamlandı",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.85)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _quickCard(
            title: 'Çalışma',
            value: '${StatsStore.totalMinutes.value} dk',
            icon: Icons.schedule_rounded,
            color: const Color(0xFF5B8DEF),
            onTap: () => Navigator.pushNamed(context, AppRoutes.stats),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickCard(title: 'Pomodoro', value: '${StatsStore.sessionCount.value}', icon: Icons.bolt_rounded, color: const Color(0xFF8B5CF6)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickCard(
            title: 'Seri',
            value: '${StatsStore.streak.value} gün',
            icon: Icons.local_fire_department_rounded,
            color: const Color(0xFFE58A3A),
          ),
        ),
      ],
    );
  }

  Widget _quickCard({required String title, required String value, required IconData icon, required Color color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 104,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _iconBox(icon: icon, bgColor: color.withOpacity(0.13), iconColor: color, size: 34),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksSection(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: TaskStore.tasks,
      builder: (context, tasks, _) {
        final doneCount = tasks.where((task) => task['isDone'] == true).length;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(17, 18, 17, 17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: const Color(0xFF5B8DEF).withOpacity(0.45), blurRadius: 30, offset: const Offset(0, 14))],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Bugünün Görevleri',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                  ),
                  GestureDetector(
                    onTap: _openAddTask,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
                      child: const Row(
                        children: [
                          Icon(Icons.add_rounded, size: 17, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Ekle',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    '$doneCount/${tasks.length} tamamlandı',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (tasks.isEmpty)
                _emptyTaskView()
              else
                for (int i = 0; i < tasks.length; i++) ...[
                  _taskItem(
                    context,
                    currentTasks: tasks,
                    index: i,
                    title: tasks[i]['title'],
                    duration: tasks[i]['duration'],
                    icon: IconData(tasks[i]['iconCode'] ?? Icons.menu_book_rounded.codePoint, fontFamily: 'MaterialIcons'),
                    iconBg: Color(tasks[i]['iconBg'] ?? 0xFFEFF2F7),
                    iconColor: Color(tasks[i]['iconColor'] ?? 0xFF6B7280),
                    isDone: tasks[i]['isDone'] == true,
                  ),
                  if (i != tasks.length - 1) const SizedBox(height: 11),
                ],
            ],
          ),
        );
      },
    );
  }

  Widget _taskItem(
    BuildContext context, {
    required List<Map<String, dynamic>> currentTasks,
    required int index,
    required String title,
    required String duration,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required bool isDone,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.taskDetail, arguments: {'title': title, 'duration': duration, 'subjectColor': iconColor});
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        decoration: BoxDecoration(color: const Color(0xFFF7F8FC), borderRadius: BorderRadius.circular(22)),
        child: Row(
          children: [
            _iconBox(icon: icon, bgColor: iconBg, iconColor: iconColor, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: isDone ? AppColors.textSecondary : AppColors.textPrimary,
                      decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                      decorationThickness: 2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _toggleTaskDone(currentTasks, index),
              child: Icon(
                isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                size: 27,
                color: isDone ? const Color(0xFF45B87A) : const Color(0xFFC7CDD8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyTaskView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: const Column(
        children: [
          Icon(Icons.add_task_rounded, size: 38, color: AppColors.textSecondary),
          SizedBox(height: 9),
          Text(
            'Bugün için görev yok',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          SizedBox(height: 4),
          Text(
            'Yeni görev ekleyerek başlayabilirsin.',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _iconBox({required IconData icon, required Color bgColor, required Color iconColor, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(size * 0.35)),
      child: Icon(icon, size: size * 0.52, color: iconColor),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF5F7FF),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SMART STUDY', style: GoogleFonts.kaiseiOpti(fontSize: 17, letterSpacing: 2, color: const Color(0xFF7A7A7A))),
              const SizedBox(height: 24),
              _drawerItem(title: 'Ana Sayfa', icon: Icons.home_rounded, route: AppRoutes.home, onTap: () => Navigator.pop(context)),
              _drawerItem(
                title: 'Pomodoro',
                icon: Icons.timer_rounded,
                route: AppRoutes.pomodoro,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.pomodoro);
                },
              ),
              _drawerItem(
                title: 'İstatistikler',
                icon: Icons.bar_chart_rounded,
                route: AppRoutes.stats,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.stats);
                },
              ),
              _drawerItem(
                title: 'Profil',
                icon: Icons.person_rounded,
                route: AppRoutes.profile,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.profile);
                },
              ),
              _drawerItem(
                title: 'Pomodoro Ayarları',
                icon: Icons.settings_rounded,
                route: AppRoutes.pomodoroSettings,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.pomodoroSettings);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem({required String title, required IconData icon, required String route, required VoidCallback onTap}) {
    final isActive = currentRoute == route;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        setState(() => currentRoute = route);
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.13) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isActive ? AppColors.primary.withOpacity(0.35) : const Color(0xFFE8E8E8)),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? AppColors.primary : AppColors.textSecondary, size: 23),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
