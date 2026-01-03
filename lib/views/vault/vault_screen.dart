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
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _updateSecurityState(0);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    platform.invokeMethod('insecure');
    _glowController.dispose();
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
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      -0.5 + (_glowController.value * 0.3),
                      -0.8 + (_glowController.value * 0.2),
                    ),
                    radius: 1.5,
                    colors: [
                      _selectedIndex == 1
                          ? CyberTheme.danger.withOpacity(0.08)
                          : CyberTheme.accent.withOpacity(0.04),
                      CyberTheme.background,
                      CyberTheme.background,
                    ],
                  ),
                ),
              );
            },
          ),

          SafeArea(
            child: Column(
              children: [
                // --- HEADER & SEGMENTED CONTROL ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, child) {
                              return Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      (_selectedIndex == 1 ? CyberTheme.danger : CyberTheme.accent),
                                      (_selectedIndex == 1 ? CyberTheme.danger : CyberTheme.accent).withOpacity(0.7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_selectedIndex == 1 ? CyberTheme.danger : CyberTheme.accent)
                                          .withOpacity(0.3 + (_glowController.value * 0.15)),
                                      blurRadius: 12 + (_glowController.value * 6),
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _selectedIndex == 1 ? LucideIcons.shieldAlert : LucideIcons.shield,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "COMMAND VAULT",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.8,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 44,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth / 2;
                            return Stack(
                              children: [
                                // Sliding Indicator
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 280),
                                  curve: Curves.easeOutCubic,
                                  left: _selectedIndex * width,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: width,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _selectedIndex == 1
                                              ? CyberTheme.danger
                                              : CyberTheme.accent,
                                          (_selectedIndex == 1
                                              ? CyberTheme.danger
                                              : CyberTheme.accent).withOpacity(0.85),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(11),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (_selectedIndex == 1
                                              ? CyberTheme.danger
                                              : CyberTheme.accent).withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
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
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              letterSpacing: 0.5,
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
                                                  size: 13,
                                                  color: _selectedIndex == 1 ? Colors.black : Colors.white54,
                                                ),
                                              ),
                                              const SizedBox(width: 7),
                                              AnimatedDefaultTextStyle(
                                                duration: const Duration(milliseconds: 200),
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12,
                                                  letterSpacing: 0.5,
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
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
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