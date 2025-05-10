part of 'statistics_bloc.dart';

enum StatisticsStatus { initial, loading, loaded, error }

// Add this enum for the overlay options
enum ActivityDetailType { screenTime, notificationsReceived, timesOpened }

class StatisticsState extends Equatable {
  final StatisticsStatus status;
  final DateTime displayedCalendarDate;
  final List<double> weeklyStudyData;
  final double recordStudyHours;
  final DateTime bestStudyDay;
  final String? errorMessage;
  // Add this property to manage the selected overlay option
  final ActivityDetailType selectedActivityDetailType;

  const StatisticsState({
    this.status = StatisticsStatus.initial,
    required this.displayedCalendarDate,
    this.weeklyStudyData = const [],
    this.recordStudyHours = 0.0,
    required this.bestStudyDay,
    this.errorMessage,
    // Initialize with a default value, e.g., screenTime
    this.selectedActivityDetailType = ActivityDetailType.screenTime,
  });

  factory StatisticsState.initial() {
    final now = DateTime.now();
    return StatisticsState(
      displayedCalendarDate: now,
      bestStudyDay: now, // Default best study day
      // Ensure initial state also has a default for the new property
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
    // Add the new property to copyWith
    ActivityDetailType? selectedActivityDetailType,
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
      // Update the new property
      selectedActivityDetailType:
          selectedActivityDetailType ?? this.selectedActivityDetailType,
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
    // Add the new property to props for Equatable comparison
    selectedActivityDetailType,
  ];
}
