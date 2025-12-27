import 'package:drift/drift.dart';
import 'app_database.dart';
import 'tables.dart';

part 'project_dao.g.dart';

@DriftAccessor(tables: [Projects, Tasks])
class ProjectDao extends DatabaseAccessor<AppDatabase>
    with _$ProjectDaoMixin {
  ProjectDao(AppDatabase db) : super(db);

  // ─────────────────────────────────────────
  // PROJECTS
  // ─────────────────────────────────────────

  Future<List<Project>> getAllProjects() {
    return select(projects).get();
  }

  Future<int> createProject(ProjectsCompanion entry) {
    return into(projects).insert(entry);
  }

  // ─────────────────────────────────────────
  // TASKS
  // ─────────────────────────────────────────

  Stream<List<Task>> watchTasksForProject(int projectId) {
    return (select(tasks)
      ..where((t) => t.projectId.equals(projectId)))
        .watch();
  }

  Future<int> createTask(TasksCompanion entry) {
    return into(tasks).insert(entry);
  }
}
