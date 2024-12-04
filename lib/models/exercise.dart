class Exercise {
  final String id;
  final String name;
  final List<Map<String, int>> sets;
  final String? notes;

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sets': sets,
        'notes': notes,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      throw Exception("Exercise 'id' is null");
    }
    if (json['name'] == null) {
      throw Exception("Exercise 'name' is null");
    }

    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      sets: json['sets'] != null
          ? List<Map<String, int>>.from(
              (json['sets'] as List).map((set) => Map<String, int>.from(set)),
            )
          : [],
      notes: json['notes'] as String?,
    );
  }
}
