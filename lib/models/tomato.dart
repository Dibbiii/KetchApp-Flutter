import 'package:ketchapp_flutter/models/activity.dart';

class Tomato {
  final int id;
  final String subject;
  final DateTime createdAt;
  final String userUUID;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime? pauseEnd;
  final int? nextTomatoId;
  List<Activity> activities;

  Tomato({
    required this.id,
    required this.subject,
    required this.createdAt,
    required this.userUUID,
    required this.startAt,
    required this.endAt,
    this.pauseEnd,
    this.nextTomatoId,
    this.activities = const [],
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
    );
  }
}
