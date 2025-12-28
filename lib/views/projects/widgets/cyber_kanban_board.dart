import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:drift/drift.dart' as drift; // Alias to avoid Value conflict
import '../../../core/theme/cyber_theme.dart';
import '../../../database/app_database.dart';
import '../../../providers/project_provider.dart';
import 'task_editor_sheet.dart';

class CyberKanbanBoard extends ConsumerWidget {
  final int projectId;
  // We accept the full list of tasks (flat or nodes). 
  // For Kanban, we usually want all tasks, not just roots?
  // Recursion makes Kanban tricky. Usually Kanban flattens everything or only shows leaves?
  // Let's assume we flatten all tasks for the board view to ensure nothing is hidden.
  final List<TaskNode> taskNodes; 

  const CyberKanbanBoard({super.key, required this.projectId, required this.taskNodes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Flatten nodes to tasks
    final List<Task> allTasks = [];
    void flatten(List<TaskNode> nodes) {
      for (var node in nodes) {
        allTasks.add(node.task);
        flatten(node.children);
      }
    }
    flatten(taskNodes);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _KanbanColumn(
             title: "INTEL / BACKLOG", 
             statusValues: const ['Yet to Plan'], 
             tasks: allTasks,
             color: Colors.white24,
             projectId: projectId,
          ),
          _KanbanColumn(
             title: "PLANNING", 
             statusValues: const ['Planning'], 
             tasks: allTasks,
             color: Colors.purple,
             projectId: projectId,
          ),
          _KanbanColumn(
             title: "ACTIVE OPERATIONS", 
             statusValues: const ['In Progress', 'Update Required'], 
             tasks: allTasks,
             color: CyberTheme.accent,
             projectId: projectId,
          ),
          _KanbanColumn(
             title: "COMPLETE / ARCHIVE", 
             statusValues: const ['Completed', 'On Hold', 'DeadEnd'], 
             tasks: allTasks,
             color: CyberTheme.success,
             projectId: projectId,
          ),
        ],
      ),
    );
  }
}

class _KanbanColumn extends ConsumerWidget {
  final String title;
  final List<String> statusValues;
  final List<Task> tasks;
  final Color color;
  final int projectId;

  const _KanbanColumn({
    required this.title,
    required this.statusValues,
    required this.tasks,
    required this.color,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columnTasks = tasks.where((t) => statusValues.contains(t.status)).toList();

    return DragTarget<Task>(
      onWillAccept: (data) => true,
      onAccept: (task) {
         // Update status to the first value of this column
         // e.g. dragging to Active -> 'In Progress'
         final newStatus = statusValues.first;
         if (task.status != newStatus) {
            ref.read(projectActionsProvider).dao.updateTask(
               task.id, 
               TasksCompanion(status: drift.Value(newStatus))
            );
         }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return Container(
          width: 280,
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHovered ? color.withOpacity(0.1) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovered ? color : Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                    child: Text("${columnTasks.length}", style: GoogleFonts.robotoMono(fontSize: 10, color: Colors.white)),
                  )
                ],
              ),
              const SizedBox(height: 12),
              
              // List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Scroll handled by horizontal parent? No, vertical needs to be careful.
                // Actually, SingleChildScrollView horizontal + ListView inside is bad.
                // Should use Column if list is small, or Fixed height if list is scrollable.
                // Kanban usually scrolls horizontally, and columns scroll vertically.
                // Let's assume columns are scrollable if needed, but for now wrap in LimitedBox or Constraints.
                itemCount: columnTasks.length,
                itemBuilder: (context, index) {
                   return _KanbanCard(task: columnTasks[index], color: color);
                },
              ),
              
              if (columnTasks.isEmpty)
                 Padding(
                   padding: const EdgeInsets.symmetric(vertical: 24),
                   child: Text("NO INTEL", style: GoogleFonts.inter(fontSize: 10, color: Colors.white10)),
                 ),
            ],
          ),
        );
      },
    );
  }
}

class _KanbanCard extends StatelessWidget {
  final Task task;
  final Color color;

  const _KanbanCard({required this.task, required this.color});

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Task>(
      data: task,
      feedback: Transform.scale(
         scale: 1.05,
         child: Material(
           color: Colors.transparent,
           child: Container(
              width: 260,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                 color: CyberTheme.surface,
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: color, width: 2),
                 boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12)],
              ),
              child: Text(task.title, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
           ),
         ),
      ),
      childWhenDragging: Opacity(
         opacity: 0.3, 
         child: _buildCardContent(),
      ),
      child: GestureDetector(
         onTap: () {
            // Edit
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => TaskEditorSheet(projectId: task.projectId, taskToEdit: task),
            );
         },
         child: _buildCardContent(),
      ),
    );
  }

  Widget _buildCardContent() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
         color: CyberTheme.glass,
         borderRadius: BorderRadius.circular(12),
         border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               if (task.threatLevel > 1)
                 Padding(
                   padding: const EdgeInsets.only(top: 2, right: 6),
                   child: Icon(LucideIcons.flame, size: 12, color: CyberTheme.danger),
                 ),
               Expanded(
                 child: Text(task.title, style: GoogleFonts.inter(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
               ),
             ],
           ),
           const SizedBox(height: 8),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
                if (task.deadline != null)
                   Text("Due ${task.deadline!.day}/${task.deadline!.month}", style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
                _StatusChip(status: task.status, color: color),
             ],
           )
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
   final String status;
   final Color color;
   const _StatusChip({required this.status, required this.color});
   
   @override
   Widget build(BuildContext context) {
      return Container(
         padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
         decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
         ),
         child: Text(status.toUpperCase(), style: GoogleFonts.inter(fontSize: 8, color: color, fontWeight: FontWeight.bold)),
      );
   }
}
