import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

class StatisticsLoadRequested extends StatisticsEvent {
  const StatisticsLoadRequested();
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

class StatisticsTotalStudyHoursUpdated extends StatisticsEvent {
  final double newTotalStudyHours;

  const StatisticsTotalStudyHoursUpdated(this.newTotalStudyHours);

  @override
  List<Object?> get props => [newTotalStudyHours];
}
