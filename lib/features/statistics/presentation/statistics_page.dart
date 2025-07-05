import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:ketchapp_flutter/features/statistics/presentation/statistics_shrimmer_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ketchapp_flutter/features/statistics/bloc/statistics_bloc.dart';
import 'package:ketchapp_flutter/features/statistics/presentation/widgets/weekly_histogram_widget.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with TickerProviderStateMixin {
  bool _isLocaleInitialized = false;

  late final AnimationController _animationController;
  late final AnimationController _fadeAnimationController;
  late final AnimationController _scaleAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  List<dynamic> statistics = [];

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleAnimationController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final statisticsBloc = BlocProvider.of<StatisticsBloc>(context);
    if (statisticsBloc.state.status == StatisticsStatus.initial) {
      // Usa addPostFrameCallback per evitare chiamate multiple e problemi di build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && statisticsBloc.state.status == StatisticsStatus.initial) {
          statisticsBloc.add(
            StatisticsLoadRequested(currentTotalStudyHours: 0),
          );
        }
      });
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
    _fadeAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocaleInitialized) {
      return _buildInitializingState(context);
    }

    final statisticsBloc = BlocProvider.of<StatisticsBloc>(context);
    final colors = Theme.of(context).colorScheme;

    final SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: colors.brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
      statusBarBrightness: colors.brightness,
      systemNavigationBarColor: colors.surface,
      systemNavigationBarIconBrightness: colors.brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: BlocBuilder<StatisticsBloc, StatisticsState>(
        builder: (context, state) {
          if (state.status == StatisticsStatus.initial ||
              state.status == StatisticsStatus.loading) {
            return const StatisticsShrimmerPage();
          }

          if (state.status == StatisticsStatus.error) {
            return _buildErrorState(context, state.errorMessage);
          }

          return _buildLoadedState(context, state, statisticsBloc);
        },
      ),
    );
  }

  Widget _buildInitializingState(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.primary.withOpacity(0.03),
              colors.surface,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: colors.primary,
                  backgroundColor: colors.primary.withOpacity(0.1),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Initializing statistics...',
                style: textTheme.titleMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? errorMessage) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.errorContainer.withOpacity(0.1),
              colors.surface,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.errorContainer.withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.error.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    color: colors.error,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Unable to load statistics',
                  style: textTheme.headlineSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    errorMessage ?? 'Error loading statistics',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                  onPressed: () {
                    final statisticsBloc = BlocProvider.of<StatisticsBloc>(context);
                    statisticsBloc.add(StatisticsLoadRequested(currentTotalStudyHours: 0));
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primaryContainer,
                    foregroundColor: colors.onPrimaryContainer,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, StatisticsState state, StatisticsBloc statisticsBloc) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.primary.withOpacity(0.05),
              colors.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                      child: Column(
                        children: [
                          _buildStatsHeader(context, state, colors, textTheme),
                          const SizedBox(height: 40),
                          _buildWeekNavigator(context, state, statisticsBloc, colors, textTheme),
                          const SizedBox(height: 24),
                          _buildHistogramSection(context, state, statisticsBloc, colors, textTheme),
                          const SizedBox(height: 32),
                          _buildSubjectsSection(context, state, colors, textTheme),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 32),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsHeader(BuildContext context, StatisticsState state, ColorScheme colors, TextTheme textTheme) {
    final dailyHours = state.weeklyStudyData.isNotEmpty
        ? state.weeklyStudyData[state.displayedCalendarDate.weekday - 1]
        : 0.0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.primary.withOpacity(0.15),
                colors.tertiary.withOpacity(0.1),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.primary.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.analytics_outlined,
            size: 72,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _formatTotalHours(dailyHours),
          style: textTheme.displayMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.outline.withOpacity(0.1),
            ),
          ),
          child: Text(
            DateUtils.isSameDay(state.displayedCalendarDate, DateTime.now())
                ? 'Focus time today'
                : 'Focus time on ${DateFormat('E, d MMM', 'it_IT').format(state.displayedCalendarDate)}',
            style: textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekNavigator(BuildContext context, StatisticsState state, StatisticsBloc statisticsBloc, ColorScheme colors, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outline.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.chevron_left_rounded,
                  color: colors.onSurfaceVariant,
                ),
                onPressed: () => statisticsBloc.add(StatisticsPreviousWeekRequested()),
                tooltip: 'Previous week',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextButton(
                onPressed: () => statisticsBloc.add(StatisticsTodayRequested()),
                style: TextButton.styleFrom(
                  backgroundColor: colors.primaryContainer.withOpacity(0.5),
                  foregroundColor: colors.onPrimaryContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  DateFormat('E, d MMM', 'it_IT').format(state.displayedCalendarDate),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.25,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSurfaceVariant,
                ),
                onPressed: () => statisticsBloc.add(StatisticsNextWeekRequested()),
                tooltip: 'Next week',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistogramSection(BuildContext context, StatisticsState state, StatisticsBloc statisticsBloc, ColorScheme colors, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colors.outline.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.primaryContainer.withOpacity(0.8),
                    colors.tertiaryContainer.withOpacity(0.6),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.bar_chart_rounded,
                      color: colors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Weekly Overview",
                          style: textTheme.headlineSmall?.copyWith(
                            color: colors.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.25,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Your focus patterns this week",
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onPrimaryContainer.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: WeeklyHistogramWidget(
                displayedCalendarDate: state.displayedCalendarDate,
                weeklyStudyData: state.weeklyStudyData,
                onDateSelected: (date) => statisticsBloc.add(
                  StatisticsDateSelectedFromHistogram(date),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsSection(BuildContext context, StatisticsState state, ColorScheme colors, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colors.outline.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.secondaryContainer.withOpacity(0.8),
                    colors.tertiaryContainer.withOpacity(0.6),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.subject_rounded,
                      color: colors.secondary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Subject Breakdown",
                          style: textTheme.headlineSmall?.copyWith(
                            color: colors.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.25,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Detailed study time per subject",
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSecondaryContainer.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (state.subjectStats.isEmpty)
              _buildEmptySubjectsState(context, colors, textTheme)
            else
              _buildSubjectsList(context, state, colors, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySubjectsState(BuildContext context, ColorScheme colors, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school_outlined,
              color: colors.onSurfaceVariant,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No study data',
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No study sessions recorded for this day',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsList(BuildContext context, StatisticsState state, ColorScheme colors, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.subjectStats.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final stat = state.subjectStats[index];
          final subjectName = stat['name'] ?? 'Unknown Subject';
          final studyTimeInHours = (stat['hours'] ?? 0.0) as num;
          final studyTimeInSeconds = (studyTimeInHours * 3600).toInt();

          return _buildEnhancedSubjectItem(
            context,
            subjectName,
            _formatDurationFromSeconds(studyTimeInSeconds),
            studyTimeInSeconds,
            stat,
            colors,
            textTheme,
          );
        },
      ),
    );
  }

  Widget _buildEnhancedSubjectItem(BuildContext context, String subjectName, String studyTime, int totalSeconds, Map<String, dynamic> stat, ColorScheme colors, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outline.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.primaryContainer.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.book_rounded,
            color: colors.primary,
            size: 20,
          ),
        ),
        title: Text(
          subjectName,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        subtitle: Text(
          studyTime,
          style: textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            color: colors.primary,
            size: 16,
          ),
        ),
        onTap: () {
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
