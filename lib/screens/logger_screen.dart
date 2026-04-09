import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../models/workout_entry.dart';
import '../providers/workout_provider.dart';

class LoggerScreen extends StatefulWidget {
  const LoggerScreen({
    super.key,
    this.exercise,
    this.selectedEquipment,
    this.existingWorkout,
  });

  final Exercise? exercise;
  final String? selectedEquipment;
  final WorkoutEntry? existingWorkout;

  @override
  State<LoggerScreen> createState() => _LoggerScreenState();
}

class _LoggerScreenState extends State<LoggerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  late final List<_SetInput> _setInputs;
  late String _selectedEquipment;

  Exercise? get _exercise => widget.exercise;
  WorkoutEntry? get _existingWorkout => widget.existingWorkout;

  @override
  void initState() {
    super.initState();

    if (_existingWorkout != null) {
      _notesController.text = _existingWorkout!.notes;
      _selectedEquipment = _existingWorkout!.equipment;
      _setInputs = _existingWorkout!.sets
          .map(
            (set) => _SetInput(
              repsController: TextEditingController(text: set.reps.toString()),
              weightController: TextEditingController(text: set.weight.toString()),
            ),
          )
          .toList();
    } else {
      _selectedEquipment = widget.selectedEquipment ?? _exercise!.equipmentOptions.first;
      _setInputs = [
        _SetInput(
          repsController: TextEditingController(),
          weightController: TextEditingController(),
        ),
      ];
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    for (final input in _setInputs) {
      input.repsController.dispose();
      input.weightController.dispose();
    }
    super.dispose();
  }

  void _addSet() {
    setState(() {
      _setInputs.add(
        _SetInput(
          repsController: TextEditingController(),
          weightController: TextEditingController(),
        ),
      );
    });
  }

  void _removeSet(int index) {
    if (_setInputs.length == 1) {
      return;
    }

    setState(() {
      final removed = _setInputs.removeAt(index);
      removed.repsController.dispose();
      removed.weightController.dispose();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<WorkoutProvider>();
    final baseExercise = _exercise ??
        provider.allExercises.firstWhere((entry) => entry.id == _existingWorkout!.exerciseId);

    final workout = WorkoutEntry(
      id: _existingWorkout?.id ?? provider.generateId('workout'),
      exerciseId: baseExercise.id,
      exerciseName: baseExercise.name,
      muscle: baseExercise.muscle,
      equipment: _selectedEquipment,
      notes: _notesController.text.trim(),
      performedAt: _existingWorkout?.performedAt ?? DateTime.now(),
      sets: _setInputs
          .map(
            (input) => WorkoutSet(
              reps: int.parse(input.repsController.text.trim()),
              weight: double.parse(input.weightController.text.trim()),
            ),
          )
          .toList(),
    );

    await provider.addOrUpdateWorkout(workout);
    if (!mounted) {
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final exercise = _exercise ??
        provider.allExercises.firstWhere((entry) => entry.id == _existingWorkout!.exerciseId);
    final availableEquipment = exercise.equipmentOptions;

    return Scaffold(
      appBar: AppBar(
        title: Text(_existingWorkout == null ? 'Log Workout' : 'Edit Workout'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(exercise.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('Muscle: ${exercise.muscle}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedEquipment,
              decoration: const InputDecoration(labelText: 'Equipment'),
              items: availableEquipment
                  .map(
                    (equipment) => DropdownMenuItem<String>(
                      value: equipment,
                      child: Text(equipment),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedEquipment = value);
                }
              },
            ),
            const SizedBox(height: 16),
            const Text('Sets'),
            const SizedBox(height: 8),
            // Keep each set editable so users can log multiple attempts quickly.
            ...List.generate(_setInputs.length, (index) {
              final input = _setInputs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: input.repsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: 'Reps ${index + 1}'),
                          validator: (value) =>
                              (value == null || int.tryParse(value) == null) ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: input.weightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Weight (kg)'),
                          validator: (value) => (value == null || double.tryParse(value) == null)
                              ? 'Required'
                              : null,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeSet(index),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              );
            }),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _addSet,
                icon: const Icon(Icons.add),
                label: const Text('Add Set'),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Add effort, tempo, or cues',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: const Text('Save Workout'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetInput {
  _SetInput({
    required this.repsController,
    required this.weightController,
  });

  final TextEditingController repsController;
  final TextEditingController weightController;
}
