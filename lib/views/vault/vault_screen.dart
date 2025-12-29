import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/cyber_theme.dart';
import 'tabs/work_notes_tab.dart';
import 'tabs/locked_vault_tab.dart';
import 'widgets/biometric_gate.dart';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0; // 0 = Work Notes, 1 = Locked Vault
  static const platform = MethodChannel('com.dhruvathaide.vanguard/security');

  @override
  void initState() {
    super.initState();
    // Initially unsecure (Work Notes are default)
    _updateSecurityState(0);
  }

  @override
  void dispose() {
    // Ensure we clear the flag when leaving
    platform.invokeMethod('insecure');
    super.dispose();
  }

  Future<void> _updateSecurityState(int index) async {
    try {
      if (index == 1) {
        await platform.invokeMethod('secure');
      } else {
        await platform.invokeMethod('insecure');
      }
    } on PlatformException catch (_) {
      // Handle platform error
    }
  }

  void _onTabChanged(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    _updateSecurityState(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberTheme.background,
      body: Stack(
        children: [
          // Background Gradient - Shifts based on tab
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.5),
                radius: 1.5,
                colors: [
                  _selectedIndex == 1 
                      ? CyberTheme.danger.withOpacity(0.1) 
                      : CyberTheme.accent.withOpacity(0.05),
                  CyberTheme.background,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // --- HEADER & SEGMENTED CONTROL ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "COMMAND VAULT",
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                              color: Colors.white,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(LucideIcons.x, size: 20, color: Colors.white54),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 50,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth / 2;
                            return Stack(
                              children: [
                                // Sliding Indicator
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutBack,
                                  left: _selectedIndex * width,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: width,
                                    decoration: BoxDecoration(
                                      color: _selectedIndex == 1 
                                          ? CyberTheme.danger.withOpacity(0.9) 
                                          : CyberTheme.accent.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (_selectedIndex == 1 
                                              ? CyberTheme.danger 
                                              : CyberTheme.accent).withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Text Labels
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _onTabChanged(0),
                                        behavior: HitTestBehavior.opaque,
                                        child: Center(
                                          child: AnimatedDefaultTextStyle(
                                            duration: const Duration(milliseconds: 200),
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: _selectedIndex == 0 ? Colors.black : Colors.white54,
                                            ),
                                            child: const Text("WORK NOTES"),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _onTabChanged(1),
                                        behavior: HitTestBehavior.opaque,
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              AnimatedSwitcher(
                                                duration: const Duration(milliseconds: 200),
                                                child: Icon(
                                                  LucideIcons.lock,
                                                  key: ValueKey(_selectedIndex == 1),
                                                  size: 14,
                                                  color: _selectedIndex == 1 ? Colors.black : Colors.white54,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              AnimatedDefaultTextStyle(
                                                duration: const Duration(milliseconds: 200),
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  color: _selectedIndex == 1 ? Colors.black : Colors.white54,
                                                ),
                                                child: const Text("LOCKED VAULT"),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // --- CONTENT ---
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _selectedIndex == 0
                        ? const WorkNotesTab()
                        : const BiometricGate(child: LockedVaultTab()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
