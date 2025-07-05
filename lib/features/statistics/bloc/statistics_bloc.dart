import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart';

import '../../../services/api_service.dart';

part 'statistics_event.dart';
part 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final AuthBloc _authBloc;

  StatisticsBloc({required AuthBloc authBloc})
      : _authBloc = authBloc,
        super(StatisticsState.initial()) {
    on<StatisticsLoadRequested>(_onLoadRequested);
    on<StatisticsPreviousWeekRequested>(_onPreviousWeekRequested);
    on<StatisticsNextWeekRequested>(_onNextWeekRequested);
    on<StatisticsTodayRequested>(_onTodayRequested);
    on<StatisticsDateSelectedFromHistogram>(_onDateSelectedFromHistogram);
    on<StatisticsTotalStudyHoursUpdated>(_onTotalStudyHoursUpdated);
  }

  Future<void> _fetchAndEmitStatisticsForWeekContainingDate(
    DateTime date,
    Emitter<StatisticsState> emit,
  ) async {
    emit(state.copyWith(status: StatisticsStatus.loading));
    try {
      final authState = _authBloc.state;
      if (authState is! Authenticated) {
        emit(state.copyWith(
            status: StatisticsStatus.error,
            errorMessage: 'User not authenticated'));
        return;
      }

      final api = ApiService();
      final userUuid = authState.userUuid;

      final formattedDate =
          "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final formattedStart =
          "${startOfWeek.year.toString().padLeft(4, '0')}-${startOfWeek.month.toString().padLeft(2, '0')}-${startOfWeek.day.toString().padLeft(2, '0')}";
      final formattedEnd =
          "${endOfWeek.year.toString().padLeft(4, '0')}-${endOfWeek.month.toString().padLeft(2, '0')}-${endOfWeek.day.toString().padLeft(2, '0')}";

      final url = "users/$userUuid/statistics?startDate=$formattedStart&endDate=$formattedEnd";
      final response = await api.fetchData(url);

      if (response is Map<String, dynamic> && response.containsKey('dates')) {
        final dates = response['dates'] as List<dynamic>?;
        if (dates != null) {
          // Data for the selected day
          final dayData = dates.firstWhere(
            (d) => d is Map<String, dynamic> && d['date'] == formattedDate,
            orElse: () => null,
          );

          List<dynamic> subjectStatsForDay = [];
          if (dayData != null && dayData['subjects'] is List) {
            // Group tomatoes by subject for the selected day
            final tomatoes = (dayData['tomatoes'] ?? dayData['sessions'] ?? []) as List<dynamic>;
            final Map<String, List<int>> subjectTomatoes = {};
            for (final tomato in tomatoes) {
              final subject = tomato['subject'] ?? tomato['subjectName'] ?? tomato['name'];
              final id = tomato['id'];
              if (subject != null && id != null) {
                subjectTomatoes.putIfAbsent(subject, () => []).add(id);
              }
            }
            // Attach tomatoes to each subject
            subjectStatsForDay = (dayData['subjects'] as List<dynamic>).map((subject) {
              final subjectMap = Map<String, dynamic>.from(subject as Map);
              final subjectName = subjectMap['name'] ?? subjectMap['subject'] ?? subjectMap['subjectName'];
              return {
                ...subjectMap,
                'tomatoes': subjectTomatoes[subjectName] ?? [],
              };
            }).toList();
          }

          // Data for the whole week
          final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
          final weeklyData = List.filled(7, 0.0);
          for (int i = 0; i < 7; i++) {
            final dateInWeek = startOfWeek.add(Duration(days: i));
            final formattedDateInWeek =
                "${dateInWeek.year.toString().padLeft(4, '0')}-${dateInWeek.month.toString().padLeft(2, '0')}-${dateInWeek.day.toString().padLeft(2, '0')}";

            final dayDataInWeek = dates.firstWhere(
              (d) =>
                  d is Map<String, dynamic> &&
                  d['date'] == formattedDateInWeek,
              orElse: () => null,
            );

            if (dayDataInWeek != null && dayDataInWeek['hours'] is num) {
              weeklyData[i] = (dayDataInWeek['hours'] as num).toDouble();
            }
          }

          emit(state.copyWith(
            status: StatisticsStatus.loaded,
            displayedCalendarDate: date,
            subjectStats: subjectStatsForDay,
            weeklyStudyData: weeklyData,
            weeklyDatesData: dates, // Store the weekly data
          ));
        } else {
          emit(state.copyWith(
            status: StatisticsStatus.error,
            errorMessage:
                "Formato di risposta API imprevisto ('dates' non è una lista).",
          ));
        }
      } else {
        // No data for today, emit empty list
        emit(state.copyWith(
          status: StatisticsStatus.loaded,
          displayedCalendarDate: date,
          subjectStats: [],
          weeklyStudyData: List.filled(7, 0.0),
        ));
      }
    } catch (e) {
      emit(state.copyWith(
          status: StatisticsStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadRequested(
    StatisticsLoadRequested event,
    Emitter<StatisticsState> emit,
  ) async {
    await _fetchAndEmitStatisticsForWeekContainingDate(DateTime.now(), emit);
  }

  Future<void> _onPreviousWeekRequested(
    StatisticsPreviousWeekRequested event,
    Emitter<StatisticsState> emit,
  ) async {
    final newDate = state.displayedCalendarDate.subtract(const Duration(days: 7));
    await _fetchAndEmitStatisticsForWeekContainingDate(newDate, emit);
  }

  Future<void> _onNextWeekRequested(
    StatisticsNextWeekRequested event,
    Emitter<StatisticsState> emit,
  ) async {
    final newDate = state.displayedCalendarDate.add(const Duration(days: 7));
    await _fetchAndEmitStatisticsForWeekContainingDate(newDate, emit);
  }

  Future<void> _onTodayRequested(
    StatisticsTodayRequested event,
    Emitter<StatisticsState> emit,
  ) async {
    await _fetchAndEmitStatisticsForWeekContainingDate(DateTime.now(), emit);
  }

  Future<void> _onDateSelectedFromHistogram(
    StatisticsDateSelectedFromHistogram event,
    Emitter<StatisticsState> emit,
  ) async {
    final selectedDate = event.selectedDate;
    final currentDisplayedDate = state.displayedCalendarDate;

    // Check if the selected date is in the same week as the currently displayed date
    final startOfWeek = currentDisplayedDate.subtract(Duration(days: currentDisplayedDate.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    if (selectedDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        selectedDate.isBefore(endOfWeek.add(const Duration(days: 1))) &&
        state.weeklyDatesData.isNotEmpty) {
      // Data for the week is already loaded, just update the selected day
      final formattedDate =
          "${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

      final dayData = state.weeklyDatesData.firstWhere(
        (d) => d is Map<String, dynamic> && d['date'] == formattedDate,
        orElse: () => null,
      );

      List<dynamic> subjectStatsForDay = [];
      if (dayData != null && dayData['subjects'] is List) {
        // Group tomatoes by subject for the selected day
        final tomatoes = (dayData['tomatoes'] ?? dayData['sessions'] ?? []) as List<dynamic>;
        final Map<String, List<int>> subjectTomatoes = {};
        for (final tomato in tomatoes) {
          final subject = tomato['subject'] ?? tomato['subjectName'] ?? tomato['name'];
          final id = tomato['id'];
          if (subject != null && id != null) {
            subjectTomatoes.putIfAbsent(subject, () => []).add(id);
          }
        }
        // Attach tomatoes to each subject
        subjectStatsForDay = (dayData['subjects'] as List<dynamic>).map((subject) {
          final subjectMap = Map<String, dynamic>.from(subject as Map);
          final subjectName = subjectMap['name'] ?? subjectMap['subject'] ?? subjectMap['subjectName'];
          return {
            ...subjectMap,
            'tomatoes': subjectTomatoes[subjectName] ?? [],
          };
        }).toList();
      }

      emit(state.copyWith(
        displayedCalendarDate: selectedDate,
        subjectStats: subjectStatsForDay,
      ));
    } else {
      // Data for the week is not loaded, fetch it
      await _fetchAndEmitStatisticsForWeekContainingDate(selectedDate, emit);
    }
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
