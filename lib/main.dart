import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/cyber_theme.dart';
import 'views/shell/app_shell.dart';

void main() {
  runApp(
    const ProviderScope(
      child: CyberExecApp(),
    ),
  );
}

class CyberExecApp extends StatelessWidget {
  const CyberExecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: CyberTheme.dark(),
      home: AppShell(key: appShellKey),
    );
  }
}
