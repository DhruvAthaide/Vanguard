import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../database/project_dao.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final projectDaoProvider = Provider<ProjectDao>((ref) {
  return ProjectDao(ref.watch(databaseProvider));
});

final projectsProvider = FutureProvider((ref) {
  return ref.watch(projectDaoProvider).getAllProjects();
});
