import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../database/app_database.dart';
import '../../../../providers/project_provider.dart';
import 'widgets/cyber_task_tree.dart';
import 'widgets/task_editor_sheet.dart'; // We will create this next

class ProjectDetailScreen extends ConsumerWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // IMPORTANT: Listening to the recursive provider
    final tasksAsync = ref.watch(recursiveTasksProvider(project.id));

    return Scaffold(
      backgroundColor: CyberTheme.background,
      appBar: AppBar(
        title: Text(project.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
             icon: const Icon(LucideIcons.moreVertical),
             onPressed: () {
                // Show options: Archive, Delete, Edit
             },
          )
        ],
      ),
      body: Column(
        children: [
             // --- METADATA HEADER ---
             Container(
               width: double.infinity,
               padding: const EdgeInsets.all(24),
               decoration: BoxDecoration(
                 color: CyberTheme.surface.withOpacity(0.5),
                 border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Text(
                       project.description ?? "No Mission Brief",
                       style: GoogleFonts.inter(color: Colors.white60, fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _Badge(icon: LucideIcons.calendar, text: project.deadline != null ? DateFormat('MMM dd').format(project.deadline!) : "Indefinite"),
                        const SizedBox(width: 12),
                        _Badge(
                            icon: LucideIcons.shieldAlert, 
                            text: project.priority.toUpperCase(),
                            color: project.priority == 'critical' ? CyberTheme.danger : CyberTheme.accent
                        ),
                      ],
                    )
                 ],
               ),
             ),
             
             // --- TASK TREE ---
             Expanded(
               child: tasksAsync.when(
                 data: (nodes) {
                   if (nodes.isEmpty) {
                      return Center(child: Text("No objectives defined.", style: GoogleFonts.inter(color: Colors.white24)));
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
           // Show new Task Editor (supports full fields)
           // For now, use a simplified version until we implement TaskEditorSheet fully
           // Or just implement TaskEditorSheet rapidly now.
           showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => TaskEditorSheet(projectId: project.id),
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
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(text, style: GoogleFonts.inter(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
       ],
     );
  }
}

// Temporary Alias until update
extension on Project {
   // Mapping fields because generated Project might have different names or we need adapters
   // Project generated: startDate, endDate. ProjectDetail expects deadline?
   // Let's use endDate as deadline
   DateTime? get deadline => endDate;
}
