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

class TomatoTimerReady extends TimerState {
  const TomatoTimerReady() : super(0);
}

class TomatoTimerInProgress extends TimerState {
  const TomatoTimerInProgress(int duration) : super(duration);
}

class TomatoTimerPaused extends TimerState {
  const TomatoTimerPaused(int duration) : super(duration);
}

class BreakTimerInProgress extends TimerState {
  final int nextTomatoId;
  const BreakTimerInProgress(int duration, {required this.nextTomatoId}) : super(duration);

  @override
  List<Object> get props => [duration, nextTomatoId];
}

class BreakTimerPaused extends TimerState {
  final int nextTomatoId;
  const BreakTimerPaused(int duration, {required this.nextTomatoId}) : super(duration);

  @override
  List<Object> get props => [duration, nextTomatoId];
}

class WaitingNextTomato extends TimerState {
  final int nextTomatoId;
  const WaitingNextTomato({required this.nextTomatoId}) : super(0);

  @override
  List<Object> get props => [nextTomatoId];
}

class TimerError extends TimerState {
  final String message;
  const TimerError({required this.message}) : super(0);

  @override
  List<Object> get props => [message];
}

class SessionComplete extends TimerState {
  const SessionComplete() : super(0);
}

class TomatoSwitched extends TimerState {
  final int newTomatoId;

  const TomatoSwitched({required this.newTomatoId}) : super(0);

  @override
  List<Object> get props => [newTomatoId];
}

class NavigatingToSummary extends TimerState {
  final List<int> completedTomatoIds;

  const NavigatingToSummary({required this.completedTomatoIds}) : super(0);

  @override
  List<Object> get props => [completedTomatoIds];
}

