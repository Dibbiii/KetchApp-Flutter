import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ketchapp_flutter/models/activity_action.dart';
import 'package:ketchapp_flutter/services/api_service.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final ApiService _apiService;
  final String _userUUID;
  final int _tomatoId;
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
      if (state.duration > 0) {
        add(_TimerTicked(duration: state.duration - 1));
      } else {
        _timer?.cancel();
        add(const NextTransition());
      }
    });
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    _tomatoDuration = event.tomatoDuration;
    _breakDuration = event.breakDuration;
    emit(TomatoTimerInProgress(_tomatoDuration));
    _startTimer(_tomatoDuration);
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) async {
    if (state is TomatoTimerInProgress || state is BreakTimerInProgress) {
      _timer?.cancel();
      try {
        await _apiService.createActivity(
            _userUUID, _tomatoId, ActivityAction.PAUSE);
        if (state is TomatoTimerInProgress) {
          emit(TomatoTimerPaused(state.duration));
        } else if (state is BreakTimerInProgress) {
          emit(BreakTimerPaused(state.duration));
        }
      } catch (e) {
        _startTimer(state.duration);
      }
    }
  }

  void _onResumed(TimerResumed event, Emitter<TimerState> emit) async {
    if (state is TomatoTimerPaused || state is BreakTimerPaused) {
      try {
        await _apiService.createActivity(
            _userUUID, _tomatoId, ActivityAction.RESUME);
        if (state is TomatoTimerPaused) {
          emit(TomatoTimerInProgress(state.duration));
        } else if (state is BreakTimerPaused) {
          emit(BreakTimerInProgress(state.duration));
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

  void _onNextTransition(NextTransition event, Emitter<TimerState> emit) {
    if (state is TomatoTimerInProgress || state is TomatoTimerPaused) {
      emit(BreakTimerInProgress(_breakDuration));
      _startTimer(_breakDuration);
    } else if (state is BreakTimerInProgress || state is BreakTimerPaused) {
      emit(const WaitingNextTomato());
    } else if (state is WaitingNextTomato) {
      emit(TomatoTimerInProgress(_tomatoDuration));
      _startTimer(_tomatoDuration);
    }
  }

  void _onTicked(_TimerTicked event, Emitter<TimerState> emit) {
    if (event.duration > 0) {
      if (state is TomatoTimerInProgress) {
        emit(TomatoTimerInProgress(event.duration));
      } else if (state is BreakTimerInProgress) {
        emit(BreakTimerInProgress(event.duration));
      }
    } else {
      _timer?.cancel();
      add(const NextTransition());
    }
  }
}