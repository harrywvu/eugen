class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.muscle,
    required this.equipmentOptions,
    this.isCustom = false,
  });

  final String id;
  final String name;
  final String muscle;
  final List<String> equipmentOptions;
  final bool isCustom;

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      muscle: map['muscle'] as String,
      equipmentOptions: List<String>.from(map['equipmentOptions'] as List),
      isCustom: map['isCustom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'muscle': muscle,
      'equipmentOptions': equipmentOptions,
      'isCustom': isCustom,
    };
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? muscle,
    List<String>? equipmentOptions,
    bool? isCustom,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      muscle: muscle ?? this.muscle,
      equipmentOptions: equipmentOptions ?? this.equipmentOptions,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}
