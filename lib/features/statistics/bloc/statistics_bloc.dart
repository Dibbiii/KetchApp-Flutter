// filepath: lib/features/statistics/bloc/statistics_bloc.dart
import 'dart:async';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // For @immutable

part 'statistics_event.dart';
part 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final Random _random = Random();

  StatisticsBloc() : super(StatisticsState.initial()) {
    on<StatisticsLoadRequested>(_onLoadRequested);
    on<StatisticsPreviousDayRequested>(_onPreviousDayRequested);
    on<StatisticsNextDayRequested>(_onNextDayRequested);
    on<StatisticsTodayRequested>(_onTodayRequested);
    on<StatisticsDateSelectedFromHistogram>(_onDateSelectedFromHistogram);
    on<StatisticsTotalStudyHoursUpdated>(_onTotalStudyHoursUpdated);
  }

  List<double> _fetchWeeklyStudyData(DateTime dateForWeek) {
    // Placeholder: In a real app, fetch data for the week containing dateForWeek
    return List.generate(7, (_) => _random.nextDouble() * 8.5 + 0.5);
  }

  Future<void> _onLoadRequested(
    StatisticsLoadRequested event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(state.copyWith(status: StatisticsStatus.loading));
    try {
      final weeklyData = _fetchWeeklyStudyData(state.displayedCalendarDate);
      double currentRecordHours = state.recordStudyHours;
      DateTime currentBestDay = state.bestStudyDay;

      if (event.currentTotalStudyHours > currentRecordHours) {
        currentRecordHours = event.currentTotalStudyHours;
        currentBestDay = DateTime.now(); // Assuming record is set now
      }

      emit(state.copyWith(
        status: StatisticsStatus.loaded,
        weeklyStudyData: weeklyData,
        recordStudyHours: currentRecordHours,
        bestStudyDay: currentBestDay,
      ));
    } catch (e) {
      emit(state.copyWith(status: StatisticsStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onPreviousDayRequested(
    StatisticsPreviousDayRequested event,
    Emitter<StatisticsState> emit,
  ) async {
    final newDate = state.displayedCalendarDate.subtract(const Duration(days: 1));
    final weeklyData = _fetchWeeklyStudyData(newDate);
    emit(state.copyWith(
      displayedCalendarDate: newDate,
      weeklyStudyData: weeklyData,
      status: StatisticsStatus.loaded,
    ));
  }

  Future<void> _onNextDayRequested(
    StatisticsNextDayRequested event,
    Emitter<StatisticsState> emit,
  ) async {
    final newDate = state.displayedCalendarDate.add(const Duration(days: 1));
    final weeklyData = _fetchWeeklyStudyData(newDate);
    emit(state.copyWith(
      displayedCalendarDate: newDate,
      weeklyStudyData: weeklyData,
      status: StatisticsStatus.loaded,
    ));
  }

  Future<void> _onTodayRequested(
    StatisticsTodayRequested event,
    Emitter<StatisticsState> emit,
  ) async {
    final newDate = DateTime.now();
    final weeklyData = _fetchWeeklyStudyData(newDate);
    emit(state.copyWith(
      displayedCalendarDate: newDate,
      weeklyStudyData: weeklyData,
      status: StatisticsStatus.loaded,
    ));
  }

  Future<void> _onDateSelectedFromHistogram(
    StatisticsDateSelectedFromHistogram event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(state.copyWith(
      displayedCalendarDate: event.selectedDate,
      status: StatisticsStatus.loaded,
      // weeklyStudyData: _fetchWeeklyStudyData(event.selectedDate), // Potentially refetch if week changes
    ));
  }

  Future<void> _onTotalStudyHoursUpdated(
    StatisticsTotalStudyHoursUpdated event,
    Emitter<StatisticsState> emit,
  ) async {
    if (event.newTotalStudyHours > state.recordStudyHours) {
      emit(state.copyWith(
        recordStudyHours: event.newTotalStudyHours,
        bestStudyDay: DateTime.now(), // Assuming record is updated now
        status: StatisticsStatus.loaded,
      ));
    } else if (state.status != StatisticsStatus.loaded) {
      // Ensure state is loaded if it wasn't, even if record didn't change
      emit(state.copyWith(status: StatisticsStatus.loaded));
    }
  }
}