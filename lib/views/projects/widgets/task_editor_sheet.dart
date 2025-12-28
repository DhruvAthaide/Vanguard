import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' show Value;
import '../../../core/theme/cyber_theme.dart';
import '../../../database/app_database.dart';
import '../../../providers/project_provider.dart';
import 'team_member_selector.dart';

class TaskEditorSheet extends ConsumerStatefulWidget {
  final int projectId;
  final Task? parentTask; // For subtasks
  final Task? taskToEdit; // For editing existing task

  const TaskEditorSheet({
    super.key,
    required this.projectId,
    this.parentTask,
    this.taskToEdit,
  });

  @override
  ConsumerState<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends ConsumerState<TaskEditorSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  int? _selectedAssigneeId;
  double _threatLevel = 1.0; 
  DateTime? _startDate;
  DateTime? _deadline;
  String _status = 'Yet to Plan';

  final List<String> _statuses = [
    'Yet to Plan', 'Planning', 'In Progress', 'Update Required', 
    'On Hold', 'Completed', 'DeadEnd'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      final t = widget.taskToEdit!;
      _titleCtrl.text = t.title;
      _descCtrl.text = t.description ?? '';
      _selectedAssigneeId = t.assignedMemberId;
      _threatLevel = t.threatLevel.toDouble();
      _startDate = t.startDate;
      _deadline = t.deadline;
      _status = t.status;
    } else {
       // Defaults for new task
       _startDate = DateTime.now();
       _deadline = DateTime.now().add(const Duration(days: 7));
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(teamMembersProvider);
    final isEdit = widget.taskToEdit != null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 24, left: 24, right: 24
      ),
      decoration: const BoxDecoration(
        color: CyberTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEdit ? "UPDATE PROTOCOL" : (widget.parentTask != null ? "ADD SUB-ROUTINE" : "NEW OBJECTIVE"), 
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: CyberTheme.accent, letterSpacing: 2.0)
                ),
                IconButton(icon: const Icon(LucideIcons.x, color: Colors.white54), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 24),
            
            // Title
            TextField(
              controller: _titleCtrl,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                 hintText: "Objective Title",
                 hintStyle: GoogleFonts.inter(color: Colors.white38),
                 filled: true,
                 fillColor: Colors.black26,
                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              autofocus: !isEdit,
            ),
            const SizedBox(height: 12),
            
            // Description
             TextField(
              controller: _descCtrl,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                 hintText: "Tactical Details (Optional)",
                 hintStyle: GoogleFonts.inter(color: Colors.white38),
                 filled: true,
                 fillColor: Colors.black26,
                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              maxLines: 2,
            ),
            
            const SizedBox(height: 24),
            
            // Dates Row
            Row(
              children: [
                Expanded(child: _DatePicker(
                  label: "START DATE", 
                  date: _startDate, 
                  onTap: () => _pickDate(true),
                )),
                const SizedBox(width: 12),
                Expanded(child: _DatePicker(
                  label: "DEADLINE", 
                  date: _deadline, 
                  color: CyberTheme.danger,
                  onTap: () => _pickDate(false),
                )),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Status Dropdown
            DropdownButtonFormField<String>(
              value: _status,
              dropdownColor: CyberTheme.surface,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                labelText: "CURRENT STATUS",
                labelStyle: GoogleFonts.inter(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) {
                 if (val != null) setState(() => _status = val);
              },
            ),

            const SizedBox(height: 24),
            
            // Threat Level
            Text("THREAT LEVEL: ${_getThreatLabel(_threatLevel)}", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54)),
            Slider(
              value: _threatLevel,
              min: 0, max: 3, divisions: 3,
              activeColor: _getThreatColor(_threatLevel),
              inactiveColor: Colors.white10,
              onChanged: (val) => setState(() => _threatLevel = val),
            ),
            
            const SizedBox(height: 16),
            
            // Team Selection
            membersAsync.when(
               data: (members) {
                  if (members.isEmpty) return const SizedBox.shrink();
                  return TeamMemberSelector(
                     members: members, 
                     selectedId: _selectedAssigneeId, 
                     onSelected: (id) => setState(() => _selectedAssigneeId = id)
                  );
               },
               loading: () => const SizedBox(height: 60),
               error: (_,__) => const SizedBox.shrink(),
            ),
  
            const SizedBox(height: 32),
            
            Row(
              children: [
                if (isEdit)
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                         // Delete logic
                         ref.read(projectActionsProvider).dao.deleteTask(widget.taskToEdit!.id);
                         Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.white.withOpacity(0.05),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("ABORT", style: GoogleFonts.inter(color: CyberTheme.danger, fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (isEdit) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                     onPressed: _saveTask,
                     style: ElevatedButton.styleFrom(
                       backgroundColor: CyberTheme.accent,
                       padding: const EdgeInsets.symmetric(vertical: 16),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                       elevation: 0,
                     ),
                     child: Text(isEdit ? "UPDATE INTEL" : "DEPLOY OBJECTIVE", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
  
  Future<void> _pickDate(bool isStart) async {
    final initial = isStart ? _startDate : _deadline;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365*5)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startDate = picked; else _deadline = picked;
      });
    }
  }

  void _saveTask() {
    if (_titleCtrl.text.isEmpty) return;

    final dao = ref.read(projectActionsProvider).dao;
    final companion = TasksCompanion(
       title: Value(_titleCtrl.text),
       description: Value(_descCtrl.text),
       status: Value(_status),
       threatLevel: Value(_threatLevel.toInt()),
       assignedMemberId: Value(_selectedAssigneeId), // Safe, Value<int?> accepts null
       startDate: Value(_startDate),
       deadline: Value(_deadline),
       // Keep existing links if editing, set for new
       projectId: widget.taskToEdit != null ? const Value.absent() : Value(widget.projectId),
       parentTaskId: widget.parentTask != null 
           ? Value(widget.parentTask!.id) 
           : (widget.taskToEdit != null ? const Value.absent() : const Value.absent()), 
    );

    if (widget.taskToEdit != null) {
       dao.updateTask(widget.taskToEdit!.id, companion);
    } else {
       dao.createTask(companion);
    }
    Navigator.pop(context);
  }
  
  String _getThreatLabel(double val) {
     switch(val.toInt()) {
       case 0: return "LOW";
       case 1: return "MEDIUM";
       case 2: return "HIGH";
       case 3: return "CRITICAL";
       default: return "UNKNOWN";
     }
  }
  
  Color _getThreatColor(double val) {
     switch(val.toInt()) {
       case 0: return Colors.blue;
       case 1: return CyberTheme.accent;
       case 2: return Colors.orange;
       case 3: return CyberTheme.danger;
       default: return Colors.white;
     }
  }
}

class _DatePicker extends StatelessWidget {
  final String label;
  final DateTime? date;
  final Color color;
  final VoidCallback onTap;

  const _DatePicker({required this.label, required this.date, this.color = CyberTheme.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
         decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
         ),
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white54)),
               const SizedBox(height: 4),
               Row(
                 children: [
                   Icon(LucideIcons.calendar, size: 14, color: color),
                   const SizedBox(width: 8),
                   Text(
                     date != null ? DateFormat('MMM dd').format(date!) : "Select",
                     style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                   ),
                 ],
               )
            ],
         ),
      ),
    );
  }
}
