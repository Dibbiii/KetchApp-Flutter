import 'package:equatable/equatable.dart';

// Optional: Define an enum for session status
enum SessionStatus { planned, inProgress, completed, cancelled }

class Session extends Equatable {
  final String id; // Unique identifier (e.g., from database or generated)
  final String subject;
  final String task;
  final DateTime startTime; // When the session is planned to start
  final Duration plannedDuration; // How long the session is planned for
  final SessionStatus status; // Current status of the session
  // Add other relevant fields as needed:
  // final DateTime? actualEndTime;
  // final String? notes;
  // final String? location;

  const Session({
    required this.id,
    required this.subject,
    required this.task,
    required this.startTime,
    required this.plannedDuration,
    this.status = SessionStatus.planned, // Default status
  });

  // Optional: Factory constructor for creating from a Map (e.g., from JSON/database)
  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'] as String,
      subject: map['subject'] as String,
      task: map['task'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      // Assuming ISO 8601 string
      plannedDuration: Duration(minutes: map['plannedDurationMinutes'] as int),
      // Assuming duration stored in minutes
      status: SessionStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse:
            () => SessionStatus.planned, // Default if status is missing/invalid
      ),
    );
  }

  // Optional: Method to convert Session object to a Map (e.g., for saving to database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'task': task,
      'startTime': startTime.toIso8601String(),
      // Store as ISO 8601 string
      'plannedDurationMinutes': plannedDuration.inMinutes,
      // Store duration in minutes
      'status': status.toString(),
      // Store enum as string
    };
  }

  // Optional: CopyWith method for easily creating modified instances
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
  bool get stringify => true; // Optional: Makes toString() more readable
}
