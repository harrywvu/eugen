import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/exercise.dart';

class ExerciseSeedLoader {
  Future<List<Exercise>> loadCoreExercises() async {
    final rawJson = await rootBundle.loadString('assets/data/exercises.json');
    final decoded = jsonDecode(rawJson) as List<dynamic>;

    return decoded
        .map((item) => Exercise.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}
