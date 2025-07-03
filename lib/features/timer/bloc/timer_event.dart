part of 'timer_bloc.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object> get props => [];
}

class TimerLoaded extends TimerEvent {
  final int tomatoDuration;
  final int breakDuration;

  const TimerLoaded({required this.tomatoDuration, required this.breakDuration});

  @override
  List<Object> get props => [tomatoDuration, breakDuration];
}

class TimerStarted extends TimerEvent {
  const TimerStarted();
}

class TimerPaused extends TimerEvent {
  const TimerPaused();
}

class TimerResumed extends TimerEvent {
  const TimerResumed();
}

class NextTransition extends TimerEvent {
  const NextTransition();
}

class TimerFinished extends TimerEvent {
  const TimerFinished();
}

class _TimerTicked extends TimerEvent {
  final int duration;
  const _TimerTicked({required this.duration});

  @override
  List<Object> get props => [duration];
}

class TimerSkipToEnd extends TimerEvent {
  const TimerSkipToEnd();
}

class NavigateToSummary extends TimerEvent {
  final List<int> completedTomatoIds;

  const NavigateToSummary({required this.completedTomatoIds});

  @override
  List<Object> get props => [completedTomatoIds];
}

class CheckScheduledTime extends TimerEvent {
  const CheckScheduledTime();
}

class _ScheduleTimerTicked extends TimerEvent {
  final Duration remainingTime;
  const _ScheduleTimerTicked({required this.remainingTime});

  @override
  List<Object> get props => [remainingTime];
}

class ToggleWhiteNoise extends TimerEvent {
  final bool isEnabled;

  const ToggleWhiteNoise({required this.isEnabled});

  @override
  List<Object> get props => [isEnabled];
}
