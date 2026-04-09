import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'data/local_storage_service.dart';
import 'providers/workout_provider.dart';
import 'screens/custom_exercise_screen.dart';
import 'screens/exercise_library_screen.dart';
import 'screens/home_screen.dart';

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

class FitnessTrackerApp extends StatelessWidget {
  const FitnessTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tracker MVP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    ExerciseLibraryScreen(),
    CustomExerciseScreen(),
  ];

  static const List<String> _titles = [
    'Recent Workouts',
    'Exercise Library',
    'Custom Exercises',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.fitness_center), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.library_books), label: 'Exercises'),
          NavigationDestination(icon: Icon(Icons.edit_note), label: 'Custom'),
        ],
      ),
    );
  }
}
