import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'home_screen.dart';
import 'pomodoro_screen.dart';
import 'profile_screen.dart';
import 'stats_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  void _selectTab(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(showDrawer: false, onOpenStats: () => _selectTab(2), onOpenProfile: () => _selectTab(3)),
          const PomodoroScreen(showBackButton: false),
          const StatsScreen(showBackButton: false),
          const ProfileSettingsPage(showBackButton: false),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        height: 72,
        backgroundColor: const Color(0xFFF4F8FF),
        elevation: 8,
        shadowColor: Colors.black12,
        indicatorColor: const Color(0xFFDCE9FF),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Ana Sayfa'),
          NavigationDestination(icon: Icon(Icons.timer_outlined), selectedIcon: Icon(Icons.timer_rounded), label: 'Pomodoro'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart_rounded), label: 'İstatistik'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }
}
