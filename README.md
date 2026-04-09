# Fitness Tracker MVP

Minimal viable Flutter app for offline workout logging. Core exercise definitions come from a local JSON asset, while workouts and custom exercises are persisted locally with Hive.

## Project Structure

```text
.
+-- assets/
|   +-- data/
|       +-- exercises.json
+-- lib/
|   +-- data/
|   |   +-- exercise_seed_loader.dart
|   |   +-- local_storage_service.dart
|   +-- models/
|   |   +-- exercise.dart
|   |   +-- workout_entry.dart
|   +-- providers/
|   |   +-- workout_provider.dart
|   +-- screens/
|   |   +-- custom_exercise_screen.dart
|   |   +-- exercise_history_screen.dart
|   |   +-- exercise_library_screen.dart
|   |   +-- home_screen.dart
|   |   +-- logger_screen.dart
|   +-- main.dart
+-- pubspec.yaml
```

## Main.dart Skeleton

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final storageService = LocalStorageService();
  await storageService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => WorkoutProvider(storageService)..load(),
      child: const FitnessTrackerApp(),
    ),
  );
}
```

## Example Models

```dart
class Exercise {
  final String id;
  final String name;
  final String muscle;
  final List<String> equipmentOptions;
  final bool isCustom;
}

class WorkoutSet {
  final int reps;
  final double weight;
}

class WorkoutEntry {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final String equipment;
  final String notes;
  final DateTime performedAt;
  final List<WorkoutSet> sets;
}
```

## Example Screen Widgets

```dart
ExerciseCard(
  exercise: exercise,
  onSelectEquipment: (equipment) {
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
);
```

```dart
ListView.builder(
  itemCount: workout.sets.length,
  itemBuilder: (context, index) {
    final set = workout.sets[index];
    return ListTile(
      title: Text('Set ${index + 1}: ${set.reps} reps'),
      subtitle: Text('${set.weight.toStringAsFixed(1)} kg'),
    );
  },
);
```

## Example Local Storage Read/Write

```dart
Future<void> saveWorkout(WorkoutEntry workout) async {
  await _workoutsBox.put(workout.id, workout.toMap());
}

List<WorkoutEntry> loadWorkouts() {
  return _workoutsBox.values
      .map((raw) => WorkoutEntry.fromMap(Map<String, dynamic>.from(raw)))
      .toList();
}
```

## Run Locally

1. Install Flutter 3.22+ and verify with `flutter doctor`.
2. From this project folder, run `flutter pub get`.
3. Start a simulator or attach a device.
4. Run `flutter run`.

## Notes

- Offline-only by design.
- Workouts and custom exercises are stored locally in Hive boxes.
- Core exercises come from `assets/data/exercises.json`.
