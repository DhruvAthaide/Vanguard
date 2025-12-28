import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Projects,
  Tasks,
  TeamMembers,
  Tags,
  ProjectTags,
  TaskTags
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  // Simple migration strategy: Drop and Recreate (Dev only)
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
       if (from < 2) {
         // In production, write proper migrations.
         // For dev speed, we wipe to ensure schema consistency.
         for (final table in allTables) {
           await m.deleteTable(table.actualTableName);
           await m.createTable(table);
         }
       }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/vanguard.db');
    return NativeDatabase(file);
  });
}
