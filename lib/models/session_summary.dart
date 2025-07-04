class SessionSummary {
  final List<dynamic> tomatoStats;
  final int totalTomatoes;
  final int completedTomatoes;
  final Duration totalPlannedTime;
  final Duration totalActualTime;
  final Duration totalPausedTime;
  final int totalPauses;
  final DateTime sessionStartTime;
  final DateTime sessionEndTime;

  SessionSummary({
    required this.tomatoStats,
    required this.totalTomatoes,
    required this.completedTomatoes,
    required this.totalPlannedTime,
    required this.totalActualTime,
    required this.totalPausedTime,
    required this.totalPauses,
    required this.sessionStartTime,
    required this.sessionEndTime,
  });

  factory SessionSummary.fromMap(Map<String, dynamic> map) {
    return SessionSummary(
      tomatoStats: map['tomatoStats'] ?? [],
      totalTomatoes: map['totalTomatoes'] ?? 0,
      completedTomatoes: map['completedTomatoes'] ?? 0,
      totalPlannedTime: map['totalPlannedTime'] ?? Duration.zero,
      totalActualTime: map['totalActualTime'] ?? Duration.zero,
      totalPausedTime: map['totalPausedTime'] ?? Duration.zero,
      totalPauses: map['totalPauses'] ?? 0,
      sessionStartTime: map['sessionStartTime'] ?? DateTime.now(),
      sessionEndTime: map['sessionEndTime'] ?? DateTime.now(),
    );
  }
}

