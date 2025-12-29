import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:async';
import '../../../core/theme/cyber_theme.dart';
import '../../../services/secure_storage_service.dart';
import '../../../providers/vault_provider.dart';

class SecureEditor extends ConsumerStatefulWidget {
  final SecureNote? note;
  const SecureEditor({super.key, this.note});

  @override
  ConsumerState<SecureEditor> createState() => _SecureEditorState();
}

class _SecureEditorState extends ConsumerState<SecureEditor> {
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  final List<String> _selectedTags = [];
  bool _isDirty = false;

  final List<String> _investigationTags = [
    'Payload',
    'Credential',
    'Incident',
    'Exploit',
    'Recon',
    'Network',
  ];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.note?.content ?? '');
    if (widget.note != null) {
      _selectedTags.addAll(widget.note!.tags);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _secureCopy() async {
    final text = _contentCtrl.text;
    if (text.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "SECURE COPY ACTIVE - Clearing in 60s",
            style: GoogleFonts.robotoMono(color: CyberTheme.danger),
          ),
          backgroundColor: Colors.black,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    // Auto-clear logic
    Future.delayed(const Duration(seconds: 60), () async {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text == text) {
        await Clipboard.setData(const ClipboardData(text: ''));
      }
    });
  }

  Future<void> _save() async {
    if (_titleCtrl.text.isEmpty) return;

    final service = ref.read(secureStorageServiceProvider);
    
    if (widget.note != null) {
      final updated = widget.note!.copyWith(
        title: _titleCtrl.text,
        content: _contentCtrl.text,
        tags: _selectedTags,
      );
      await service.saveNote(updated);
    } else {
      await service.createNote(
        title: _titleCtrl.text,
        content: _contentCtrl.text,
        tags: _selectedTags,
      );
    }
    
    ref.invalidate(secureNotesProvider);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Darker for "Red-Team" feel
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: CyberTheme.danger, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.shield, color: CyberTheme.danger, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "CLASSIFIED_EDITOR_V1",
                        style: GoogleFonts.robotoMono(
                          color: CyberTheme.danger,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.copy, color: CyberTheme.accent),
                        tooltip: "Secure Copy",
                        onPressed: _secureCopy,
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(LucideIcons.x, color: Colors.white54),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- EDITOR ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleCtrl,
                      style: GoogleFonts.robotoMono(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: "Operation Title...",
                        hintStyle: GoogleFonts.robotoMono(color: Colors.white24),
                        border: InputBorder.none,
                      ),
                    ),
                    
                    const Divider(color: Colors.white12),
                    
                    // Tags
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _investigationTags.map((tag) {
                        final isSelected = _selectedTags.contains(tag);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedTags.remove(tag);
                              } else {
                                _selectedTags.add(tag);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10, 
                              vertical: 4
                            ),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? CyberTheme.danger.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isSelected 
                                    ? CyberTheme.danger 
                                    : Colors.white24,
                              ),
                            ),
                            child: Text(
                              "#$tag",
                              style: GoogleFonts.robotoMono(
                                fontSize: 11,
                                color: isSelected ? CyberTheme.danger : Colors.white54,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    TextField(
                      controller: _contentCtrl,
                      maxLines: null,
                      style: GoogleFonts.robotoMono(
                        fontSize: 14,
                        color: CyberTheme.accent, // Terminal green/cyan look
                        height: 1.5,
                      ),
                      decoration: InputDecoration(
                        hintText: "> Enter detailed payload or credentials...",
                        hintStyle: GoogleFonts.robotoMono(color: Colors.white24),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- FOOTER ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CyberTheme.danger,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "ENCRYPT & SAVE",
                        style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
