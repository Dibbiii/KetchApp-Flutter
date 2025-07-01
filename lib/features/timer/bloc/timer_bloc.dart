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
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void _startTimer(int duration) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      if (state.duration > 0) {
        add(_TimerTicked(duration: state.duration - 1));
      } else {
        _timer?.cancel();
        add(const NextTransition());
      }
    });
  }

  void _onLoaded(TimerLoaded event, Emitter<TimerState> emit) async {
    _tomatoDuration = event.tomatoDuration;
    _breakDuration = event.breakDuration;
    try {
      var activities = await _apiService.getTomatoActivities(_tomatoId);
      print('Activities for tomato $_tomatoId: $activities');

      if (activities.any((a) => a.action == ActivityAction.END.toShortString())) {
        final tomato = await _apiService.getTomatoById(_tomatoId);
        if (tomato.nextTomatoId != null) {
          emit(WaitingNextTomato(nextTomatoId: tomato.nextTomatoId!));
          add(const NextTransition()); // Automatically trigger the next transition
        } else {
          emit(const SessionComplete());
        }
        return;
      }

      if (activities.isEmpty) {
        emit(const TomatoTimerReady());
        return;
      }

      activities.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      DateTime? lastStartTime;
      Duration elapsedDuration = Duration.zero;

      for (final activity in activities) {
        if (activity.action == ActivityAction.START.toShortString() ||
            activity.action == ActivityAction.RESUME.toShortString()) {
          lastStartTime = activity.createdAt;
        } else if (activity.action == ActivityAction.PAUSE.toShortString() &&
            lastStartTime != null) {
          elapsedDuration += activity.createdAt.difference(lastStartTime);
          lastStartTime = null;
        }
      }

      final lastActivity = activities.last;

      if (lastActivity.action == ActivityAction.PAUSE.toShortString()) {
        final remainingDuration = _tomatoDuration - elapsedDuration.inSeconds;
        emit(TomatoTimerPaused(remainingDuration > 0 ? remainingDuration : 0));
      } else { // Last activity was START or RESUME
        if (lastStartTime != null) {
          elapsedDuration += DateTime.now().difference(lastStartTime);
        }
        final remainingDuration = _tomatoDuration - elapsedDuration.inSeconds;
        final duration = remainingDuration > 0 ? remainingDuration : 0;
        emit(TomatoTimerInProgress(duration));
        _startTimer(duration);
      }
    } catch (e) {
      // Handle potential errors, e.g., by emitting a failure state
    }
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) async {
    // This now only handles the start button press
    try {
      var activities = await _apiService.getTomatoActivities(_tomatoId);
      if (!activities.any((a) => a.action == ActivityAction.START.toShortString())) {
        await _apiService.createActivity(
            _userUUID, _tomatoId, ActivityAction.START, ActivityType.TIMER);
        // Refresh activities after adding a new one
        activities = await _apiService.getTomatoActivities(_tomatoId);
      }

      activities.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      DateTime? lastStartTime;
      Duration elapsedDuration = Duration.zero;

      for (final activity in activities) {
        if (activity.action == ActivityAction.START.toShortString() ||
            activity.action == ActivityAction.RESUME.toShortString()) {
          lastStartTime = activity.createdAt;
        } else if (activity.action == ActivityAction.PAUSE.toShortString() &&
            lastStartTime != null) {
          elapsedDuration += activity.createdAt.difference(lastStartTime);
          lastStartTime = null;
        }
      }

      if (lastStartTime != null) {
        elapsedDuration += DateTime.now().difference(lastStartTime);
      }

      final remainingDuration = _tomatoDuration - elapsedDuration.inSeconds;
      final duration = remainingDuration > 0 ? remainingDuration : 0;
      emit(TomatoTimerInProgress(duration));
      _startTimer(duration);
    } catch (e) {
      //
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
      int nextTomatoId;
      if (state is BreakTimerInProgress) {
        nextTomatoId = (state as BreakTimerInProgress).nextTomatoId;
      } else {
        nextTomatoId = (state as BreakTimerPaused).nextTomatoId;
      }
      emit(WaitingNextTomato(nextTomatoId: nextTomatoId));
      add(const NextTransition()); // Automatically trigger the next transition
    } else if (state is WaitingNextTomato) {
      final waitingState = state as WaitingNextTomato;
      _tomatoId = waitingState.nextTomatoId;
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
    if (event.duration > 0) {
      if (state is TomatoTimerInProgress) {
        emit(TomatoTimerInProgress(event.duration));
      } else if (state is BreakTimerInProgress) {
        final breakState = state as BreakTimerInProgress;
        emit(BreakTimerInProgress(event.duration,
            nextTomatoId: breakState.nextTomatoId));
      }
    } else {
      _timer?.cancel();
      add(const NextTransition());
    }
  }
}