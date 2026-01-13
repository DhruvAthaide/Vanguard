import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import 'package:intl/intl.dart';

import '../../../database/app_database.dart';
import '../../../core/security/encryption_service.dart';
import '../models/report_config.dart';

class ReportGenerator {
  final AppDatabase database;

  ReportGenerator(this.database);

  Future<Uint8List> generateReport(ReportConfig config) async {
    final pdf = pw.Document();
    
    // 1. Fetch Data
    final project = await (database.select(database.projects)..where((tbl) => tbl.id.equals(config.projectId))).getSingle();
    
    List<Task> tasks = [];
    if (config.includeTasks) {
      tasks = await (database.select(database.tasks)..where((tbl) => tbl.projectId.equals(config.projectId))).get();
    }
    
    // Note: WorkNotes are currently global, but might be linked to project via tags in future. 
    // For now, we'll fetch all or filter if we had a link. 
    // Assuming for this prototype we fetch recent notes or all notes if requested.
    // TODO: Filter notes by project if a link exists. usage: const [];
    List<WorkNote> notes = [];
    if (config.includeNotes) {
       notes = await database.select(database.workNotes).get();
    }

    final fontData = await PdfGoogleFonts.jetBrainsMonoRegular();
    final fontBold = await PdfGoogleFonts.jetBrainsMonoBold();
    
    // 2. Build PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: fontData,
          bold: fontBold,
        ),
        header: (context) => _buildHeader(config, project.name),
        footer: (context) => _buildFooter(context, config.classification),
        build: (context) => [
          _buildTitlePage(config, project, tasks.length, notes.length),
          if (config.includeTasks) ...[
            pw.SizedBox(height: 20),
            pw.Header(level: 1, text: 'Mission Tasks'),
            _buildTaskTable(tasks),
          ],
          if (config.includeNotes) ...[
             pw.SizedBox(height: 20),
            pw.Header(level: 1, text: 'Field Notes'),
            ...notes.map((n) => _buildNoteItem(n)),
          ],
        ],
      ),
    );

    // 3. Save & Encrypt
    final rawBytes = await pdf.save();

    if (config.password != null && config.password!.isNotEmpty) {
      return EncryptionService.encryptData(rawBytes, config.password!);
    } else {
      return rawBytes;
    }
  }

  pw.Widget _buildHeader(ReportConfig config, String projectName) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 1)),
      ),
      padding: const pw.EdgeInsets.only(bottom: 10),
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('VANGUARD OPS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.Text('PROJECT: ${projectName.toUpperCase()}', style: const pw.TextStyle(fontSize: 10)),
          pw.Text(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()), style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context, String classification) {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
             pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(fontSize: 10)),
             pw.Text(classification.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
          ]
        )
      ]
    );
  }

  pw.Widget _buildTitlePage(ReportConfig config, Project project, int taskCount, int noteCount) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(config.reportTitle, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Text('Classification: ${config.classification}', style: pw.TextStyle(color: PdfColors.red, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 30),
        pw.Text('Mission Summary:'),
        pw.Bullet(text: 'Project: ${project.name}'),
        pw.Bullet(text: 'Description: ${project.description ?? "N/A"}'),
        pw.Bullet(text: 'Status: ${project.isArchived ? "Archived" : "Active"}'),
        pw.Bullet(text: 'Tasks Included: $taskCount'),
        pw.Bullet(text: 'Notes Included: $noteCount'),
      ],
    );
  }

  pw.Widget _buildTaskTable(List<Task> tasks) {
    return pw.TableHelper.fromTextArray(
      headers: ['ID', 'Title', 'Status', 'Priority'],
      data: tasks.map((t) => [
        t.id.toString(),
        t.title,
        t.status,
        _priorityToString(t.threatLevel),
      ]).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.black),
      cellAlignment: pw.Alignment.centerLeft,
    );
  }

  String _priorityToString(int level) {
    switch(level) {
      case 0: return 'LOW';
      case 1: return 'MED';
      case 2: return 'HIGH';
      case 3: return 'CRIT';
      default: return 'UNK';
    }
  }

  pw.Widget _buildNoteItem(WorkNote note) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
           pw.Text(note.title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
           pw.Padding(
             padding: const pw.EdgeInsets.only(left: 10),
             child: pw.Text(note.content ?? '', style: const pw.TextStyle(fontSize: 10)),
           ),
           pw.Divider(color: PdfColors.grey),
        ]
      )
    );
  }
}
