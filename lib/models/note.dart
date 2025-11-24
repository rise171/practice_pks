class Note {
  final int id;
  final String title;
  final String body;
  final int userId;

  Note({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'] ?? 0,
    title: json['title'] ?? '',
    body: json['body'] ?? json['content'] ?? '',
    userId: json['userId'] ?? 1,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'userId': userId,
  };

  Note copyWith({
    int? id,
    String? title,
    String? body,
    int? userId,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      userId: userId ?? this.userId,
    );
  }
}