class Achievement {
  final String title;
  final String description;
  final DateTime? collectedDate;
  final String iconUrl;

  Achievement({
    required this.title,
    required this.description,
    this.collectedDate,
    required this.iconUrl,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      title: json['title']?.toString() ?? 'Unknown Achievement',
      description: json['description']?.toString() ?? 'No description available',
      collectedDate: json['collected_date'] != null
          ? DateTime.parse(json['collected_date'])
          : null,
      iconUrl: json['icon_url']?.toString() ?? '',
    );
  }
}
