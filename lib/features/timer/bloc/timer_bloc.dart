import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ketchapp_flutter/models/activity_action.dart';
import 'package:ketchapp_flutter/models/activity_type.dart';
import 'package:ketchapp_flutter/services/api_service.dart';


part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final ApiService _apiService;
  final String _userUUID;
  int _tomatoId;
  Timer? _timer;

  int _tomatoDuration = 0;
  int _breakDuration = 0;

  TimerBloc(
      {required ApiService apiService,
        required String userUUID,
        required int tomatoId})
      : _apiService = apiService,
        _userUUID = userUUID,
        _tomatoId = tomatoId,
        super(const WaitingFirstTomato()) {
    on<TimerLoaded>(_onLoaded);
    on<TimerStarted>(_onStarted);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerFinished>(_onFinished);
    on<NextTransition>(_onNextTransition);
    on<_TimerTicked>(_onTicked);
    on<TimerSkipToEnd>(_onSkipToEnd);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void _startTimer(int duration) {
    print('_startTimer called with duration: $duration');
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      print('Timer tick - state.duration: ${state.duration}, isClosed: $isClosed');
      if (isClosed) {
        timer.cancel();
        return;
      }
      if (state.duration > 0) {
        print('Adding _TimerTicked with duration: ${state.duration - 1}');
        add(_TimerTicked(duration: state.duration - 1));
      } else {
        print('Timer finished, cancelling and adding NextTransition');
        _timer?.cancel();
        add(const NextTransition());
      }
    });
    print('Timer periodic created successfully');
  }

  void _onLoaded(TimerLoaded event, Emitter<TimerState> emit) async {
    _tomatoDuration = event.tomatoDuration;
    _breakDuration = event.breakDuration;
    try {
      var activities = await _apiService.getTomatoActivities(_tomatoId);
      print('Activities for tomato $_tomatoId: $activities');

      final hasTimerEnd = activities.any((a) =>
          a.action == ActivityAction.END.toShortString() &&
          a.type == ActivityType.TIMER.toShortString());

      if (hasTimerEnd) {
        final tomato = await _apiService.getTomatoById(_tomatoId);
        if (tomato.nextTomatoId != null) {
          final hasBreakEnd = activities.any((a) =>
              a.action == ActivityAction.END.toShortString() &&
              a.type == ActivityType.BREAK.toShortString());
          if (hasBreakEnd) {
            emit(WaitingNextTomato(nextTomatoId: tomato.nextTomatoId!));
            return;
          } else {
            // Handle ongoing break
            activities.sort((a, b) => a.createdAt.compareTo(b.createdAt));

            DateTime? lastBreakStartTime;
            Duration elapsedBreakDuration = Duration.zero;

            for (final activity in activities) {
              if (activity.type == ActivityType.BREAK.toShortString()) {
                if (activity.action == ActivityAction.START.toShortString() ||
                    activity.action == ActivityAction.RESUME.toShortString()) {
                  lastBreakStartTime = activity.createdAt;
                } else if (activity.action ==
                        ActivityAction.PAUSE.toShortString() &&
                    lastBreakStartTime != null) {
                  elapsedBreakDuration +=
                      activity.createdAt.difference(lastBreakStartTime);
                  lastBreakStartTime = null;
                }
              }
            }

            final lastActivity = activities.last;

            if (lastActivity.type == ActivityType.BREAK.toShortString() &&
                lastActivity.action == ActivityAction.PAUSE.toShortString()) {
              final remainingDuration =
                  _breakDuration - elapsedBreakDuration.inSeconds;
              emit(BreakTimerPaused(remainingDuration > 0 ? remainingDuration : 0,
                  nextTomatoId: tomato.nextTomatoId!));
            } else {
              // Break is in progress
              if (lastBreakStartTime != null) {
                elapsedBreakDuration +=
                    DateTime.now().toUtc().difference(lastBreakStartTime);
              }
              final remainingDuration =
                  _breakDuration - elapsedBreakDuration.inSeconds;
              final duration = remainingDuration > 0 ? remainingDuration : 0;
              emit(BreakTimerInProgress(duration,
                  nextTomatoId: tomato.nextTomatoId!));
              _startTimer(duration);
            }
            return;
          }
        } else {
          emit(const SessionComplete());
          return;
        }
      }

      if (activities.isEmpty) {
        emit(const TomatoTimerReady());
        return;
      }

      activities.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      DateTime? lastStartTime;
      Duration elapsedDuration = Duration.zero;

      for (final activity in activities) {
        if (activity.type == ActivityType.TIMER.toShortString()) {
          if (activity.action == ActivityAction.START.toShortString() ||
              activity.action == ActivityAction.RESUME.toShortString()) {
            lastStartTime = activity.createdAt;
          } else if (activity.action == ActivityAction.PAUSE.toShortString() &&
              lastStartTime != null) {
            elapsedDuration += activity.createdAt.difference(lastStartTime);
            lastStartTime = null;
          }
        }
      }

      final lastActivity = activities.last;

      if (lastActivity.type == ActivityType.TIMER.toShortString() &&
          lastActivity.action == ActivityAction.PAUSE.toShortString()) {
        final remainingDuration = _tomatoDuration - elapsedDuration.inSeconds;
        emit(TomatoTimerPaused(remainingDuration > 0 ? remainingDuration : 0));
      } else if (lastActivity.type == ActivityType.TIMER.toShortString() &&
                 (lastActivity.action == ActivityAction.START.toShortString() ||
                  lastActivity.action == ActivityAction.RESUME.toShortString())) {
        // Timer è attivo, calcola il tempo rimanente
        if (lastStartTime != null) {
          elapsedDuration += DateTime.now().toUtc().difference(lastStartTime);
        }
        final remainingDuration = _tomatoDuration - elapsedDuration.inSeconds;
        final duration = remainingDuration > 0 ? remainingDuration : 0;

        if (duration > 0) {
          print('Emitting TomatoTimerInProgress with duration: $duration in _onLoaded');
          emit(TomatoTimerInProgress(duration));
          _startTimer(duration);
        } else {
          // Il timer è già finito, ma non abbiamo ricevuto la notifica
          print('Timer already finished, emitting TomatoTimerReady');
          emit(const TomatoTimerReady());
        }
      } else {
        // Nessuna attività TIMER, mostra ready
        print('No TIMER activities found, emitting TomatoTimerReady');
        emit(const TomatoTimerReady());
      }
    } catch (e) {
      // Handle potential errors, e.g., by emitting a failure state
    }
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) async {
    print('Timer starting...');
    // This now only handles the start button press
    try {
      final tomato = await _apiService.getTomatoById(_tomatoId);
      print('Starting tomato: $tomato');

      var activities = await _apiService.getTomatoActivities(_tomatoId);
      print('Current activities: $activities');

      if (!activities.any((a) => a.action == ActivityAction.START.toShortString() && a.type == ActivityType.TIMER.toShortString())) {
        await _apiService.createActivity(
            _userUUID, _tomatoId, ActivityAction.START, ActivityType.TIMER);
        // Refresh activities after adding a new one
        activities = await _apiService.getTomatoActivities(_tomatoId);
        print('Activities after START creation: $activities');
      }

      activities.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      DateTime? lastStartTime;
      Duration elapsedDuration = Duration.zero;

      for (final activity in activities) {
        if (activity.type == ActivityType.TIMER.toShortString()) {
          if (activity.action == ActivityAction.START.toShortString() ||
              activity.action == ActivityAction.RESUME.toShortString()) {
            lastStartTime = activity.createdAt;
          } else if (activity.action == ActivityAction.PAUSE.toShortString() &&
              lastStartTime != null) {
            elapsedDuration += activity.createdAt.difference(lastStartTime);
            lastStartTime = null;
          }
        }
      }

      if (lastStartTime != null) {
        elapsedDuration += DateTime.now().toUtc().difference(lastStartTime);
      }

      final remainingDuration = _tomatoDuration - elapsedDuration.inSeconds;
      final duration = remainingDuration > 0 ? remainingDuration : 0;

      print('Calculated duration: $duration seconds (remaining: $remainingDuration, elapsed: ${elapsedDuration.inSeconds})');

      emit(TomatoTimerInProgress(duration));
      print('Emitted TomatoTimerInProgress state with duration: $duration');

      _startTimer(duration);
      print('Timer started with duration: $duration');
    } catch (e) {
      print('Error in _onStarted: $e');
    }
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) async {
    if (state is TomatoTimerInProgress || state is BreakTimerInProgress) {
      _timer?.cancel();
      try {
        final type =
            state is TomatoTimerInProgress ? ActivityType.TIMER : ActivityType.BREAK;
        await _apiService.createActivity(
            _userUUID, _tomatoId, ActivityAction.PAUSE, type);
        if (state is TomatoTimerInProgress) {
          emit(TomatoTimerPaused(state.duration));
        } else if (state is BreakTimerInProgress) {
          final breakState = state as BreakTimerInProgress;
          emit(BreakTimerPaused(breakState.duration,
              nextTomatoId: breakState.nextTomatoId));
        }
      } catch (e) {
        _startTimer(state.duration);
      }
    }
  }

  void _onResumed(TimerResumed event, Emitter<TimerState> emit) async {
    if (state is TomatoTimerPaused || state is BreakTimerPaused) {
      try {
        final type =
            state is TomatoTimerPaused ? ActivityType.TIMER : ActivityType.BREAK;
        await _apiService.createActivity(
            _userUUID, _tomatoId, ActivityAction.RESUME, type);
        if (state is TomatoTimerPaused) {
          emit(TomatoTimerInProgress(state.duration));
        } else if (state is BreakTimerPaused) {
          final breakPausedState = state as BreakTimerPaused;
          emit(BreakTimerInProgress(breakPausedState.duration,
              nextTomatoId: breakPausedState.nextTomatoId));
        }
        _startTimer(state.duration);
      } catch (e) {
        //
      }
    }
  }

  void _onFinished(TimerFinished event, Emitter<TimerState> emit) {
    _timer?.cancel();
    emit(const SessionComplete());
  }

  void _onNextTransition(NextTransition event, Emitter<TimerState> emit) async {
    if (state is TomatoTimerInProgress || state is TomatoTimerPaused) {
      await _apiService.createActivity(
          _userUUID, _tomatoId, ActivityAction.END, ActivityType.TIMER);
      final tomato = await _apiService.getTomatoById(_tomatoId);
      if (tomato.nextTomatoId != null) {
        await _apiService.createActivity(
            _userUUID, _tomatoId, ActivityAction.START, ActivityType.BREAK);
        emit(BreakTimerInProgress(_breakDuration, nextTomatoId: tomato.nextTomatoId!));
        _startTimer(_breakDuration);
      } else {
        emit(const SessionComplete());
      }
    } else if (state is BreakTimerInProgress || state is BreakTimerPaused) {
      await _apiService.createActivity(
          _userUUID, _tomatoId, ActivityAction.END, ActivityType.BREAK);
      if (state is BreakTimerInProgress) {
        final breakState = state as BreakTimerInProgress;
        // Non emettere WaitingNextTomato, passa direttamente al prossimo tomato
        _tomatoId = breakState.nextTomatoId;

        // Ottieni il nuovo tomato e calcola la sua durata
        final newTomato = await _apiService.getTomatoById(_tomatoId);
        final newTomatoDuration = newTomato.endAt.difference(newTomato.startAt).inSeconds;
        final newBreakDuration = newTomato.pauseEnd != null
            ? newTomato.pauseEnd!.difference(newTomato.endAt).inSeconds
            : 0;

        // Aggiorna le durate nel bloc
        _tomatoDuration = newTomatoDuration;
        _breakDuration = newBreakDuration;

        print('Auto-switching to tomato $_tomatoId with duration: $_tomatoDuration seconds');

        // Prima emetti TomatoSwitched per notificare l'UI del cambio
        emit(TomatoSwitched(newTomatoId: _tomatoId));

        // Aspetta un po' per permettere all'UI di aggiornarsi
        await Future.delayed(const Duration(milliseconds: 100));

        // Crea automaticamente l'attività START per il nuovo tomato
        await _apiService.createActivity(
            _userUUID, _tomatoId, ActivityAction.START, ActivityType.TIMER);

        // Avvia automaticamente il timer del nuovo tomato
        emit(TomatoTimerInProgress(_tomatoDuration));
        _startTimer(_tomatoDuration);
      } else if (state is BreakTimerPaused) {
        final breakState = state as BreakTimerPaused;
        emit(WaitingNextTomato(nextTomatoId: breakState.nextTomatoId));
        add(const NextTransition()); // Automatically trigger the next transition
      }
    } else if (state is WaitingNextTomato) {
      final waitingState = state as WaitingNextTomato;
      _tomatoId = waitingState.nextTomatoId;

      // Ottieni il nuovo tomato e calcola la sua durata
      final newTomato = await _apiService.getTomatoById(_tomatoId);
      final newTomatoDuration = newTomato.endAt.difference(newTomato.startAt).inSeconds;
      final newBreakDuration = newTomato.pauseEnd != null
          ? newTomato.pauseEnd!.difference(newTomato.endAt).inSeconds
          : 0;

      // Aggiorna le durate nel bloc
      _tomatoDuration = newTomatoDuration;
      _breakDuration = newBreakDuration;

      print('Switching to tomato $_tomatoId with duration: $_tomatoDuration seconds');

      final activities = await _apiService.getTomatoActivities(_tomatoId);
      if (!activities.any((a) => a.action == ActivityAction.START.toShortString())) {
        await _apiService.createActivity(
            _userUUID, _tomatoId, ActivityAction.START, ActivityType.TIMER);
      }
      emit(TomatoTimerInProgress(_tomatoDuration));
      _startTimer(_tomatoDuration);
    }
  }

  void _onTicked(_TimerTicked event, Emitter<TimerState> emit) {
    print('_onTicked called with duration: ${event.duration}, current state: ${state.runtimeType}');
    if (event.duration > 0) {
      if (state is TomatoTimerInProgress) {
        print('Emitting TomatoTimerInProgress with duration: ${event.duration}');
        emit(TomatoTimerInProgress(event.duration));
      } else if (state is BreakTimerInProgress) {
        final breakState = state as BreakTimerInProgress;
        print('Emitting BreakTimerInProgress with duration: ${event.duration}');
        emit(BreakTimerInProgress(event.duration,
            nextTomatoId: breakState.nextTomatoId));
      }
    } else {
      print('Timer reached 0, cancelling and adding NextTransition');
      _timer?.cancel();
      add(const NextTransition());
    }
  }

  void _onSkipToEnd(TimerSkipToEnd event, Emitter<TimerState> emit) async {
    print('Skipping to end - leaving 10 seconds...');

    if (state is TomatoTimerInProgress) {
      // Imposta il timer del pomodoro a 10 secondi
      _timer?.cancel();
      emit(TomatoTimerInProgress(10));
      _startTimer(10);
      print('Skipped tomato timer to 10 seconds');
    } else if (state is BreakTimerInProgress) {
      // Imposta il timer del break a 10 secondi
      final breakState = state as BreakTimerInProgress;
      _timer?.cancel();
      emit(BreakTimerInProgress(10, nextTomatoId: breakState.nextTomatoId));
      _startTimer(10);
      print('Skipped break timer to 10 seconds');
    } else if (state is TomatoTimerPaused) {
      // Se il pomodoro è in pausa, riprendi con 10 secondi
      _timer?.cancel();
      emit(TomatoTimerInProgress(10));
      _startTimer(10);
      print('Resumed tomato timer with 10 seconds');
    } else if (state is BreakTimerPaused) {
      // Se il break è in pausa, riprendi con 10 secondi
      final breakState = state as BreakTimerPaused;
      _timer?.cancel();
      emit(BreakTimerInProgress(10, nextTomatoId: breakState.nextTomatoId));
      _startTimer(10);
      print('Resumed break timer with 10 seconds');
    }
  }
}