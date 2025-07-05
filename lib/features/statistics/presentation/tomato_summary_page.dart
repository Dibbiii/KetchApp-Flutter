import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:ketchapp_flutter/services/api_service.dart';
import 'package:ketchapp_flutter/services/session_stats_service.dart';

class TimerSummaryPage extends StatefulWidget {
  static const String routeName = '/timer-summary';

  final dynamic sessionSummary;
  final VoidCallback? onGoHome;
  final VoidCallback? onPlanAgain;

  final String? subjectName;
  final int? totalSeconds;
  final IconData? subjectIcon;
  final Color? subjectColor;
  final List<dynamic>? tomatoes;

  final String? id;
  const TimerSummaryPage({
    super.key,
    this.sessionSummary,
    this.onGoHome,
    this.onPlanAgain,
    this.subjectName,
    this.totalSeconds,
    this.subjectIcon,
    this.subjectColor,
    this.tomatoes,
    this.id,
  });

  const TimerSummaryPage.sessionSummary({
    Key? key,
    required dynamic sessionSummary,
    required VoidCallback onGoHome,
    required VoidCallback onPlanAgain,
  }) : this(
    key: key,
    sessionSummary: sessionSummary,
    onGoHome: onGoHome,
    onPlanAgain: onPlanAgain,
  );

  const TimerSummaryPage.subjectStatistics({
    Key? key,
    required String subjectName,
    required int totalSeconds,
    required IconData subjectIcon,
    required Color subjectColor,
    required List<dynamic> tomatoes,
  }) : this(
    key: key,
    subjectName: subjectName,
    totalSeconds: totalSeconds,
    subjectIcon: subjectIcon,
    subjectColor: subjectColor,
    tomatoes: tomatoes,
  );

  @override
  State<TimerSummaryPage> createState() => _TimerSummaryPageState();
}

class _TimerSummaryPageState extends State<TimerSummaryPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  late Future<String?> _subjectFuture = Future.value(null);
  late Future<Map<String, dynamic>> _tomatoStatsFuture;

  bool get _isSessionSummary => widget.sessionSummary != null;
  bool get _isSubjectStatistics => widget.subjectName != null || (!_isSessionSummary);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fadeAnimationController.forward();
    _scaleAnimationController.forward();
    if (widget.id != null) {
      final sessionStatsService = SessionStatsService(ApiService());
      _tomatoStatsFuture = sessionStatsService.getTomatoChainSummary(int.parse(widget.id!));
      _subjectFuture = _fetchSubjectFromTomatoId(widget.id!);
    } else {
      _tomatoStatsFuture = Future.value({
        'subject': widget.subjectName,
        'tomatoIds': [],
        'tomatoes': [],
        'totalDuration': Duration.zero,
        'totalPauses': 0,
        'efficiency': 0.0,
      });
      _subjectFuture = Future.value(widget.subjectName);
    }
  }

  Future<String?> _fetchSubjectFromTomatoId(String id) async {
    try {
      final tomatoId = int.tryParse(id);
      if (tomatoId == null) return null;
      final api = ApiService();
      final tomato = await api.getTomatoById(tomatoId);
      return tomato.subject;
    } catch (e) {
      return null;
    }
  }

  void _initializeAnimations() {
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
  void dispose() {
    _fadeAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    Map<String, dynamic>? routeArgs;
    if (_isSubjectStatistics && widget.subjectName == null) {
      try {
        routeArgs = GoRouterState.of(context).extra as Map<String, dynamic>?;
      } catch (e) {
      }
    }

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
      child: Scaffold(
        backgroundColor: colors.surface,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                (_isSessionSummary
                    ? colors.primary
                    : (widget.subjectColor ?? routeArgs?['color'] ?? colors.primary))
                    .withOpacity(0.1),
                colors.surface,
              ],
            ),
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _isSessionSummary
                  ? _buildSessionSummaryView(context, colors, theme.textTheme)
                  : _buildSubjectStatisticsView(context, colors, theme.textTheme, routeArgs),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionSummaryView(BuildContext context, ColorScheme colors, TextTheme textTheme) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
            child: Column(
              children: [
                _buildCelebrationHeader(context, colors, textTheme),
                const SizedBox(height: 40),
                _buildSessionOverview(context, colors, textTheme),
                const SizedBox(height: 32),
                _buildSessionTomatoList(context, colors, textTheme),
                const SizedBox(height: 32),
                _buildActionButtons(context, colors, textTheme),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectStatisticsView(BuildContext context, ColorScheme colors, TextTheme textTheme, Map<String, dynamic>? routeArgs) {
    final subjectName = widget.subjectName ?? routeArgs?['name'] as String? ?? 'Unknown Subject';
    final totalSeconds = widget.totalSeconds ?? routeArgs?['totalSeconds'] as int? ?? 0;
    final iconData = widget.subjectIcon ?? routeArgs?['icon'] as IconData? ?? Icons.book_rounded;
    final color = widget.subjectColor ?? routeArgs?['color'] as Color? ?? colors.primary;
    final tomatoes = widget.tomatoes ?? routeArgs?['tomatoes'] as List<dynamic>? ?? [];

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverAppBar(context, subjectName, iconData, color, colors, textTheme),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildSubjectStatsOverview(context, totalSeconds, tomatoes.length, colors, textTheme),
                const SizedBox(height: 32),
                _buildSubjectTomatoesSection(context, tomatoes, colors, textTheme),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, String subjectName, IconData iconData, Color color, ColorScheme colors, TextTheme textTheme) {
    return FutureBuilder<String?>(
      future: _subjectFuture,
      builder: (context, snapshot) {
        final displaySubject = snapshot.connectionState == ConnectionState.done && snapshot.data != null
            ? snapshot.data!
            : subjectName;
        return SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: colors.surface,
          surfaceTintColor: Colors.transparent,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: colors.onSurface),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              displaySubject,
              style: textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withOpacity(0.2),
                    colors.surface,
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    iconData,
                    size: 64,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCelebrationHeader(BuildContext context, ColorScheme colors, TextTheme textTheme) {
    final sessionSummary = widget.sessionSummary!;
    final isCompleted = sessionSummary.completedTomatoes == sessionSummary.totalTomatoes;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCompleted
                  ? colors.primaryContainer.withOpacity(0.8)
                  : colors.errorContainer.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: isCompleted ? colors.primary : colors.error,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCompleted ? 'Great job!' : 'Session interrupted',
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isCompleted
                      ? 'You have completed the session successfully.'
                      : 'Don\'t worry, you can try again later.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionOverview(BuildContext context, ColorScheme colors, TextTheme textTheme) {
    final sessionSummary = widget.sessionSummary!;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    color: colors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Session Overview',
                  style: textTheme.headlineSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Time',
                    _formatDurationFromSeconds(sessionSummary.totalActualTime.inSeconds),
                    Icons.schedule_rounded,
                    colors.primary,
                    colors,
                    textTheme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Pomodoros',
                    sessionSummary.completedTomatoes.toString(),
                    Icons.access_time_rounded,
                    colors.secondary,
                    colors,
                    textTheme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color accentColor, ColorScheme colors, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTomatoList(BuildContext context, ColorScheme colors, TextTheme textTheme) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _tomatoStatsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          );
        }
        final tomatoes = snapshot.data!['tomatoes'] as List<dynamic>;
        if (tomatoes.isEmpty) {
          return _buildEmptyTomatoesState(context, colors, textTheme);
        }
        return _buildSessionTomatoesList(context, tomatoes, colors, textTheme);
      },
    );
  }

  Widget _buildEmptyTomatoesState(BuildContext context, ColorScheme colors, TextTheme textTheme) {
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
              Icons.hourglass_empty_rounded,
              color: colors.onSurfaceVariant,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Pomodoro sessions',
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start studying to see your Pomodoro sessions here',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTomatoesList(BuildContext context, List<dynamic> tomatoes, ColorScheme colors, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tomatoes.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final tomato = tomatoes[index];
          return _buildSessionTomatoItem(
            context,
            tomato,
            index + 1,
            colors,
            textTheme,
          );
        },
      ),
    );
  }

  Widget _buildSessionTomatoItem(BuildContext context, dynamic tomato, int sessionNumber, ColorScheme colors, TextTheme textTheme) {
    final startTime = tomato['startAt'] is DateTime
        ? tomato['startAt']
        : null;
    final endTime = tomato['endAt'] is DateTime
        ? tomato['endAt']
        : null;
    final duration = (endTime != null && startTime != null)
        ? endTime.difference(startTime).inSeconds
        : 0;
    final isCompleted = tomato['nextTomatoId'] != null;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isCompleted
                ? colors.primaryContainer.withValues(alpha: 0.8)
                : colors.errorContainer.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: isCompleted ? colors.primary : colors.error,
            size: 20,
          ),
        ),
        title: Text(
          'Session $sessionNumber',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (startTime != null)
              Text(
                DateFormat('HH:mm - dd/MM/yyyy').format(startTime),
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 2),
            Text(
              '${(duration / 60).round()} minutes',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isCompleted
                ? colors.primaryContainer.withValues(alpha: 0.5)
                : colors.errorContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isCompleted ? 'Completed' : 'Interrupted',
            style: textTheme.labelSmall?.copyWith(
              color: isCompleted ? colors.primary : colors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Dettaglio sessione di prova')),
          );
        },
      ),
    );
  }


  Widget _buildSubjectStatsOverview(BuildContext context, int totalSeconds, int tomatoCount, ColorScheme colors, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    color: colors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Study Statistics',
                  style: textTheme.headlineSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Time',
                    _formatDurationFromSeconds(totalSeconds),
                    Icons.schedule_rounded,
                    colors.primary,
                    colors,
                    textTheme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Pomodoros',
                    tomatoCount.toString(),
                    Icons.access_time_rounded,
                    colors.secondary,
                    colors,
                    textTheme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectTomatoesSection(BuildContext context, List<dynamic> tomatoes, ColorScheme colors, TextTheme textTheme) {
    if (widget.id != null) {
      return FutureBuilder<Map<String, dynamic>>(
        future: _tomatoStatsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            );
          }
          final tomatoesList = snapshot.data!['tomatoes'] as List<dynamic>;
          if (tomatoesList.isEmpty) {
            return _buildEmptyTomatoesState(context, colors, textTheme);
          }
          return _buildTomatoesList(context, tomatoesList, colors, textTheme);
        },
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
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
        child: _buildTomatoesList(context, tomatoes, colors, textTheme),
      );
    }
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colors, TextTheme textTheme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.outline.withOpacity(0.2),
              ),
            ),
            child: TextButton.icon(
              onPressed: widget.onGoHome ?? () => Navigator.pop(context),
              icon: const Icon(Icons.home_rounded),
              label: const Text('Go Home'),
              style: TextButton.styleFrom(
                foregroundColor: colors.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primary,
                  colors.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FilledButton.icon(
              onPressed: widget.onPlanAgain ?? () => Navigator.pop(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Plan Again'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: colors.onPrimary,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
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

  Widget _buildTomatoesList(BuildContext context, List<dynamic> tomatoes, ColorScheme colors, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tomatoes.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final tomato = tomatoes[index];
          return _buildTomatoItem(
            context,
            tomato,
            colors,
            textTheme,
          );
        },
      ),
    );
  }

  Widget _buildTomatoItem(BuildContext context, dynamic tomato, ColorScheme colors, TextTheme textTheme) {
    final startTime = tomato['startAt'] is DateTime
        ? tomato['startAt']
        : null;
    final endTime = tomato['endAt'] is DateTime
        ? tomato['endAt']
        : null;
    final duration = (endTime != null && startTime != null)
        ? endTime.difference(startTime).inSeconds
        : 0;
    final isCompleted = tomato['nextTomatoId'] != null;
    final tomatoId = tomato['id'] ?? 'N/A';
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isCompleted
                ? colors.primaryContainer.withValues(alpha: 0.8)
                : colors.errorContainer.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: isCompleted ? colors.primary : colors.error,
            size: 20,
          ),
        ),
        title: Text(
          'ID: $tomatoId',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (startTime != null)
              Text(
                DateFormat('HH:mm - dd/MM/yyyy').format(startTime),
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 2),
            Text(
              '${(duration / 60).round()} minutes',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isCompleted
                ? colors.primaryContainer.withValues(alpha: 0.5)
                : colors.errorContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isCompleted ? 'Completed' : 'Interrupted',
            style: textTheme.labelSmall?.copyWith(
              color: isCompleted ? colors.primary : colors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Dettaglio sessione di prova')),
          );
        },
      ),
    );
  }
}
