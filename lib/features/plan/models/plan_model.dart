class PlanModel {
  final String userUUID;
  final String session;
  final String breakDuration;
  final List<CalendarEntry> calendar;
  final List<SubjectEntry> subjects;

  PlanModel({
    required this.userUUID,
    required this.session,
    required this.breakDuration,
    required this.calendar,
    required this.subjects,
  });

  PlanModel copyWith({
    String? userUUID,
    String? session,
    String? breakDuration,
    List<CalendarEntry>? calendar,
    List<SubjectEntry>? subjects,
  }) {
    return PlanModel(
      userUUID: userUUID ?? this.userUUID,
      session: session ?? this.session,
      breakDuration: breakDuration ?? this.breakDuration,
      calendar: calendar ?? this.calendar,
      subjects: subjects ?? this.subjects,
    );
  }

  Map<String, dynamic> toJson() => {
        'userUUID': userUUID,
        'session': session,
        'breakDuration': breakDuration,
        'calendar': calendar.map((e) => e.toJson()).toList(),
        'subjects': subjects.map((e) => e.toJson()).toList(),
      };

  factory PlanModel.fromJson(Map<String, dynamic> json) => PlanModel(
        userUUID: json['userUUID'] as String? ?? '',
        session: json['session'] as String? ?? '',
        breakDuration: json['breakDuration'] as String? ?? '',
        calendar: (json['calendar'] as List<dynamic>? ?? [])
            .map((e) => CalendarEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        subjects: (json['subjects'] as List<dynamic>? ?? [])
            .map((e) => SubjectEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CalendarEntry {
  final String startAt;
  final String endAt;
  final String title;

  CalendarEntry({
    required this.startAt,
    required this.endAt,
    required this.title,
  });

  Map<String, dynamic> toJson() => {
        'start_at': startAt,
        'end_at': endAt,
        'title': title,
      };

  factory CalendarEntry.fromJson(Map<String, dynamic> json) => CalendarEntry(
        startAt: json['start_at'] as String? ?? '',
        endAt: json['end_at'] as String? ?? '',
        title: json['title'] as String? ?? '',
      );
}

class SubjectEntry {
  final String subject;
  final String? duration;

  SubjectEntry({
    required this.subject,
    this.duration,
  });

  Map<String, dynamic> toJson() => {
        'name': subject,
        'duration': duration,
      };

  factory SubjectEntry.fromJson(Map<String, dynamic> json) => SubjectEntry(
        subject: json['name'] as String? ?? '',
        duration: json['duration'] as String?,
      );
}
