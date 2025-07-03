import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ketchapp_flutter/models/activity_action.dart';
import 'package:ketchapp_flutter/models/activity_type.dart';
import 'package:ketchapp_flutter/services/api_service.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  static const int _skipToEndDuration = 10;
  static const Duration _timerInterval = Duration(seconds: 1);
  static const Duration _transitionDelay = Duration(milliseconds: 100);

  final ApiService _apiService;
  final String _userUUID;

  int _tomatoId;
  Timer? _timer;
  int _tomatoDuration = 0;
  int _breakDuration = 0;

  // Tracciamento dei pomodori completati nella sessione
  final List<int> _completedTomatoIds = [];

  // Cache for activity strings to avoid repeated conversions
  static final Map<ActivityAction, String> _actionStringCache = {
    for (final action in ActivityAction.values) action: action.toShortString(),
  };

  static final Map<ActivityType, String> _typeStringCache = {
    for (final type in ActivityType.values) type: type.toShortString(),
  };

  TimerBloc({
    required ApiService apiService,
    required String userUUID,
    required int tomatoId,
  })  : _apiService = apiService,
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
    on<NavigateToSummary>(_onNavigateToSummary);
    on<CheckScheduledTime>(_onCheckScheduledTime);
    on<_ScheduleTimerTicked>(_onScheduleTimerTicked);
    on<ToggleWhiteNoise>(_onToggleWhiteNoise);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  /// Starts a countdown timer with the specified duration
  void _startTimer(int duration) {
    _timer?.cancel();
    _timer = Timer.periodic(_timerInterval, (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }

      final currentDuration = state.duration;
      if (currentDuration > 0) {
        add(_TimerTicked(duration: currentDuration - 1));
      } else {
        timer.cancel();
        add(const NextTransition());
      }
    });
  }

  /// Calculates elapsed duration from a list of activities with improved performance
  Duration _calculateElapsedDuration(
    List<dynamic> activities,
    ActivityType type,
  ) {
    final typeString = _typeStringCache[type]!;
    final startString = _actionStringCache[ActivityAction.START]!;
    final resumeString = _actionStringCache[ActivityAction.RESUME]!;
    final pauseString = _actionStringCache[ActivityAction.PAUSE]!;

    DateTime? lastStartTime;
    var totalElapsed = Duration.zero;

    // Process only relevant activities
    final relevantActivities = activities
        .where((activity) => activity.type == typeString)
        .toList();

    for (final activity in relevantActivities) {
      final action = activity.action as String;

      if (action == startString || action == resumeString) {
        lastStartTime = activity.createdAt as DateTime;
      } else if (action == pauseString && lastStartTime != null) {
        totalElapsed += (activity.createdAt as DateTime).difference(lastStartTime);
        lastStartTime = null;
      }
    }

    // Add current running time if still active
    if (lastStartTime != null) {
      totalElapsed += DateTime.now().toUtc().difference(lastStartTime);
    }

    return totalElapsed;
  }

  /// Checks if an action is START or RESUME with cached strings
  bool _isStartOrResumeAction(String action) {
    return action == _actionStringCache[ActivityAction.START] ||
           action == _actionStringCache[ActivityAction.RESUME];
  }

  /// Checks if there's an activity with the specified action and type
  bool _hasActivity(
    List<dynamic> activities,
    ActivityAction action,
    ActivityType type,
  ) {
    final actionString = _actionStringCache[action]!;
    final typeString = _typeStringCache[type]!;

    return activities.any((a) =>
        a.action == actionString && a.type == typeString);
  }

  /// Gets the remaining duration from total duration and elapsed time
  int _getRemainingDuration(int totalDuration, Duration elapsedDuration) {
    final remaining = totalDuration - elapsedDuration.inSeconds;
    return remaining.clamp(0, totalDuration);
  }

  /// Sorts activities by creation time - extracted for reuse
  void _sortActivitiesByTime(List<dynamic> activities) {
    activities.sort((a, b) =>
        (a.createdAt as DateTime).compareTo(b.createdAt as DateTime));
  }

  Future<void> _onLoaded(TimerLoaded event, Emitter<TimerState> emit) async {
    _tomatoDuration = event.tomatoDuration;
    _breakDuration = event.breakDuration;

    try {
      final activities = await _apiService.getTomatoActivities(_tomatoId);

      // Check if timer has ended
      if (_hasActivity(activities, ActivityAction.END, ActivityType.TIMER)) {
        await _handleTimerEndedState(activities, emit);
        return;
      }

      // Handle empty activities
      if (activities.isEmpty) {
        emit(const TomatoTimerReady());
        return;
      }

      await _handleActiveTimerState(activities, emit);
    } catch (e) {
      emit(const TimerError(message: 'Failed to load timer'));
    }
  }

  Future<void> _handleTimerEndedState(
    List<dynamic> activities,
    Emitter<TimerState> emit,
  ) async {
    try {
      final tomato = await _apiService.getTomatoById(_tomatoId);

      if (tomato.nextTomatoId == null) {
        emit(SessionComplete(isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
        return;
      }

      final hasBreakEnd = _hasActivity(activities, ActivityAction.END, ActivityType.BREAK);

      if (hasBreakEnd) {
        emit(WaitingNextTomato(nextTomatoId: tomato.nextTomatoId!, isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
      } else {
        await _handleOngoingBreak(activities, tomato.nextTomatoId!, emit);
      }
    } catch (e) {
      emit(TimerError(message: 'Failed to handle timer end', isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
    }
  }

  Future<void> _handleOngoingBreak(
    List<dynamic> activities,
    int nextTomatoId,
    Emitter<TimerState> emit,
  ) async {
    _sortActivitiesByTime(activities);

    final elapsedBreakDuration = _calculateElapsedDuration(activities, ActivityType.BREAK);
    final remainingDuration = _getRemainingDuration(_breakDuration, elapsedBreakDuration);

    if (activities.isEmpty) return;

    final lastActivity = activities.last;
    final isBreakPaused = lastActivity.type == _typeStringCache[ActivityType.BREAK] &&
        lastActivity.action == _actionStringCache[ActivityAction.PAUSE];

    if (isBreakPaused) {
      emit(BreakTimerPaused(remainingDuration, nextTomatoId: nextTomatoId, isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
    } else {
      emit(BreakTimerInProgress(remainingDuration, nextTomatoId: nextTomatoId, isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
      _startTimer(remainingDuration);
    }
  }

  Future<void> _handleActiveTimerState(
    List<dynamic> activities,
    Emitter<TimerState> emit,
  ) async {
    _sortActivitiesByTime(activities);

    final elapsedDuration = _calculateElapsedDuration(activities, ActivityType.TIMER);
    final remainingDuration = _getRemainingDuration(_tomatoDuration, elapsedDuration);
    final lastActivity = activities.last;

    if (lastActivity.type == _typeStringCache[ActivityType.TIMER]) {
      if (lastActivity.action == _actionStringCache[ActivityAction.PAUSE]) {
        emit(TomatoTimerPaused(remainingDuration, isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
      } else if (_isStartOrResumeAction(lastActivity.action)) {
        if (remainingDuration > 0) {
          emit(TomatoTimerInProgress(remainingDuration, isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
          _startTimer(remainingDuration);
        } else {
          emit(TomatoTimerReady(isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
        }
      } else {
        emit(TomatoTimerReady(isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
      }
    } else {
      emit(TomatoTimerReady(isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
    }
  }

  Future<void> _onStarted(TimerStarted event, Emitter<TimerState> emit) async {
    try {
      var activities = await _apiService.getTomatoActivities(_tomatoId);

      // Create START activity if it doesn't exist
      if (!_hasActivity(activities, ActivityAction.START, ActivityType.TIMER)) {
        await _apiService.createActivity(
            _userUUID, _tomatoId, ActivityAction.START, ActivityType.TIMER);
        activities = await _apiService.getTomatoActivities(_tomatoId);
      }

      _sortActivitiesByTime(activities);

      final elapsedDuration = _calculateElapsedDuration(activities, ActivityType.TIMER);
      final remainingDuration = _getRemainingDuration(_tomatoDuration, elapsedDuration);

      emit(TomatoTimerInProgress(remainingDuration, isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
      _startTimer(remainingDuration);
    } catch (e) {
      emit(TimerError(message: 'Failed to start timer', isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
    }
  }

  Future<void> _onPaused(TimerPaused event, Emitter<TimerState> emit) async {
    final currentState = state;
    if (currentState is! TomatoTimerInProgress && currentState is! BreakTimerInProgress) {
      return;
    }

    _timer?.cancel();

    try {
      final type = currentState is TomatoTimerInProgress
          ? ActivityType.TIMER
          : ActivityType.BREAK;

      await _apiService.createActivity(_userUUID, _tomatoId, ActivityAction.PAUSE, type);

      switch (currentState) {
        case TomatoTimerInProgress():
          emit(TomatoTimerPaused(currentState.duration, isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
        case BreakTimerInProgress():
          emit(BreakTimerPaused(currentState.duration, nextTomatoId: currentState.nextTomatoId, isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
      }
    } catch (e) {
      // Restart timer on API failure to maintain user experience
      _startTimer(currentState.duration);
    }
  }

  Future<void> _onResumed(TimerResumed event, Emitter<TimerState> emit) async {
    final currentState = state;
    if (currentState is! TomatoTimerPaused && currentState is! BreakTimerPaused) {
      return;
    }

    try {
      final type = currentState is TomatoTimerPaused
          ? ActivityType.TIMER
          : ActivityType.BREAK;

      await _apiService.createActivity(_userUUID, _tomatoId, ActivityAction.RESUME, type);

      switch (currentState) {
        case TomatoTimerPaused():
          emit(TomatoTimerInProgress(currentState.duration, isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
        case BreakTimerPaused():
          emit(BreakTimerInProgress(currentState.duration, nextTomatoId: currentState.nextTomatoId, isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
      }

      _startTimer(currentState.duration);
    } catch (e) {
      emit(TimerError(message: 'Failed to resume timer', isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
    }
  }

  void _onFinished(TimerFinished event, Emitter<TimerState> emit) {
    _timer?.cancel();
    emit(SessionComplete(isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
  }

  Future<void> _onNextTransition(NextTransition event, Emitter<TimerState> emit) async {
    final currentState = state;

    try {
      switch (currentState) {
        case TomatoTimerInProgress() || TomatoTimerPaused():
          await _handleTomatoToBreakTransition(emit);
        case BreakTimerInProgress() || BreakTimerPaused():
          await _handleBreakToTomatoTransition(emit);
        case WaitingNextTomato():
          await _handleWaitingToTomatoTransition(emit);
        default:
          // No valid transition from current state
          break;
      }
    } catch (e) {
      emit(TimerError(message: 'Failed to transition', isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
    }
  }

  Future<void> _handleTomatoToBreakTransition(Emitter<TimerState> emit) async {
    await _apiService.createActivity(_userUUID, _tomatoId, ActivityAction.END, ActivityType.TIMER);

    // Aggiungi il pomodoro corrente alla lista dei completati
    if (!_completedTomatoIds.contains(_tomatoId)) {
      _completedTomatoIds.add(_tomatoId);
    }

    final tomato = await _apiService.getTomatoById(_tomatoId);

    if (tomato.nextTomatoId != null) {
      await _apiService.createActivity(_userUUID, _tomatoId, ActivityAction.START, ActivityType.BREAK);
      emit(BreakTimerInProgress(_breakDuration, nextTomatoId: tomato.nextTomatoId!, isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
      _startTimer(_breakDuration);
    } else {
      // Fine della sessione - naviga al riepilogo
      emit(NavigatingToSummary(completedTomatoIds: List.unmodifiable(_completedTomatoIds), isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
    }
  }

  Future<void> _handleBreakToTomatoTransition(Emitter<TimerState> emit) async {
    await _apiService.createActivity(_userUUID, _tomatoId, ActivityAction.END, ActivityType.BREAK);

    final currentState = state;
    switch (currentState) {
      case BreakTimerInProgress():
        await _switchToNextTomato(currentState.nextTomatoId, emit, autoStart: true);
      case BreakTimerPaused():
        emit(WaitingNextTomato(nextTomatoId: currentState.nextTomatoId, isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
        add(const NextTransition());
      default:
        break;
    }
  }

  Future<void> _handleWaitingToTomatoTransition(Emitter<TimerState> emit) async {
    final waitingState = state as WaitingNextTomato;
    await _switchToNextTomato(waitingState.nextTomatoId, emit);
  }

  Future<void> _switchToNextTomato(
    int nextTomatoId,
    Emitter<TimerState> emit, {
    bool autoStart = false,
  }) async {
    _tomatoId = nextTomatoId;

    // Update tomato durations
    final newTomato = await _apiService.getTomatoById(_tomatoId);
    _tomatoDuration = newTomato.endAt.difference(newTomato.startAt).inSeconds;
    _breakDuration = newTomato.pauseEnd?.difference(newTomato.endAt).inSeconds ?? 0;

    // 🕐 NUOVO: Controlla se il pomodoro deve iniziare ora o è programmato per dopo
    final scheduledStartTime = newTomato.startAt;
    final currentTime = DateTime.now().toUtc();

    print('🕐 Controllo orario pomodoro $nextTomatoId:');
    print('   Programmato per: $scheduledStartTime');
    print('   Ora corrente: $currentTime');

    if (scheduledStartTime.isAfter(currentTime)) {
      // Il pomodoro è programmato per il futuro - dobbiamo aspettare
      final waitTime = scheduledStartTime.difference(currentTime);
      print('⏰ Il prossimo pomodoro inizierà tra ${_formatDuration(waitTime)}');

      emit(WaitingForScheduledTime(
        nextTomatoId: nextTomatoId,
        scheduledStartTime: scheduledStartTime,
        remainingWaitTime: waitTime,
        isWhiteNoiseEnabled: state.isWhiteNoiseEnabled,
      ));

      // Avvia un timer per aggiornare il countdown
      _startScheduleTimer(waitTime, emit);
      return;
    }

    // Il pomodoro può iniziare ora
    print('✅ Il pomodoro può iniziare ora');

    if (autoStart) {
      // Auto-switch with notification
      emit(TomatoSwitched(newTomatoId: _tomatoId, isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
      await Future.delayed(_transitionDelay);

      await _apiService.createActivity(_userUUID, _tomatoId, ActivityAction.START, ActivityType.TIMER);
      emit(TomatoTimerInProgress(_tomatoDuration, isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
      _startTimer(_tomatoDuration);
    } else {
      // Manual switch - mostra che è pronto per iniziare
      emit(TomatoTimerReady(isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
    }
  }

  /// Avvia un timer per il countdown dell'attesa
  void _startScheduleTimer(Duration waitTime, Emitter<TimerState> emit) {
    _timer?.cancel();
    _timer = Timer.periodic(_timerInterval, (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }

      final currentState = state;
      if (currentState is WaitingForScheduledTime) {
        final newWaitTime = currentState.scheduledStartTime.difference(DateTime.now().toUtc());

        if (newWaitTime.inSeconds <= 0) {
          // È ora di iniziare il pomodoro!
          timer.cancel();
          print('🎯 È ora di iniziare il pomodoro ${currentState.nextTomatoId}!');
          emit(TomatoTimerReady(isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
        } else {
          // Aggiorna il countdown
          emit(WaitingForScheduledTime(
            nextTomatoId: currentState.nextTomatoId,
            scheduledStartTime: currentState.scheduledStartTime,
            remainingWaitTime: newWaitTime,
            isWhiteNoiseEnabled: state.isWhiteNoiseEnabled,
          ));
        }
      } else {
        timer.cancel();
      }
    });
  }

  /// Helper per formattare la durata in modo leggibile
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  void _onTicked(_TimerTicked event, Emitter<TimerState> emit) {
    final duration = event.duration;

    if (duration > 0) {
      final currentState = state;
      switch (currentState) {
        case TomatoTimerInProgress():
          emit(TomatoTimerInProgress(duration, isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
        case BreakTimerInProgress():
          emit(BreakTimerInProgress(duration, nextTomatoId: currentState.nextTomatoId, isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
        default:
          break;
      }
    } else {
      _timer?.cancel();
      add(const NextTransition());
    }
  }

  Future<void> _onSkipToEnd(TimerSkipToEnd event, Emitter<TimerState> emit) async {
    _timer?.cancel();

    final currentState = state;
    switch (currentState) {
      case TomatoTimerInProgress():
        emit(TomatoTimerInProgress(_skipToEndDuration, isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
        _startTimer(_skipToEndDuration);
      case BreakTimerInProgress():
        emit(BreakTimerInProgress(_skipToEndDuration, nextTomatoId: currentState.nextTomatoId, isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
        _startTimer(_skipToEndDuration);
      case TomatoTimerPaused():
        emit(TomatoTimerInProgress(_skipToEndDuration, isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
        _startTimer(_skipToEndDuration);
      case BreakTimerPaused():
        emit(BreakTimerInProgress(_skipToEndDuration, nextTomatoId: currentState.nextTomatoId, isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
        _startTimer(_skipToEndDuration);
      default:
        break;
    }
  }

  Future<void> _onNavigateToSummary(NavigateToSummary event, Emitter<TimerState> emit) async {
    _timer?.cancel();

    // Logica per il tracciamento dei pomodori completati
    try {
      // Aggiungi l'ID del pomodoro corrente se non è già tracciato
      if (!_completedTomatoIds.contains(_tomatoId)) {
        _completedTomatoIds.add(_tomatoId);
      }

      // Invia gli ID dei pomodori completati alla schermata di riepilogo
      emit(NavigatingToSummary(completedTomatoIds: List.unmodifiable(_completedTomatoIds), isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
    } catch (e) {
      emit(TimerError(message: 'Failed to navigate to summary', isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
    }
  }

  Future<void> _onCheckScheduledTime(CheckScheduledTime event, Emitter<TimerState> emit) async {
    try {
      final tomato = await _apiService.getTomatoById(_tomatoId);

      // Controlla se il pomodoro è programmato per ora
      final scheduledStartTime = tomato.startAt;
      final currentTime = DateTime.now().toUtc();

      if (scheduledStartTime.isAfter(currentTime)) {
        // Il pomodoro è programmato per il futuro
        final waitTime = scheduledStartTime.difference(currentTime);
        emit(WaitingForScheduledTime(
          nextTomatoId: _tomatoId,
          scheduledStartTime: scheduledStartTime,
          remainingWaitTime: waitTime,
          isWhiteNoiseEnabled: state.isWhiteNoiseEnabled,
        ));
        _startScheduleTimer(waitTime, emit);
      } else {
        // Il pomodoro può iniziare ora
        emit(TomatoTimerReady(isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
      }
    } catch (e) {
      emit(TimerError(message: 'Failed to check scheduled time', isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
    }
  }

  void _onScheduleTimerTicked(_ScheduleTimerTicked event, Emitter<TimerState> emit) {
    final currentState = state;
    if (currentState is WaitingForScheduledTime) {
      if (event.remainingTime.inSeconds > 0) {
        emit(WaitingForScheduledTime(
          nextTomatoId: currentState.nextTomatoId,
          scheduledStartTime: currentState.scheduledStartTime,
          remainingWaitTime: event.remainingTime,
          isWhiteNoiseEnabled: state.isWhiteNoiseEnabled,
        ));
      } else {
        emit(TomatoTimerReady(isWhiteNoiseEnabled: state.isWhiteNoiseEnabled));
      }
    }
  }

  void _onToggleWhiteNoise(ToggleWhiteNoise event, Emitter<TimerState> emit) {
    final currentState = state;
    if (currentState is WaitingFirstTomato) {
      emit(currentState.copyWith(isWhiteNoiseEnabled: event.isEnabled));
    } else if (currentState is TomatoTimerReady) {
      emit(currentState.copyWith(isWhiteNoiseEnabled: event.isEnabled));
    } else if (currentState is TomatoTimerInProgress) {
      emit(currentState.copyWith(isWhiteNoiseEnabled: event.isEnabled));
    } else if (currentState is TomatoTimerPaused) {
      emit(currentState.copyWith(isWhiteNoiseEnabled: event.isEnabled));
    } else if (currentState is BreakTimerInProgress) {
      emit(currentState.copyWith(isWhiteNoiseEnabled: event.isEnabled));
    } else if (currentState is BreakTimerPaused) {
      emit(currentState.copyWith(isWhiteNoiseEnabled: event.isEnabled));
    } else if (currentState is WaitingNextTomato) {
      emit(currentState.copyWith(isWhiteNoiseEnabled: event.isEnabled));
    } else if (currentState is WaitingForScheduledTime) {
      emit(currentState.copyWith(isWhiteNoiseEnabled: event.isEnabled));
    } else if (currentState is TomatoScheduled) {
      emit(currentState.copyWith(isWhiteNoiseEnabled: event.isEnabled));
    } else if (currentState is TimerError) {
      emit(currentState.copyWith(isWhiteNoiseEnabled: event.isEnabled));
    } else if (currentState is SessionComplete) {
      emit(currentState.copyWith(isWhiteNoiseEnabled: event.isEnabled));
    } else if (currentState is TomatoSwitched) {
      emit(currentState.copyWith(isWhiteNoiseEnabled: event.isEnabled));
    } else if (currentState is NavigatingToSummary) {
      emit(currentState.copyWith(isWhiteNoiseEnabled: event.isEnabled));
    }
  }
}
