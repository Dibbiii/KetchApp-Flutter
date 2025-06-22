class PlanModel {
  final String userId;
  final Config config;
  final List<CalendarEntry> calendar;
  final List<TomatoEntry> tomatoes;

  PlanModel({
    required this.userId,
    required this.config,
    required this.calendar,
    required this.tomatoes,
  });

  Map<String, dynamic> toJson() => {
        'user_uuid': userId,
        'config': config.toJson(),
        'calendar': calendar.map((e) => e.toJson()).toList(),
        'tomatoes': tomatoes.map((e) => e.toJson()).toList(),
      };

  factory PlanModel.fromJson(Map<String, dynamic> json) => PlanModel(
        userId: json['user_uuid'] as String? ?? '',
        config: Config.fromJson(json['config'] as Map<String, dynamic>? ?? {}),
        calendar: (json['calendar'] as List<dynamic>? ?? [])
            .map((e) => CalendarEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        tomatoes: (json['tomatoes'] as List<dynamic>? ?? [])
            .map((e) => TomatoEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Config {
  final Notifications notifications;
  final String session;
  final String pause;

  Config({
    required this.notifications,
    required this.session,
    required this.pause,
  });

  Map<String, dynamic> toJson() => {
        'notifications': notifications.toJson(),
        'session': session,
        'pause': pause,
      };

  factory Config.fromJson(Map<String, dynamic> json) => Config(
        notifications: Notifications.fromJson(
            json['notifications'] as Map<String, dynamic>? ?? {}),
        session: json['session'] as String? ?? '',
        pause: json['pause'] as String? ?? '',
      );
}

class Notifications {
  final bool enabled;
  final String sound;
  final bool vibration;

  Notifications({
    required this.enabled,
    required this.sound,
    required this.vibration,
  });

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'sound': sound,
        'vibration': vibration,
      };

  factory Notifications.fromJson(Map<String, dynamic> json) => Notifications(
        enabled: json['enabled'] as bool? ?? true,
        sound: json['sound'] as String? ?? 'default',
        vibration: json['vibration'] as bool? ?? true,
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

class TomatoEntry {
  final String title;
  final String subject;

  TomatoEntry({
    required this.title,
    required this.subject,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'subject': subject,
      };

  factory TomatoEntry.fromJson(Map<String, dynamic> json) => TomatoEntry(
        title: json['title'] as String? ?? '',
        subject: json['subject'] as String? ?? '',
      );
}
