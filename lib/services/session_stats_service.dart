import 'package:ketchapp_flutter/models/activity_action.dart';
import 'package:ketchapp_flutter/models/activity_type.dart';
import 'package:ketchapp_flutter/models/tomato_session_stats.dart';
import 'package:ketchapp_flutter/services/api_service.dart';

class SessionStatsService {
  final ApiService _apiService;

  SessionStatsService(this._apiService);

  /// Calcola le statistiche per una singola sessione di pomodori
  Future<SessionSummary> calculateSessionStats(List<int> tomatoIds) async {
    print('🔍 Calcolo statistiche per ${tomatoIds.length} pomodori: $tomatoIds');

    final List<TomatoStats> tomatoStatsList = [];
    DateTime? sessionStartTime;
    DateTime? sessionEndTime;

    for (final tomatoId in tomatoIds) {
      try {
        print('📊 Processando pomodoro $tomatoId...');
        final tomato = await _apiService.getTomatoById(tomatoId);
        final activities = await _apiService.getTomatoActivities(tomatoId);

        print('📋 Pomodoro $tomatoId: ${activities.length} attività trovate');

        // Debug: stampa tutte le attività
        for (int i = 0; i < activities.length; i++) {
          final activity = activities[i];
          print('  Activity $i: ${activity.runtimeType} - ${_getActivityInfo(activity)}');
        }

        if (activities.isEmpty) {
          print('⚠️ Nessuna attività per il pomodoro $tomatoId, saltando...');
          continue;
        }

        final stats = await _calculateTomatoStats(tomato, activities);
        tomatoStatsList.add(stats);

        print('✅ Statistiche calcolate per pomodoro $tomatoId: ${stats.actualDuration} effettivo vs ${stats.plannedDuration} pianificato');

        // Determina i tempi di inizio e fine della sessione
        if (sessionStartTime == null || stats.startTime.isBefore(sessionStartTime)) {
          sessionStartTime = stats.startTime;
        }

        if (stats.endTime != null &&
            (sessionEndTime == null || stats.endTime!.isAfter(sessionEndTime))) {
          sessionEndTime = stats.endTime!;
        }
      } catch (e, stackTrace) {
        print('❌ Errore nel calcolare le statistiche per il pomodoro $tomatoId: $e');
        print('Stack trace: $stackTrace');
      }
    }

    final summary = SessionSummary(
      tomatoStats: tomatoStatsList,
      totalTomatoes: tomatoStatsList.length,
      completedTomatoes: tomatoStatsList.where((s) => s.isCompleted).length,
      totalPlannedTime: tomatoStatsList.fold(
        Duration.zero,
        (sum, stats) => sum + stats.plannedDuration
      ),
      totalActualTime: tomatoStatsList.fold(
        Duration.zero,
        (sum, stats) => sum + stats.actualDuration
      ),
      totalPausedTime: tomatoStatsList.fold(
        Duration.zero,
        (sum, stats) => sum + stats.totalPausedTime
      ),
      totalPauses: tomatoStatsList.fold(
        0,
        (sum, stats) => sum + stats.pauseCount
      ),
      sessionStartTime: sessionStartTime ?? DateTime.now(),
      sessionEndTime: sessionEndTime ?? DateTime.now(),
    );

    print('🎯 Riepilogo sessione: ${summary.completedTomatoes}/${summary.totalTomatoes} completati, ${summary.totalActualTime} tempo totale');
    return summary;
  }

  /// Helper per ottenere info di debug dall'attività
  String _getActivityInfo(dynamic activity) {
    try {
      final type = _getActivityProperty(activity, 'type') ?? 'unknown';
      final action = _getActivityProperty(activity, 'action') ?? 'unknown';
      final createdAt = _getActivityProperty(activity, 'createdAt') ?? 'unknown';
      return 'type=$type, action=$action, time=$createdAt';
    } catch (e) {
      return 'Errore nell\'accesso alle proprietà: $e';
    }
  }

  /// Helper sicuro per accedere alle proprietà dell'attività
  dynamic _getActivityProperty(dynamic activity, String property) {
    try {
      // Prova diversi modi di accesso alle proprietà
      if (activity is Map) {
        return activity[property];
      } else {
        // Prova ad accedere come oggetto con getter
        switch (property) {
          case 'type':
            return activity.type;
          case 'action':
            return activity.action;
          case 'createdAt':
            return activity.createdAt;
          default:
            return null;
        }
      }
    } catch (e) {
      print('⚠️ Errore nell\'accesso alla proprietà $property: $e');
      return null;
    }
  }

  /// Calcola le statistiche per un singolo pomodoro
  Future<TomatoStats> _calculateTomatoStats(dynamic tomato, List<dynamic> activities) async {
    try {
      print('🔍 Calcolando statistiche per pomodoro ${tomato.id}...');

      // Ordina le attività per tempo
      final sortedActivities = <dynamic>[];
      for (final activity in activities) {
        try {
          final createdAt = _getActivityProperty(activity, 'createdAt');
          if (createdAt != null) {
            sortedActivities.add(activity);
          }
        } catch (e) {
          print('⚠️ Saltando attività senza timestamp: $e');
        }
      }

      sortedActivities.sort((a, b) {
        try {
          final timeA = _getActivityProperty(a, 'createdAt') as DateTime;
          final timeB = _getActivityProperty(b, 'createdAt') as DateTime;
          return timeA.compareTo(timeB);
        } catch (e) {
          print('⚠️ Errore nell\'ordinamento: $e');
          return 0;
        }
      });

      // Filtra le attività del timer
      final timerActivities = <dynamic>[];
      for (final activity in sortedActivities) {
        try {
          final type = _getActivityProperty(activity, 'type');
          if (type == ActivityType.TIMER.toShortString() || type == 'timer') {
            timerActivities.add(activity);
          }
        } catch (e) {
          print('⚠️ Errore nel filtrare attività timer: $e');
        }
      }

      print('📊 Trovate ${timerActivities.length} attività timer per pomodoro ${tomato.id}');

      if (timerActivities.isEmpty) {
        print('⚠️ Nessuna attività timer trovata per pomodoro ${tomato.id}');
        return TomatoStats(
          tomatoId: tomato.id,
          tomatoName: _getActivityProperty(tomato, 'name') ?? 'Pomodoro ${tomato.id}',
          plannedDuration: Duration(seconds: _getActivityProperty(tomato, 'duration') ?? 1500),
          actualDuration: Duration.zero,
          totalPausedTime: Duration.zero,
          pauseCount: 0,
          startTime: DateTime.now(),
          isCompleted: false,
          wasOvertime: false,
        );
      }

      // Trova il primo START
      dynamic startActivity;
      for (final activity in timerActivities) {
        final action = _getActivityProperty(activity, 'action');
        if (action == ActivityAction.START.toShortString() || action == 'start') {
          startActivity = activity;
          break;
        }
      }
      startActivity ??= timerActivities.first;

      // Trova l'ultimo END
      dynamic endActivity;
      for (final activity in timerActivities.reversed) {
        final action = _getActivityProperty(activity, 'action');
        if (action == ActivityAction.END.toShortString() || action == 'end') {
          endActivity = activity;
          break;
        }
      }

      // Calcola il tempo effettivo di lavoro
      final workingDuration = _calculateWorkingTime(timerActivities);

      // Calcola il tempo totale di pausa
      final pausedTime = _calculatePausedTime(timerActivities);

      // Conta le pause
      int pauseCount = 0;
      for (final activity in timerActivities) {
        try {
          final action = _getActivityProperty(activity, 'action');
          if (action == ActivityAction.PAUSE.toShortString() || action == 'pause') {
            pauseCount++;
          }
        } catch (e) {
          print('⚠️ Errore nel contare le pause: $e');
        }
      }

      final plannedDuration = Duration(seconds: _getActivityProperty(tomato, 'duration') ?? 1500);
      final isCompleted = endActivity != null;
      final wasOvertime = workingDuration > plannedDuration;

      final stats = TomatoStats(
        tomatoId: tomato.id,
        tomatoName: _getActivityProperty(tomato, 'name') ?? 'Pomodoro ${tomato.id}',
        plannedDuration: plannedDuration,
        actualDuration: workingDuration,
        totalPausedTime: pausedTime,
        pauseCount: pauseCount,
        startTime: _getActivityProperty(startActivity, 'createdAt') as DateTime? ?? DateTime.now(),
        endTime: endActivity != null ? _getActivityProperty(endActivity, 'createdAt') as DateTime? : null,
        isCompleted: isCompleted,
        wasOvertime: wasOvertime,
      );

      print('✅ Statistiche pomodoro ${tomato.id}: pianificato=${plannedDuration.inMinutes}min, effettivo=${workingDuration.inMinutes}min, pause=${pauseCount}, completato=$isCompleted');

      return stats;
    } catch (e, stackTrace) {
      print('❌ Errore generale nel calcolo delle statistiche per il pomodoro ${tomato.id}: $e');
      print('Stack trace: $stackTrace');

      // Ritorna statistiche di default in caso di errore
      return TomatoStats(
        tomatoId: tomato.id,
        tomatoName: 'Pomodoro ${tomato.id}',
        plannedDuration: Duration(seconds: 1500),
        actualDuration: Duration.zero,
        totalPausedTime: Duration.zero,
        pauseCount: 0,
        startTime: DateTime.now(),
        isCompleted: false,
        wasOvertime: false,
      );
    }
  }

  /// Calcola il tempo effettivo di lavoro (escluse le pause)
  Duration _calculateWorkingTime(List<dynamic> timerActivities) {
    try {
      DateTime? lastStartTime;
      Duration totalWorkingTime = Duration.zero;

      print('🕐 Calcolando tempo di lavoro per ${timerActivities.length} attività...');

      for (final activity in timerActivities) {
        try {
          final action = _getActivityProperty(activity, 'action');
          final time = _getActivityProperty(activity, 'createdAt') as DateTime?;

          if (time == null || action == null) continue;

          print('  📝 $action at $time');

          // Normalizza le azioni per il confronto
          final normalizedAction = action.toString().toLowerCase();

          if (normalizedAction == 'start' || normalizedAction == 'resume') {
            lastStartTime = time;
            print('    🟢 Iniziato periodo di lavoro');
          } else if (normalizedAction == 'pause' || normalizedAction == 'end') {
            if (lastStartTime != null) {
              final duration = time.difference(lastStartTime);
              totalWorkingTime += duration;
              print('    ⏱️ Aggiunto segmento: ${duration.inMinutes}min ${duration.inSeconds % 60}s');
              lastStartTime = null;
            }
          }
        } catch (e) {
          print('⚠️ Errore nel processare attività: $e');
        }
      }

      // Se il timer è ancora in corso, aggiungi il tempo fino ad ora
      if (lastStartTime != null) {
        final currentDuration = DateTime.now().difference(lastStartTime);
        totalWorkingTime += currentDuration;
        print('    ⏱️ Aggiunto tempo corrente: ${currentDuration.inMinutes}min ${currentDuration.inSeconds % 60}s');
      }

      print('✅ Tempo totale di lavoro: ${totalWorkingTime.inMinutes}min ${totalWorkingTime.inSeconds % 60}s');
      return totalWorkingTime;
    } catch (e) {
      print('❌ Errore nel calcolo del tempo di lavoro: $e');
      return Duration.zero;
    }
  }

  /// Calcola il tempo totale di pausa
  Duration _calculatePausedTime(List<dynamic> timerActivities) {
    try {
      DateTime? lastPauseTime;
      Duration totalPausedTime = Duration.zero;

      print('⏸️ Calcolando tempo di pausa...');

      for (final activity in timerActivities) {
        try {
          final action = _getActivityProperty(activity, 'action');
          final time = _getActivityProperty(activity, 'createdAt') as DateTime?;

          if (time == null || action == null) continue;

          // Normalizza le azioni per il confronto
          final normalizedAction = action.toString().toLowerCase();

          if (normalizedAction == 'pause') {
            lastPauseTime = time;
            print('    ⏸️ Iniziata pausa at $time');
          } else if ((normalizedAction == 'resume' || normalizedAction == 'end') && lastPauseTime != null) {
            final pauseDuration = time.difference(lastPauseTime);
            totalPausedTime += pauseDuration;
            print('    ⏸️ Pausa durata: ${pauseDuration.inMinutes}min ${pauseDuration.inSeconds % 60}s');
            lastPauseTime = null;
          }
        } catch (e) {
          print('⚠️ Errore nel calcolare pausa: $e');
        }
      }

      // Se è ancora in pausa, aggiungi il tempo fino ad ora
      if (lastPauseTime != null) {
        final currentPauseDuration = DateTime.now().difference(lastPauseTime);
        totalPausedTime += currentPauseDuration;
        print('    ⏸️ Pausa corrente: ${currentPauseDuration.inMinutes}min ${currentPauseDuration.inSeconds % 60}s');
      }

      print('✅ Tempo totale di pausa: ${totalPausedTime.inMinutes}min ${totalPausedTime.inSeconds % 60}s');
      return totalPausedTime;
    } catch (e) {
      print('❌ Errore nel calcolo del tempo di pausa: $e');
      return Duration.zero;
    }
  }
}
