class Tomato {
  final int id;
  final String subject;
  final DateTime createdAt;
  final String userUUID;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime? pauseEnd;
  final int? nextTomatoId;

  Tomato({
    required this.id,
    required this.subject,
    required this.createdAt,
    required this.userUUID,
    required this.startAt,
    required this.endAt,
    this.pauseEnd,
    this.nextTomatoId,
  });

  factory Tomato.fromJson(Map<String, dynamic> json) {
    return Tomato(
      id: json['id'],
      subject: json['subject'],
      createdAt: DateTime.parse(json['createdAt']),
      userUUID: json['userUUID'],
      startAt: DateTime.parse(json['startAt']),
      endAt: DateTime.parse(json['endAt']),
      pauseEnd:
          json['pauseEnd'] != null ? DateTime.parse(json['pauseEnd']) : null,
      nextTomatoId: json['nextTomatoId'],
    );
  }
}
