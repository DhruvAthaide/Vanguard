import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/cyber_theme.dart';
import '../../../providers/vault_provider.dart';
import '../../../services/secure_storage_service.dart';
import '../widgets/secure_editor.dart';
import '../widgets/pin_change_dialog.dart';

class LockedVaultTab extends ConsumerWidget {
  const LockedVaultTab({super.key});

  Future<void> _handleChangePIN(BuildContext context, WidgetRef ref) async {
    final pinService = ref.read(pinServiceProvider);
    
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const PinChangeDialog(),
    );
    
    if (result != null && context.mounted) {
      final success = await pinService.changePin(
        result['oldPin']!,
        result['newPin']!,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'PIN changed successfully',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: CyberTheme.accent,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Incorrect current PIN',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: CyberTheme.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(secureNotesProvider);
    final vaultController = ref.read(vaultControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Locked Header with Change PIN
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => vaultController.lock(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: CyberTheme.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: CyberTheme.danger.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.lock, color: CyberTheme.danger, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            "INSTANT LOCK",
                            style: GoogleFonts.inter(
                              color: CyberTheme.danger,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _handleChangePIN(context, ref),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: CyberTheme.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: CyberTheme.accent.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.keyRound, color: CyberTheme.accent, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          "CHANGE PIN",
                          style: GoogleFonts.inter(
                            color: CyberTheme.accent,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: notesAsync.when(
              data: (notes) {
                if (notes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.shield, size: 48, color: CyberTheme.danger.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          "VAULT EMPTY",
                          style: GoogleFonts.robotoMono(
                            color: CyberTheme.danger.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: notes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Dismissible(
                      key: Key(note.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: CyberTheme.surface,
                            title: Text(
                              'Delete Secure Note?',
                              style: GoogleFonts.inter(color: Colors.white),
                            ),
                            content: Text(
                              'This will permanently delete this encrypted note.',
                              style: GoogleFonts.inter(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('CANCEL', style: GoogleFonts.inter()),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  'DELETE',
                                  style: GoogleFonts.inter(color: CyberTheme.danger),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) async {
                        final service = ref.read(secureStorageServiceProvider);
                        await service.deleteNote(note.id);
                        ref.invalidate(secureNotesProvider);
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: CyberTheme.danger,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(LucideIcons.trash2, color: Colors.white),
                      ),
                      child: _SecureNoteCard(note: note),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: CyberTheme.danger),
              ),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SecureEditor()),
        ),
        backgroundColor: CyberTheme.danger,
        child: const Icon(LucideIcons.plus, color: Colors.black),
      ),
    );
  }
}

class _SecureNoteCard extends ConsumerWidget {
  final SecureNote note;
  const _SecureNoteCard({required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SecureEditor(note: note)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CyberTheme.danger.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: GoogleFonts.robotoMono(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: CyberTheme.danger,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  DateFormat('HH:mm').format(note.updatedAt),
                  style: GoogleFonts.robotoMono(
                    fontSize: 10,
                    color: CyberTheme.danger.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            if (note.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: note.tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: CyberTheme.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "#$tag",
                    style: GoogleFonts.robotoMono(
                      fontSize: 10,
                      color: CyberTheme.danger.withOpacity(0.8),
                    ),
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
