import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ketchapp_flutter/features/statistics/presentation/statistics_shrimmer_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import BLoC
import 'package:ketchapp_flutter/features/statistics/bloc/statistics_bloc.dart'; // Import your BLoC// Import StatItemWidget
import 'package:ketchapp_flutter/features/statistics/presentation/widgets/weekly_histogram_widget.dart'; // Import WeeklyHistogramWidget
import 'package:ketchapp_flutter/features/statistics/presentation/widgets/subject_stat_item_widget.dart'; // Add this import


class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  bool _isLocaleInitialized = false;
  bool _showShimmer = true;

  late final AnimationController _animationController;

  List<dynamic> statistics = [];



  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showShimmer = false;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final statisticsBloc = BlocProvider.of<StatisticsBloc>(context);
    if (statisticsBloc.state.status == StatisticsStatus.initial) {
      final summaryState = Provider.of<SummaryState>(context, listen: false);
      statisticsBloc.add(
        StatisticsLoadRequested(
          currentTotalStudyHours: summaryState.totalCompletedHours,
        ),
      );
    }
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('it_IT', null);
    if (mounted) {
      setState(() {
        _isLocaleInitialized = true;
      });
    }
  }

  String _formatDurationFromSeconds(int totalSeconds) {
    if (totalSeconds < 0) totalSeconds = 0;
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    String result = '';
    if (hours > 0) result += '$hours or${hours > 1 ? 'e' : 'a'}';
    if (minutes > 0) {
      if (hours > 0) result += ', ';
      result += '$minutes min';
    }
    return result.isEmpty ? '0 min' : result;
  }

  String _formatTotalHours(double totalHours) {
    if (totalHours < 0) totalHours = 0;
    final int hours = totalHours.truncate();
    final int minutes = ((totalHours - hours) * 60).round();
    String result = '';
    if (hours > 0) result += '$hours or${hours > 1 ? 'e' : 'a'}';
    if (minutes > 0) {
      if (hours > 0) result += ', ';
      result += '$minutes min';
    }
    return result.isEmpty ? '0 min' : result;
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocaleInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final summaryState = Provider.of<SummaryState>(context);
    final statisticsBloc = BlocProvider.of<StatisticsBloc>(context);

    if (summaryState.totalCompletedHours >
        statisticsBloc.state.recordStudyHours) {
      statisticsBloc.add(
        StatisticsTotalStudyHoursUpdated(summaryState.totalCompletedHours),
      );
    }

    return BlocBuilder<StatisticsBloc, StatisticsState>(
      builder: (context, state) {
        if (_showShimmer) {
          return const StatisticsShrimmerPage();
        }
        final colors = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        if (state.status == StatisticsStatus.initial ||
            state.status == StatisticsStatus.loading) {
          return const StatisticsShrimmerPage();
        }

        if (state.status == StatisticsStatus.error) {
          return Scaffold(
            body: Center(
              child: Text(
                state.errorMessage ??
                    'Errore nel caricamento delle statistiche.',
              ),
            ),
          );
        }

        return SafeArea(
          child: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            _formatTotalHours(
                              state.weeklyStudyData.isNotEmpty
                                  ? state.weeklyStudyData[state
                                          .displayedCalendarDate
                                          .weekday -
                                      1]
                                  : 0.0,
                            ),
                            style: textTheme.displaySmall?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateUtils.isSameDay(
                                  state.displayedCalendarDate,
                                  DateTime.now(),
                                )
                                ? 'Oggi'
                                : DateFormat(
                                  'E, d MMM',
                                  'it_IT',
                                ).format(state.displayedCalendarDate),
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () =>
                              statisticsBloc.add(StatisticsPreviousWeekRequested()),
                          tooltip: 'Settimana precedente',
                        ),
                        TextButton(
                          onPressed:
                              () => statisticsBloc.add(
                                StatisticsTodayRequested(),
                              ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            DateFormat(
                              'E, d MMM',
                              'it_IT',
                            ).format(state.displayedCalendarDate),
                            style: textTheme.titleSmall?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () =>
                              statisticsBloc.add(StatisticsNextWeekRequested()),
                          tooltip: 'Settimana successiva',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    WeeklyHistogramWidget(
                      displayedCalendarDate: state.displayedCalendarDate,
                      weeklyStudyData: state.weeklyStudyData,
                      onDateSelected:
                          (date) => statisticsBloc.add(
                            StatisticsDateSelectedFromHistogram(date),
                          ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Dettaglio Materie Studiate',
                      style: textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (state.subjectStats.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'Nessun dato di studio per questo giorno.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.subjectStats.length,
                        itemBuilder: (context, index) {
                          final stat = state.subjectStats[index];
                          final subjectName =
                              stat['name'] ?? 'Materia Sconosciuta';
                          final studyTimeInHours = (stat['hours'] ?? 0.0) as num;
                          final studyTimeInSeconds = (studyTimeInHours * 3600).toInt();

                          // TODO: You might want to have a mapping for icons and colors based on subjectName
                          return SubjectStatItemWidget(
                            subjectIcon: Icons.book_rounded,
                            iconColor: Colors.blueGrey,
                            subjectName: subjectName,
                            studyTime:
                                _formatDurationFromSeconds(studyTimeInSeconds),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
