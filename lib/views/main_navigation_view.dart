import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'history_view.dart';
import 'home_view.dart';
import 'settings_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeView(),
    const HistoryView(),
    const SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1B3A57);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        indicatorColor: primaryColor.withOpacity(0.15),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.directions_subway_outlined),
            selectedIcon: const Icon(Icons.directions_subway, color: primaryColor),
            label: 'nav_home'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history, color: primaryColor),
            label: 'nav_history'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings, color: primaryColor),
            label: 'nav_settings'.tr,
          ),
        ],
      ),
    );
  }
}