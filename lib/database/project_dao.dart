import 'package:drift/drift.dart';
import 'app_database.dart';
import 'tables.dart';

part 'project_dao.g.dart';

@DriftAccessor(tables: [Projects, Tasks, TeamMembers, Tags, ProjectTags, TaskTags])
class ProjectDao extends DatabaseAccessor<AppDatabase>
    with _$ProjectDaoMixin {
  ProjectDao(AppDatabase db) : super(db);

  // ─────────────────────────────────────────
  // PROJECTS
  // ─────────────────────────────────────────

  Stream<List<Project>> watchAllProjects() {
    return (select(projects)
      ..orderBy([(t) => OrderingTerm(expression: t.startDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<int> createProject(ProjectsCompanion entry) {
    return into(projects).insert(entry);
  }
  
  Future<bool> updateProject(int id, ProjectsCompanion entry) {
    return (update(projects)..where((t) => t.id.equals(id))).write(entry).then((rows) => rows > 0);
  }
  
  Future<int> deleteProject(int id) {
    return (delete(projects)..where((t) => t.id.equals(id))).go();
  }

  // ─────────────────────────────────────────
  // TASKS
  // ─────────────────────────────────────────

  Stream<List<Task>> watchTasksForProject(int projectId) {
    return (select(tasks)
      ..where((t) => t.projectId.equals(projectId))
      ..orderBy([(t) => OrderingTerm(expression: t.orderIndex)])) // Order by index
        .watch();
  }

  Future<int> createTask(TasksCompanion entry) {
    return into(tasks).insert(entry);
  }
  
  Future<bool> updateTask(int id, TasksCompanion entry) {
     return (update(tasks)..where((t) => t.id.equals(id))).write(entry).then((rows) => rows > 0);
  }
  
  Future<int> deleteTask(int id) {
     return (delete(tasks)..where((t) => t.id.equals(id))).go();
  }

  // ─────────────────────────────────────────
  // TEAM & TAGS
  // ─────────────────────────────────────────
  
  Stream<List<TeamMember>> watchTeamMembers() => select(teamMembers).watch();
  
  Future<int> addTeamMember(TeamMembersCompanion entry) => into(teamMembers).insert(entry);
  
  Stream<List<Tag>> watchTags() => select(tags).watch();
  
  Future<int> createTag(TagsCompanion entry) => into(tags).insert(entry);
}
