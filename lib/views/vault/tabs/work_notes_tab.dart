import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:ui';
import '../../../core/theme/cyber_theme.dart';
import '../../../providers/vault_provider.dart';
import '../../../database/app_database.dart';
import '../../../providers/project_provider.dart';
import 'package:drift/drift.dart' as drift;
import '../widgets/rich_note_editor.dart';
import 'package:vanguard/features/deaddrop/ui/share_qr_dialog.dart';

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
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.05),
                          Colors.white.withOpacity(0.02),
                        ],
                      ),
                    ),
                    child: Icon(
                      LucideIcons.fileText,
                      size: 42,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "No Intel Logged",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 100,
            ),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Text(
                        'Delete Note?',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      content: Text(
                        'This action cannot be undone.',
                        style: GoogleFonts.inter(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            'CANCEL',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            'DELETE',
                            style: GoogleFonts.inter(
                              color: CyberTheme.danger,
                              fontWeight: FontWeight.w700,
                            ),
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
                  padding: const EdgeInsets.only(right: 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        CyberTheme.danger.withOpacity(0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(LucideIcons.trash2, color: Colors.white, size: 20),
                ),
                child: GestureDetector(
                  onTap: () => _showEditor(context, ref, note: note),
                  child: _WorkNoteCard(note: note),
                ),
              );
            },
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: CyberTheme.accent,
            strokeWidth: 3,
          ),
        ),
        error: (e, s) => Center(
          child: Text(
            'Error: $e',
            style: GoogleFonts.inter(color: CyberTheme.danger),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditor(context, ref),
        backgroundColor: CyberTheme.accent,
        elevation: 8,
        child: const Icon(LucideIcons.plus, color: Colors.black, size: 22),
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

class _WorkNoteCard extends StatefulWidget {
  final WorkNote note;

  const _WorkNoteCard({required this.note});

  @override
  State<_WorkNoteCard> createState() => _WorkNoteCardState();
}

class _WorkNoteCardState extends State<_WorkNoteCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.note.title,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM dd HH:mm').format(widget.note.updatedAt),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                  if (widget.note.content != null && widget.note.content!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 54),
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
                            data: widget.note.content!,
                            styleSheet: MarkdownStyleSheet(
                              p: GoogleFonts.inter(
                                fontSize: 13,
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
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
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
    _contentCtrl = MarkdownSyntaxHighlighter(text: widget.note?.content ?? '');
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
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                CyberTheme.surface.withOpacity(0.95),
                CyberTheme.surface.withOpacity(0.98),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: CyberTheme.accent,
                      letterSpacing: 1.4,
                    ),
                  ),
                  // Share Button
                  GestureDetector(
                    onTap: () {
                      if (_contentCtrl.text.isEmpty) return;
                      showDialog(
                        context: context,
                        builder: (_) => ShareQrDialog(
                          title: _titleCtrl.text.isEmpty ? 'Untitled Note' : _titleCtrl.text,
                          dataToShare: _contentCtrl.text,
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.qrCode, size: 13, color: CyberTheme.accent),
                          const SizedBox(width: 5),
                          Text(
                            "DROP",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: CyberTheme.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Preview Toggle
                  GestureDetector(
                    onTap: () => setState(() => _isPreview = !_isPreview),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isPreview ? CyberTheme.accent.withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isPreview ? CyberTheme.accent : Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isPreview ? LucideIcons.eyeOff : LucideIcons.eye,
                            size: 13,
                            color: _isPreview ? CyberTheme.accent : Colors.white60,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _isPreview ? "EDIT" : "PREVIEW",
                            style: GoogleFonts.inter(
                              fontSize: 10,
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
              const SizedBox(height: 14),
              TextField(
                controller: _titleCtrl,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: "Title",
                  hintStyle: GoogleFonts.inter(color: Colors.white.withOpacity(0.35)),
                  border: InputBorder.none,
                ),
              ),
              Divider(color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 10),
              Expanded(
                child: _isPreview
                    ? SingleChildScrollView(
                  child: MarkdownBody(
                    data: _contentCtrl.text.isEmpty ? "*No content*" : _contentCtrl.text,
                    styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.inter(fontSize: 15, color: Colors.white70),
                      h1: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      h2: GoogleFonts.inter(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
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
              const SizedBox(height: 14),
              if (!_isPreview)
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CyberTheme.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    "SAVE RECORD",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}