import 'package:meta/meta.dart';

@immutable
class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.defaultIncrementKg,
    required this.smallestPlatePairKg,
    required this.isBarbell,
  });

  factory Exercise.fromJson(Map<String, Object?> json) {
    return Exercise(
      id: json['id']! as String,
      name: json['name']! as String,
      category: ExerciseCategory.values.byName(json['category']! as String),
      defaultIncrementKg: _doubleFromJson(json['defaultIncrementKg']),
      smallestPlatePairKg: _doubleFromJson(json['smallestPlatePairKg']),
      isBarbell: json['isBarbell']! as bool,
    );
  }

  final String id;
  final String name;
  final ExerciseCategory category;
  final double defaultIncrementKg;
  final double smallestPlatePairKg;
  final bool isBarbell;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'defaultIncrementKg': defaultIncrementKg,
      'smallestPlatePairKg': smallestPlatePairKg,
      'isBarbell': isBarbell,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Exercise &&
            other.id == id &&
            other.name == name &&
            other.category == category &&
            other.defaultIncrementKg == defaultIncrementKg &&
            other.smallestPlatePairKg == smallestPlatePairKg &&
            other.isBarbell == isBarbell;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        category,
        defaultIncrementKg,
        smallestPlatePairKg,
        isBarbell,
      );
}

enum ExerciseCategory { legs, push, pull, calves, shoulders, arms, hinge, core }

@immutable
class ExerciseBlock {
  const ExerciseBlock({
    required this.id,
    required this.exerciseId,
    required this.minSets,
    required this.maxSets,
    required this.repMin,
    required this.repMax,
    required this.restMinSeconds,
    required this.restMaxSeconds,
    this.equipmentHint,
  });

  factory ExerciseBlock.fromJson(Map<String, Object?> json) {
    return ExerciseBlock(
      id: json['id']! as String,
      exerciseId: json['exerciseId']! as String,
      minSets: _intFromJson(json['minSets']),
      maxSets: _intFromJson(json['maxSets']),
      repMin: _intFromJson(json['repMin']),
      repMax: _intFromJson(json['repMax']),
      restMinSeconds: _intFromJson(json['restMinSeconds']),
      restMaxSeconds: _intFromJson(json['restMaxSeconds']),
      equipmentHint: json['equipmentHint'] as String?,
    );
  }

  final String id;
  final String exerciseId;
  final int minSets;
  final int maxSets;
  final int repMin;
  final int repMax;
  final int restMinSeconds;
  final int restMaxSeconds;
  final String? equipmentHint;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'minSets': minSets,
      'maxSets': maxSets,
      'repMin': repMin,
      'repMax': repMax,
      'restMinSeconds': restMinSeconds,
      'restMaxSeconds': restMaxSeconds,
      'equipmentHint': equipmentHint,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ExerciseBlock &&
            other.id == id &&
            other.exerciseId == exerciseId &&
            other.minSets == minSets &&
            other.maxSets == maxSets &&
            other.repMin == repMin &&
            other.repMax == repMax &&
            other.restMinSeconds == restMinSeconds &&
            other.restMaxSeconds == restMaxSeconds &&
            other.equipmentHint == equipmentHint;
  }

  @override
  int get hashCode => Object.hash(
        id,
        exerciseId,
        minSets,
        maxSets,
        repMin,
        repMax,
        restMinSeconds,
        restMaxSeconds,
        equipmentHint,
      );
}

@immutable
class Workout {
  const Workout({
    required this.id,
    required this.name,
    required this.blocks,
  });

  factory Workout.fromJson(Map<String, Object?> json) {
    return Workout(
      id: json['id']! as String,
      name: json['name']! as String,
      blocks: _listFromJson(json['blocks'])
          .map((block) => ExerciseBlock.fromJson(_mapFromJson(block)))
          .toList(),
    );
  }

  final String id;
  final String name;
  final List<ExerciseBlock> blocks;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'blocks': blocks.map((block) => block.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Workout &&
            other.id == id &&
            other.name == name &&
            _listEquals(other.blocks, blocks);
  }

  @override
  int get hashCode => Object.hash(id, name, Object.hashAll(blocks));
}

@immutable
class Program {
  const Program({
    required this.id,
    required this.name,
    required this.weeks,
    required this.schedulePattern,
    required this.workouts,
    required this.exercises,
  });

  factory Program.fromJson(Map<String, Object?> json) {
    return Program(
      id: json['id']! as String,
      name: json['name']! as String,
      weeks: _intFromJson(json['weeks']),
      schedulePattern: _listFromJson(json['schedulePattern'])
          .map((entry) => entry! as String)
          .toList(),
      workouts: _listFromJson(json['workouts'])
          .map((workout) => Workout.fromJson(_mapFromJson(workout)))
          .toList(),
      exercises: _listFromJson(json['exercises'])
          .map((exercise) => Exercise.fromJson(_mapFromJson(exercise)))
          .toList(),
    );
  }

  final String id;
  final String name;
  final int weeks;
  final List<String> schedulePattern;
  final List<Workout> workouts;
  final List<Exercise> exercises;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'weeks': weeks,
      'schedulePattern': schedulePattern,
      'workouts': workouts.map((workout) => workout.toJson()).toList(),
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Program &&
            other.id == id &&
            other.name == name &&
            other.weeks == weeks &&
            _listEquals(other.schedulePattern, schedulePattern) &&
            _listEquals(other.workouts, workouts) &&
            _listEquals(other.exercises, exercises);
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        weeks,
        Object.hashAll(schedulePattern),
        Object.hashAll(workouts),
        Object.hashAll(exercises),
      );
}

int _intFromJson(Object? value) => (value! as num).toInt();

double _doubleFromJson(Object? value) => (value! as num).toDouble();

List<Object?> _listFromJson(Object? value) => (value! as List).cast<Object?>();

Map<String, Object?> _mapFromJson(Object? value) {
  return (value! as Map).cast<String, Object?>();
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
