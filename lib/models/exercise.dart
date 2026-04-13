class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.muscle,
    required this.equipmentOptions,
  });

  final String id;
  final String name;
  final String muscle;
  final List<String> equipmentOptions;

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      muscle: map['muscle'] as String,
      equipmentOptions: List<String>.from(map['equipmentOptions'] as List),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'muscle': muscle,
      'equipmentOptions': equipmentOptions,
    };
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? muscle,
    List<String>? equipmentOptions,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      muscle: muscle ?? this.muscle,
      equipmentOptions: equipmentOptions ?? this.equipmentOptions,
    );
  }
}
