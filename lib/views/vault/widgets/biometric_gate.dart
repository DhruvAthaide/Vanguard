import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/cyber_theme.dart';
import '../../../providers/vault_provider.dart';
import 'pin_setup_dialog.dart';
import 'pin_entry_dialog.dart';

class BiometricGate extends ConsumerStatefulWidget {
  final Widget child;

  const BiometricGate({super.key, required this.child});

  @override
  ConsumerState<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends ConsumerState<BiometricGate>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handlePinAuth(BuildContext context, WidgetRef ref) async {
    final pinService = ref.read(pinServiceProvider);
    final controller = ref.read(vaultControllerProvider.notifier);

    final hasPin = await pinService.hasPin();

    if (!hasPin) {
      // Show PIN setup dialog
      final newPin = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const PinSetupDialog(),
      );

      if (newPin != null) {
        await pinService.setupPin(newPin);
        controller.unlock();
      }
    } else {
      // Show PIN entry dialog
      final enteredPin = await showDialog<String>(
        context: context,
        builder: (_) => const PinEntryDialog(),
      );

      if (enteredPin != null) {
        final isValid = await pinService.verifyPin(enteredPin);
        if (isValid) {
          controller.unlock();
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Incorrect PIN',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: CyberTheme.danger,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vaultState = ref.watch(vaultControllerProvider);
    final controller = ref.read(vaultControllerProvider.notifier);

    if (vaultState == VaultState.unlocked) {
      return widget.child;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      CyberTheme.danger.withOpacity(0.2),
                      CyberTheme.danger.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: CyberTheme.danger.withOpacity(0.3 + (_pulseController.value * 0.2)),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CyberTheme.danger.withOpacity(0.15 * _pulseController.value),
                      blurRadius: 20 + (10 * _pulseController.value),
                      spreadRadius: 3 + (2 * _pulseController.value),
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.lock,
                  size: 56,
                  color: CyberTheme.danger,
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          Text(
            "RESTRICTED ACCESS",
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Authentication Required",
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white54,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 40),

          // Biometric Auth Button
          _AuthButton(
            onPressed: () => controller.authenticate(),
            icon: LucideIcons.fingerprint,
            label: "BIOMETRIC AUTH",
            isPrimary: true,
          ),

          const SizedBox(height: 14),

          // PIN Auth Button
          _AuthButton(
            onPressed: () => _handlePinAuth(context, ref),
            icon: LucideIcons.keyRound,
            label: "USE PIN INSTEAD",
            isPrimary: false,
          ),
        ],
      ),
    );
  }
}

class _AuthButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool isPrimary;

  const _AuthButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.isPrimary,
  });

  @override
  State<_AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<_AuthButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? LinearGradient(
              colors: [
                CyberTheme.danger,
                CyberTheme.danger.withOpacity(0.85),
              ],
            )
                : null,
            color: widget.isPrimary ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isPrimary
                  ? Colors.transparent
                  : CyberTheme.danger.withOpacity(0.5),
              width: widget.isPrimary ? 0 : 1.5,
            ),
            boxShadow: widget.isPrimary
                ? [
              BoxShadow(
                color: CyberTheme.danger.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: widget.isPrimary ? Colors.black : CyberTheme.danger,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  color: widget.isPrimary ? Colors.black : CyberTheme.danger,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}