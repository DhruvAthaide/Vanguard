import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:drift/drift.dart';
import '../services/secure_storage_service.dart';
import '../services/pin_service.dart';
import '../database/app_database.dart';
import '../providers/project_provider.dart';
import '../main.dart'; 

// ─────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────

final pinServiceProvider = Provider<PinService>((ref) {
  return PinService();
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final secureNotesProvider = FutureProvider.autoDispose<List<SecureNote>>((ref) async {
  final service = ref.watch(secureStorageServiceProvider);
  return service.readAllNotes();
});

final workNotesProvider = StreamProvider.autoDispose<List<WorkNote>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.workNotes)
        ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)]))
      .watch();
});


// ─────────────────────────────────────────
// VAULT CONTROLLER (Auth & Session)
// ─────────────────────────────────────────

enum VaultState { locked, unlocked }

class VaultController extends StateNotifier<VaultState> {
  final LocalAuthentication _auth = LocalAuthentication();
  
  VaultController() : super(VaultState.locked) {
    // Listen to app lifecycle to lock on background
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == AppLifecycleState.paused.toString()) {
        lock();
      }
      return msg;
    });
  }

  void lock() {
    if (state != VaultState.locked) {
      state = VaultState.locked;
      // Clear sensitive data from memory if possible/needed beyond state reset
    }
  }

  void unlock() {
    state = VaultState.unlocked;
  }

  Future<bool> authenticate() async {
    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      
      if (!canCheckBiometrics && !isDeviceSupported) {
        // No biometric hardware available
        print('VaultController: No biometric hardware available');
        return false; 
      }

      final authenticated = await _auth.authenticate(
        localizedReason: 'Authenticate to access Locked Vault',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allows PIN/Pattern/Password
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Vault Access Required',
            cancelButton: 'Cancel',
            biometricHint: 'Verify your identity',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
            lockOut: 'Please re-enable biometrics',
          ),
        ],
      );

      if (authenticated) {
        state = VaultState.unlocked;
        return true;
      }
      return false;
    } on PlatformException catch (e) {
      print('VaultController: PlatformException - ${e.code}: ${e.message}');
      // Handle specific error codes
      if (e.code == 'NotAvailable' || e.code == 'NotEnrolled') {
        // Biometrics not set up
        print('VaultController: Biometrics not available or not enrolled');
      }
      return false;
    } catch (e) {
      print('VaultController: Error during authentication - $e');
      return false;
    }
  }
}

final vaultControllerProvider = StateNotifierProvider<VaultController, VaultState>((ref) {
  return VaultController();
});
