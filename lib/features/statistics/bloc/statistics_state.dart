part of 'statistics_bloc.dart';

enum StatisticsStatus { initial, loading, loaded, error }

enum ActivityDetailType { screenTime, notificationsReceived, timesOpened }

class StatisticsState extends Equatable {
  final StatisticsStatus status;
  final DateTime displayedCalendarDate;
  final List<double> weeklyStudyData;
  final double recordStudyHours;
  final DateTime bestStudyDay;
  final String? errorMessage;
  final ActivityDetailType selectedActivityDetailType;
  final List<dynamic> subjectStats;
  final List<dynamic> weeklyDatesData;

  const StatisticsState({
    this.status = StatisticsStatus.initial,
    required this.displayedCalendarDate,
    this.weeklyStudyData = const [],
    this.recordStudyHours = 0.0,
    required this.bestStudyDay,
    this.errorMessage,
    // Initialize with a default value, e.g., screenTime
    this.selectedActivityDetailType = ActivityDetailType.screenTime,
    this.subjectStats = const [],
    this.weeklyDatesData = const [],
  });

  factory StatisticsState.initial() {
    final now = DateTime.now();
    return StatisticsState(
      displayedCalendarDate: now,
      bestStudyDay: now,
      selectedActivityDetailType: ActivityDetailType.screenTime,
    );
  }

  StatisticsState copyWith({
    StatisticsStatus? status,
    DateTime? displayedCalendarDate,
    List<double>? weeklyStudyData,
    double? recordStudyHours,
    DateTime? bestStudyDay,
    String? errorMessage,
    bool clearErrorMessage = false,
    ActivityDetailType? selectedActivityDetailType,
    List<dynamic>? subjectStats,
    List<dynamic>? weeklyDatesData,
  }) {
    return StatisticsState(
      status: status ?? this.status,
      displayedCalendarDate:
          displayedCalendarDate ?? this.displayedCalendarDate,
      weeklyStudyData: weeklyStudyData ?? this.weeklyStudyData,
      recordStudyHours: recordStudyHours ?? this.recordStudyHours,
      bestStudyDay: bestStudyDay ?? this.bestStudyDay,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      selectedActivityDetailType:
          selectedActivityDetailType ?? this.selectedActivityDetailType,
      subjectStats: subjectStats ?? this.subjectStats,
      weeklyDatesData: weeklyDatesData ?? this.weeklyDatesData,
    );
  }

  @override
  List<Object?> get props => [
    status,
    displayedCalendarDate,
    weeklyStudyData,
    recordStudyHours,
    bestStudyDay,
    errorMessage,
    selectedActivityDetailType,
    subjectStats,
    weeklyDatesData,
  ];
}
