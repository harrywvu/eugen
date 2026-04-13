import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../models/workout_session.dart';
import '../providers/workout_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _expandedActiveExercises = <String>{};
  final Set<String> _expandedHistorySessions = <String>{};
  final Set<String> _expandedHistoryExercises = <String>{};

  bool _showExercisePicker = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        final activeWorkout = provider.activeWorkout;
        final sessions = provider.recentSessions;
        final filteredExercises =
            provider.filterExercises(_searchController.text);

        if (provider.isLoading) {
          return const SafeArea(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (provider.loadError != null) ...[
                _MessageCard(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Text(provider.loadError!),
                ),
                const SizedBox(height: 16),
              ],
              _buildWorkoutControls(context, provider, activeWorkout),
              if (activeWorkout != null) ...[
                const SizedBox(height: 16),
                if (_showExercisePicker)
                  _ExercisePickerCard(
                    controller: _searchController,
                    exercises: filteredExercises,
                    onSearchChanged: () => setState(() {}),
                    onClose: () => setState(() => _showExercisePicker = false),
                  ),
                if (_showExercisePicker) const SizedBox(height: 16),
                if (activeWorkout.exercises.isEmpty)
                  const _MessageCard(
                    child: Text('Workout empty. Add exercise inline.'),
                  )
                else
                  ...activeWorkout.exercises.map(
                    (exercise) => _ActiveExerciseCard(
                      exercise: exercise,
                      expanded: _expandedActiveExercises.contains(exercise.id),
                      onToggle: () =>
                          _toggle(_expandedActiveExercises, exercise.id),
                    ),
                  ),
              ],
              const SizedBox(height: 16),
              if (sessions.isEmpty)
                const _MessageCard(
                  child: Text('No sessions yet. Start workout.'),
                )
              else
                ...sessions.map(
                  (session) => _HistorySessionCard(
                    session: session,
                    expanded: _expandedHistorySessions.contains(session.id),
                    expandedExercises: _expandedHistoryExercises,
                    onToggleSession: () =>
                        _toggle(_expandedHistorySessions, session.id),
                    onToggleExercise: (historyExerciseKey) =>
                        _toggle(_expandedHistoryExercises, historyExerciseKey),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkoutControls(
    BuildContext context,
    WorkoutProvider provider,
    ActiveWorkoutSession? activeWorkout,
  ) {
    if (activeWorkout == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: FilledButton(
          onPressed: provider.startWorkout,
          child: const Text('Start Workout'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FilledButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final session = await provider.finishWorkout();
                if (session != null) {
                  return;
                }
                messenger.showSnackBar(
                  const SnackBar(content: Text('Add exercise before finish.')),
                );
              },
              child: const Text('Finish Workout'),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: provider.discardWorkout,
              child: const Text('Discard'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _showExercisePicker = !_showExercisePicker;
                });
              },
              child: Text(_showExercisePicker
                  ? 'Hide Exercise Picker'
                  : 'Add Exercise'),
            ),
            const Spacer(),
            Text(DateFormat.Hm().format(activeWorkout.startedAt)),
          ],
        ),
      ],
    );
  }

  void _toggle(Set<String> values, String id) {
    setState(() {
      if (!values.add(id)) {
        values.remove(id);
      }
    });
  }
}

class _ExercisePickerCard extends StatelessWidget {
  const _ExercisePickerCard({
    required this.controller,
    required this.exercises,
    required this.onSearchChanged,
    required this.onClose,
  });

  final TextEditingController controller;
  final List<Exercise> exercises;
  final VoidCallback onSearchChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WorkoutProvider>();

    return _MessageCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Search exercises',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (_) => onSearchChanged(),
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (exercises.isEmpty)
            const Text('No exercise match.')
          else
            ...exercises.map((exercise) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name.toUpperCase(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: exercise.equipmentOptions.map((equipment) {
                        return ChoiceChip(
                          label: Text(equipment.toUpperCase()),
                          selected: false,
                          onSelected: (_) {
                            provider.addExerciseToActiveWorkout(
                              exercise: exercise,
                              equipmentVariation: equipment,
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _ActiveExerciseCard extends StatelessWidget {
  const _ActiveExerciseCard({
    required this.exercise,
    required this.expanded,
    required this.onToggle,
  });

  final WorkoutSessionExercise exercise;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WorkoutProvider>();
    final warmupSets = exercise.sets
        .where((set) => set.metadata.purpose == SetPurpose.warmup)
        .toList();
    final mainSets = exercise.sets
        .where((set) => set.metadata.purpose != SetPurpose.warmup)
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _MessageCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onToggle,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name.toUpperCase(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                            '${exercise.equipmentVariation} • ${exercise.sets.length} sets'),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        provider.removeExerciseFromActiveWorkout(exercise.id),
                    icon: const Icon(Icons.delete_outline),
                  ),
                  Icon(expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
            if (expanded) ...[
              if (warmupSets.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...warmupSets.map(
                  (set) => _SetEditorRow(
                    exerciseId: exercise.id,
                    set: set,
                    accentColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                  ),
                ),
              ],
              if (mainSets.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...mainSets.map(
                  (set) => _SetEditorRow(
                    exerciseId: exercise.id,
                    set: set,
                    accentColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(
                  onPressed: () => provider.addSetToExercise(exercise.id),
                  child: const Text('Add Set'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SetEditorRow extends StatelessWidget {
  const _SetEditorRow({
    required this.exerciseId,
    required this.set,
    required this.accentColor,
  });

  final String exerciseId;
  final WorkoutSet set;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WorkoutProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: set.reps == 0 ? '' : set.reps.toString(),
                  decoration: const InputDecoration(labelText: 'Reps'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => provider.updateSetFields(
                    sessionExerciseId: exerciseId,
                    setId: set.id,
                    reps: int.tryParse(value) ?? 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue:
                      set.weight == 0 ? '' : set.weight.toStringAsFixed(1),
                  decoration: const InputDecoration(labelText: 'Weight'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) => provider.updateSetFields(
                    sessionExerciseId: exerciseId,
                    setId: set.id,
                    weight: double.tryParse(value) ?? 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: set.rpe?.toString() ?? '',
                  decoration: const InputDecoration(labelText: 'RPE'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) => provider.updateSetFields(
                    sessionExerciseId: exerciseId,
                    setId: set.id,
                    rpe: value.trim().isEmpty ? null : double.tryParse(value),
                    clearRpe: value.trim().isEmpty,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => provider.removeSetFromExercise(
                  sessionExerciseId: exerciseId,
                  setId: set.id,
                ),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<SetPurpose>(
                  initialValue: set.metadata.purpose,
                  decoration: const InputDecoration(labelText: 'Purpose'),
                  items: SetPurpose.values
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    provider.updateSetFields(
                      sessionExerciseId: exerciseId,
                      setId: set.id,
                      metadata: set.metadata.copyWith(purpose: value),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<SetStructureType>(
                  initialValue: set.metadata.structure,
                  decoration: const InputDecoration(labelText: 'Structure'),
                  items: SetStructureType.values
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    provider.updateSetFields(
                      sessionExerciseId: exerciseId,
                      setId: set.id,
                      metadata: set.metadata.copyWith(structure: value),
                    );
                  },
                ),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Failure'),
            value: set.metadata.failure,
            onChanged: (value) => provider.updateSetFields(
              sessionExerciseId: exerciseId,
              setId: set.id,
              metadata: set.metadata.copyWith(failure: value),
            ),
          ),
          TextFormField(
            initialValue: set.metadata.supersetWith ?? '',
            decoration:
                const InputDecoration(labelText: 'Superset With Exercise Id'),
            onChanged: (value) => provider.updateSetFields(
              sessionExerciseId: exerciseId,
              setId: set.id,
              metadata: set.metadata.copyWith(
                supersetWith: value.trim(),
                clearSupersetWith: value.trim().isEmpty,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: set.metadata.linkedTopSetId ?? '',
            decoration: const InputDecoration(labelText: 'Linked Top Set Id'),
            onChanged: (value) => provider.updateSetFields(
              sessionExerciseId: exerciseId,
              setId: set.id,
              metadata: set.metadata.copyWith(
                linkedTopSetId: value.trim(),
                clearLinkedTopSetId: value.trim().isEmpty,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: set.notes,
            decoration: const InputDecoration(labelText: 'Notes'),
            maxLines: 2,
            onChanged: (value) => provider.updateSetFields(
              sessionExerciseId: exerciseId,
              setId: set.id,
              notes: value,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorySessionCard extends StatelessWidget {
  const _HistorySessionCard({
    required this.session,
    required this.expanded,
    required this.expandedExercises,
    required this.onToggleSession,
    required this.onToggleExercise,
  });

  final WorkoutSession session;
  final bool expanded;
  final Set<String> expandedExercises;
  final VoidCallback onToggleSession;
  final ValueChanged<String> onToggleExercise;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WorkoutProvider>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _MessageCard(
        child: Column(
          children: [
            InkWell(
              onTap: onToggleSession,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat.yMMMd().add_jm().format(session.date)),
                        const SizedBox(height: 4),
                        Text(
                          '${session.exercises.length} exercises • ${session.totalSets} sets • ${session.totalVolume.toStringAsFixed(1)} kg',
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => provider.deleteSession(session.id),
                    icon: const Icon(Icons.delete_outline),
                  ),
                  Icon(expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
            if (expanded) ...[
              const SizedBox(height: 12),
              ...session.exercises.map((exercise) {
                final key = '${session.id}:${exercise.id}';
                final open = expandedExercises.contains(key);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => onToggleExercise(key),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(exercise.name.toUpperCase()),
                                    const SizedBox(height: 4),
                                    Text(exercise.equipmentVariation),
                                  ],
                                ),
                              ),
                              Icon(
                                  open ? Icons.expand_less : Icons.expand_more),
                            ],
                          ),
                        ),
                        if (open) ...[
                          const SizedBox(height: 12),
                          ...exercise.sets.map(
                            (set) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${set.metadata.purpose.name} • ${set.reps} reps • ${set.weight.toStringAsFixed(1)} kg'
                                  '${set.rpe != null ? ' • RPE ${set.rpe}' : ''}'
                                  '${set.metadata.failure ? ' • failure' : ''}'
                                  '${set.notes.trim().isNotEmpty ? '\n${set.notes}' : ''}',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.child,
    this.color,
  });

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
