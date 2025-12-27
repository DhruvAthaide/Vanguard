import 'package:drift/drift.dart';

class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
}

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get projectId =>
      integer().references(Projects, #id)();

  IntColumn get parentTaskId =>
      integer().nullable().references(Tasks, #id)();

  TextColumn get title => text()();
  TextColumn get assignedTo => text()();
  DateTimeColumn get deadline => dateTime()();

  TextColumn get status => text()
      .withDefault(const Constant("todo"))(); // todo | progress | done
}
