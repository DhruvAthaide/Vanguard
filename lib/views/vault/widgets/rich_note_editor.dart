import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/cyber_theme.dart';

// Custom TextEditingController to handle syntax highlighting
class MarkdownSyntaxHighlighter extends TextEditingController {
  MarkdownSyntaxHighlighter({String? text}) : super(text: text);

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<TextSpan> children = [];
    final pattern = RegExp(
      r'(\*\*.*?\*\*)|(\*.*?\*)|(```.*?```)|(`.*?`)|(#{1,6}\s.*?$)|(>.*?$)|(-\s.*?$)|(\d+\.\s.*?$)',
      multiLine: true,
      dotAll: true // allows . to match newlines for code blocks
    );

    int currentStart = 0;
    
    // We need to use text.splitMapJoin or similar, but since we need multiple matches
    // manual iteration is safer for overlapping styles (though Regex above is simple)
    
    for (final match in pattern.allMatches(text)) {
      // Add text before match
      if (match.start > currentStart) {
        children.add(TextSpan(
          text: text.substring(currentStart, match.start),
          style: style,
        ));
      }

      final String matchText = match.group(0)!;
      TextStyle highlightStyle = style ?? const TextStyle();

      if (matchText.startsWith('**')) { // Bold
        highlightStyle = highlightStyle.copyWith(
          fontWeight: FontWeight.bold,
          color: CyberTheme.accent,
        );
      } else if (matchText.startsWith('*')) { // Italic
        highlightStyle = highlightStyle.copyWith(
          fontStyle: FontStyle.italic,
          color: Colors.white,
        );
      } else if (matchText.startsWith('`')) { // Code
        highlightStyle = highlightStyle.copyWith(
          fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
          backgroundColor: Colors.white.withOpacity(0.1),
          // color: Colors.orangeAccent,
        );
      } else if (matchText.startsWith('#')) { // Headers
        highlightStyle = highlightStyle.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: (style?.fontSize ?? 14) * 1.2,
          color: Colors.white,
        );
      } else if (matchText.startsWith('>')) { // Quote
        highlightStyle = highlightStyle.copyWith(
          fontStyle: FontStyle.italic,
          color: Colors.white60,
        );
      } else if (matchText.startsWith('-') || RegExp(r'\d+\.').hasMatch(matchText)) { // Lists
        highlightStyle = highlightStyle.copyWith(
          color: CyberTheme.accent,
        );
      }

      children.add(TextSpan(
        text: matchText,
        style: highlightStyle,
      ));

      currentStart = match.end;
    }

    // Add remaining text
    if (currentStart < text.length) {
      children.add(TextSpan(
        text: text.substring(currentStart),
        style: style,
      ));
    }

    return TextSpan(style: style, children: children);
  }
}

class RichNoteEditor extends StatefulWidget {
  final TextEditingController controller;
  final String? initialText;

  const RichNoteEditor({
    super.key,
    required this.controller,
    this.initialText,
  });

  @override
  State<RichNoteEditor> createState() => _RichNoteEditorState();
}

class _RichNoteEditorState extends State<RichNoteEditor> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Do not set text here if controller is passed from parent, parent handles it.
    // However, if we want syntax highlighting, the PARENT must use the MarkdownSyntaxHighlighter controller.
    // If the parent passes a basic TextEditingController, highlighting won't work.
    // BUT we can wrap it? No, TextField takes the controller.
    // We will update the PARENT to use our new controller class.
    if (widget.initialText != null && widget.controller.text.isEmpty) {
      widget.controller.text = widget.initialText!;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _insertText(String prefix, String suffix) {
    final selection = widget.controller.selection;
    final text = widget.controller.text;
    
    if (selection.isValid) {
      final selectedText = selection.textInside(text);
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '$prefix$selectedText$suffix',
      );
      
      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + prefix.length + selectedText.length + suffix.length,
        ),
      );
    }
    _focusNode.requestFocus();
  }

  void _insertAtCursor(String text) {
    final selection = widget.controller.selection;
    final currentText = widget.controller.text;
    
    if (selection.isValid) {
      final newText = currentText.replaceRange(
        selection.start,
        selection.end,
        text,
      );
      
      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + text.length,
        ),
      );
    }
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Formatting Toolbar
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CyberTheme.surface.withOpacity(0.7),
                    CyberTheme.surface.withOpacity(0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FormatButton(
                    icon: LucideIcons.bold,
                    tooltip: 'Bold (**text**)',
                    onPressed: () => _insertText('**', '**'),
                  ),
                  _FormatButton(
                    icon: LucideIcons.italic,
                    tooltip: 'Italic (*text*)',
                    onPressed: () => _insertText('*', '*'),
                  ),
                  _FormatButton(
                    icon: LucideIcons.code,
                    tooltip: 'Code (`code`)',
                    onPressed: () => _insertText('`', '`'),
                  ),
                  _FormatButton(
                    icon: LucideIcons.heading1,
                    tooltip: 'Heading 1',
                    onPressed: () => _insertAtCursor('# '),
                  ),
                  _FormatButton(
                    icon: LucideIcons.heading2,
                    tooltip: 'Heading 2',
                    onPressed: () => _insertAtCursor('## '),
                  ),
                  _FormatButton(
                    icon: LucideIcons.list,
                    tooltip: 'Bullet List',
                    onPressed: () => _insertAtCursor('- '),
                  ),
                  _FormatButton(
                    icon: LucideIcons.listOrdered,
                    tooltip: 'Numbered List',
                    onPressed: () => _insertAtCursor('1. '),
                  ),
                  _FormatButton(
                    icon: LucideIcons.quote,
                    tooltip: 'Quote',
                    onPressed: () => _insertAtCursor('> '),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Text Editor
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CyberTheme.surface.withOpacity(0.6),
                      CyberTheme.surface.withOpacity(0.4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.6,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write your note... (supports markdown)',
                    hintStyle: GoogleFonts.jetBrainsMono(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FormatButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _FormatButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<_FormatButton> createState() => _FormatButtonState();
}

class _FormatButtonState extends State<_FormatButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.9 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(_isPressed ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: CyberTheme.accent,
            ),
          ),
        ),
      ),
    );
  }
}
