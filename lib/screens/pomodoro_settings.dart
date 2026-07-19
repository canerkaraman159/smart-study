import 'package:flutter/material.dart';
import '../data/pomodoro_settings.dart';

class AppColors {
  static const background = Color(0xFFE0E6FF);
  static const primary = Color(0xFF5B8DEF);
  static const textPrimary = Color(0xFF2B2B2B);
  static const textSecondary = Color(0xFF6B6B6B);
}

class PomodoroSettingsScreen extends StatefulWidget {
  const PomodoroSettingsScreen({super.key});

  @override
  State<PomodoroSettingsScreen> createState() => _PomodoroSettingsScreenState();
}

class _PomodoroSettingsScreenState extends State<PomodoroSettingsScreen> {
  int work = PomodoroSettings.focusMinutes.value;
  int shortBreak = PomodoroSettings.shortBreak.value;
  int longBreak = PomodoroSettings.longBreak.value;
  int sessions = PomodoroSettings.sessions.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 8, 24, 80),
        child: SizedBox(
          height: 58,
          child: ElevatedButton(
            onPressed: () async {
              await PomodoroSettings.save(focus: work, short: shortBreak, long: longBreak, sessionCount: sessions);

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 8,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            ),
            child: const Text(
              "Kaydet",
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
          child: Column(
            children: [
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.arrow_back, size: 32, color: Colors.black),
                    ),
                  ),

                  const Expanded(
                    child: Center(
                      child: Text(
                        "Pomodoro Ayarları",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.4),
                      ),
                    ),
                  ),

                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 32),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: const Color(0xFFE7E7E7)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 12, offset: const Offset(0, 4))],
                ),

                child: Column(
                  children: [
                    _settingRow(
                      icon: Icons.timer_outlined,
                      label: "Çalışma Süresi",
                      value: work,
                      onMinus: () {
                        if (work > 1) {
                          setState(() => work -= 1);
                        }
                      },
                      onPlus: () {
                        setState(() => work += 1);
                      },
                    ),

                    _divider(),

                    _settingRow(
                      icon: Icons.free_breakfast_outlined,
                      label: "Kısa Mola",
                      value: shortBreak,
                      onMinus: () {
                        if (shortBreak > 1) {
                          setState(() => shortBreak -= 1);
                        }
                      },
                      onPlus: () {
                        setState(() => shortBreak += 1);
                      },
                    ),

                    _divider(),

                    _settingRow(
                      icon: Icons.nights_stay_outlined,
                      label: "Uzun Mola",
                      value: longBreak,
                      onMinus: () {
                        if (longBreak > 5) {
                          setState(() => longBreak -= 5);
                        }
                      },
                      onPlus: () {
                        setState(() => longBreak += 5);
                      },
                    ),

                    _divider(),

                    _settingRow(
                      icon: Icons.repeat_rounded,
                      label: "Seans Sayısı",
                      value: sessions,
                      onMinus: () {
                        if (sessions > 1) {
                          setState(() => sessions--);
                        }
                      },
                      onPlus: () {
                        setState(() => sessions++);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE7E7E7)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.lightbulb_outline, color: AppColors.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "25 / 5 Pomodoro düzeni odak için ideal kabul edilir.",
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(color: Color(0xFFEAEAEA), height: 1),
    );
  }

  Widget _settingRow({
    required IconData icon,
    required String label,
    required int value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text("dakika", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),

          _stepButton(icon: Icons.remove, onTap: onMinus),

          Container(
            width: 52,
            alignment: Alignment.center,
            child: Text(
              "$value",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),

          _stepButton(icon: Icons.add, onTap: onPlus),
        ],
      ),
    );
  }

  Widget _stepButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: const Color(0xFFF3F6FF), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
    );
  }
}
