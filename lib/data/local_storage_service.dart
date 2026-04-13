import 'package:hive/hive.dart';

import '../models/workout_session.dart';

class LocalStorageService {
  static const String workoutsBoxName = 'workouts_box';

  late Box _workoutsBox;

  Future<void> init() async {
    _workoutsBox = await Hive.openBox(workoutsBoxName);
  }

  List<WorkoutSession> loadWorkouts() {
    final sessions = <WorkoutSession>[];
    for (final raw in _workoutsBox.values) {
      try {
        sessions.add(
          WorkoutSession.fromMap(Map<String, dynamic>.from(raw as Map)),
        );
      } catch (_) {
        continue;
      }
    }
    return sessions;
  }

  Future<void> saveWorkout(WorkoutSession workout) async {
    await _workoutsBox.put(workout.id, workout.toMap());
  }

  Future<void> deleteWorkout(String workoutId) async {
    await _workoutsBox.delete(workoutId);
  }
}
