class WorkoutSet {
  const WorkoutSet({
    required this.reps,
    required this.weight,
  });

  final int reps;
  final double weight;

  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      reps: map['reps'] as int,
      weight: (map['weight'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reps': reps,
      'weight': weight,
    };
  }
}

class WorkoutEntry {
  const WorkoutEntry({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.muscle,
    required this.equipment,
    required this.notes,
    required this.performedAt,
    required this.sets,
  });

  final String id;
  final String exerciseId;
  final String exerciseName;
  final String muscle;
  final String equipment;
  final String notes;
  final DateTime performedAt;
  final List<WorkoutSet> sets;

  factory WorkoutEntry.fromMap(Map<String, dynamic> map) {
    return WorkoutEntry(
      id: map['id'] as String,
      exerciseId: map['exerciseId'] as String,
      exerciseName: map['exerciseName'] as String,
      muscle: map['muscle'] as String,
      equipment: map['equipment'] as String,
      notes: map['notes'] as String? ?? '',
      performedAt: DateTime.parse(map['performedAt'] as String),
      sets: (map['sets'] as List)
          .map((setMap) => WorkoutSet.fromMap(Map<String, dynamic>.from(setMap)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'muscle': muscle,
      'equipment': equipment,
      'notes': notes,
      'performedAt': performedAt.toIso8601String(),
      'sets': sets.map((set) => set.toMap()).toList(),
    };
  }
}
