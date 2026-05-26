// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ExerciseStatesTable extends ExerciseStates
    with TableInfo<$ExerciseStatesTable, ExerciseState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseIdMeta =
      const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
      'exercise_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currentWorkingWeightKgMeta =
      const VerificationMeta('currentWorkingWeightKg');
  @override
  late final GeneratedColumn<double> currentWorkingWeightKg =
      GeneratedColumn<double>('current_working_weight_kg', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdatedAtMeta =
      const VerificationMeta('lastUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> lastUpdatedAt =
      GeneratedColumn<DateTime>('last_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _historyJsonMeta =
      const VerificationMeta('historyJson');
  @override
  late final GeneratedColumn<String> historyJson = GeneratedColumn<String>(
      'history_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  @override
  List<GeneratedColumn> get $columns =>
      [exerciseId, currentWorkingWeightKg, lastUpdatedAt, historyJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_states';
  @override
  VerificationContext validateIntegrity(Insertable<ExerciseState> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exercise_id')) {
      context.handle(
          _exerciseIdMeta,
          exerciseId.isAcceptableOrUnknown(
              data['exercise_id']!, _exerciseIdMeta));
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('current_working_weight_kg')) {
      context.handle(
          _currentWorkingWeightKgMeta,
          currentWorkingWeightKg.isAcceptableOrUnknown(
              data['current_working_weight_kg']!, _currentWorkingWeightKgMeta));
    } else if (isInserting) {
      context.missing(_currentWorkingWeightKgMeta);
    }
    if (data.containsKey('last_updated_at')) {
      context.handle(
          _lastUpdatedAtMeta,
          lastUpdatedAt.isAcceptableOrUnknown(
              data['last_updated_at']!, _lastUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedAtMeta);
    }
    if (data.containsKey('history_json')) {
      context.handle(
          _historyJsonMeta,
          historyJson.isAcceptableOrUnknown(
              data['history_json']!, _historyJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId};
  @override
  ExerciseState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseState(
      exerciseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}exercise_id'])!,
      currentWorkingWeightKg: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}current_working_weight_kg'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
      historyJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}history_json'])!,
    );
  }

  @override
  $ExerciseStatesTable createAlias(String alias) {
    return $ExerciseStatesTable(attachedDatabase, alias);
  }
}

class ExerciseState extends DataClass implements Insertable<ExerciseState> {
  final String exerciseId;
  final double currentWorkingWeightKg;
  final DateTime lastUpdatedAt;
  final String historyJson;
  const ExerciseState(
      {required this.exerciseId,
      required this.currentWorkingWeightKg,
      required this.lastUpdatedAt,
      required this.historyJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<String>(exerciseId);
    map['current_working_weight_kg'] = Variable<double>(currentWorkingWeightKg);
    map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    map['history_json'] = Variable<String>(historyJson);
    return map;
  }

  ExerciseStatesCompanion toCompanion(bool nullToAbsent) {
    return ExerciseStatesCompanion(
      exerciseId: Value(exerciseId),
      currentWorkingWeightKg: Value(currentWorkingWeightKg),
      lastUpdatedAt: Value(lastUpdatedAt),
      historyJson: Value(historyJson),
    );
  }

  factory ExerciseState.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseState(
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      currentWorkingWeightKg:
          serializer.fromJson<double>(json['currentWorkingWeightKg']),
      lastUpdatedAt: serializer.fromJson<DateTime>(json['lastUpdatedAt']),
      historyJson: serializer.fromJson<String>(json['historyJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<String>(exerciseId),
      'currentWorkingWeightKg':
          serializer.toJson<double>(currentWorkingWeightKg),
      'lastUpdatedAt': serializer.toJson<DateTime>(lastUpdatedAt),
      'historyJson': serializer.toJson<String>(historyJson),
    };
  }

  ExerciseState copyWith(
          {String? exerciseId,
          double? currentWorkingWeightKg,
          DateTime? lastUpdatedAt,
          String? historyJson}) =>
      ExerciseState(
        exerciseId: exerciseId ?? this.exerciseId,
        currentWorkingWeightKg:
            currentWorkingWeightKg ?? this.currentWorkingWeightKg,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
        historyJson: historyJson ?? this.historyJson,
      );
  ExerciseState copyWithCompanion(ExerciseStatesCompanion data) {
    return ExerciseState(
      exerciseId:
          data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      currentWorkingWeightKg: data.currentWorkingWeightKg.present
          ? data.currentWorkingWeightKg.value
          : this.currentWorkingWeightKg,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
      historyJson:
          data.historyJson.present ? data.historyJson.value : this.historyJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseState(')
          ..write('exerciseId: $exerciseId, ')
          ..write('currentWorkingWeightKg: $currentWorkingWeightKg, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('historyJson: $historyJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      exerciseId, currentWorkingWeightKg, lastUpdatedAt, historyJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseState &&
          other.exerciseId == this.exerciseId &&
          other.currentWorkingWeightKg == this.currentWorkingWeightKg &&
          other.lastUpdatedAt == this.lastUpdatedAt &&
          other.historyJson == this.historyJson);
}

class ExerciseStatesCompanion extends UpdateCompanion<ExerciseState> {
  final Value<String> exerciseId;
  final Value<double> currentWorkingWeightKg;
  final Value<DateTime> lastUpdatedAt;
  final Value<String> historyJson;
  final Value<int> rowid;
  const ExerciseStatesCompanion({
    this.exerciseId = const Value.absent(),
    this.currentWorkingWeightKg = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.historyJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseStatesCompanion.insert({
    required String exerciseId,
    required double currentWorkingWeightKg,
    required DateTime lastUpdatedAt,
    this.historyJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : exerciseId = Value(exerciseId),
        currentWorkingWeightKg = Value(currentWorkingWeightKg),
        lastUpdatedAt = Value(lastUpdatedAt);
  static Insertable<ExerciseState> custom({
    Expression<String>? exerciseId,
    Expression<double>? currentWorkingWeightKg,
    Expression<DateTime>? lastUpdatedAt,
    Expression<String>? historyJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (currentWorkingWeightKg != null)
        'current_working_weight_kg': currentWorkingWeightKg,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (historyJson != null) 'history_json': historyJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseStatesCompanion copyWith(
      {Value<String>? exerciseId,
      Value<double>? currentWorkingWeightKg,
      Value<DateTime>? lastUpdatedAt,
      Value<String>? historyJson,
      Value<int>? rowid}) {
    return ExerciseStatesCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      currentWorkingWeightKg:
          currentWorkingWeightKg ?? this.currentWorkingWeightKg,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      historyJson: historyJson ?? this.historyJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (currentWorkingWeightKg.present) {
      map['current_working_weight_kg'] =
          Variable<double>(currentWorkingWeightKg.value);
    }
    if (lastUpdatedAt.present) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt.value);
    }
    if (historyJson.present) {
      map['history_json'] = Variable<String>(historyJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseStatesCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('currentWorkingWeightKg: $currentWorkingWeightKg, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('historyJson: $historyJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionsTable extends WorkoutSessions
    with TableInfo<$WorkoutSessionsTable, WorkoutSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _programIdMeta =
      const VerificationMeta('programId');
  @override
  late final GeneratedColumn<String> programId = GeneratedColumn<String>(
      'program_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _workoutIdMeta =
      const VerificationMeta('workoutId');
  @override
  late final GeneratedColumn<String> workoutId = GeneratedColumn<String>(
      'workout_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateUtcMeta =
      const VerificationMeta('dateUtc');
  @override
  late final GeneratedColumn<DateTime> dateUtc = GeneratedColumn<DateTime>(
      'date_utc', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _entriesJsonMeta =
      const VerificationMeta('entriesJson');
  @override
  late final GeneratedColumn<String> entriesJson = GeneratedColumn<String>(
      'entries_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _schemaVersionMeta =
      const VerificationMeta('schemaVersion');
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
      'schema_version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        programId,
        workoutId,
        dateUtc,
        startedAt,
        completedAt,
        entriesJson,
        schemaVersion
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<WorkoutSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('program_id')) {
      context.handle(_programIdMeta,
          programId.isAcceptableOrUnknown(data['program_id']!, _programIdMeta));
    } else if (isInserting) {
      context.missing(_programIdMeta);
    }
    if (data.containsKey('workout_id')) {
      context.handle(_workoutIdMeta,
          workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta));
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('date_utc')) {
      context.handle(_dateUtcMeta,
          dateUtc.isAcceptableOrUnknown(data['date_utc']!, _dateUtcMeta));
    } else if (isInserting) {
      context.missing(_dateUtcMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('entries_json')) {
      context.handle(
          _entriesJsonMeta,
          entriesJson.isAcceptableOrUnknown(
              data['entries_json']!, _entriesJsonMeta));
    }
    if (data.containsKey('schema_version')) {
      context.handle(
          _schemaVersionMeta,
          schemaVersion.isAcceptableOrUnknown(
              data['schema_version']!, _schemaVersionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      programId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}program_id'])!,
      workoutId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}workout_id'])!,
      dateUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_utc'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      entriesJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entries_json'])!,
      schemaVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}schema_version'])!,
    );
  }

  @override
  $WorkoutSessionsTable createAlias(String alias) {
    return $WorkoutSessionsTable(attachedDatabase, alias);
  }
}

class WorkoutSession extends DataClass implements Insertable<WorkoutSession> {
  final String id;
  final String programId;
  final String workoutId;
  final DateTime dateUtc;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String entriesJson;
  final int schemaVersion;
  const WorkoutSession(
      {required this.id,
      required this.programId,
      required this.workoutId,
      required this.dateUtc,
      required this.startedAt,
      this.completedAt,
      required this.entriesJson,
      required this.schemaVersion});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['program_id'] = Variable<String>(programId);
    map['workout_id'] = Variable<String>(workoutId);
    map['date_utc'] = Variable<DateTime>(dateUtc);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['entries_json'] = Variable<String>(entriesJson);
    map['schema_version'] = Variable<int>(schemaVersion);
    return map;
  }

  WorkoutSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionsCompanion(
      id: Value(id),
      programId: Value(programId),
      workoutId: Value(workoutId),
      dateUtc: Value(dateUtc),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      entriesJson: Value(entriesJson),
      schemaVersion: Value(schemaVersion),
    );
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSession(
      id: serializer.fromJson<String>(json['id']),
      programId: serializer.fromJson<String>(json['programId']),
      workoutId: serializer.fromJson<String>(json['workoutId']),
      dateUtc: serializer.fromJson<DateTime>(json['dateUtc']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      entriesJson: serializer.fromJson<String>(json['entriesJson']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'programId': serializer.toJson<String>(programId),
      'workoutId': serializer.toJson<String>(workoutId),
      'dateUtc': serializer.toJson<DateTime>(dateUtc),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'entriesJson': serializer.toJson<String>(entriesJson),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
    };
  }

  WorkoutSession copyWith(
          {String? id,
          String? programId,
          String? workoutId,
          DateTime? dateUtc,
          DateTime? startedAt,
          Value<DateTime?> completedAt = const Value.absent(),
          String? entriesJson,
          int? schemaVersion}) =>
      WorkoutSession(
        id: id ?? this.id,
        programId: programId ?? this.programId,
        workoutId: workoutId ?? this.workoutId,
        dateUtc: dateUtc ?? this.dateUtc,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        entriesJson: entriesJson ?? this.entriesJson,
        schemaVersion: schemaVersion ?? this.schemaVersion,
      );
  WorkoutSession copyWithCompanion(WorkoutSessionsCompanion data) {
    return WorkoutSession(
      id: data.id.present ? data.id.value : this.id,
      programId: data.programId.present ? data.programId.value : this.programId,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      dateUtc: data.dateUtc.present ? data.dateUtc.value : this.dateUtc,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      entriesJson:
          data.entriesJson.present ? data.entriesJson.value : this.entriesJson,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSession(')
          ..write('id: $id, ')
          ..write('programId: $programId, ')
          ..write('workoutId: $workoutId, ')
          ..write('dateUtc: $dateUtc, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('entriesJson: $entriesJson, ')
          ..write('schemaVersion: $schemaVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, programId, workoutId, dateUtc, startedAt,
      completedAt, entriesJson, schemaVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSession &&
          other.id == this.id &&
          other.programId == this.programId &&
          other.workoutId == this.workoutId &&
          other.dateUtc == this.dateUtc &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.entriesJson == this.entriesJson &&
          other.schemaVersion == this.schemaVersion);
}

class WorkoutSessionsCompanion extends UpdateCompanion<WorkoutSession> {
  final Value<String> id;
  final Value<String> programId;
  final Value<String> workoutId;
  final Value<DateTime> dateUtc;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<String> entriesJson;
  final Value<int> schemaVersion;
  final Value<int> rowid;
  const WorkoutSessionsCompanion({
    this.id = const Value.absent(),
    this.programId = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.dateUtc = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.entriesJson = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutSessionsCompanion.insert({
    required String id,
    required String programId,
    required String workoutId,
    required DateTime dateUtc,
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    this.entriesJson = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        programId = Value(programId),
        workoutId = Value(workoutId),
        dateUtc = Value(dateUtc),
        startedAt = Value(startedAt);
  static Insertable<WorkoutSession> custom({
    Expression<String>? id,
    Expression<String>? programId,
    Expression<String>? workoutId,
    Expression<DateTime>? dateUtc,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<String>? entriesJson,
    Expression<int>? schemaVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (programId != null) 'program_id': programId,
      if (workoutId != null) 'workout_id': workoutId,
      if (dateUtc != null) 'date_utc': dateUtc,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (entriesJson != null) 'entries_json': entriesJson,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutSessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? programId,
      Value<String>? workoutId,
      Value<DateTime>? dateUtc,
      Value<DateTime>? startedAt,
      Value<DateTime?>? completedAt,
      Value<String>? entriesJson,
      Value<int>? schemaVersion,
      Value<int>? rowid}) {
    return WorkoutSessionsCompanion(
      id: id ?? this.id,
      programId: programId ?? this.programId,
      workoutId: workoutId ?? this.workoutId,
      dateUtc: dateUtc ?? this.dateUtc,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      entriesJson: entriesJson ?? this.entriesJson,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (programId.present) {
      map['program_id'] = Variable<String>(programId.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<String>(workoutId.value);
    }
    if (dateUtc.present) {
      map['date_utc'] = Variable<DateTime>(dateUtc.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (entriesJson.present) {
      map['entries_json'] = Variable<String>(entriesJson.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionsCompanion(')
          ..write('id: $id, ')
          ..write('programId: $programId, ')
          ..write('workoutId: $workoutId, ')
          ..write('dateUtc: $dateUtc, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('entriesJson: $entriesJson, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsEntriesTable extends SettingsEntries
    with TableInfo<$SettingsEntriesTable, SettingsEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_entries';
  @override
  VerificationContext validateIntegrity(Insertable<SettingsEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingsEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsEntry(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SettingsEntriesTable createAlias(String alias) {
    return $SettingsEntriesTable(attachedDatabase, alias);
  }
}

class SettingsEntry extends DataClass implements Insertable<SettingsEntry> {
  final String key;
  final String value;
  const SettingsEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsEntriesCompanion toCompanion(bool nullToAbsent) {
    return SettingsEntriesCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory SettingsEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingsEntry copyWith({String? key, String? value}) => SettingsEntry(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  SettingsEntry copyWithCompanion(SettingsEntriesCompanion data) {
    return SettingsEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsEntriesCompanion extends UpdateCompanion<SettingsEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<SettingsEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsEntriesCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SettingsEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ExerciseStatesTable exerciseStates = $ExerciseStatesTable(this);
  late final $WorkoutSessionsTable workoutSessions =
      $WorkoutSessionsTable(this);
  late final $SettingsEntriesTable settingsEntries =
      $SettingsEntriesTable(this);
  late final ExerciseStateDao exerciseStateDao =
      ExerciseStateDao(this as AppDatabase);
  late final WorkoutSessionDao workoutSessionDao =
      WorkoutSessionDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [exerciseStates, workoutSessions, settingsEntries];
}

typedef $$ExerciseStatesTableCreateCompanionBuilder = ExerciseStatesCompanion
    Function({
  required String exerciseId,
  required double currentWorkingWeightKg,
  required DateTime lastUpdatedAt,
  Value<String> historyJson,
  Value<int> rowid,
});
typedef $$ExerciseStatesTableUpdateCompanionBuilder = ExerciseStatesCompanion
    Function({
  Value<String> exerciseId,
  Value<double> currentWorkingWeightKg,
  Value<DateTime> lastUpdatedAt,
  Value<String> historyJson,
  Value<int> rowid,
});

class $$ExerciseStatesTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseStatesTable> {
  $$ExerciseStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get exerciseId => $composableBuilder(
      column: $table.exerciseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get currentWorkingWeightKg => $composableBuilder(
      column: $table.currentWorkingWeightKg,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get historyJson => $composableBuilder(
      column: $table.historyJson, builder: (column) => ColumnFilters(column));
}

class $$ExerciseStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseStatesTable> {
  $$ExerciseStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get exerciseId => $composableBuilder(
      column: $table.exerciseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentWorkingWeightKg => $composableBuilder(
      column: $table.currentWorkingWeightKg,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get historyJson => $composableBuilder(
      column: $table.historyJson, builder: (column) => ColumnOrderings(column));
}

class $$ExerciseStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseStatesTable> {
  $$ExerciseStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get exerciseId => $composableBuilder(
      column: $table.exerciseId, builder: (column) => column);

  GeneratedColumn<double> get currentWorkingWeightKg => $composableBuilder(
      column: $table.currentWorkingWeightKg, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => column);

  GeneratedColumn<String> get historyJson => $composableBuilder(
      column: $table.historyJson, builder: (column) => column);
}

class $$ExerciseStatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExerciseStatesTable,
    ExerciseState,
    $$ExerciseStatesTableFilterComposer,
    $$ExerciseStatesTableOrderingComposer,
    $$ExerciseStatesTableAnnotationComposer,
    $$ExerciseStatesTableCreateCompanionBuilder,
    $$ExerciseStatesTableUpdateCompanionBuilder,
    (
      ExerciseState,
      BaseReferences<_$AppDatabase, $ExerciseStatesTable, ExerciseState>
    ),
    ExerciseState,
    PrefetchHooks Function()> {
  $$ExerciseStatesTableTableManager(
      _$AppDatabase db, $ExerciseStatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> exerciseId = const Value.absent(),
            Value<double> currentWorkingWeightKg = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
            Value<String> historyJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExerciseStatesCompanion(
            exerciseId: exerciseId,
            currentWorkingWeightKg: currentWorkingWeightKg,
            lastUpdatedAt: lastUpdatedAt,
            historyJson: historyJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String exerciseId,
            required double currentWorkingWeightKg,
            required DateTime lastUpdatedAt,
            Value<String> historyJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExerciseStatesCompanion.insert(
            exerciseId: exerciseId,
            currentWorkingWeightKg: currentWorkingWeightKg,
            lastUpdatedAt: lastUpdatedAt,
            historyJson: historyJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExerciseStatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExerciseStatesTable,
    ExerciseState,
    $$ExerciseStatesTableFilterComposer,
    $$ExerciseStatesTableOrderingComposer,
    $$ExerciseStatesTableAnnotationComposer,
    $$ExerciseStatesTableCreateCompanionBuilder,
    $$ExerciseStatesTableUpdateCompanionBuilder,
    (
      ExerciseState,
      BaseReferences<_$AppDatabase, $ExerciseStatesTable, ExerciseState>
    ),
    ExerciseState,
    PrefetchHooks Function()>;
typedef $$WorkoutSessionsTableCreateCompanionBuilder = WorkoutSessionsCompanion
    Function({
  required String id,
  required String programId,
  required String workoutId,
  required DateTime dateUtc,
  required DateTime startedAt,
  Value<DateTime?> completedAt,
  Value<String> entriesJson,
  Value<int> schemaVersion,
  Value<int> rowid,
});
typedef $$WorkoutSessionsTableUpdateCompanionBuilder = WorkoutSessionsCompanion
    Function({
  Value<String> id,
  Value<String> programId,
  Value<String> workoutId,
  Value<DateTime> dateUtc,
  Value<DateTime> startedAt,
  Value<DateTime?> completedAt,
  Value<String> entriesJson,
  Value<int> schemaVersion,
  Value<int> rowid,
});

class $$WorkoutSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get programId => $composableBuilder(
      column: $table.programId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get workoutId => $composableBuilder(
      column: $table.workoutId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateUtc => $composableBuilder(
      column: $table.dateUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entriesJson => $composableBuilder(
      column: $table.entriesJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion, builder: (column) => ColumnFilters(column));
}

class $$WorkoutSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get programId => $composableBuilder(
      column: $table.programId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get workoutId => $composableBuilder(
      column: $table.workoutId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateUtc => $composableBuilder(
      column: $table.dateUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entriesJson => $composableBuilder(
      column: $table.entriesJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion,
      builder: (column) => ColumnOrderings(column));
}

class $$WorkoutSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get programId =>
      $composableBuilder(column: $table.programId, builder: (column) => column);

  GeneratedColumn<String> get workoutId =>
      $composableBuilder(column: $table.workoutId, builder: (column) => column);

  GeneratedColumn<DateTime> get dateUtc =>
      $composableBuilder(column: $table.dateUtc, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<String> get entriesJson => $composableBuilder(
      column: $table.entriesJson, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion, builder: (column) => column);
}

class $$WorkoutSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkoutSessionsTable,
    WorkoutSession,
    $$WorkoutSessionsTableFilterComposer,
    $$WorkoutSessionsTableOrderingComposer,
    $$WorkoutSessionsTableAnnotationComposer,
    $$WorkoutSessionsTableCreateCompanionBuilder,
    $$WorkoutSessionsTableUpdateCompanionBuilder,
    (
      WorkoutSession,
      BaseReferences<_$AppDatabase, $WorkoutSessionsTable, WorkoutSession>
    ),
    WorkoutSession,
    PrefetchHooks Function()> {
  $$WorkoutSessionsTableTableManager(
      _$AppDatabase db, $WorkoutSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> programId = const Value.absent(),
            Value<String> workoutId = const Value.absent(),
            Value<DateTime> dateUtc = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<String> entriesJson = const Value.absent(),
            Value<int> schemaVersion = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkoutSessionsCompanion(
            id: id,
            programId: programId,
            workoutId: workoutId,
            dateUtc: dateUtc,
            startedAt: startedAt,
            completedAt: completedAt,
            entriesJson: entriesJson,
            schemaVersion: schemaVersion,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String programId,
            required String workoutId,
            required DateTime dateUtc,
            required DateTime startedAt,
            Value<DateTime?> completedAt = const Value.absent(),
            Value<String> entriesJson = const Value.absent(),
            Value<int> schemaVersion = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkoutSessionsCompanion.insert(
            id: id,
            programId: programId,
            workoutId: workoutId,
            dateUtc: dateUtc,
            startedAt: startedAt,
            completedAt: completedAt,
            entriesJson: entriesJson,
            schemaVersion: schemaVersion,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WorkoutSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkoutSessionsTable,
    WorkoutSession,
    $$WorkoutSessionsTableFilterComposer,
    $$WorkoutSessionsTableOrderingComposer,
    $$WorkoutSessionsTableAnnotationComposer,
    $$WorkoutSessionsTableCreateCompanionBuilder,
    $$WorkoutSessionsTableUpdateCompanionBuilder,
    (
      WorkoutSession,
      BaseReferences<_$AppDatabase, $WorkoutSessionsTable, WorkoutSession>
    ),
    WorkoutSession,
    PrefetchHooks Function()>;
typedef $$SettingsEntriesTableCreateCompanionBuilder = SettingsEntriesCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsEntriesTableUpdateCompanionBuilder = SettingsEntriesCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SettingsEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SettingsEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsEntriesTable,
    SettingsEntry,
    $$SettingsEntriesTableFilterComposer,
    $$SettingsEntriesTableOrderingComposer,
    $$SettingsEntriesTableAnnotationComposer,
    $$SettingsEntriesTableCreateCompanionBuilder,
    $$SettingsEntriesTableUpdateCompanionBuilder,
    (
      SettingsEntry,
      BaseReferences<_$AppDatabase, $SettingsEntriesTable, SettingsEntry>
    ),
    SettingsEntry,
    PrefetchHooks Function()> {
  $$SettingsEntriesTableTableManager(
      _$AppDatabase db, $SettingsEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsEntriesCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsEntriesCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsEntriesTable,
    SettingsEntry,
    $$SettingsEntriesTableFilterComposer,
    $$SettingsEntriesTableOrderingComposer,
    $$SettingsEntriesTableAnnotationComposer,
    $$SettingsEntriesTableCreateCompanionBuilder,
    $$SettingsEntriesTableUpdateCompanionBuilder,
    (
      SettingsEntry,
      BaseReferences<_$AppDatabase, $SettingsEntriesTable, SettingsEntry>
    ),
    SettingsEntry,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ExerciseStatesTableTableManager get exerciseStates =>
      $$ExerciseStatesTableTableManager(_db, _db.exerciseStates);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(_db, _db.workoutSessions);
  $$SettingsEntriesTableTableManager get settingsEntries =>
      $$SettingsEntriesTableTableManager(_db, _db.settingsEntries);
}

mixin _$ExerciseStateDaoMixin on DatabaseAccessor<AppDatabase> {
  $ExerciseStatesTable get exerciseStates => attachedDatabase.exerciseStates;
  ExerciseStateDaoManager get managers => ExerciseStateDaoManager(this);
}

class ExerciseStateDaoManager {
  final _$ExerciseStateDaoMixin _db;
  ExerciseStateDaoManager(this._db);
  $$ExerciseStatesTableTableManager get exerciseStates =>
      $$ExerciseStatesTableTableManager(
          _db.attachedDatabase, _db.exerciseStates);
}

mixin _$WorkoutSessionDaoMixin on DatabaseAccessor<AppDatabase> {
  $WorkoutSessionsTable get workoutSessions => attachedDatabase.workoutSessions;
  WorkoutSessionDaoManager get managers => WorkoutSessionDaoManager(this);
}

class WorkoutSessionDaoManager {
  final _$WorkoutSessionDaoMixin _db;
  WorkoutSessionDaoManager(this._db);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(
          _db.attachedDatabase, _db.workoutSessions);
}

mixin _$SettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SettingsEntriesTable get settingsEntries => attachedDatabase.settingsEntries;
  SettingsDaoManager get managers => SettingsDaoManager(this);
}

class SettingsDaoManager {
  final _$SettingsDaoMixin _db;
  SettingsDaoManager(this._db);
  $$SettingsEntriesTableTableManager get settingsEntries =>
      $$SettingsEntriesTableTableManager(
          _db.attachedDatabase, _db.settingsEntries);
}
