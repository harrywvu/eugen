import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/exercise_seed_loader.dart';
import '../data/local_storage_service.dart';
import '../models/exercise.dart';
import '../models/workout_session.dart';

class ActiveWorkoutSession {
  const ActiveWorkoutSession({
    required this.id,
    required this.startedAt,
    required this.exercises,
  });

  final String id;
  final DateTime startedAt;
  final List<WorkoutSessionExercise> exercises;

  ActiveWorkoutSession copyWith({
    String? id,
    DateTime? startedAt,
    List<WorkoutSessionExercise>? exercises,
  }) {
    return ActiveWorkoutSession(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      exercises: exercises ?? this.exercises,
    );
  }
}

class WorkoutProvider extends ChangeNotifier {
  WorkoutProvider(this._storageService);

  final LocalStorageService _storageService;
  final ExerciseSeedLoader _seedLoader = ExerciseSeedLoader();

  final List<Exercise> _exercises = [];
  final List<WorkoutSession> _sessions = [];

  ActiveWorkoutSession? _activeWorkout;
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _loadError;

  bool get isLoading => _isLoading;
  String? get loadError => _loadError;
  ActiveWorkoutSession? get activeWorkout => _activeWorkout;

  List<Exercise> get allExercises =>
      [..._exercises]..sort((a, b) => a.name.compareTo(b.name));

  List<WorkoutSession> get recentSessions =>
      [..._sessions]..sort((a, b) => b.date.compareTo(a.date));

  Future<void> load() async {
    if (_isLoading || _hasLoaded) {
      return;
    }

    _isLoading = true;
    _loadError = null;
    notifyListeners();

    try {
      final exercises = await _seedLoader.loadCoreExercises();
      final sessions = _storageService.loadWorkouts();

      _exercises
        ..clear()
        ..addAll(exercises);
      _sessions
        ..clear()
        ..addAll(sessions);
      _hasLoaded = true;
    } catch (_) {
      _loadError = 'Failed to load local workout data.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Exercise> filterExercises(String query) {
    final q = query.trim().toLowerCase();
    final filtered = allExercises.where((exercise) {
      if (q.isEmpty) {
        return true;
      }
      return exercise.name.toLowerCase().contains(q) ||
          exercise.muscle.toLowerCase().contains(q) ||
          exercise.equipmentOptions
              .any((option) => option.toLowerCase().contains(q));
    }).toList();
    filtered.sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }

  void startWorkout() {
    if (_activeWorkout != null) {
      return;
    }

    _activeWorkout = ActiveWorkoutSession(
      id: generateId('active_workout'),
      startedAt: DateTime.now(),
      exercises: const [],
    );
    notifyListeners();
  }

  void discardWorkout() {
    if (_activeWorkout == null) {
      return;
    }
    _activeWorkout = null;
    notifyListeners();
  }

  void addExerciseToActiveWorkout({
    required Exercise exercise,
    required String equipmentVariation,
  }) {
    final current = _activeWorkout;
    if (current == null) {
      return;
    }

    final updatedExercises = [
      ...current.exercises,
      WorkoutSessionExercise(
        id: generateId('session_exercise'),
        exerciseId: exercise.id,
        name: exercise.name,
        muscle: exercise.muscle,
        equipmentVariation: equipmentVariation,
        sets: [
          WorkoutSet(
            id: generateId('set'),
            reps: 0,
            weight: 0,
          ),
        ],
      ),
    ];

    _activeWorkout = current.copyWith(exercises: updatedExercises);
    notifyListeners();
  }

  void removeExerciseFromActiveWorkout(String sessionExerciseId) {
    final current = _activeWorkout;
    if (current == null) {
      return;
    }

    _activeWorkout = current.copyWith(
      exercises: current.exercises
          .where((exercise) => exercise.id != sessionExerciseId)
          .toList(),
    );
    notifyListeners();
  }

  void addSetToExercise(String sessionExerciseId) {
    final current = _activeWorkout;
    if (current == null) {
      return;
    }

    _activeWorkout = current.copyWith(
      exercises: current.exercises.map((exercise) {
        if (exercise.id != sessionExerciseId) {
          return exercise;
        }
        return exercise.copyWith(
          sets: [
            ...exercise.sets,
            WorkoutSet(
              id: generateId('set'),
              reps: 0,
              weight: 0,
            ),
          ],
        );
      }).toList(),
    );
    notifyListeners();
  }

  void removeSetFromExercise({
    required String sessionExerciseId,
    required String setId,
  }) {
    final current = _activeWorkout;
    if (current == null) {
      return;
    }

    _activeWorkout = current.copyWith(
      exercises: current.exercises.map((exercise) {
        if (exercise.id != sessionExerciseId || exercise.sets.length <= 1) {
          return exercise;
        }
        return exercise.copyWith(
          sets: exercise.sets.where((set) => set.id != setId).toList(),
        );
      }).toList(),
    );
    notifyListeners();
  }

  void updateSetFields({
    required String sessionExerciseId,
    required String setId,
    int? reps,
    double? weight,
    double? rpe,
    bool clearRpe = false,
    String? notes,
    WorkoutSetMetadata? metadata,
  }) {
    final current = _activeWorkout;
    if (current == null) {
      return;
    }

    _activeWorkout = current.copyWith(
      exercises: current.exercises.map((exercise) {
        if (exercise.id != sessionExerciseId) {
          return exercise;
        }
        return exercise.copyWith(
          sets: exercise.sets.map((set) {
            if (set.id != setId) {
              return set;
            }
            return set.copyWith(
              reps: reps,
              weight: weight,
              rpe: rpe,
              clearRpe: clearRpe,
              notes: notes,
              metadata: metadata,
            );
          }).toList(),
        );
      }).toList(),
    );
    notifyListeners();
  }

  Future<WorkoutSession?> finishWorkout() async {
    final current = _activeWorkout;
    if (current == null || current.exercises.isEmpty) {
      return null;
    }

    final session = WorkoutSession(
      id: generateId('workout_session'),
      date: DateTime.now(),
      exercises: current.exercises.map((exercise) {
        return exercise.copyWith(
          sets: exercise.sets.map((set) {
            return set.copyWith(
              reps: max(0, set.reps),
              weight: max(0, set.weight),
              notes: set.notes.trim(),
            );
          }).toList(),
        );
      }).toList(),
    );

    _sessions.add(session);
    await _storageService.saveWorkout(session);
    _activeWorkout = null;
    notifyListeners();
    return session;
  }

  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((session) => session.id == sessionId);
    await _storageService.deleteWorkout(sessionId);
    notifyListeners();
  }

  String generateId(String prefix) {
    final random = Random();
    final stamp = DateTime.now().microsecondsSinceEpoch;
    return '${prefix}_$stamp${random.nextInt(9999)}';
  }
}
