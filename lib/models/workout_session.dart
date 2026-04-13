enum SetPurpose { warmup, working, top, backoff }

enum SetStructureType { normal, cluster, restPause }

class WorkoutSetMetadata {
  const WorkoutSetMetadata({
    this.purpose = SetPurpose.working,
    this.failure = false,
    this.structure = SetStructureType.normal,
    this.supersetWith,
    this.linkedTopSetId,
  });

  final SetPurpose purpose;
  final bool failure;
  final SetStructureType structure;
  final String? supersetWith;
  final String? linkedTopSetId;

  WorkoutSetMetadata copyWith({
    SetPurpose? purpose,
    bool? failure,
    SetStructureType? structure,
    String? supersetWith,
    String? linkedTopSetId,
    bool clearSupersetWith = false,
    bool clearLinkedTopSetId = false,
  }) {
    return WorkoutSetMetadata(
      purpose: purpose ?? this.purpose,
      failure: failure ?? this.failure,
      structure: structure ?? this.structure,
      supersetWith:
          clearSupersetWith ? null : (supersetWith ?? this.supersetWith),
      linkedTopSetId:
          clearLinkedTopSetId ? null : (linkedTopSetId ?? this.linkedTopSetId),
    );
  }

  factory WorkoutSetMetadata.fromMap(Map<String, dynamic> map) {
    return WorkoutSetMetadata(
      purpose: SetPurpose.values.byName(map['purpose'] as String? ?? 'working'),
      failure: map['failure'] as bool? ?? false,
      structure: SetStructureType.values
          .byName(map['structure'] as String? ?? 'normal'),
      supersetWith: map['supersetWith'] as String?,
      linkedTopSetId: map['linkedTopSetId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'purpose': purpose.name,
      'failure': failure,
      'structure': structure.name,
      'supersetWith': supersetWith,
      'linkedTopSetId': linkedTopSetId,
    };
  }
}

class WorkoutSet {
  const WorkoutSet({
    required this.id,
    required this.reps,
    required this.weight,
    this.rpe,
    this.notes = '',
    this.metadata = const WorkoutSetMetadata(),
  });

  final String id;
  final int reps;
  final double weight;
  final double? rpe;
  final String notes;
  final WorkoutSetMetadata metadata;

  WorkoutSet copyWith({
    String? id,
    int? reps,
    double? weight,
    double? rpe,
    bool clearRpe = false,
    String? notes,
    WorkoutSetMetadata? metadata,
  }) {
    return WorkoutSet(
      id: id ?? this.id,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      rpe: clearRpe ? null : (rpe ?? this.rpe),
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      id: map['id'] as String? ?? '',
      reps: map['reps'] as int? ?? 0,
      weight: (map['weight'] as num? ?? 0).toDouble(),
      rpe: (map['rpe'] as num?)?.toDouble(),
      notes: map['notes'] as String? ?? '',
      metadata: WorkoutSetMetadata.fromMap(
        Map<String, dynamic>.from(map['metadata'] as Map? ?? const {}),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reps': reps,
      'weight': weight,
      'rpe': rpe,
      'notes': notes,
      'metadata': metadata.toMap(),
    };
  }
}

class WorkoutSessionExercise {
  const WorkoutSessionExercise({
    required this.id,
    required this.exerciseId,
    required this.name,
    required this.muscle,
    required this.equipmentVariation,
    required this.sets,
  });

  final String id;
  final String exerciseId;
  final String name;
  final String muscle;
  final String equipmentVariation;
  final List<WorkoutSet> sets;

  WorkoutSessionExercise copyWith({
    String? id,
    String? exerciseId,
    String? name,
    String? muscle,
    String? equipmentVariation,
    List<WorkoutSet>? sets,
  }) {
    return WorkoutSessionExercise(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      muscle: muscle ?? this.muscle,
      equipmentVariation: equipmentVariation ?? this.equipmentVariation,
      sets: sets ?? this.sets,
    );
  }

  factory WorkoutSessionExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutSessionExercise(
      id: map['id'] as String? ?? '',
      exerciseId: map['exerciseId'] as String? ?? '',
      name: map['name'] as String,
      muscle: map['muscle'] as String? ?? '',
      equipmentVariation: map['equipmentVariation'] as String,
      sets: (map['sets'] as List<dynamic>? ?? [])
          .map((setMap) =>
              WorkoutSet.fromMap(Map<String, dynamic>.from(setMap as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'name': name,
      'muscle': muscle,
      'equipmentVariation': equipmentVariation,
      'sets': sets.map((set) => set.toMap()).toList(),
    };
  }
}

class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.date,
    required this.exercises,
  });

  final String id;
  final DateTime date;
  final List<WorkoutSessionExercise> exercises;

  double get totalVolume {
    return exercises.fold<double>(
      0,
      (exerciseTotal, exercise) =>
          exerciseTotal +
          exercise.sets.fold<double>(
            0,
            (setTotal, set) => set.metadata.purpose == SetPurpose.warmup
                ? setTotal
                : setTotal + (set.reps * set.weight),
          ),
    );
  }

  int get totalSets {
    return exercises.fold<int>(
        0, (sum, exercise) => sum + exercise.sets.length);
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      exercises: (map['exercises'] as List<dynamic>? ?? [])
          .map(
            (exerciseMap) => WorkoutSessionExercise.fromMap(
              Map<String, dynamic>.from(exerciseMap as Map),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
    };
  }
}
