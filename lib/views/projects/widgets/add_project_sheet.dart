import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../providers/project_provider.dart';

class AddProjectSheet extends ConsumerStatefulWidget {
  const AddProjectSheet({super.key});

  @override
  ConsumerState<AddProjectSheet> createState() => _AddProjectSheetState();
}

class _AddProjectSheetState extends ConsumerState<AddProjectSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _deadline = DateTime.now().add(const Duration(days: 14));

  @override
  Widget build(BuildContext context) {
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
              Text("INITIATE OPERATION", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: CyberTheme.accent, letterSpacing: 2.0)),
              IconButton(icon: const Icon(LucideIcons.x, color: Colors.white54), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 24),
          
          TextField(
            controller: _nameCtrl,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
               labelText: "Operation Code Name",
               labelStyle: const TextStyle(color: Colors.white54),
               filled: true,
               fillColor: Colors.black26,
               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _descCtrl,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
               labelText: "Mission Brief (Optional)",
               labelStyle: const TextStyle(color: Colors.white54),
               filled: true,
               fillColor: Colors.black26,
               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          
          // Date Picker
          GestureDetector(
             onTap: () async {
                final d = await showDatePicker(
                   context: context, 
                   initialDate: _deadline, 
                   firstDate: DateTime.now(), 
                   lastDate: DateTime.now().add(const Duration(days: 365*5))
                );
                if (d != null) setState(() => _deadline = d);
             },
             child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                   color: Colors.black26,
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: Colors.white12),
                ),
                child: Row(
                   children: [
                      const Icon(LucideIcons.calendar, size: 16, color: CyberTheme.accent),
                      const SizedBox(width: 12),
                      Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            Text("DEADLINE", style: GoogleFonts.inter(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold)),
                            Text(DateFormat('MMM dd, yyyy').format(_deadline), style: GoogleFonts.inter(color: Colors.white)),
                         ],
                      )
                   ],
                ),
             ),
          ),
          
          const SizedBox(height: 32),
          
          ElevatedButton(
             onPressed: () {
                if (_nameCtrl.text.isNotEmpty) {
                   ref.read(projectActionsProvider).createProject(
                      _nameCtrl.text,
                      _descCtrl.text,
                      _deadline,
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
             child: Text("COMMENCE OPERATION", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          )
        ],
      ),
    );
  }
}
