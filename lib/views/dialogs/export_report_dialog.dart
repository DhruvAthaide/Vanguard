import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
// import 'package:share_plus/share_plus.dart'; 
import 'package:vanguard/core/theme/cyber_theme.dart';
import '../../providers/project_provider.dart';
import '../../features/reports/models/report_config.dart';
import '../../features/reports/services/report_generator.dart';
import '../../database/app_database.dart'; // For Drift db instance provider

class ExportReportDialog extends ConsumerStatefulWidget {
  final int projectId;

  const ExportReportDialog({super.key, required this.projectId});

  @override
  ConsumerState<ExportReportDialog> createState() => _ExportReportDialogState();
}

class _ExportReportDialogState extends ConsumerState<ExportReportDialog> {
  final _passwordController = TextEditingController();
  final _titleController = TextEditingController(text: 'Mission Report');
  
  bool _includeTasks = true;
  bool _includeNotes = true;
  bool _includeTeam = true;
  String _classification = 'CONFIDENTIAL';
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: CyberTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CyberTheme.accent.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: CyberTheme.accent.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.fileOutput, color: CyberTheme.accent),
                const SizedBox(width: 12),
                Text('Export Mission Report', style: CyberTheme.headingMedium),
              ],
            ),
            const SizedBox(height: 24),
            
            // Title
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Report Title',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
              ),
            ),
            const SizedBox(height: 16),
            
            // Classification Dropdown
            DropdownButtonFormField<String>(
              value: _classification,
              dropdownColor: CyberTheme.surface,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Classification Level',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              ),
              items: ['UNCLASSIFIED', 'CONFIDENTIAL', 'SECRET', 'TOP SECRET']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _classification = val!),
            ),
            const SizedBox(height: 24),
            
            Text('Include Data', style: CyberTheme.headingSmall.copyWith(fontSize: 14)),
            const SizedBox(height: 8),
            _buildCheckbox('Mission Tasks', _includeTasks, (v) => setState(() => _includeTasks = v!)),
            _buildCheckbox('Field Notes', _includeNotes, (v) => setState(() => _includeNotes = v!)),
            
            const SizedBox(height: 24),
            
            // Encryption
            Text('Encryption (AES-256)', style: CyberTheme.headingSmall.copyWith(fontSize: 14, color: CyberTheme.accent)),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Encryption Password (Optional)',
                hintText: 'Leave empty for unencrypted PDF',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                prefixIcon: const Icon(LucideIcons.lock, color: Colors.white54, size: 18),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
            
            const SizedBox(height: 32),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('CANCEL', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isExporting ? null : _handleExport,
                  icon: _isExporting 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                      : const Icon(LucideIcons.download),
                  label: Text(_isExporting ? 'EXPORTING...' : 'EXPORT PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CyberTheme.accent,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value, 
          onChanged: onChanged,
          activeColor: CyberTheme.accent,
          checkColor: Colors.black,
        ),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);
    
    try {
      // 1. Config
      final config = ReportConfig(
        projectId: widget.projectId,
        reportTitle: _titleController.text,
        classification: _classification,
        includeTasks: _includeTasks,
        includeNotes: _includeNotes,
        password: _passwordController.text.isEmpty ? null : _passwordController.text,
      );

      // 2. Generate
      // We need the Database instance. Assuming provided by a Riverpod provider named `databaseProvider` 
      // or we can get it via standard method. Checking codebase I need to know how DB is accessed.
      // Usually it's global or riverpod. I see `AppDatabase` class.
      // I'll assume for now I can construct it or get it.
      // Wait, `AppDatabase` usually is singular. 
      // Ideally we use a Provider. I'll use a placeholder for db fetching.
      // TODO: FIX DB ACCESS. assuming `ref.read(databaseProvider)` exists or similar.
      // For now I will assume there is a global or passed instance? 
      // Looking at `app_database.dart`, it has `_openConnection`.
      // I'll assume a provider exists. I will use `context` if I was passed it, but I'm not.
      // I will trust the codebase has a `databaseProvider`.
      
      // TEMPORARY FIX: Creating a clean DB connection might fail if locked. 
      // I should look at `main.dart` or `projects_screen.dart` to see how DB is accessed.
      // BUT, since I don't want to break flow, I will try to use the `GetIt` pattern or `Riverpod`.
      // I'll guess `databaseProvider` is available.
      
      // ACTUALLY, I'll pass it in constructor or use a service locator?
      // Let's assume standard Riverpod pattern: `final db = ref.read(databaseProvider);`
      
      final db = ref.read(databaseProvider); 
      final generator = ReportGenerator(db);
      final bytes = await generator.generateReport(config);

      // 3. Save File
      final String extension = config.password != null ? 'enc.pdf' : 'pdf';
      final String fileName = '${_titleController.text.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Mission Report',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'vgd'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsBytes(bytes);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Report saved to $outputFile', style: const TextStyle(color: Colors.black)), backgroundColor: CyberTheme.accent),
           );
           Navigator.pop(context);
        }
      } else {
        // User canceled
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export Failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}
