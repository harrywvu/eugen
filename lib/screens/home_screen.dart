import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/workout_entry.dart';
import '../providers/workout_provider.dart';
import 'exercise_history_screen.dart';
import 'logger_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        final workouts = provider.recentWorkouts;

        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (workouts.isEmpty) {
          return const Center(
            child: Text('No workouts logged yet. Start from the Exercises tab.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            final workout = workouts[index];
            return _WorkoutCard(workout: workout);
          },
        );
      },
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.workout});

  final WorkoutEntry workout;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WorkoutProvider>();
    final dateLabel = DateFormat.yMMMd().add_jm().format(workout.performedAt);
    final volume = workout.sets.fold<double>(
      0,
      (sum, set) => sum + (set.reps * set.weight),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workout.exerciseName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text('${workout.equipment} | ${workout.muscle}'),
            Text(dateLabel),
            const SizedBox(height: 8),
            Text('Sets: ${workout.sets.length} | Volume: ${volume.toStringAsFixed(1)} kg'),
            if (workout.notes.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(workout.notes),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LoggerScreen(existingWorkout: workout),
                      ),
                    );
                  },
                  child: const Text('Edit'),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExerciseHistoryScreen(
                          exerciseId: workout.exerciseId,
                          exerciseName: workout.exerciseName,
                        ),
                      ),
                    );
                  },
                  child: const Text('History'),
                ),
                TextButton(
                  onPressed: () => provider.deleteWorkout(workout.id),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
