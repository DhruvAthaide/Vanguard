import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/project_provider.dart';
import 'project_editor_sheet.dart';
import 'task_list.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Projects"),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const ProjectEditorSheet(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("New Project"),
      ),

      body: projectsAsync.when(
        loading: () =>
        const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (projects) {
          if (projects.isEmpty) {
            return const Center(
              child: Text(
                "No projects yet",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Row(
                    children: [
                      _priorityDot(project.priority),
                      const SizedBox(width: 8),
                      Text(
                        project.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    "${_fmt(project.startDate)} → ${_fmt(project.endDate)}",
                    style: const TextStyle(color: Colors.white60),
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text("Edit"),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text("Delete"),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) =>
                              ProjectEditorSheet(project: project),
                        );
                      }
                    },
                  ),
                  children: [
                    TaskList(projectId: project.id),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _priorityDot(String priority) {
    Color c;
    switch (priority) {
      case 'high':
        c = Colors.red;
        break;
      case 'medium':
        c = Colors.orange;
        break;
      default:
        c = Colors.green;
    }

    return Container(
      width: 10,
      height: 10,
      decoration:
      BoxDecoration(color: c, shape: BoxShape.circle),
    );
  }

  String _fmt(DateTime? d) {
    if (d == null) return "—";
    return "${d.day}/${d.month}";
  }
}
