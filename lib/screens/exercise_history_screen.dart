import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/workout_provider.dart';

class ExerciseHistoryScreen extends StatelessWidget {
  const ExerciseHistoryScreen({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
  });

  final String exerciseId;
  final String exerciseName;

  @override
  Widget build(BuildContext context) {
    final history = context.watch<WorkoutProvider>().historyForExercise(exerciseId);

    return Scaffold(
      appBar: AppBar(title: Text('$exerciseName History')),
      body: history.isEmpty
          ? const Center(child: Text('No history yet for this exercise.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final workout = history[index];
                final topSet = workout.sets.isEmpty
                    ? null
                    : workout.sets.reduce((a, b) => a.weight >= b.weight ? a : b);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      '${DateFormat.yMMMd().format(workout.performedAt)} | ${workout.equipment}',
                    ),
                    subtitle: Text(
                      'Sets: ${workout.sets.length}'
                      '${topSet != null ? ' | Top set: ${topSet.reps} x ${topSet.weight.toStringAsFixed(1)} kg' : ''}'
                      '${workout.notes.trim().isNotEmpty ? '\n${workout.notes}' : ''}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
