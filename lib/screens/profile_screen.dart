import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_app/main.dart';

import '../core/theme/app_colors.dart';
import '../data/stats_store.dart';
import '../data/task_store.dart';
import '../widgets/delete_confirmation_dialog.dart';

class ProfileSettingsPage extends StatefulWidget {
  final bool showBackButton;

  const ProfileSettingsPage({super.key, this.showBackButton = true});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  bool notificationsEnabled = false;

  void _deleteCompletedTasks() {
    TaskStore.deleteCompletedTasks();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tamamlanan görevler silindi')));
  }

  Future<void> _openEditProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage('Profilini düzenlemek için giriş yapmalısın.');
      return;
    }

    Map<String, dynamic> data = <String, dynamic>{};
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      data = snapshot.data() ?? <String, dynamic>{};
    } catch (_) {
      // Firestore okunamazsa Auth ve yerel hedef değerleriyle form yine açılır.
    }

    if (!mounted) return;

    final nameController = TextEditingController(text: (data['displayName'] ?? user.displayName ?? '').toString());
    final usernameController = TextEditingController(text: (data['username'] ?? '').toString());
    bool isSaving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> save() async {
              final displayName = nameController.text.trim();
              final username = usernameController.text.trim();
              if (displayName.length < 2) {
                _showMessage('Ad soyad en az 2 karakter olmalı.');
                return;
              }
              setSheetState(() => isSaving = true);

              try {
                await user.updateDisplayName(displayName);
                await FirebaseFirestore.instance.collection('users').doc(user.uid).set(<String, dynamic>{
                  'displayName': displayName,
                  'username': username,
                  'email': user.email,
                  'updatedAt': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));
                await user.reload();

                if (!mounted) return;
                Navigator.of(sheetContext).pop();
                setState(() {});
                _showMessage('Profil güncellendi.');
              } on FirebaseException catch (error) {
                _showMessage(error.message ?? 'Profil güncellenemedi.');
              } catch (_) {
                _showMessage('Profil güncellenirken bir hata oluştu.');
              } finally {
                if (sheetContext.mounted) {
                  setSheetState(() => isSaving = false);
                }
              }
            }

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 42,
                            height: 5,
                            decoration: BoxDecoration(color: const Color(0xFFD8DCE7), borderRadius: BorderRadius.circular(99)),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Profili düzenle',
                          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 18),
                        _ProfileTextField(
                          controller: nameController,
                          label: 'Ad Soyad',
                          icon: Icons.person_outline_rounded,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 13),
                        _ProfileTextField(
                          controller: usernameController,
                          label: 'Kullanıcı adı (isteğe bağlı)',
                          icon: Icons.alternate_email_rounded,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            onPressed: isSaving ? null : save,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: isSaving
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                                : const Text('Kaydet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    usernameController.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
              _buildHeader(context),
              const SizedBox(height: 22),
              _ProfileCard(onEdit: _openEditProfile),
              const SizedBox(height: 16),
              const _StatsSection(),
              const SizedBox(height: 16),
              _buildSettingsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        if (widget.showBackButton) ...[
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
              child: const Icon(Icons.arrow_back_rounded, size: 24, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Text(
          'Profil & Ayarlar',
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.75, height: 1),
        ),
      ],
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _SettingsArrowRow(
            icon: Icons.edit_rounded,
            title: 'Profili düzenle',
            subtitle: 'Adını ve kullanıcı adını değiştir',
            iconColor: AppColors.primary,
            iconBackground: const Color(0xFFE7EDFF),
            onTap: _openEditProfile,
          ),
          const _SectionDivider(),
          _SettingsSwitchRow(
            icon: Icons.notifications_none_rounded,
            title: 'Bildirimler',
            subtitle: 'Hatırlatmaları aç veya kapat',
            value: notificationsEnabled,
            onChanged: (value) => setState(() => notificationsEnabled = value),
          ),
          const _SectionDivider(),
          _SettingsArrowRow(
            icon: Icons.delete_outline_rounded,
            title: 'Tamamlanan görevleri sil',
            subtitle: 'Bitirdiğin görevleri temizle',
            iconColor: const Color(0xFFEF4444),
            iconBackground: const Color(0xFFFFE8E8),
            onTap: () => showDeleteTasksDialog(context, _deleteCompletedTasks),
          ),
          const _SectionDivider(),
          _SettingsArrowRow(
            icon: Icons.info_outline_rounded,
            title: 'Sorun bildir',
            subtitle: 'Geri bildirim veya hata gönder',
            iconColor: const Color(0xFF8B5CF6),
            iconBackground: const Color(0xFFF0E8FF),
            onTap: () => Navigator.pushNamed(context, AppRoutes.reportIssue),
          ),
        ],
      ),
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

class _ProfileCard extends StatelessWidget {
  final VoidCallback onEdit;

  const _ProfileCard({required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? <String, dynamic>{};
        final displayName = (data['displayName'] ?? user.displayName ?? 'Smart Study Kullanıcısı').toString().trim();
        final username = (data['username'] ?? '').toString().trim();
        final email = user.email ?? '';
        final initial = displayName.isNotEmpty ? displayName.characters.first.toUpperCase() : 'S';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF5B8DEF), Color(0xFF6FA4FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [BoxShadow(color: const Color(0xFF5B8DEF).withOpacity(0.22), blurRadius: 20, offset: const Offset(0, 9))],
          ),
          child: Row(
            children: [
              _Avatar(initial: initial),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.35, height: 1),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      username.isNotEmpty ? '@$username • $email' : email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70, height: 1.2),
                    ),
                    const SizedBox(height: 12),
                    const _ProfileBadge(),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Profili düzenle',
                onPressed: onEdit,
                style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.18)),
                icon: const Icon(Icons.edit_rounded, size: 21, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initial;

  const _Avatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 82,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.22),
        border: Border.all(color: Colors.white.withOpacity(0.72), width: 3),
      ),
      child: Text(
        initial,
        style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white),
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.17),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withOpacity(0.23)),
      ),
      child: const Text(
        'Smart Study kullanıcısı',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF5F7FC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: TaskStore.tasks,
      builder: (context, tasks, _) {
        final completed = tasks.where((task) => task['isDone'] == true).length;

        return ValueListenableBuilder<int>(
          valueListenable: StatsStore.totalMinutes,
          builder: (context, totalMinutes, _) {
            return ValueListenableBuilder<int>(
              valueListenable: StatsStore.streak,
              builder: (context, streak, _) {
                return Row(
                  children: [
                    Expanded(
                      child: _StatCard(icon: Icons.check_circle_rounded, value: '$completed', label: 'Tamamlandı', color: const Color(0xFF45B87A)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(icon: Icons.schedule_rounded, value: _formatMinutes(totalMinutes), label: 'Toplam', color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_fire_department_rounded,
                        value: '$streak gün',
                        label: 'Seri',
                        color: const Color(0xFFE58A3A),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  static String _formatMinutes(int totalMinutes) {
    if (totalMinutes < 60) {
      return '$totalMinutes dk';
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (minutes == 0) {
      return '$hours sa';
    }

    return '$hours s ${minutes}d';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 106,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7EAF2)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.11), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: color.withOpacity(0.13), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 19, color: color),
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary, height: 1),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary, height: 1),
          ),
        ],
      ),
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchRow({required this.icon, required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _SettingsRowShell(
      icon: icon,
      iconColor: AppColors.primary,
      iconBackground: const Color(0xFFE7EDFF),
      title: title,
      subtitle: subtitle,
      trailing: Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary, activeTrackColor: AppColors.primary.withOpacity(0.28)),
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
    return _SettingsRowShell(
      icon: Icons.flag_rounded,
      iconColor: const Color(0xFF8B5CF6),
      iconBackground: const Color(0xFFF0E8FF),
      title: 'Kişisel hedef',
      subtitle: 'Günlük çalışma hedefin',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _GoalButton(icon: Icons.remove_rounded, onTap: onMinus),
          SizedBox(
            width: 58,
            child: Text(
              '$value dk',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
          ),
          _GoalButton(icon: Icons.add_rounded, onTap: onPlus),
        ],
      ),
    );
  }
}

class _SettingsArrowRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback onTap;

  const _SettingsArrowRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBackground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: _SettingsRowShell(
        icon: icon,
        iconColor: iconColor,
        iconBackground: iconBackground,
        title: title,
        subtitle: subtitle,
        trailing: const Icon(Icons.chevron_right_rounded, size: 25, color: AppColors.textSecondary),
      ),
    );
  }
}

class _SettingsRowShell extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingsRowShell({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: iconBackground, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.15),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          trailing,
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
        decoration: BoxDecoration(color: const Color(0xFFF1F4FC), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 17, color: AppColors.primary),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFEDF0F5));
  }
}
