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

  TimerBloc(
      {required ApiService apiService,
      required String userUUID,
      required int tomatoId})
      : _apiService = apiService,
        _userUUID = userUUID,
        _tomatoId = tomatoId,
        super(const TimerInitial(0)) {
    on<TimerStarted>(_onStarted);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerFinished>(_onFinished);
    on<_TimerTicked>(_onTicked);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.duration > 0) {
        add(_TimerTicked(duration: state.duration - 1));
      } else {
        _timer?.cancel();
      }
    });
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    emit(TimerRunInProgress(event.duration));
    _startTimer();
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) async {
    if (state is TimerRunInProgress) {
      _timer?.cancel();
      try {
        await _apiService.createActivity(_userUUID, _tomatoId, ActivityAction.PAUSE);
        emit(TimerRunPause(state.duration));
      } catch (e) {
        _startTimer();
      }
    }
  }

  void _onResumed(TimerResumed event, Emitter<TimerState> emit) async {
    if (state is TimerRunPause) {
      try {
        await _apiService.createActivity(_userUUID, _tomatoId, ActivityAction.RESUME);
        emit(TimerRunInProgress(state.duration));
        _startTimer();
      } catch (e) {
        //
      }
    }
  }

  void _onFinished(TimerFinished event, Emitter<TimerState> emit) {
    _timer?.cancel();
    emit(const TimerRunComplete());
  }

  void _onTicked(_TimerTicked event, Emitter<TimerState> emit) {
    emit(event.duration > 0
        ? TimerRunInProgress(event.duration)
        : const TimerRunComplete());
    if (event.duration <= 0) {
      _timer?.cancel();
    }
  }
}