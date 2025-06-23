part of 'timer_bloc.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object> get props => [];
}

class TimerStarted extends TimerEvent {
  final int tomatoDuration;
  final int breakDuration;
  const TimerStarted({required this.tomatoDuration, required this.breakDuration});

  @override
  List<Object> get props => [tomatoDuration, breakDuration];
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