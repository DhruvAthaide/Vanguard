class ReportConfig {
  final int projectId;
  final String reportTitle;
  final String classification; // e.g., "SECRET", "CONFIDENTIAL"
  final bool includeTasks;
  final bool includeNotes;
  final bool includeTeam;
  final String? password; // If null, no encryption

  ReportConfig({
    required this.projectId,
    required this.reportTitle,
    this.classification = 'CONFIDENTIAL',
    this.includeTasks = true,
    this.includeNotes = true,
    this.includeTeam = true,
    this.password,
  });
}
