import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/cyber_theme.dart';
import '../../../providers/vault_provider.dart';
import 'pin_setup_dialog.dart';
import 'pin_entry_dialog.dart';

class BiometricGate extends ConsumerWidget {
  final Widget child;

  const BiometricGate({super.key, required this.child});

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
                  style: GoogleFonts.inter(color: Colors.white),
                ),
                backgroundColor: CyberTheme.danger,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaultState = ref.watch(vaultControllerProvider);
    final controller = ref.read(vaultControllerProvider.notifier);

    if (vaultState == VaultState.unlocked) {
      return child;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  CyberTheme.danger.withOpacity(0.2),
                  CyberTheme.danger.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: CyberTheme.danger.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: CyberTheme.danger.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              LucideIcons.lock,
              size: 64,
              color: CyberTheme.danger,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "RESTRICTED ACCESS",
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 3.0,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Authentication Required",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white54,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 48),
          
          // Biometric Auth Button
          GestureDetector(
            onTap: () => controller.authenticate(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: CyberTheme.danger,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: CyberTheme.danger.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.fingerprint, color: Colors.black),
                  const SizedBox(width: 12),
                  Text(
                    "BIOMETRIC AUTH",
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // PIN Auth Button
          GestureDetector(
            onTap: () => _handlePinAuth(context, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CyberTheme.danger.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.keyRound, color: CyberTheme.danger, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    "USE PIN INSTEAD",
                    style: GoogleFonts.inter(
                      color: CyberTheme.danger,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
