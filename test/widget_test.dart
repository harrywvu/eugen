import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_tracker_mvp/models/workout_session.dart';

void main() {
  test('WorkoutSession computes aggregate totals from nested exercises', () {
    final session = WorkoutSession(
      id: 'session_1',
      date: DateTime(2026, 1, 1),
      exercises: [
        WorkoutSessionExercise(
          id: 'exercise_1',
          exerciseId: 'incline_bench_press',
          name: 'Incline Bench Press',
          muscle: 'Chest',
          equipmentVariation: 'Dumbbells',
          sets: [
            WorkoutSet(id: 'set_1', reps: 10, weight: 25),
            WorkoutSet(id: 'set_2', reps: 8, weight: 30),
          ],
        ),
        WorkoutSessionExercise(
          id: 'exercise_2',
          exerciseId: 'shoulder_press',
          name: 'Shoulder Press',
          muscle: 'Shoulders',
          equipmentVariation: 'Machine',
          sets: [
            WorkoutSet(id: 'set_3', reps: 12, weight: 40),
          ],
        ),
      ],
    );

    expect(session.totalSets, 3);
    expect(session.totalVolume, 970);
  });
}
