import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../dashboard/dashboard_screen.dart';
import '../intel_feed/intel_feed_screen.dart';
import '../projects/projects_screen.dart';
import '../timeline/timeline_screen.dart';
import '../vault/vault_screen.dart';
import 'widgets/cyber_nav_bar.dart';

// Global key to access shell state
final GlobalKey<_AppShellState> appShellKey = GlobalKey<_AppShellState>();

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  final screens = const [
    DashboardScreen(),
    IntelFeedScreen(),
    ProjectsScreen(),
    VaultScreen(),
  ];

  final destinations = const [
    NavDestination(icon: LucideIcons.home, label: "Home"),
    NavDestination(icon: LucideIcons.rss, label: "Intel"),
    NavDestination(icon: LucideIcons.layers, label: "Projects"),
    NavDestination(icon: LucideIcons.lock, label: "Vault"),
  ];

  void switchTab(int newIndex) {
    setState(() => index = newIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(index),
          child: screens[index],
        ),
      ),
      bottomNavigationBar: CyberNavBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: destinations,
      ),
    );
  }
}
