import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../intel_feed/intel_feed_screen.dart';


class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  final screens = const [
    IntelFeedScreen(),
    Placeholder(),
    Placeholder(),
    Placeholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: [
          NavigationDestination(
            icon: Icon(LucideIcons.rss),
            label: "Intel",
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.layers),
            label: "Projects",
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.calendar),
            label: "Timeline",
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.lock),
            label: "Vault",
          ),
        ],
      ),
    );
  }
}
