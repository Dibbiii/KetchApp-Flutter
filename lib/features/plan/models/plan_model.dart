class PlanModel {
  final Map<String, dynamic> config;
  final List<CalendarEntry> calendar;
  final List<TomatoEntry> tomatoes;
  final List<RuleEntry> rules;

  PlanModel({
    required this.config,
    required this.calendar,
    required this.tomatoes,
    required this.rules,
  });

  Map<String, dynamic> toJson() => {
        'config': config,
        'calendar': calendar.map((e) => e.toJson()).toList(),
        'tomatoes': tomatoes.map((e) => e.toJson()).toList(),
        'rules': rules.map((e) => e.toJson()).toList(),
      };

  factory PlanModel.fromJson(Map<String, dynamic> json) => PlanModel(
        config: json['config'] ?? {},
        calendar: (json['calendar'] as List<dynamic>? ?? [])
            .map((e) => CalendarEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        tomatoes: (json['tomatoes'] as List<dynamic>? ?? [])
            .map((e) => TomatoEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        rules: (json['rules'] as List<dynamic>? ?? [])
            .map((e) => RuleEntry.fromJson(e as Map<String, dynamic>))
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
        startAt: json['start_at'] ?? '',
        endAt: json['end_at'] ?? '',
        title: json['title'] ?? '',
      );
}

class TomatoEntry {
  final String title;
  final String session;
  final String pause;
  final String subject;

  TomatoEntry({
    required this.title,
    required this.session,
    required this.pause,
    required this.subject,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'session': session,
        'pause': pause,
        'subject': subject,
      };

  factory TomatoEntry.fromJson(Map<String, dynamic> json) => TomatoEntry(
        title: json['title'] ?? '',
        session: json['session'] ?? '',
        pause: json['pause'] ?? '',
        subject: json['subject'] ?? '',
      );
}

class RuleEntry {
  final String title;
  final String startAt;
  final String endAt;

  const RuleEntry({
    required this.title,
    required this.startAt,
    required this.endAt,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'start_at': startAt,
        'end_at': endAt,
      };

  factory RuleEntry.fromJson(Map<String, dynamic> json) => RuleEntry(
        title: json['title'] as String? ?? '',
        startAt: json['start_at'] as String? ?? '',
        endAt: json['end_at'] as String? ?? '',
      );
}
