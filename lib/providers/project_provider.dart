import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../database/project_dao.dart';

// --- DATABASE ACCESS ---

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final projectDaoProvider = Provider<ProjectDao>((ref) {
  return ProjectDao(ref.watch(databaseProvider));
});

// --- EXEC FILTERING ---

class ProjectFilterState {
  final String searchQuery;
  final bool showArchived;
  final int? priorityFilter; // 0-3 (Low-Critical)
  final int? assigneeFilterId;
  final int? tagFilterId;

  const ProjectFilterState({
    this.searchQuery = '',
    this.showArchived = false,
    this.priorityFilter,
    this.assigneeFilterId,
    this.tagFilterId,
  });

  ProjectFilterState copyWith({
    String? searchQuery,
    bool? showArchived,
    int? priorityFilter,
    int? assigneeFilterId,
    int? tagFilterId,
  }) {
    return ProjectFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      showArchived: showArchived ?? this.showArchived,
      priorityFilter: priorityFilter ?? this.priorityFilter,
      assigneeFilterId: assigneeFilterId ?? this.assigneeFilterId,
      tagFilterId: tagFilterId ?? this.tagFilterId,
    );
  }
}

class ProjectFilterController extends StateNotifier<ProjectFilterState> {
  ProjectFilterController() : super(const ProjectFilterState());

  void setSearch(String query) => state = state.copyWith(searchQuery: query);
  void toggleArchived() => state = state.copyWith(showArchived: !state.showArchived);
  void setPriority(int? p) => state = state.copyWith(priorityFilter: p);
  void setAssignee(int? id) => state = state.copyWith(assigneeFilterId: id);
}

final projectFilterProvider =
    StateNotifierProvider<ProjectFilterController, ProjectFilterState>((ref) {
  return ProjectFilterController();
});

// --- PROJECTS LIST ---

final projectListProvider = StreamProvider<List<Project>>((ref) {
  final dao = ref.watch(projectDaoProvider);
  final filter = ref.watch(projectFilterProvider);

  // In a real app, push filters to SQL. Here we filter in Dart for simplicity/speed with Riverpod
  return dao.watchAllProjects().map((projects) {
    return projects.where((p) {
      if (p.isArchived != filter.showArchived) return false;
      if (filter.searchQuery.isNotEmpty) {
        if (!p.name.toLowerCase().contains(filter.searchQuery.toLowerCase())) {
          return false;
        }
      }
      // Add more filters here if needed
      return true;
    }).toList();
  });
});


// --- TASK RECURSION ---

class TaskNode {
  final Task task;
  final List<TaskNode> children;
  final int depth;

  TaskNode({required this.task, this.children = const [], this.depth = 0});
  
  // Basic progress: (completed children / total children)
  double get progress {
     if (children.isEmpty) return task.status == 'done' ? 1.0 : 0.0;
     int completed = children.where((c) => c.task.status == 'done').length;
     // Recurse? For now, just direct children count is enough for simple heatmaps
     return completed / children.length;
  }
}

final recursiveTasksProvider = StreamProvider.family<List<TaskNode>, int>((ref, projectId) {
  final dao = ref.watch(projectDaoProvider);
  
  return dao.watchTasksForProject(projectId).map((allTasks) {
    // 1. Build ID Map
    final Map<int, Task> taskMap = {for (var t in allTasks) t.id: t};
    
    // 2. Group by Parent
    final Map<int?, List<Task>> grouped = {};
    for (var t in allTasks) {
      if (!grouped.containsKey(t.parentTaskId)) grouped[t.parentTaskId] = [];
      grouped[t.parentTaskId]!.add(t);
    }
    
    // 3. Sort by orderIndex
    for (var key in grouped.keys) {
      grouped[key]!.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    }

    // 4. Recursive Build Function
    List<TaskNode> buildNodes(int? parentId, int depth) {
      final children = grouped[parentId] ?? [];
      return children.map((t) {
        return TaskNode(
          task: t,
          depth: depth,
          children: buildNodes(t.id, depth + 1),
        );
      }).toList();
    }

    return buildNodes(null, 0); // Start with root tasks (parentTaskId == null)
  });
});

// --- TEAM MEMBERS ---

final teamMembersProvider = StreamProvider<List<TeamMember>>((ref) {
  return ref.watch(projectDaoProvider).watchTeamMembers();
});

// --- ACTIONS CONTROLLER ---

class ProjectActions {
  final ProjectDao dao;
  ProjectActions(this.dao);

  Future<void> createProject(String name, String desc, DateTime deadline) {
    return dao.createProject(ProjectsCompanion(
      name: Value(name),
      description: Value(desc),
      startDate: Value(DateTime.now()),
      endDate: Value(deadline),
    ));
  }
  
  Future<void> archiveProject(int id, bool archive) {
     return dao.updateProject(id, ProjectsCompanion(isArchived: Value(archive)));
  }

  Future<void> createTask(int projectId, String title, {int? parentId}) {
    return dao.createTask(TasksCompanion(
        projectId: Value(projectId),
        parentTaskId: parentId == null ? const Value.absent() : Value(parentId),
        title: Value(title),
        deadline: Value(DateTime.now().add(const Duration(days: 3))),
    ));
  }

  Future<void> toggleTaskStatus(Task task) {
    final newStatus = task.status == 'done' ? 'todo' : 'done';
    return dao.updateTask(task.id, TasksCompanion(status: Value(newStatus)));
  }
  
  Future<void> reorderTasks(List<Task> sortedTasks) async {
     // Batch update orderIndex
     // In Drift, this might be loop of updates or a transaction
     // Simpler: Just update the ones that changed.
     // For this MVP, we assume the UI sends the new full list order.
     for (int i=0; i<sortedTasks.length; i++) {
        final t = sortedTasks[i];
        if (t.orderIndex != i) {
           await dao.updateTask(t.id, TasksCompanion(orderIndex: Value(i)));
        }
     }
  }
}

final projectActionsProvider = Provider((ref) {
  return ProjectActions(ref.watch(projectDaoProvider));
});
