import 'package:hive/hive.dart';

import '../models/exercise.dart';
import '../models/workout_entry.dart';

class LocalStorageService {
  static const String workoutsBoxName = 'workouts_box';
  static const String customExercisesBoxName = 'custom_exercises_box';

  late Box _workoutsBox;
  late Box _customExercisesBox;

  Future<void> init() async {
    _workoutsBox = await Hive.openBox(workoutsBoxName);
    _customExercisesBox = await Hive.openBox(customExercisesBoxName);
  }

  List<WorkoutEntry> loadWorkouts() {
    return _workoutsBox.values
        .map((raw) => WorkoutEntry.fromMap(Map<String, dynamic>.from(raw as Map)))
        .toList();
  }

  Future<void> saveWorkout(WorkoutEntry workout) async {
    await _workoutsBox.put(workout.id, workout.toMap());
  }

  Future<void> deleteWorkout(String workoutId) async {
    await _workoutsBox.delete(workoutId);
  }

  List<Exercise> loadCustomExercises() {
    return _customExercisesBox.values
        .map((raw) => Exercise.fromMap(Map<String, dynamic>.from(raw as Map)))
        .toList();
  }

  Future<void> saveCustomExercise(Exercise exercise) async {
    await _customExercisesBox.put(exercise.id, exercise.toMap());
  }

  Future<void> deleteCustomExercise(String exerciseId) async {
    await _customExercisesBox.delete(exerciseId);
  }
}
