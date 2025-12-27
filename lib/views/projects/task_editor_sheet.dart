import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/project_provider.dart';
import '../../database/app_database.dart';
import 'package:drift/drift.dart' as drift;

class TaskEditorSheet extends ConsumerStatefulWidget {
  final int projectId;

  const TaskEditorSheet({super.key, required this.projectId});

  @override
  ConsumerState<TaskEditorSheet> createState() =>
      _TaskEditorSheetState();
}

class _TaskEditorSheetState
    extends ConsumerState<TaskEditorSheet> {
  final title = TextEditingController();
  final assigned = TextEditingController();
  DateTime? due;
  String status = 'todo';

  @override
  Widget build(BuildContext context) {
    final dao = ref.read(projectDaoProvider);

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "New Task",
            style:
            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          TextField(
            controller: title,
            decoration:
            const InputDecoration(labelText: "Task Title"),
          ),
          TextField(
            controller: assigned,
            decoration:
            const InputDecoration(labelText: "Assigned To"),
          ),

          DropdownButtonFormField(
            value: status,
            items: const [
              DropdownMenuItem(value: 'todo', child: Text("To Do")),
              DropdownMenuItem(
                  value: 'progress', child: Text("In Progress")),
              DropdownMenuItem(value: 'done', child: Text("Done")),
            ],
            onChanged: (v) => setState(() => status = v!),
          ),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: () async {
              await dao.createTask(
                TasksCompanion.insert(
                  projectId: widget.projectId,
                  title: title.text,
                  assignedTo: drift.Value(assigned.text),
                  deadline: due ?? DateTime.now(),
                  status: drift.Value(status),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text("Save Task"),
          ),
        ],
      ),
    );
  }
}
