part of 'timer_bloc.dart';

abstract class TimerState extends Equatable {
  final int duration;
  final bool isWhiteNoiseEnabled;

  const TimerState(this.duration, {this.isWhiteNoiseEnabled = false});

  @override
  List<Object> get props => [duration, isWhiteNoiseEnabled];

  TimerState copyWith({
    int? duration,
    bool? isWhiteNoiseEnabled,
  });
}

class WaitingFirstTomato extends TimerState {
  const WaitingFirstTomato({bool isWhiteNoiseEnabled = false})
      : super(0, isWhiteNoiseEnabled: isWhiteNoiseEnabled);

  @override
  WaitingFirstTomato copyWith({
    int? duration,
    bool? isWhiteNoiseEnabled,
  }) {
    return WaitingFirstTomato(
      isWhiteNoiseEnabled: isWhiteNoiseEnabled ?? this.isWhiteNoiseEnabled,
    );
  }
}

class TomatoTimerReady extends TimerState {
  const TomatoTimerReady({bool isWhiteNoiseEnabled = false})
      : super(0, isWhiteNoiseEnabled: isWhiteNoiseEnabled);

  @override
  TomatoTimerReady copyWith({
    int? duration,
    bool? isWhiteNoiseEnabled,
  }) {
    return TomatoTimerReady(
      isWhiteNoiseEnabled: isWhiteNoiseEnabled ?? this.isWhiteNoiseEnabled,
    );
  }
}

class TomatoTimerInProgress extends TimerState {
  const TomatoTimerInProgress(int duration, {bool isWhiteNoiseEnabled = false})
      : super(duration, isWhiteNoiseEnabled: isWhiteNoiseEnabled);

  @override
  TomatoTimerInProgress copyWith({
    int? duration,
    bool? isWhiteNoiseEnabled,
  }) {
    return TomatoTimerInProgress(
      duration ?? this.duration,
      isWhiteNoiseEnabled: isWhiteNoiseEnabled ?? this.isWhiteNoiseEnabled,
    );
  }
}

class TomatoTimerPaused extends TimerState {
  const TomatoTimerPaused(int duration, {bool isWhiteNoiseEnabled = false})
      : super(duration, isWhiteNoiseEnabled: isWhiteNoiseEnabled);

  @override
  TomatoTimerPaused copyWith({
    int? duration,
    bool? isWhiteNoiseEnabled,
  }) {
    return TomatoTimerPaused(
      duration ?? this.duration,
      isWhiteNoiseEnabled: isWhiteNoiseEnabled ?? this.isWhiteNoiseEnabled,
    );
  }
}

class BreakTimerInProgress extends TimerState {
  final int nextTomatoId;
  const BreakTimerInProgress(int duration, {required this.nextTomatoId, bool isWhiteNoiseEnabled = false})
      : super(duration, isWhiteNoiseEnabled: isWhiteNoiseEnabled);

  @override
  List<Object> get props => [duration, nextTomatoId, isWhiteNoiseEnabled];

  @override
  BreakTimerInProgress copyWith({
    int? duration,
    bool? isWhiteNoiseEnabled,
    int? nextTomatoId,
  }) {
    return BreakTimerInProgress(
      duration ?? this.duration,
      nextTomatoId: nextTomatoId ?? this.nextTomatoId,
      isWhiteNoiseEnabled: isWhiteNoiseEnabled ?? this.isWhiteNoiseEnabled,
    );
  }
}

class BreakTimerPaused extends TimerState {
  final int nextTomatoId;
  const BreakTimerPaused(int duration, {required this.nextTomatoId, bool isWhiteNoiseEnabled = false})
      : super(duration, isWhiteNoiseEnabled: isWhiteNoiseEnabled);

  @override
  List<Object> get props => [duration, nextTomatoId, isWhiteNoiseEnabled];

  @override
  BreakTimerPaused copyWith({
    int? duration,
    bool? isWhiteNoiseEnabled,
    int? nextTomatoId,
  }) {
    return BreakTimerPaused(
      duration ?? this.duration,
      nextTomatoId: nextTomatoId ?? this.nextTomatoId,
      isWhiteNoiseEnabled: isWhiteNoiseEnabled ?? this.isWhiteNoiseEnabled,
    );
  }
}

class WaitingNextTomato extends TimerState {
  final int nextTomatoId;
  const WaitingNextTomato({required this.nextTomatoId, bool isWhiteNoiseEnabled = false})
      : super(0, isWhiteNoiseEnabled: isWhiteNoiseEnabled);

  @override
  List<Object> get props => [nextTomatoId, isWhiteNoiseEnabled];

  @override
  WaitingNextTomato copyWith({
    int? duration,
    bool? isWhiteNoiseEnabled,
    int? nextTomatoId,
  }) {
    return WaitingNextTomato(
      nextTomatoId: nextTomatoId ?? this.nextTomatoId,
      isWhiteNoiseEnabled: isWhiteNoiseEnabled ?? this.isWhiteNoiseEnabled,
    );
  }
}

class WaitingForScheduledTime extends TimerState {
  final int nextTomatoId;
  final DateTime scheduledStartTime;
  final Duration remainingWaitTime;

  const WaitingForScheduledTime({
    required this.nextTomatoId,
    required this.scheduledStartTime,
    required this.remainingWaitTime,
    bool isWhiteNoiseEnabled = false,
  }) : super(0, isWhiteNoiseEnabled: isWhiteNoiseEnabled);

  @override
  List<Object> get props => [nextTomatoId, scheduledStartTime, remainingWaitTime, isWhiteNoiseEnabled];

  @override
  WaitingForScheduledTime copyWith({
    int? duration,
    bool? isWhiteNoiseEnabled,
    int? nextTomatoId,
    DateTime? scheduledStartTime,
    Duration? remainingWaitTime,
  }) {
    return WaitingForScheduledTime(
      nextTomatoId: nextTomatoId ?? this.nextTomatoId,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      remainingWaitTime: remainingWaitTime ?? this.remainingWaitTime,
      isWhiteNoiseEnabled: isWhiteNoiseEnabled ?? this.isWhiteNoiseEnabled,
    );
  }
}

class TomatoScheduled extends TimerState {
  final int remainingTime;

  const TomatoScheduled(this.remainingTime, {bool isWhiteNoiseEnabled = false})
      : super(remainingTime, isWhiteNoiseEnabled: isWhiteNoiseEnabled);

  @override
  List<Object> get props => [remainingTime, isWhiteNoiseEnabled];

  @override
  TomatoScheduled copyWith({
    int? duration,
    bool? isWhiteNoiseEnabled,
    int? remainingTime,
  }) {
    return TomatoScheduled(
      remainingTime ?? this.remainingTime,
      isWhiteNoiseEnabled: isWhiteNoiseEnabled ?? this.isWhiteNoiseEnabled,
    );
  }
}

class TimerError extends TimerState {
  final String message;
  const TimerError({required this.message, bool isWhiteNoiseEnabled = false})
      : super(0, isWhiteNoiseEnabled: isWhiteNoiseEnabled);

  @override
  List<Object> get props => [message, isWhiteNoiseEnabled];

  @override
  TimerError copyWith({
    int? duration,
    bool? isWhiteNoiseEnabled,
    String? message,
  }) {
    return TimerError(
      message: message ?? this.message,
      isWhiteNoiseEnabled: isWhiteNoiseEnabled ?? this.isWhiteNoiseEnabled,
    );
  }
}

class SessionComplete extends TimerState {
  const SessionComplete({bool isWhiteNoiseEnabled = false})
      : super(0, isWhiteNoiseEnabled: isWhiteNoiseEnabled);

  @override
  SessionComplete copyWith({
    int? duration,
    bool? isWhiteNoiseEnabled,
  }) {
    return SessionComplete(
      isWhiteNoiseEnabled: isWhiteNoiseEnabled ?? this.isWhiteNoiseEnabled,
    );
  }
}

class TomatoSwitched extends TimerState {
  final int newTomatoId;

  const TomatoSwitched({required this.newTomatoId, bool isWhiteNoiseEnabled = false})
      : super(0, isWhiteNoiseEnabled: isWhiteNoiseEnabled);

  @override
  List<Object> get props => [newTomatoId, isWhiteNoiseEnabled];

  @override
  TomatoSwitched copyWith({
    int? duration,
    bool? isWhiteNoiseEnabled,
    int? newTomatoId,
  }) {
    return TomatoSwitched(
      newTomatoId: newTomatoId ?? this.newTomatoId,
      isWhiteNoiseEnabled: isWhiteNoiseEnabled ?? this.isWhiteNoiseEnabled,
    );
  }
}

class NavigatingToSummary extends TimerState {
  final List<int> completedTomatoIds;

  const NavigatingToSummary({required this.completedTomatoIds, bool isWhiteNoiseEnabled = false})
      : super(0, isWhiteNoiseEnabled: isWhiteNoiseEnabled);

  @override
  List<Object> get props => [completedTomatoIds, isWhiteNoiseEnabled];

  @override
  NavigatingToSummary copyWith({
    int? duration,
    bool? isWhiteNoiseEnabled,
    List<int>? completedTomatoIds,
  }) {
    return NavigatingToSummary(
      completedTomatoIds: completedTomatoIds ?? this.completedTomatoIds,
      isWhiteNoiseEnabled: isWhiteNoiseEnabled ?? this.isWhiteNoiseEnabled,
    );
  }
}
