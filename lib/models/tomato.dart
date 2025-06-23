class Tomato {
  final int id;
  final String subject;
  final DateTime createdAt;
  final String userUUID;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime? pauseEnd;
  final int? nextTomatoId;
  final int pomodoros;
  final int shortBreak;

  Tomato({
    required this.id,
    required this.subject,
    required this.createdAt,
    required this.userUUID,
    required this.startAt,
    required this.endAt,
    this.pauseEnd,
    this.nextTomatoId,
    required this.pomodoros,
    required this.shortBreak,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'created_at': createdAt.toIso8601String(),
      'userUUID': userUUID,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'pause_end': pauseEnd?.toIso8601String(),
      'next_tomato_id': nextTomatoId,
      'pomodoros': pomodoros,
      'short_break': shortBreak,
    };
  }

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
      pomodoros: json['pomodoros'] ?? 4, // Default to 4 if not present
      shortBreak: json['shortBreak'] ?? 5, // Default to 5 if not present
    );
  }
}
