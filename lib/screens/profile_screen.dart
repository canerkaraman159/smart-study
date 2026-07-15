import 'package:flutter/material.dart';
import 'package:study_app/main.dart';

import '../widgets/delete_confirmation_dialog.dart';
import '../data/task_store.dart';
import '../data/goal_store.dart';

class AppColors {
  static const background = Color(0xFFE0E6FF);
  static const cardBackground = Color(0xFFD2DAFB);
  static const primary = Color(0xFF5B8DEF);
  static const textPrimary = Color(0xFF2B2B2B);
  static const textSecondary = Color(0xFF6B6B6B);
}

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  bool notificationsEnabled = false;

  void _deleteCompletedTasks() {
    TaskStore.deleteCompletedTasks();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tamamlanan görevler silindi")));
  }

  Future<void> _decreaseGoal() async {
    if (GoalStore.dailyGoalMinutes.value > 30) {
      await GoalStore.saveDailyGoal(GoalStore.dailyGoalMinutes.value - 30);
      setState(() {});
    }
  }

  Future<void> _increaseGoal() async {
    await GoalStore.saveDailyGoal(GoalStore.dailyGoalMinutes.value + 30);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SizedBox(
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.arrow_back, size: 42, color: Colors.black),
                        ),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'Profil & Ayarlar',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black, height: 1.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 18),
                      const _ProfileHeader(),
                      const SizedBox(height: 16),
                      const _StatsCard(),
                      const SizedBox(height: 18),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Column(
                            children: [
                              _MenuSwitchRow(
                                title: 'Bildirimler',
                                value: notificationsEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    notificationsEnabled = value;
                                  });
                                },
                              ),
                              const _MenuDivider(),

                              _GoalSettingRow(value: GoalStore.dailyGoalMinutes.value, onMinus: _decreaseGoal, onPlus: _increaseGoal),
                              const _MenuDivider(),

                              _MenuArrowRow(
                                icon: Icons.access_time_rounded,
                                title: 'Pomodoro Ayarları',
                                onTap: () {
                                  Navigator.pushNamed(context, AppRoutes.pomodoroSettings);
                                },
                              ),
                              const _MenuDivider(),

                              _MenuArrowRow(
                                icon: Icons.delete_outline_rounded,
                                title: 'Tamamlanan görevleri sil',
                                onTap: () {
                                  showDeleteTasksDialog(context, _deleteCompletedTasks);
                                },
                              ),
                              const _MenuDivider(),

                              _MenuArrowRow(
                                icon: Icons.info_outline_rounded,
                                title: 'Bize Sorununuzu bildirin',
                                onTap: () {
                                  Navigator.pushNamed(context, AppRoutes.reportIssue);
                                },
                              ),
                              const _MenuDivider(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 183,
      child: Column(
        children: [
          _Avatar(),
          SizedBox(height: 14),
          Text(
            'Caner Karaman',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black, height: 1.0),
          ),
          SizedBox(height: 8),
          Text(
            'canerkaraman159@gmail.com',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9A9A9A), height: 1.0),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 105,
      height: 105,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFD3D3D3),
        border: Border.all(color: const Color(0xFFF1F1F1), width: 4),
      ),
      child: Center(
        child: SizedBox(width: 70, height: 70, child: CustomPaint(painter: _AvatarPainter())),
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = const Color(0xFF676767)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final headCenter = Offset(size.width / 2, size.height * 0.28);
    final headRadius = size.width * 0.17;
    canvas.drawCircle(headCenter, headRadius, strokePaint);

    final bodyRect = Rect.fromCenter(center: Offset(size.width / 2, size.height * 0.95), width: size.width * 0.95, height: size.height * 0.95);

    canvas.drawArc(bodyRect, 3.82, 1.78, false, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StatsCard extends StatelessWidget {
  const _StatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 129,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE3E3E3), width: 1.2),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: _StatItem(icon: Icons.check_circle_outline_rounded, iconColor: Color(0xFF31B44B), value: '45', label: 'Tamamlandı'),
            ),
            _StatDivider(),
            Expanded(
              child: _StatItem(icon: Icons.access_time_rounded, iconColor: Colors.black, value: '128 sa', label: 'Toplam Zaman'),
            ),
            _StatDivider(),
            Expanded(
              child: _StatItem(icon: Icons.school_rounded, iconColor: Color(0xFF8A8A8A), value: '8', label: 'Toplam Kurs'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatItem({required this.icon, required this.iconColor, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 40, color: iconColor),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 23, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.0),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w400, color: Color(0xFF7D7D7D), height: 1.0),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1.2, height: 86, color: const Color(0xFFD7D7D7));
  }
}

class _MenuSwitchRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _MenuSwitchRow({required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Row(
        children: [
          const SizedBox(
            width: 36,
            height: 40,
            child: Center(child: Icon(Icons.notifications_none_rounded, size: 36, color: Color(0xFF7C7C7C))),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black, height: 1.0),
            ),
          ),
          _CustomSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _GoalSettingRow extends StatelessWidget {
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _GoalSettingRow({required this.value, required this.onMinus, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        children: [
          const SizedBox(
            width: 36,
            height: 40,
            child: Center(child: Icon(Icons.flag_outlined, size: 34, color: Color(0xFF7C7C7C))),
          ),
          const SizedBox(width: 24),
          const Expanded(
            child: Text(
              'Günlük Hedef',
              style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black, height: 1.0),
            ),
          ),
          _GoalButton(icon: Icons.remove, onTap: onMinus),
          SizedBox(
            width: 76,
            child: Text(
              '$value dk',
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
          _GoalButton(icon: Icons.add, onTap: onPlus),
        ],
      ),
    );
  }
}

class _GoalButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GoalButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(color: const Color(0xFFF3F6FF), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}

class _MenuArrowRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _MenuArrowRow({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 54,
        child: Row(
          children: [
            SizedBox(
              width: 36,
              height: 40,
              child: Center(child: Icon(icon, size: 36, color: const Color(0xFF7C7C7C))),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black, height: 1.0),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 40, color: Color(0xFF7C7C7C)),
          ],
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return Container(margin: const EdgeInsets.symmetric(vertical: 2), height: 1.2, color: const Color(0xFFBDBDBD));
  }
}

class _CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CustomSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 53,
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(color: const Color(0xFFA3A3A3), borderRadius: BorderRadius.circular(18)),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
