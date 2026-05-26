import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:shared_models/shared_models.dart' as shared;

part 'database.g.dart';

class ExerciseStates extends Table {
  TextColumn get exerciseId => text()();
  RealColumn get currentWorkingWeightKg => real()();
  DateTimeColumn get lastUpdatedAt => dateTime()();
  TextColumn get historyJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column<Object>> get primaryKey => {exerciseId};
}

class WorkoutSessions extends Table {
  TextColumn get id => text()();
  TextColumn get programId => text()();
  TextColumn get workoutId => text()();
  DateTimeColumn get dateUtc => dateTime()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get entriesJson => text().withDefault(const Constant('[]'))();
  IntColumn get schemaVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SettingsEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(
  tables: [ExerciseStates, WorkoutSessions, SettingsEntries],
  daos: [ExerciseStateDao, WorkoutSessionDao, SettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {},
      );
}

QueryExecutor openConnection() => driftDatabase(name: 'menno_tracker');

@DriftAccessor(tables: [ExerciseStates])
class ExerciseStateDao extends DatabaseAccessor<AppDatabase>
    with _$ExerciseStateDaoMixin {
  ExerciseStateDao(super.db);

  Future<shared.ExerciseState?> get(String exerciseId) async {
    final row = await (select(exerciseStates)
          ..where((table) => table.exerciseId.equals(exerciseId)))
        .getSingleOrNull();
    return row == null ? null : _exerciseStateFromRow(row);
  }

  Future<void> upsert(shared.ExerciseState state) {
    return into(exerciseStates).insertOnConflictUpdate(
      _exerciseStateToCompanion(state),
    );
  }

  Future<List<shared.ExerciseState>> all() async {
    final rows = await select(exerciseStates).get();
    return rows.map(_exerciseStateFromRow).toList(growable: false);
  }

  ExerciseStatesCompanion _exerciseStateToCompanion(
    shared.ExerciseState state,
  ) {
    return ExerciseStatesCompanion.insert(
      exerciseId: state.exerciseId,
      currentWorkingWeightKg: state.currentWorkingWeightKg,
      lastUpdatedAt: state.lastUpdatedAt.toUtc(),
      historyJson: Value(
        jsonEncode(state.history.map((change) => change.toJson()).toList()),
      ),
    );
  }

  shared.ExerciseState _exerciseStateFromRow(ExerciseState row) {
    return shared.ExerciseState.fromJson({
      'exerciseId': row.exerciseId,
      'currentWorkingWeightKg': row.currentWorkingWeightKg,
      'lastUpdatedAt': row.lastUpdatedAt.toUtc().toIso8601String(),
      'history': _decodeJsonList(row.historyJson, 'historyJson'),
    });
  }
}

@DriftAccessor(tables: [WorkoutSessions])
class WorkoutSessionDao extends DatabaseAccessor<AppDatabase>
    with _$WorkoutSessionDaoMixin {
  WorkoutSessionDao(super.db);

  Future<void> insert(shared.WorkoutSession session) {
    return into(workoutSessions).insert(_workoutSessionToCompanion(session));
  }

  Future<List<shared.WorkoutSession>> listAll() async {
    final rows = await (select(workoutSessions)
          ..orderBy([
            (table) => OrderingTerm.desc(table.dateUtc),
            (table) => OrderingTerm.desc(table.startedAt),
          ]))
        .get();
    return rows.map(_workoutSessionFromRow).toList(growable: false);
  }

  Future<shared.WorkoutSession?> byId(String id) async {
    final row = await (select(workoutSessions)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _workoutSessionFromRow(row);
  }

  WorkoutSessionsCompanion _workoutSessionToCompanion(
    shared.WorkoutSession session,
  ) {
    return WorkoutSessionsCompanion.insert(
      id: session.id,
      programId: session.programId,
      workoutId: session.workoutId,
      dateUtc: session.dateUtc.toUtc(),
      startedAt: session.startedAt.toUtc(),
      completedAt: Value(session.completedAt?.toUtc()),
      entriesJson: Value(
        jsonEncode(session.entries.map((entry) => entry.toJson()).toList()),
      ),
      schemaVersion: Value(session.schemaVersion),
    );
  }

  shared.WorkoutSession _workoutSessionFromRow(WorkoutSession row) {
    return shared.WorkoutSession.fromJson({
      'id': row.id,
      'programId': row.programId,
      'workoutId': row.workoutId,
      'dateUtc': row.dateUtc.toUtc().toIso8601String(),
      'startedAt': row.startedAt.toUtc().toIso8601String(),
      'completedAt': row.completedAt?.toUtc().toIso8601String(),
      'entries': _decodeJsonList(row.entriesJson, 'entriesJson'),
      'schemaVersion': row.schemaVersion,
    });
  }
}

@DriftAccessor(tables: [SettingsEntries])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<String?> getString(String key) async {
    final row = await (select(settingsEntries)
          ..where((table) => table.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setString(String key, String value) {
    return into(settingsEntries).insertOnConflictUpdate(
      SettingsEntriesCompanion.insert(key: key, value: value),
    );
  }

  Future<double?> getDouble(String key) async {
    final value = await getString(key);
    return value == null ? null : double.tryParse(value);
  }

  Future<void> setDouble(String key, double value) {
    return setString(key, value.toString());
  }

  Future<int?> getInt(String key) async {
    final value = await getString(key);
    return value == null ? null : int.tryParse(value);
  }

  Future<void> setInt(String key, int value) {
    return setString(key, value.toString());
  }
}

List<Object?> _decodeJsonList(String source, String fieldName) {
  final decoded = jsonDecode(source);
  if (decoded is List) {
    return decoded.cast<Object?>();
  }
  throw FormatException('Expected $fieldName to contain a JSON list.', decoded);
}
