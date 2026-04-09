import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../providers/workout_provider.dart';

class CustomExerciseScreen extends StatelessWidget {
  const CustomExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        final exercises = provider.allExercises.where((exercise) => exercise.isCustom).toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: () => _showExerciseDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Custom Exercise'),
                ),
              ),
            ),
            Expanded(
              child: exercises.isEmpty
                  ? const Center(child: Text('No custom exercises yet.'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = exercises[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(exercise.name),
                            subtitle: Text(
                              '${exercise.muscle} | ${exercise.equipmentOptions.join(', ')}',
                            ),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                IconButton(
                                  onPressed: () => _showExerciseDialog(context, exercise: exercise),
                                  icon: const Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () => provider.deleteCustomExercise(exercise.id),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showExerciseDialog(BuildContext context, {Exercise? exercise}) async {
    final provider = context.read<WorkoutProvider>();
    final nameController = TextEditingController(text: exercise?.name ?? '');
    final muscleController = TextEditingController(text: exercise?.muscle ?? '');
    final equipmentController = TextEditingController(
      text: exercise?.equipmentOptions.join(', ') ?? '',
    );
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(exercise == null ? 'Add Custom Exercise' : 'Edit Custom Exercise'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Exercise name'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: muscleController,
                  decoration: const InputDecoration(labelText: 'Primary muscle'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: equipmentController,
                  decoration: const InputDecoration(
                    labelText: 'Equipment options',
                    hintText: 'Comma separated',
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final parsedEquipment = equipmentController.text
                    .split(',')
                    .map((item) => item.trim())
                    .where((item) => item.isNotEmpty)
                    .toList();

                final customExercise = Exercise(
                  id: exercise?.id ?? provider.generateId('exercise'),
                  name: nameController.text.trim(),
                  muscle: muscleController.text.trim(),
                  equipmentOptions: parsedEquipment,
                  isCustom: true,
                );

                await provider.addOrUpdateCustomExercise(customExercise);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    muscleController.dispose();
    equipmentController.dispose();
  }
}
