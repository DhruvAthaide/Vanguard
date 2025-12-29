import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/cyber_theme.dart';
import '../../../providers/vault_provider.dart';
import '../../../database/app_database.dart';
import '../../../providers/project_provider.dart'; // For databaseProvider
import 'package:drift/drift.dart' as drift;

class WorkNotesTab extends ConsumerWidget {
  const WorkNotesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(workNotesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.fileText, size: 48, color: Colors.white24),
                  const SizedBox(height: 16),
                  Text(
                    "No Intel Logged",
                    style: GoogleFonts.inter(
                      color: Colors.white38,
                      fontWeight: FontWeight.w600,
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
                key: Key(note.id.toString()),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: CyberTheme.surface,
                      title: Text(
                        'Delete Note?',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                      content: Text(
                        'This action cannot be undone.',
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
                  final db = ref.read(databaseProvider);
                  await (db.delete(db.workNotes)
                        ..where((t) => t.id.equals(note.id)))
                      .go();
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
                child: GestureDetector(
                  onTap: () => _showEditor(context, ref, note: note),
                  child: _WorkNoteCard(note: note),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditor(context, ref),
        backgroundColor: CyberTheme.accent,
        child: const Icon(LucideIcons.plus, color: Colors.black),
      ),
    );
  }

  void _showEditor(BuildContext context, WidgetRef ref, {WorkNote? note}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WorkNoteEditor(note: note),
    );
  }
}

class _WorkNoteCard extends StatelessWidget {
  final WorkNote note;

  const _WorkNoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                DateFormat('MMM dd HH:mm').format(note.updatedAt),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
          if (note.content != null && note.content!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              note.content!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white70,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _WorkNoteEditor extends ConsumerStatefulWidget {
  final WorkNote? note;
  const _WorkNoteEditor({this.note});

  @override
  ConsumerState<_WorkNoteEditor> createState() => _WorkNoteEditorState();
}

class _WorkNoteEditorState extends ConsumerState<_WorkNoteEditor> {
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.isEmpty) return;

    final db = ref.read(databaseProvider);
    if (widget.note != null) {
      await (db.update(db.workNotes)..where((t) => t.id.equals(widget.note!.id)))
          .write(WorkNotesCompanion(
            title: drift.Value(_titleCtrl.text),
            content: drift.Value(_contentCtrl.text),
            updatedAt: drift.Value(DateTime.now()),
          ));
    } else {
      await db.into(db.workNotes).insert(WorkNotesCompanion.insert(
            title: _titleCtrl.text,
            content: drift.Value(_contentCtrl.text),
          ));
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: CyberTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.note != null ? "EDIT LOG" : "NEW INTEL",
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: CyberTheme.accent,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: "Title",
              hintStyle: GoogleFonts.inter(color: Colors.white38),
              border: InputBorder.none,
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.1)),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: TextField(
              controller: _contentCtrl,
              maxLines: null,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white70,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: "Enter details...",
                hintStyle: GoogleFonts.inter(color: Colors.white38),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: CyberTheme.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              "SAVE RECORD",
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
