class Photo {
  final String path;
  final DateTime date;

  Photo({
    required this.path,
    required this.date,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      path: json['path'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'path': path,
        'date': date.toIso8601String(),
      };
}
