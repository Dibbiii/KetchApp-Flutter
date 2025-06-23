import 'package:equatable/equatable.dart';

enum SessionStatus { planned, inProgress, completed, cancelled }

class Session extends Equatable {
  final String id;
  final String subject;
  final String task;
  final DateTime startTime;
  final Duration plannedDuration;
  final SessionStatus status;

  const Session({
    required this.id,
    required this.subject,
    required this.task,
    required this.startTime,
    required this.plannedDuration,
    this.status = SessionStatus.planned,
  });

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'] as String,
      subject: map['subject'] as String,
      task: map['task'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      plannedDuration: Duration(minutes: map['plannedDurationMinutes'] as int),
      status: SessionStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse:
            () => SessionStatus.planned,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'task': task,
      'startTime': startTime.toIso8601String(),
      'plannedDurationMinutes': plannedDuration.inMinutes,
      'status': status.toString(),
    };
  }

  Session copyWith({
    String? id,
    String? subject,
    String? task,
    DateTime? startTime,
    Duration? plannedDuration,
    SessionStatus? status,
  }) {
    return Session(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      task: task ?? this.task,
      startTime: startTime ?? this.startTime,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    id,
    subject,
    task,
    startTime,
    plannedDuration,
    status,
  ];

  @override
  bool get stringify => true;
}
