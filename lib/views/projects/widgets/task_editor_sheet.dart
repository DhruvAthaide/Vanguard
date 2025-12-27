import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:drift/drift.dart' show Value; // Import Value
import '../../../../core/theme/cyber_theme.dart';
import '../../../../database/app_database.dart'; // Import TasksCompanion
import '../../../../providers/project_provider.dart';
import 'team_member_selector.dart';

class TaskEditorSheet extends ConsumerStatefulWidget {
  final int projectId;
  
  const TaskEditorSheet({super.key, required this.projectId});

  @override
  ConsumerState<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends ConsumerState<TaskEditorSheet> {
  final _titleCtrl = TextEditingController();
  int? _selectedAssigneeId;
  double _threatLevel = 1.0; // 1 (Med) default

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(teamMembersProvider);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 24, left: 24, right: 24
      ),
      decoration: const BoxDecoration(
        color: CyberTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("NEW OBJECTIVE", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: CyberTheme.accent, letterSpacing: 2.0)),
              IconButton(icon: const Icon(LucideIcons.x, color: Colors.white54), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _titleCtrl,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
               hintText: "Enter objective parameters...",
               hintStyle: GoogleFonts.inter(color: Colors.white38),
               filled: true,
               fillColor: Colors.black26,
               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            autofocus: true,
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
          
          const SizedBox(height: 24),
          
          // Team Selection
          membersAsync.when(
             data: (members) {
                if (members.isEmpty) return const SizedBox.shrink(); // Hide if no team
                return TeamMemberSelector(
                   members: members, 
                   selectedId: _selectedAssigneeId, 
                   onSelected: (id) => setState(() => _selectedAssigneeId = id)
                );
             },
             loading: () => const LinearProgressIndicator(minHeight: 2, color: CyberTheme.accent),
             error: (_,__) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 32),
          
          ElevatedButton(
             onPressed: () {
                if (_titleCtrl.text.isNotEmpty) {
                   ref.read(projectActionsProvider).dao.createTask(
                      TasksCompanion(
                         projectId: Value(widget.projectId),
                         title: Value(_titleCtrl.text),
                         threatLevel: Value(_threatLevel.toInt()),
                         assignedMemberId: _selectedAssigneeId == null ? const Value.absent() : Value(_selectedAssigneeId!),
                         deadline: Value(DateTime.now().add(const Duration(days: 3))), // Default
                      )
                   );
                   Navigator.pop(context);
                }
             },
             style: ElevatedButton.styleFrom(
               backgroundColor: CyberTheme.accent,
               padding: const EdgeInsets.symmetric(vertical: 16),
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
               elevation: 0,
             ),
             child: Text("DEPLOY OBJECTIVE", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          )
        ],
      ),
    );
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
