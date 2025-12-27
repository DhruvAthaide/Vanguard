import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/project_provider.dart';
import '../../database/app_database.dart';
import 'package:drift/drift.dart' as drift;

class ProjectEditorSheet extends ConsumerStatefulWidget {
  final Project? project;

  const ProjectEditorSheet({super.key, this.project});

  @override
  ConsumerState<ProjectEditorSheet> createState() =>
      _ProjectEditorSheetState();
}

class _ProjectEditorSheetState
    extends ConsumerState<ProjectEditorSheet> {
  late TextEditingController name;
  String priority = 'medium';
  DateTime? start;
  DateTime? end;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.project?.name);
    priority = widget.project?.priority ?? 'medium';
    start = widget.project?.startDate;
    end = widget.project?.endDate;
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

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
          Text(
            widget.project == null ? "New Project" : "Edit Project",
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: name,
            decoration:
            const InputDecoration(labelText: "Project Name"),
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField(
            value: priority,
            items: const [
              DropdownMenuItem(value: 'low', child: Text("Low")),
              DropdownMenuItem(value: 'medium', child: Text("Medium")),
              DropdownMenuItem(value: 'high', child: Text("High")),
            ],
            onChanged: (v) => setState(() => priority = v!),
            decoration:
            const InputDecoration(labelText: "Priority"),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              TextButton(
                onPressed: () async {
                  start = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    initialDate: DateTime.now(),
                  );
                  setState(() {});
                },
                child: Text(
                  start == null
                      ? "Start Date"
                      : _formatDate(start!),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  end = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    initialDate: DateTime.now(),
                  );
                  setState(() {});
                },
                child: Text(
                  end == null
                      ? "End Date"
                      : _formatDate(start!),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () async {
              if (widget.project == null) {
                await dao.createProject(
                  ProjectsCompanion.insert(
                    name: name.text,
                    priority: drift.Value(priority),
                    startDate: start ?? DateTime.now(),
                    endDate: drift.Value(end),
                  ),
                );
              }
              Navigator.pop(context);
              ref.invalidate(projectsProvider);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
