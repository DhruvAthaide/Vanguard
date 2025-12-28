import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:drift/drift.dart' show Value;
import '../../../core/theme/cyber_theme.dart';
import '../../../database/app_database.dart';
import '../../../providers/project_provider.dart';
import 'task_editor_sheet.dart';

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
    final isDone = task.status == 'Completed'; 
    // Status Logic check: we now have many statuses. 
    // Let's say 'Completed' or 'DeadEnd' counts as done visually?
    // Or just strikethrough 'Completed' only.
    final isStrike = task.status == 'Completed';
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
              
              // EXPANDER
              if (hasChildren)
                GestureDetector(
                   onTap: () => setState(() => _expanded = !_expanded),
                   child: Container(
                     width: 20, 
                     alignment: Alignment.center,
                     child: Icon(
                        _expanded ? LucideIcons.chevronDown : LucideIcons.chevronRight,
                        size: 16,
                        color: Colors.white54,
                     ),
                   ),
                )
              else
                const SizedBox(width: 20),

              const SizedBox(width: 4),
              
              // CONTENT BOX
              Expanded(
                child: GestureDetector(
                  onLongPress: () {
                     // Edit Mode
                     showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => TaskEditorSheet(
                           projectId: task.projectId,
                           taskToEdit: task,
                        )
                     );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                       color: Colors.white.withOpacity(0.03),
                       borderRadius: BorderRadius.circular(8),
                       border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      children: [
                         // Status Checkbox equivalent
                         GestureDetector(
                            onTap: widget.onToggleStatus,
                            child: Container(
                               width: 16, height: 16,
                               margin: const EdgeInsets.only(right: 12),
                               decoration: BoxDecoration(
                                 color: isStrike ? CyberTheme.success.withOpacity(0.2) : Colors.transparent,
                                 border: Border.all(
                                   color: isStrike ? CyberTheme.success : _getStatusColor(task.status).withOpacity(0.5),
                                   width: 1.5,
                                 ),
                                 borderRadius: BorderRadius.circular(4),
                               ),
                               child: isStrike ? const Icon(LucideIcons.check, size: 12, color: CyberTheme.success) : null,
                            ),
                         ),
                      
                         if (task.threatLevel > 1)
                            Container(
                               width: 6, height: 6,
                               margin: const EdgeInsets.only(right: 8),
                               decoration: BoxDecoration(shape: BoxShape.circle, color: threatColor, boxShadow: [BoxShadow(color: threatColor, blurRadius: 4)]),
                            ),
                         
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 task.title,
                                 style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: isStrike ? Colors.white38 : Colors.white,
                                    decoration: isStrike ? TextDecoration.lineThrough : null,
                                    fontWeight: FontWeight.w500,
                                 ),
                               ),
                               if (task.status != 'Yet to Plan' && task.status != 'Completed')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                       task.status.toUpperCase(),
                                       style: GoogleFonts.inter(fontSize: 9, color: _getStatusColor(task.status), fontWeight: FontWeight.bold),
                                    ),
                                  )
                             ],
                           ),
                         ),
                         
                         // Add Subtask Button
                         IconButton(
                            icon: const Icon(LucideIcons.plusCircle, size: 16, color: Colors.white24),
                            onPressed: () {
                               showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => TaskEditorSheet(
                                     projectId: task.projectId,
                                     parentTask: task,
                                  )
                               );
                            },
                         )
                      ],
                    ),
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
                // Determine next status cycle
                // Simple cycle or just toggle complete?
                // Plan: "One-tap checkbox ... status-cycle"
                // Let's implement a simple cycle: Yet to Plan -> In Progress -> Completed -> Yet to Plan
                // Or user can use edit sheet for specific status.
                // For 'checkBox' visual, it implies Done/Not Done.
                // Let's stick to: If not Completed -> Completed. If Completed -> In Progress.
                final newStatus = task.status == 'Completed' ? 'In Progress' : 'Completed';
                 ref.read(projectActionsProvider).dao.updateTask(
                    child.task.id, 
                    TasksCompanion(status: Value(newStatus))
                 );
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
  
  Color _getStatusColor(String status) {
     switch(status) {
       case 'Completed': return CyberTheme.success;
       case 'In Progress': return Colors.blue;
       case 'DeadEnd': return Colors.red;
       case 'Planning': return Colors.purple;
       default: return Colors.white54;
     }
  }
}
