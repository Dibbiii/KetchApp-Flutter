part of 'statistics_bloc.dart';

@immutable
abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

class StatisticsLoadRequested extends StatisticsEvent {
  final double currentTotalStudyHours; // From SummaryState

  const StatisticsLoadRequested({required this.currentTotalStudyHours});

  @override
  List<Object?> get props => [currentTotalStudyHours];
}

class StatisticsPreviousWeekRequested extends StatisticsEvent {}

class StatisticsNextWeekRequested extends StatisticsEvent {}

class StatisticsTodayRequested extends StatisticsEvent {}

class StatisticsDateSelectedFromHistogram extends StatisticsEvent {
  final DateTime selectedDate;

  const StatisticsDateSelectedFromHistogram(this.selectedDate);

  @override
  List<Object?> get props => [selectedDate];
}

// Event to notify the BLoC about updates from SummaryState
class StatisticsTotalStudyHoursUpdated extends StatisticsEvent {
  final double newTotalStudyHours;

  const StatisticsTotalStudyHoursUpdated(this.newTotalStudyHours);

  @override
  List<Object?> get props => [newTotalStudyHours];
}

