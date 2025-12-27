import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/project_provider.dart';
import 'task_editor_sheet.dart';

class TaskList extends ConsumerWidget {
  final int projectId;

  const TaskList({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(projectDaoProvider);

    return Column(
      children: [
        StreamBuilder(
          stream: dao.watchTasksForProject(projectId),
          builder: (context, snapshot) {
            final tasks = snapshot.data ?? [];

            return Column(
              children: tasks.map((t) {
                return ListTile(
                  title: Text(t.title),
                  subtitle:
                  Text("${t.assignedTo} • ${t.deadline}"),
                );
              }).toList(),
            );
          },
        ),
        TextButton.icon(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) =>
                  TaskEditorSheet(projectId: projectId),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text("Add Task"),
        ),
      ],
    );
  }
}
