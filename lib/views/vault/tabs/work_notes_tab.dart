import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/theme/cyber_theme.dart';
import '../../../providers/vault_provider.dart';
import '../../../database/app_database.dart';
import '../../../providers/project_provider.dart'; // For databaseProvider
import 'package:drift/drift.dart' as drift;
import '../widgets/rich_note_editor.dart';

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
            // Use MarkdownBody to render the content preview
            // Use MarkdownBody to render the content preview
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 60),
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.white, Colors.transparent],
                  stops: [0.0, 0.7, 1.0],
                ).createShader(bounds),
                blendMode: BlendMode.dstIn,
                child: ClipRect(
                  child: MarkdownBody(
                    data: note.content!,
                    styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                      strong: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: CyberTheme.accent,
                      ),
                      em: GoogleFonts.inter(
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                      code: GoogleFonts.jetBrainsMono(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
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
  late bool _isPreview;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    // Use custom highlighter controller
    _contentCtrl = MarkdownSyntaxHighlighter(text: widget.note?.content ?? '');
    // Default to preview mode if editing an existing note
    _isPreview = widget.note != null;
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
      height: MediaQuery.of(context).size.height * 0.85,
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              // Preview Toggle
              GestureDetector(
                onTap: () => setState(() => _isPreview = !_isPreview),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isPreview ? CyberTheme.accent.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isPreview ? CyberTheme.accent : Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isPreview ? LucideIcons.eyeOff : LucideIcons.eye,
                        size: 14,
                        color: _isPreview ? CyberTheme.accent : Colors.white60,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isPreview ? "EDIT" : "PREVIEW",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _isPreview ? CyberTheme.accent : Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
          const SizedBox(height: 12),
          Expanded(
            child: _isPreview
                ? SingleChildScrollView(
                    child: MarkdownBody(
                      data: _contentCtrl.text.isEmpty ? "*No content*" : _contentCtrl.text,
                      styleSheet: MarkdownStyleSheet(
                        p: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
                        h1: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        h2: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        strong: GoogleFonts.inter(fontWeight: FontWeight.bold, color: CyberTheme.accent),
                        em: GoogleFonts.inter(fontStyle: FontStyle.italic, color: Colors.white),
                        blockquote: GoogleFonts.inter(fontStyle: FontStyle.italic, color: Colors.white60),
                        code: GoogleFonts.jetBrainsMono(backgroundColor: Colors.white.withOpacity(0.1)),
                        listBullet: TextStyle(color: CyberTheme.accent),
                      ),
                    ),
                  )
                : RichNoteEditor(
                    controller: _contentCtrl,
                    initialText: widget.note?.content,
                  ),
          ),
          const SizedBox(height: 16),
          if (!_isPreview)
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
