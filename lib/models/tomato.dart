class Tomato {
  final int id;
  final String subject;
  final DateTime createdAt;

  Tomato({
    required this.id,
    required this.subject,
    required this.createdAt,
  });

  factory Tomato.fromJson(Map<String, dynamic> json) {
    return Tomato(
      id: json['id'],
      subject: json['subject'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
