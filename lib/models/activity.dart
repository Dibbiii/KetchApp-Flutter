class Activity {
  final int id;
  final String type;
  final String action;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.type,
    required this.action,
    required this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      type: json['type'],
      action: json['action'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

