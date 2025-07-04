import 'package:ketchapp_flutter/models/activity.dart';
import 'package:ketchapp_flutter/models/session_summary.dart';
import 'package:ketchapp_flutter/services/api_service.dart';

import '../models/activity_action.dart';
import '../models/activity_type.dart';

/// Placeholder implementation for session stats service
class SessionStatsService {
  final ApiService apiService;
  SessionStatsService(this.apiService);

  Future<SessionSummary> calculateSessionStats(List<int> tomatoIds) async {
    // Placeholder: return a dummy summary object
    return SessionSummary(
      tomatoStats: [],
      totalTomatoes: tomatoIds.length,
      completedTomatoes: tomatoIds.length,
      totalPlannedTime: Duration(minutes: 25 * tomatoIds.length),
      totalActualTime: Duration(minutes: 25 * tomatoIds.length),
      totalPausedTime: Duration.zero,
      totalPauses: 0,
      sessionStartTime: DateTime.now(),
      sessionEndTime: DateTime.now(),
    );
  }

  /// Returns a summary for a chain of tomatoes starting from the given tomatoId.
  Future<Map<String, dynamic>> getTomatoChainSummary(int tomatoId) async {
    var tomatoIds = <int>[];
    var tomatoesData = <Map<String, dynamic>>[];
    String? subject;
    int? currentId = tomatoId;
    int totalPauses = 0;
    var totalDuration = Duration.zero;
    int totalPlannedSeconds = 0;

    // Helper to extract property from Map or object
    dynamic getProp(dynamic obj, String key) {
      if (obj is Map) return obj[key];
      try {
        return obj?.toJson()[key] ?? obj?[key];
      } catch (_) {
        try {
          return obj?.__getattribute__(key);
        } catch (_) {
          return null;
        }
      }
    }

    // Traverse the tomato chain
    print('Tomato chain for id $tomatoId:');
    while (currentId != null) {
      final tomato = await apiService.getTomatoById(currentId);
      print('  Tomato: id=${getProp(tomato, 'id')}, subject=${getProp(tomato, 'subject')}, start_at=${getProp(tomato, 'start_at')}, end_at=${getProp(tomato, 'end_at')}');
      subject ??= getProp(tomato, 'subject');
      tomatoIds.add(currentId);
      // Fetch activities for this tomato
      final activities = await apiService.getTomatoActivities(currentId);
      print('    Activities for tomato $currentId:');
      for (final activity in activities) {
        print('      $activity');
      }
      print('    Total activities: ${activities.length}');
      // Count PAUSE actions
      final pauseClicked = activities.where((activity) {
        final action = getProp(activity, 'action');
        final actionStr = action is ActivityAction
            ? action.toShortString().toUpperCase()
            : (action != null ? action.toString().toUpperCase() : null);
        return actionStr == 'PAUSE';
      }).length;
      totalPauses += pauseClicked;

      // Calculate stats from activities
      DateTime? realStartAt;
      DateTime? realEndAt;
      DateTime? realPauseEnd;
      Duration effectiveTime = Duration.zero;
      Duration breakTime = Duration.zero;
      // Find first TIMER/START and last TIMER/END (case-insensitive)
      for (final activity in activities) {
        final type = getProp(activity, 'type');
        final action = getProp(activity, 'action');
        var createdAt = getProp(activity, 'createdAt') ?? getProp(activity, 'created_at');
        if (createdAt is String) {
          try {
            createdAt = DateTime.parse(createdAt);
          } catch (_) {
            createdAt = null;
          }
        }
        final typeStr = type is ActivityType
            ? type.toShortString().toUpperCase()
            : type != null ? type.toString().toUpperCase() : null;
        final actionStr = action is ActivityAction
            ? action.toShortString().toUpperCase()
            : action != null ? action.toString().toUpperCase() : null;
        if (typeStr == 'TIMER' && actionStr == 'START') {
          if (realStartAt == null || (createdAt != null && createdAt.isBefore(realStartAt))) {
            realStartAt = createdAt;
          }
        }
        if (typeStr == 'TIMER' && actionStr == 'END') {
          if (realEndAt == null || (createdAt != null && createdAt.isAfter(realEndAt))) {
            realEndAt = createdAt;
          }
        }
      }
      // Sum all BREAK/START-END pairs for breakTime, find last resume (case-insensitive)
      DateTime? breakStart;
      for (final activity in activities) {
        final type = getProp(activity, 'type');
        final action = getProp(activity, 'action');
        var createdAt = getProp(activity, 'createdAt') ?? getProp(activity, 'created_at');
        if (createdAt is String) {
          try {
            createdAt = DateTime.parse(createdAt);
          } catch (_) {
            createdAt = null;
          }
        }
        final typeStr = type is ActivityType
            ? type.toShortString().toUpperCase()
            : type != null ? type.toString().toUpperCase() : null;
        final actionStr = action is ActivityAction
            ? action.toShortString().toUpperCase()
            : action != null ? action.toString().toUpperCase() : null;
        if (typeStr == 'BREAK' && actionStr == 'START') {
          breakStart = createdAt;
        }
        if (typeStr == 'BREAK' && actionStr == 'END' && breakStart != null && createdAt != null) {
          breakTime += createdAt.difference(breakStart);
          breakStart = null;
          realPauseEnd = createdAt;
        }
        if (typeStr == 'TIMER' && actionStr == 'RESUME') {
          realPauseEnd = createdAt;
        }
      }
      if (realStartAt != null && realEndAt != null) {
        effectiveTime = realEndAt.difference(realStartAt) - breakTime;
      }
      // Calculate tempoEffettivo using only START and END for this tomato
      DateTime? tomatoStartAt = getProp(tomato, 'startAt') ?? getProp(tomato, 'start_at');
      DateTime? tomatoEndAt = getProp(tomato, 'endAt') ?? getProp(tomato, 'end_at');
      if (tomatoStartAt is String) {
        try {
          tomatoStartAt = DateTime.parse(tomatoStartAt as String);
        } catch (_) {
          tomatoStartAt = null;
        }
      }
      if (tomatoEndAt is String) {
        try {
          tomatoEndAt = DateTime.parse(tomatoEndAt as String);
        } catch (_) {
          tomatoEndAt = null;
        }
      }
      // Ensure both are DateTime before using
      Duration tempoEffettivo = Duration.zero;
      if (tomatoStartAt is DateTime && tomatoEndAt is DateTime) {
        tempoEffettivo = tomatoEndAt.difference(tomatoStartAt);
      }
      // Use a helper to build the stats map more cleanly
      // Helper to build stats map for a tomato
      Map<String, dynamic> buildTomatoStats() {
        final map = <String, dynamic>{};
        if (tempoEffettivo.inSeconds > 0) map['tempoEffettivo'] = tempoEffettivo;
        if (breakTime.inSeconds > 0) map['breakTime'] = breakTime;
        if (pauseClicked > 0) map['pauseClicked'] = pauseClicked;
        if (realStartAt != null) map['RealStartAt'] = realStartAt;
        if (realEndAt != null) map['RealEndAt'] = realEndAt;
        if (realPauseEnd != null) map['RealPauseEnd'] = realPauseEnd;
        return map;
      }
      final tomatoStats = buildTomatoStats();
      // Print stats in a compact, readable way
      print('    Stats:');
      for (final entry in tomatoStats.entries) {
        print('      ${entry.key}: ${entry.value}');
      }

      // Calculate durations
      final tomatoPauseEndAt = getProp(tomato, 'pauseEndAt') ?? getProp(tomato, 'pause_end_at');
      final plannedSeconds = (getProp(tomato, 'plannedDuration') ?? getProp(tomato, 'planned_duration') ?? 1500) as int;
      totalPlannedSeconds += plannedSeconds;
      Duration tomatoDuration = Duration.zero;
      if (tomatoStartAt != null && tomatoEndAt != null) {
        tomatoDuration = tomatoEndAt.difference(tomatoStartAt);
        totalDuration += tomatoDuration;
      }

      tomatoesData.add({
        'id': getProp(tomato, 'id'),
        'startAt': tomatoStartAt,
        'endAt': tomatoEndAt,
        'pauseEndAt': tomatoPauseEndAt,
        'activityStartAt': null,
        'activityEndAt': null,
        'activityPauseStartAt': null,
        'activityPauseEndAt': null,
        'pauseCount': pauseClicked,
        'pauseDuration': breakTime,
        'activities': activities,
        'duration': tomatoDuration,
        'plannedSeconds': plannedSeconds,
      });
      currentId = getProp(tomato, 'nextTomatoId') ?? getProp(tomato, 'next_tomato_id');
    }

    // Calculate efficiency
    double efficiency = 0;
    if (totalPlannedSeconds > 0) {
      efficiency = (totalDuration.inSeconds / totalPlannedSeconds) * 100;
    }

    return {
      'subject': subject,
      'tomatoIds': tomatoIds,
      'tomatoes': tomatoesData,
      'totalDuration': totalDuration,
      'totalPauses': totalPauses,
      'efficiency': efficiency,
    };
  }
}
