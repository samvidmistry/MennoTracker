/// Runtime/session model JSON contract for MennoTracker.
///
/// JSON keys are camelCase and must match the Dart field names. DateTime values
/// serialize as ISO-8601 UTC strings with a trailing `Z`. Enums serialize as
/// their Dart `.name` string. `schemaVersion` is required on `WorkoutSession`
/// and `WatchPayload` JSON and currently defaults to `1` when reading older
/// payloads that omit it.
///
/// The Swift mirror at `apps/phone/ios/MennoWatch/WatchPayload.swift` must
/// match this contract exactly.
library;

import 'package:meta/meta.dart';

import 'json_helpers.dart';

const Object _unset = Object();

/// Why an exercise's working weight changed.
enum WeightChangeReason {
  increment,
  deload,
  manual,
  firstTime;

  /// Parses a serialized enum name, falling back to [manual] when unknown.
  static WeightChangeReason fromJson(String? value) =>
      parseWeightChangeReason(value);

  /// Serializes this reason as its Dart enum name.
  String toJson() => name;
}

/// Parses a weight-change reason name, defaulting to [WeightChangeReason.manual].
WeightChangeReason parseWeightChangeReason(String? value) {
  for (final reason in WeightChangeReason.values) {
    if (reason.name == value) {
      return reason;
    }
  }

  return WeightChangeReason.manual;
}

@immutable
class WeightChange {
  const WeightChange({
    required this.fromKg,
    required this.toKg,
    required this.atUtc,
    this.reason = WeightChangeReason.manual,
  });

  factory WeightChange.fromJson(Map<String, Object?> json) => WeightChange(
        fromKg: _requiredDouble(json, 'fromKg'),
        toKg: _requiredDouble(json, 'toKg'),
        atUtc: _requiredDateTime(json, 'atUtc'),
        reason: WeightChangeReason.fromJson(_optionalString(json, 'reason')),
      );

  final double fromKg;
  final double toKg;
  final DateTime atUtc;
  final WeightChangeReason reason;

  Map<String, Object?> toJson() => <String, Object?>{
        'fromKg': fromKg,
        'toKg': toKg,
        'atUtc': dateTimeToIso8601Utc(atUtc),
        'reason': reason.toJson(),
      };

  WeightChange copyWith({
    double? fromKg,
    double? toKg,
    DateTime? atUtc,
    WeightChangeReason? reason,
  }) =>
      WeightChange(
        fromKg: fromKg ?? this.fromKg,
        toKg: toKg ?? this.toKg,
        atUtc: atUtc ?? this.atUtc,
        reason: reason ?? this.reason,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightChange &&
          fromKg == other.fromKg &&
          toKg == other.toKg &&
          atUtc == other.atUtc &&
          reason == other.reason;

  @override
  int get hashCode => Object.hash(
        fromKg,
        toKg,
        _dateTimeHash(atUtc),
        reason,
      );
}

@immutable
class ExerciseState {
  ExerciseState({
    required this.exerciseId,
    required this.currentWorkingWeightKg,
    required this.lastUpdatedAt,
    List<WeightChange> history = const <WeightChange>[],
  }) : history = List<WeightChange>.unmodifiable(history);

  factory ExerciseState.fromJson(Map<String, Object?> json) => ExerciseState(
        exerciseId: _requiredString(json, 'exerciseId'),
        currentWorkingWeightKg: _requiredDouble(json, 'currentWorkingWeightKg'),
        lastUpdatedAt: _requiredDateTime(json, 'lastUpdatedAt'),
        history: _jsonList(
          json,
          'history',
          (value) => WeightChange.fromJson(_jsonObject(value, 'history')),
          defaultEmpty: true,
        ),
      );

  final String exerciseId;
  final double currentWorkingWeightKg;
  final DateTime lastUpdatedAt;
  final List<WeightChange> history;

  Map<String, Object?> toJson() => <String, Object?>{
        'exerciseId': exerciseId,
        'currentWorkingWeightKg': currentWorkingWeightKg,
        'lastUpdatedAt': dateTimeToIso8601Utc(lastUpdatedAt),
        'history': history.map((change) => change.toJson()).toList(),
      };

  ExerciseState copyWith({
    String? exerciseId,
    double? currentWorkingWeightKg,
    DateTime? lastUpdatedAt,
    List<WeightChange>? history,
  }) =>
      ExerciseState(
        exerciseId: exerciseId ?? this.exerciseId,
        currentWorkingWeightKg:
            currentWorkingWeightKg ?? this.currentWorkingWeightKg,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
        history: history ?? this.history,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseState &&
          exerciseId == other.exerciseId &&
          currentWorkingWeightKg == other.currentWorkingWeightKg &&
          lastUpdatedAt == other.lastUpdatedAt &&
          _listEquals(history, other.history);

  @override
  int get hashCode => Object.hash(
        exerciseId,
        currentWorkingWeightKg,
        _dateTimeHash(lastUpdatedAt),
        Object.hashAll(history),
      );
}

@immutable
class SetLog {
  const SetLog({
    required this.targetRepMin,
    required this.targetRepMax,
    required this.actualReps,
    this.rpe,
    required this.completedAt,
    this.isWarmup = false,
    this.isFailed = false,
  });

  factory SetLog.fromJson(Map<String, Object?> json) => SetLog(
        targetRepMin: _requiredInt(json, 'targetRepMin'),
        targetRepMax: _requiredInt(json, 'targetRepMax'),
        actualReps: _requiredInt(json, 'actualReps'),
        rpe: _optionalDouble(json, 'rpe'),
        completedAt: _requiredDateTime(json, 'completedAt'),
        isWarmup: _boolWithDefault(json, 'isWarmup', defaultValue: false),
        isFailed: _boolWithDefault(json, 'isFailed', defaultValue: false),
      );

  final int targetRepMin;
  final int targetRepMax;
  final int actualReps;
  final double? rpe;
  final DateTime completedAt;
  final bool isWarmup;
  final bool isFailed;

  Map<String, Object?> toJson() => <String, Object?>{
        'targetRepMin': targetRepMin,
        'targetRepMax': targetRepMax,
        'actualReps': actualReps,
        'rpe': rpe,
        'completedAt': dateTimeToIso8601Utc(completedAt),
        'isWarmup': isWarmup,
        'isFailed': isFailed,
      };

  SetLog copyWith({
    int? targetRepMin,
    int? targetRepMax,
    int? actualReps,
    Object? rpe = _unset,
    DateTime? completedAt,
    bool? isWarmup,
    bool? isFailed,
  }) =>
      SetLog(
        targetRepMin: targetRepMin ?? this.targetRepMin,
        targetRepMax: targetRepMax ?? this.targetRepMax,
        actualReps: actualReps ?? this.actualReps,
        rpe: identical(rpe, _unset) ? this.rpe : rpe as double?,
        completedAt: completedAt ?? this.completedAt,
        isWarmup: isWarmup ?? this.isWarmup,
        isFailed: isFailed ?? this.isFailed,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetLog &&
          targetRepMin == other.targetRepMin &&
          targetRepMax == other.targetRepMax &&
          actualReps == other.actualReps &&
          rpe == other.rpe &&
          completedAt == other.completedAt &&
          isWarmup == other.isWarmup &&
          isFailed == other.isFailed;

  @override
  int get hashCode => Object.hash(
        targetRepMin,
        targetRepMax,
        actualReps,
        rpe,
        _dateTimeHash(completedAt),
        isWarmup,
        isFailed,
      );
}

@immutable
class ExerciseEntry {
  ExerciseEntry({
    required this.blockId,
    required this.exerciseId,
    required this.workingWeightKg,
    List<SetLog> sets = const <SetLog>[],
    this.suggestionAppliedKg,
  }) : sets = List<SetLog>.unmodifiable(sets);

  factory ExerciseEntry.fromJson(Map<String, Object?> json) => ExerciseEntry(
        blockId: _requiredString(json, 'blockId'),
        exerciseId: _requiredString(json, 'exerciseId'),
        workingWeightKg: _requiredDouble(json, 'workingWeightKg'),
        sets: _jsonList(
          json,
          'sets',
          (value) => SetLog.fromJson(_jsonObject(value, 'sets')),
          defaultEmpty: true,
        ),
        suggestionAppliedKg: _optionalDouble(json, 'suggestionAppliedKg'),
      );

  final String blockId;
  final String exerciseId;
  final double workingWeightKg;
  final List<SetLog> sets;
  final double? suggestionAppliedKg;

  Map<String, Object?> toJson() => <String, Object?>{
        'blockId': blockId,
        'exerciseId': exerciseId,
        'workingWeightKg': workingWeightKg,
        'sets': sets.map((set) => set.toJson()).toList(),
        'suggestionAppliedKg': suggestionAppliedKg,
      };

  ExerciseEntry copyWith({
    String? blockId,
    String? exerciseId,
    double? workingWeightKg,
    List<SetLog>? sets,
    Object? suggestionAppliedKg = _unset,
  }) =>
      ExerciseEntry(
        blockId: blockId ?? this.blockId,
        exerciseId: exerciseId ?? this.exerciseId,
        workingWeightKg: workingWeightKg ?? this.workingWeightKg,
        sets: sets ?? this.sets,
        suggestionAppliedKg: identical(suggestionAppliedKg, _unset)
            ? this.suggestionAppliedKg
            : suggestionAppliedKg as double?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseEntry &&
          blockId == other.blockId &&
          exerciseId == other.exerciseId &&
          workingWeightKg == other.workingWeightKg &&
          _listEquals(sets, other.sets) &&
          suggestionAppliedKg == other.suggestionAppliedKg;

  @override
  int get hashCode => Object.hash(
        blockId,
        exerciseId,
        workingWeightKg,
        Object.hashAll(sets),
        suggestionAppliedKg,
      );
}

@immutable
class WorkoutSession {
  WorkoutSession({
    required this.id,
    required this.programId,
    required this.workoutId,
    required this.dateUtc,
    required this.startedAt,
    this.completedAt,
    List<ExerciseEntry> entries = const <ExerciseEntry>[],
    this.schemaVersion = currentSchemaVersion,
  }) : entries = List<ExerciseEntry>.unmodifiable(entries);

  factory WorkoutSession.fromJson(Map<String, Object?> json) => WorkoutSession(
        id: _requiredString(json, 'id'),
        programId: _requiredString(json, 'programId'),
        workoutId: _requiredString(json, 'workoutId'),
        dateUtc: _requiredDateTime(json, 'dateUtc'),
        startedAt: _requiredDateTime(json, 'startedAt'),
        completedAt: _optionalDateTime(json, 'completedAt'),
        entries: _jsonList(
          json,
          'entries',
          (value) => ExerciseEntry.fromJson(_jsonObject(value, 'entries')),
          defaultEmpty: true,
        ),
        schemaVersion: _intWithDefault(
          json,
          'schemaVersion',
          defaultValue: currentSchemaVersion,
        ),
      );

  static const int currentSchemaVersion = 1;

  final String id;
  final String programId;
  final String workoutId;
  final DateTime dateUtc;
  final DateTime startedAt;
  final DateTime? completedAt;
  final List<ExerciseEntry> entries;
  final int schemaVersion;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'programId': programId,
        'workoutId': workoutId,
        'dateUtc': dateTimeToIso8601Utc(dateUtc),
        'startedAt': dateTimeToIso8601Utc(startedAt),
        'completedAt':
            completedAt == null ? null : dateTimeToIso8601Utc(completedAt!),
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'schemaVersion': schemaVersion,
      };

  WorkoutSession copyWith({
    String? id,
    String? programId,
    String? workoutId,
    DateTime? dateUtc,
    DateTime? startedAt,
    Object? completedAt = _unset,
    List<ExerciseEntry>? entries,
    int? schemaVersion,
  }) =>
      WorkoutSession(
        id: id ?? this.id,
        programId: programId ?? this.programId,
        workoutId: workoutId ?? this.workoutId,
        dateUtc: dateUtc ?? this.dateUtc,
        startedAt: startedAt ?? this.startedAt,
        completedAt: identical(completedAt, _unset)
            ? this.completedAt
            : completedAt as DateTime?,
        entries: entries ?? this.entries,
        schemaVersion: schemaVersion ?? this.schemaVersion,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSession &&
          id == other.id &&
          programId == other.programId &&
          workoutId == other.workoutId &&
          dateUtc == other.dateUtc &&
          startedAt == other.startedAt &&
          completedAt == other.completedAt &&
          _listEquals(entries, other.entries) &&
          schemaVersion == other.schemaVersion;

  @override
  int get hashCode => Object.hash(
        id,
        programId,
        workoutId,
        _dateTimeHash(dateUtc),
        _dateTimeHash(startedAt),
        completedAt == null ? null : _dateTimeHash(completedAt!),
        Object.hashAll(entries),
        schemaVersion,
      );
}

@immutable
class WatchPayload {
  WatchPayload({
    this.schemaVersion = currentSchemaVersion,
    required this.sessionId,
    required this.workoutId,
    required this.workoutName,
    List<WatchExerciseBlock> blocks = const <WatchExerciseBlock>[],
  }) : blocks = List<WatchExerciseBlock>.unmodifiable(blocks);

  factory WatchPayload.fromJson(Map<String, Object?> json) => WatchPayload(
        schemaVersion: _intWithDefault(
          json,
          'schemaVersion',
          defaultValue: currentSchemaVersion,
        ),
        sessionId: _requiredString(json, 'sessionId'),
        workoutId: _requiredString(json, 'workoutId'),
        workoutName: _requiredString(json, 'workoutName'),
        blocks: _jsonList(
          json,
          'blocks',
          (value) => WatchExerciseBlock.fromJson(_jsonObject(value, 'blocks')),
          defaultEmpty: true,
        ),
      );

  static const int currentSchemaVersion = 1;

  final int schemaVersion;
  final String sessionId;
  final String workoutId;
  final String workoutName;
  final List<WatchExerciseBlock> blocks;

  Map<String, Object?> toJson() => <String, Object?>{
        'schemaVersion': schemaVersion,
        'sessionId': sessionId,
        'workoutId': workoutId,
        'workoutName': workoutName,
        'blocks': blocks.map((block) => block.toJson()).toList(),
      };

  WatchPayload copyWith({
    int? schemaVersion,
    String? sessionId,
    String? workoutId,
    String? workoutName,
    List<WatchExerciseBlock>? blocks,
  }) =>
      WatchPayload(
        schemaVersion: schemaVersion ?? this.schemaVersion,
        sessionId: sessionId ?? this.sessionId,
        workoutId: workoutId ?? this.workoutId,
        workoutName: workoutName ?? this.workoutName,
        blocks: blocks ?? this.blocks,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchPayload &&
          schemaVersion == other.schemaVersion &&
          sessionId == other.sessionId &&
          workoutId == other.workoutId &&
          workoutName == other.workoutName &&
          _listEquals(blocks, other.blocks);

  @override
  int get hashCode => Object.hash(
        schemaVersion,
        sessionId,
        workoutId,
        workoutName,
        Object.hashAll(blocks),
      );
}

@immutable
class WatchExerciseBlock {
  const WatchExerciseBlock({
    required this.blockId,
    required this.exerciseId,
    required this.exerciseName,
    required this.workingWeightKg,
    required this.targetSets,
    required this.repMin,
    required this.repMax,
    required this.restSeconds,
  });

  factory WatchExerciseBlock.fromJson(Map<String, Object?> json) =>
      WatchExerciseBlock(
        blockId: _requiredString(json, 'blockId'),
        exerciseId: _requiredString(json, 'exerciseId'),
        exerciseName: _requiredString(json, 'exerciseName'),
        workingWeightKg: _requiredDouble(json, 'workingWeightKg'),
        targetSets: _requiredInt(json, 'targetSets'),
        repMin: _requiredInt(json, 'repMin'),
        repMax: _requiredInt(json, 'repMax'),
        restSeconds: _requiredInt(json, 'restSeconds'),
      );

  final String blockId;
  final String exerciseId;
  final String exerciseName;
  final double workingWeightKg;
  final int targetSets;
  final int repMin;
  final int repMax;
  final int restSeconds;

  Map<String, Object?> toJson() => <String, Object?>{
        'blockId': blockId,
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'workingWeightKg': workingWeightKg,
        'targetSets': targetSets,
        'repMin': repMin,
        'repMax': repMax,
        'restSeconds': restSeconds,
      };

  WatchExerciseBlock copyWith({
    String? blockId,
    String? exerciseId,
    String? exerciseName,
    double? workingWeightKg,
    int? targetSets,
    int? repMin,
    int? repMax,
    int? restSeconds,
  }) =>
      WatchExerciseBlock(
        blockId: blockId ?? this.blockId,
        exerciseId: exerciseId ?? this.exerciseId,
        exerciseName: exerciseName ?? this.exerciseName,
        workingWeightKg: workingWeightKg ?? this.workingWeightKg,
        targetSets: targetSets ?? this.targetSets,
        repMin: repMin ?? this.repMin,
        repMax: repMax ?? this.repMax,
        restSeconds: restSeconds ?? this.restSeconds,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchExerciseBlock &&
          blockId == other.blockId &&
          exerciseId == other.exerciseId &&
          exerciseName == other.exerciseName &&
          workingWeightKg == other.workingWeightKg &&
          targetSets == other.targetSets &&
          repMin == other.repMin &&
          repMax == other.repMax &&
          restSeconds == other.restSeconds;

  @override
  int get hashCode => Object.hash(
        blockId,
        exerciseId,
        exerciseName,
        workingWeightKg,
        targetSets,
        repMin,
        repMax,
        restSeconds,
      );
}

Object? _requiredValue(Map<String, Object?> json, String fieldName) {
  if (!json.containsKey(fieldName) || json[fieldName] == null) {
    throw FormatException('Missing required field `$fieldName`.');
  }

  return json[fieldName];
}

String _requiredString(Map<String, Object?> json, String fieldName) {
  final value = _requiredValue(json, fieldName);
  if (value is String) {
    return value;
  }

  throw FormatException('Field `$fieldName` must be a string.', value);
}

String? _optionalString(Map<String, Object?> json, String fieldName) {
  final value = json[fieldName];
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }

  throw FormatException('Field `$fieldName` must be a string.', value);
}

int _requiredInt(Map<String, Object?> json, String fieldName) {
  final value = _requiredValue(json, fieldName);
  if (value is int) {
    return value;
  }

  throw FormatException('Field `$fieldName` must be an integer.', value);
}

int _intWithDefault(
  Map<String, Object?> json,
  String fieldName, {
  required int defaultValue,
}) {
  final value = json[fieldName];
  if (value == null) {
    return defaultValue;
  }
  if (value is int) {
    return value;
  }

  throw FormatException('Field `$fieldName` must be an integer.', value);
}

double _requiredDouble(Map<String, Object?> json, String fieldName) {
  final value = _requiredValue(json, fieldName);
  if (value is num) {
    return value.toDouble();
  }

  throw FormatException('Field `$fieldName` must be a number.', value);
}

double? _optionalDouble(Map<String, Object?> json, String fieldName) {
  final value = json[fieldName];
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toDouble();
  }

  throw FormatException('Field `$fieldName` must be a number.', value);
}

bool _boolWithDefault(
  Map<String, Object?> json,
  String fieldName, {
  required bool defaultValue,
}) {
  final value = json[fieldName];
  if (value == null) {
    return defaultValue;
  }
  if (value is bool) {
    return value;
  }

  throw FormatException('Field `$fieldName` must be a boolean.', value);
}

DateTime _requiredDateTime(Map<String, Object?> json, String fieldName) =>
    parseUtcDateTime(_requiredValue(json, fieldName), fieldName);

DateTime? _optionalDateTime(Map<String, Object?> json, String fieldName) {
  final value = json[fieldName];
  if (value == null) {
    return null;
  }

  return parseUtcDateTime(value, fieldName);
}

List<T> _jsonList<T>(
  Map<String, Object?> json,
  String fieldName,
  T Function(Object? value) parseItem, {
  bool defaultEmpty = false,
}) {
  final value = json[fieldName];
  if (value == null) {
    if (defaultEmpty) {
      return const <Never>[];
    }
    throw FormatException('Missing required field `$fieldName`.');
  }
  if (value is! List) {
    throw FormatException('Field `$fieldName` must be a list.', value);
  }

  return List<T>.unmodifiable(value.map(parseItem));
}

Map<String, Object?> _jsonObject(Object? value, String fieldName) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, value) {
      if (key is! String) {
        throw FormatException(
          'Field `$fieldName` must contain JSON objects with string keys.',
          key,
        );
      }

      return MapEntry<String, Object?>(key, value);
    });
  }

  throw FormatException('Field `$fieldName` must contain JSON objects.', value);
}

bool _listEquals<T>(List<T> left, List<T> right) {
  if (identical(left, right)) {
    return true;
  }
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) {
      return false;
    }
  }

  return true;
}

int _dateTimeHash(DateTime value) => value.toUtc().microsecondsSinceEpoch;
