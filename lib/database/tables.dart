import 'package:drift/drift.dart';

// ─────────────────────────────────────────
// CORE TABLES
// ─────────────────────────────────────────

class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  
  // Status & Priority
  TextColumn get priority => text().withDefault(const Constant('medium'))(); // low, medium, high, critical
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  
  // Timeline
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
}

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // Hierarchy
  IntColumn get projectId => integer().references(Projects, #id, onDelete: KeyAction.cascade)();
  IntColumn get parentTaskId => integer().nullable().references(Tasks, #id, onDelete: KeyAction.cascade)();
  
  // Content
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  
  // Logistics
  IntColumn get assignedMemberId => integer().nullable().references(TeamMembers, #id)();
  
  // 0=Low, 1=Medium, 2=High, 3=Critical
  IntColumn get threatLevel => integer().withDefault(const Constant(1))(); 
  
  // For drag-and-drop ordering
  IntColumn get orderIndex => integer().withDefault(const Constant(0))(); 
  
  // Dates
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get deadline => dateTime().nullable()();
  
  // Status: todo, progress, review, done
  TextColumn get status => text().withDefault(const Constant('todo'))(); 
  
  // Archival
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

// ─────────────────────────────────────────
// METADATA TABLES
// ─────────────────────────────────────────

class TeamMembers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get role => text()(); // e.g. "Red Team Lead", "Exploit Dev"
  TextColumn get avatarUrl => text().nullable()(); // Local path or asset
  TextColumn get initials => text().withLength(min: 1, max: 3)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

class WorkNotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get content => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get tags => text().nullable()(); // Comma separated for simple tagging
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get label => text().unique()();
  TextColumn get colorHex => text().withDefault(const Constant('0xFF38BDF8'))(); // Default cyan
}

// ─────────────────────────────────────────
// JUNCTION TABLES (Many-to-Many)
// ─────────────────────────────────────────

class ProjectTags extends Table {
  IntColumn get projectId => integer().references(Projects, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId => integer().references(Tags, #id, onDelete: KeyAction.cascade)();
  
  @override
  Set<Column> get primaryKey => {projectId, tagId};
}

class TaskTags extends Table {
  IntColumn get taskId => integer().references(Tasks, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId => integer().references(Tags, #id, onDelete: KeyAction.cascade)();
  
  @override
  Set<Column> get primaryKey => {taskId, tagId};
}
