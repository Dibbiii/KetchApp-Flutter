part of 'timer_bloc.dart';

abstract class TimerState extends Equatable {
  final int duration;
  const TimerState(this.duration);

  @override
  List<Object> get props => [duration];
}

class WaitingFirstTomato extends TimerState {
  const WaitingFirstTomato() : super(0);
}

class TomatoTimerInProgress extends TimerState {
  const TomatoTimerInProgress(super.duration);
}

class TomatoTimerPaused extends TimerState {
  const TomatoTimerPaused(super.duration);
}

class BreakTimerInProgress extends TimerState {
  const BreakTimerInProgress(super.duration);
}

class BreakTimerPaused extends TimerState {
  const BreakTimerPaused(super.duration);
}

class WaitingNextTomato extends TimerState {
  const WaitingNextTomato() : super(0);
}

class SessionComplete extends TimerState {
  const SessionComplete() : super(0);
}
