import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../database/app_database.dart';
import '../../../../providers/project_provider.dart';

class CyberTaskTree extends ConsumerStatefulWidget {
  final TaskNode node;
  final VoidCallback onToggleStatus;

  const CyberTaskTree({
    super.key,
    required this.node,
    required this.onToggleStatus,
  });

  @override
  ConsumerState<CyberTaskTree> createState() => _CyberTaskTreeState();
}

class _CyberTaskTreeState extends ConsumerState<CyberTaskTree> with SingleTickerProviderStateMixin {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final task = widget.node.task;
    final hasChildren = widget.node.children.isNotEmpty;
    final isDone = task.status == 'done';
    final threatColor = _getThreatColor(task.threatLevel);

    return Column(
      children: [
        // The Tile Itself
        Container(
          margin: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              // Indentation
              SizedBox(width: widget.node.depth * 24.0),
              
              // Checkbox / Status
              GestureDetector(
                onTap: widget.onToggleStatus,
                child: Container(
                   width: 20, height: 20,
                   decoration: BoxDecoration(
                     color: isDone ? CyberTheme.success.withOpacity(0.2) : Colors.transparent,
                     border: Border.all(
                       color: isDone ? CyberTheme.success : Colors.white24,
                       width: 1.5,
                     ),
                     borderRadius: BorderRadius.circular(6),
                   ),
                   child: isDone ? const Icon(LucideIcons.check, size: 14, color: CyberTheme.success) : null,
                ),
              ),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                     color: Colors.white.withOpacity(0.03),
                     borderRadius: BorderRadius.circular(8),
                     border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                       if (task.threatLevel > 1)
                          Container(
                             width: 6, height: 6,
                             margin: const EdgeInsets.only(right: 8),
                             decoration: BoxDecoration(shape: BoxShape.circle, color: threatColor, boxShadow: [BoxShadow(color: threatColor, blurRadius: 4)]),
                          ),
                       
                       Expanded(
                         child: Text(
                           task.title,
                           style: GoogleFonts.inter(
                              color: isDone ? Colors.white38 : Colors.white,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                              fontWeight: FontWeight.w500,
                           ),
                         ),
                       ),
                       
                       if (hasChildren)
                          GestureDetector(
                             onTap: () => setState(() => _expanded = !_expanded),
                             child: Icon(
                                _expanded ? LucideIcons.chevronDown : LucideIcons.chevronRight,
                                size: 16,
                                color: Colors.white54,
                             ),
                          )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Children (Recursive)
        if (_expanded)
           ...widget.node.children.map((child) => CyberTaskTree(
             node: child,
             onToggleStatus: () {
                ref.read(projectActionsProvider).toggleTaskStatus(child.task);
             },
           )),
      ],
    );
  }

  Color _getThreatColor(int level) {
      if (level >= 3) return CyberTheme.danger;
      if (level == 2) return Colors.orange;
      return CyberTheme.accent;
  }
}
