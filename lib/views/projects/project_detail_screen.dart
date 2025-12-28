import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/cyber_theme.dart';
import '../../database/app_database.dart';
import '../../providers/project_provider.dart';
import 'widgets/cyber_task_tree.dart';
import 'widgets/cyber_kanban_board.dart';
import 'widgets/task_editor_sheet.dart';
import 'widgets/add_project_sheet.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  bool _isKanbanMode = false;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(recursiveTasksProvider(widget.project.id));

    return Scaffold(
      backgroundColor: CyberTheme.background,
      appBar: AppBar(
        title: Text(widget.project.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // View Toggle
          IconButton(
            icon: Icon(_isKanbanMode ? LucideIcons.list : LucideIcons.layoutGrid, color: CyberTheme.accent),
            onPressed: () => setState(() => _isKanbanMode = !_isKanbanMode),
            tooltip: _isKanbanMode ? "Switch to List" : "Switch to Board",
          ),
          PopupMenuButton<String>(
             icon: const Icon(LucideIcons.moreVertical),
             onSelected: (val) async {
                if (val == 'edit') {
                   // Open Edit Sheet
                   showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => AddProjectSheet(projectToEdit: widget.project),
                   );
                } else if (val == 'archive') {
                   await ref.read(projectActionsProvider).archiveProject(widget.project.id, !widget.project.isArchived);
                } else if (val == 'delete') {
                   // Confirm? For now direct support.
                   await ref.read(projectActionsProvider).deleteProject(widget.project.id);
                   if (context.mounted) Navigator.pop(context); // Go back to list
                }
             },
             itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text("Edit Operation parameters")),
                PopupMenuItem(value: 'archive', child: Text(widget.project.isArchived ? "Unarchive Operation" : "Archive Operation")),
                const PopupMenuItem(value: 'delete', child: Text("Terminate Operation", style: TextStyle(color: CyberTheme.danger))),
             ],
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
             // --- METADATA HEADER (Minimal) ---
             if (!_isKanbanMode) // Hide in Kanban to give more space? Or keep? Let's keep minimal.
               Container(
                 padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      if (widget.project.description != null)
                        Text(
                           widget.project.description!,
                           style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
                           maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _Badge(
                              icon: LucideIcons.shieldAlert, 
                              text: widget.project.priority.toUpperCase(),
                              color: widget.project.priority == 'critical' ? CyberTheme.danger : CyberTheme.accent
                          ),
                          const SizedBox(width: 12),
                           _Badge(icon: LucideIcons.calendar, text: widget.project.endDate != null ? DateFormat('MMM dd').format(widget.project.endDate!) : "No Deadline"),
                        ],
                      )
                   ],
                 ),
               ),
             
             // --- CONTENT ---
             Expanded(
               child: tasksAsync.when(
                 data: (nodes) {
                   if (nodes.isEmpty) {
                      return Center(child: Text("No objectives defined.", style: GoogleFonts.inter(color: Colors.white24)));
                   }
                   
                   if (_isKanbanMode) {
                      return CyberKanbanBoard(projectId: widget.project.id, taskNodes: nodes);
                   }

                   return ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: nodes.length,
                      itemBuilder: (context, index) {
                         return CyberTaskTree(
                           node: nodes[index], 
                           onToggleStatus: () {
                              ref.read(projectActionsProvider).toggleTaskStatus(nodes[index].task);
                           }
                         );
                      },
                   );
                 },
                 loading: () => const Center(child: CircularProgressIndicator(color: CyberTheme.accent)),
                 error: (e,s) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
               ),
             ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
           showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => TaskEditorSheet(projectId: widget.project.id),
           );
        },
        backgroundColor: CyberTheme.accent,
        label: const Text("Add Objective", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        icon: const Icon(LucideIcons.plus, color: Colors.black),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  
  const _Badge({required this.icon, required this.text, this.color = Colors.white54});
  
  @override
  Widget build(BuildContext context) {
     return Row(
       mainAxisSize: MainAxisSize.min,
       children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(text, style: GoogleFonts.inter(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
       ],
     );
  }
}
