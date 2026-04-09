import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../providers/workout_provider.dart';
import 'exercise_history_screen.dart';
import 'logger_screen.dart';

class ExerciseLibraryScreen extends StatelessWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        final exercises = provider.filteredExercises();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search by name, muscle, or equipment',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: provider.setSearchQuery,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: provider.equipmentFilter,
                    decoration: const InputDecoration(labelText: 'Filter by equipment'),
                    items: provider.allEquipmentFilters
                        .map(
                          (equipment) => DropdownMenuItem<String>(
                            value: equipment,
                            child: Text(equipment),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        provider.setEquipmentFilter(value);
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: exercises.isEmpty
                  ? const Center(child: Text('No exercises match the current filters.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = exercises[index];
                        final historyCount = provider.historyForExercise(exercise.id).length;
                        return _ExerciseCard(
                          exercise: exercise,
                          historyCount: historyCount,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.historyCount,
  });

  final Exercise exercise;
  final int historyCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    exercise.name.toUpperCase(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExerciseHistoryScreen(
                          exerciseId: exercise.id,
                          exerciseName: exercise.name,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.show_chart),
                  tooltip: 'View history',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Muscle: ${exercise.muscle} | History entries: $historyCount'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: exercise.equipmentOptions
                  .map(
                    (equipment) => FilledButton.tonal(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoggerScreen(
                              exercise: exercise,
                              selectedEquipment: equipment,
                            ),
                          ),
                        );
                      },
                      child: Text(equipment.toUpperCase()),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
