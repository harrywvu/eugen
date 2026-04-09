import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/exercise_seed_loader.dart';
import '../data/local_storage_service.dart';
import '../models/exercise.dart';
import '../models/workout_entry.dart';

class WorkoutProvider extends ChangeNotifier {
  WorkoutProvider(this._storageService);

  final LocalStorageService _storageService;
  final ExerciseSeedLoader _seedLoader = ExerciseSeedLoader();

  final List<Exercise> _coreExercises = [];
  final List<Exercise> _customExercises = [];
  final List<WorkoutEntry> _workouts = [];

  bool _isLoading = false;
  String _searchQuery = '';
  String _equipmentFilter = 'All';

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get equipmentFilter => _equipmentFilter;

  List<WorkoutEntry> get recentWorkouts {
    final sorted = [..._workouts];
    sorted.sort((a, b) => b.performedAt.compareTo(a.performedAt));
    return sorted;
  }

  List<Exercise> get allExercises => [..._coreExercises, ..._customExercises];

  List<String> get allEquipmentFilters {
    final values = <String>{'All'};
    for (final exercise in allExercises) {
      values.addAll(exercise.equipmentOptions);
    }
    final sorted = values.toList()..sort();
    if (sorted.remove('All')) {
      sorted.insert(0, 'All');
    }
    return sorted;
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _coreExercises
      ..clear()
      ..addAll(await _seedLoader.loadCoreExercises());
    _customExercises
      ..clear()
      ..addAll(_storageService.loadCustomExercises());
    _workouts
      ..clear()
      ..addAll(_storageService.loadWorkouts());

    _isLoading = false;
    notifyListeners();
  }

  List<Exercise> filteredExercises() {
    return allExercises.where((exercise) {
      final matchesText = _searchQuery.isEmpty ||
          exercise.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          exercise.muscle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          exercise.equipmentOptions.any(
            (equipment) => equipment.toLowerCase().contains(_searchQuery.toLowerCase()),
          );

      final matchesEquipment = _equipmentFilter == 'All' ||
          exercise.equipmentOptions.contains(_equipmentFilter);

      return matchesText && matchesEquipment;
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setEquipmentFilter(String value) {
    _equipmentFilter = value;
    notifyListeners();
  }

  List<WorkoutEntry> historyForExercise(String exerciseId) {
    final history = _workouts.where((workout) => workout.exerciseId == exerciseId).toList();
    history.sort((a, b) => b.performedAt.compareTo(a.performedAt));
    return history;
  }

  Future<void> addOrUpdateWorkout(WorkoutEntry workout) async {
    _workouts.removeWhere((entry) => entry.id == workout.id);
    _workouts.add(workout);
    await _storageService.saveWorkout(workout);
    notifyListeners();
  }

  Future<void> deleteWorkout(String workoutId) async {
    _workouts.removeWhere((entry) => entry.id == workoutId);
    await _storageService.deleteWorkout(workoutId);
    notifyListeners();
  }

  Future<void> addOrUpdateCustomExercise(Exercise exercise) async {
    final stored = exercise.copyWith(isCustom: true);
    _customExercises.removeWhere((entry) => entry.id == stored.id);
    _customExercises.add(stored);
    await _storageService.saveCustomExercise(stored);
    notifyListeners();
  }

  Future<void> deleteCustomExercise(String exerciseId) async {
    _customExercises.removeWhere((entry) => entry.id == exerciseId);
    await _storageService.deleteCustomExercise(exerciseId);
    notifyListeners();
  }

  String generateId(String prefix) {
    final random = Random();
    final stamp = DateTime.now().microsecondsSinceEpoch;
    return '${prefix}_$stamp${random.nextInt(9999)}';
  }
}
