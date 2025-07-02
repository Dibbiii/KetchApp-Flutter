class TomatoStats {
  final int tomatoId;
  final String tomatoName;
  final Duration plannedDuration;
  final Duration actualDuration;
  final Duration totalPausedTime;
  final int pauseCount;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isCompleted;
  final bool wasOvertime;

  const TomatoStats({
    required this.tomatoId,
    required this.tomatoName,
    required this.plannedDuration,
    required this.actualDuration,
    required this.totalPausedTime,
    required this.pauseCount,
    required this.startTime,
    this.endTime,
    required this.isCompleted,
    required this.wasOvertime,
  });

  Duration get overtimeDuration => wasOvertime ? actualDuration - plannedDuration : Duration.zero;

  double get efficiencyPercentage =>
    plannedDuration.inSeconds > 0
      ? (plannedDuration.inSeconds / actualDuration.inSeconds) * 100
      : 100.0;
}

class SessionSummary {
  final List<TomatoStats> tomatoStats;
  final int totalTomatoes;
  final int completedTomatoes;
  final Duration totalPlannedTime;
  final Duration totalActualTime;
  final Duration totalPausedTime;
  final int totalPauses;
  final DateTime sessionStartTime;
  final DateTime sessionEndTime;

  const SessionSummary({
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

  double get completionRate => totalTomatoes > 0 ? (completedTomatoes / totalTomatoes) * 100 : 0.0;

  double get overallEfficiency =>
    totalPlannedTime.inSeconds > 0
      ? (totalPlannedTime.inSeconds / totalActualTime.inSeconds) * 100
      : 100.0;

  Duration get totalOvertimeDuration =>
    tomatoStats.fold(Duration.zero, (sum, stats) => sum + stats.overtimeDuration);
}
