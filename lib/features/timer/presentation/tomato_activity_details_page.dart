import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:ketchapp_flutter/services/api_service.dart';

class TomatoActivityDetailsPage extends StatefulWidget {
  final dynamic tomato;
  final ApiService apiService;

  const TomatoActivityDetailsPage({
    Key? key,
    required this.tomato,
    required this.apiService,
  }) : super(key: key);

  @override
  State<TomatoActivityDetailsPage> createState() => _TomatoActivityDetailsPageState();
}

class _TomatoActivityDetailsPageState extends State<TomatoActivityDetailsPage>
    with TickerProviderStateMixin {
  // Placeholder for activities
  List<dynamic> activities = [];
  // Placeholder for loading state
  bool isLoading = true;
  // Placeholder for error message
  String? errorMessage;

  // Placeholder for animation controllers
  late AnimationController _fadeAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Placeholder for loading activities
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

  Future<void> _loadActivities() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final loadedActivities = await widget.apiService.getTomatoActivities(widget.tomato.id);

      // Sort activities by time
      loadedActivities.sort((a, b) {
        try {
          final timeA = _getActivityProperty(a, 'createdAt') as DateTime;
          final timeB = _getActivityProperty(b, 'createdAt') as DateTime;
          return timeA.compareTo(timeB);
        } catch (e) {
          return 0;
        }
      });

      setState(() {
        activities = loadedActivities;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  dynamic _getActivityProperty(dynamic activity, String property) {
    if (activity is Map<String, dynamic>) {
      // Handle different possible property names and formats
      switch (property) {
        case 'actionType':
          final actionType = activity['actionType'] ?? activity['action_type'] ?? activity['type'] ?? activity['action'] ?? 'unknown';
          // Debug print to see what values we're getting
          print('DEBUG: actionType found: $actionType for activity: $activity');
          return actionType;
        case 'activityType':
          final activityType = activity['activityType'] ?? activity['activity_type'] ?? activity['category'] ?? activity['timer_type'] ?? activity['type'] ?? 'timer';
          // Debug print to see what values we're getting
          print('DEBUG: activityType found: $activityType for activity: $activity');
          return activityType;
        case 'createdAt':
          final timeValue = activity['createdAt'] ?? activity['created_at'] ?? activity['timestamp'];
          if (timeValue == null) return null;

          // Handle different time formats
          if (timeValue is DateTime) {
            return timeValue;
          } else if (timeValue is String) {
            try {
              return DateTime.parse(timeValue);
            } catch (e) {
              // Try different formats
              try {
                return DateFormat('yyyy-MM-dd HH:mm:ss').parse(timeValue);
              } catch (e2) {
                try {
                  return DateFormat('yyyy-MM-ddTHH:mm:ss').parse(timeValue);
                } catch (e3) {
                  print('Failed to parse date: $timeValue');
                  return null;
                }
              }
            }
          } else if (timeValue is int) {
            // Handle timestamp in milliseconds or seconds
            try {
              if (timeValue > 1000000000000) {
                // Milliseconds
                return DateTime.fromMillisecondsSinceEpoch(timeValue);
              } else {
                // Seconds
                return DateTime.fromMillisecondsSinceEpoch(timeValue * 1000);
              }
            } catch (e) {
              print('Failed to parse timestamp: $timeValue');
              return null;
            }
          }
          return null;
        default:
          return activity[property];
      }
    }

    // Handle other possible types of activity objects
    try {
      // Try to access as a class property using reflection-like approach
      switch (property) {
        case 'actionType':
          return activity?.actionType ?? activity?.action_type ?? activity?.type ?? 'unknown';
        case 'activityType':
          return activity?.activityType ?? activity?.activity_type ?? activity?.category ?? 'timer';
        case 'createdAt':
          return activity?.createdAt ?? activity?.created_at ?? activity?.timestamp;
        default:
          return null;
      }
    } catch (e) {
      print('Error accessing property $property: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                colors.primary.withValues(alpha: 0.05),
                colors.surface,
              ],
            ),
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 200,
                    floating: false,
                    pinned: true,
                    backgroundColor: colors.surface.withValues(alpha: 0.95),
                    foregroundColor: colors.onSurface,
                    elevation: 0,
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHigh.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: colors.onSurface,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        'Activity Details',
                        style: textTheme.titleLarge?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              colors.primaryContainer.withValues(alpha: 0.3),
                              colors.surface,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildTomatoHeader(context, colors, textTheme),
                            const SizedBox(height: 32),
                            if (isLoading)
                              _buildLoadingState(context, colors, textTheme)
                            else if (errorMessage != null)
                              _buildErrorState(context, colors, textTheme)
                            else
                              _buildActivitiesList(context, colors, textTheme),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTomatoHeader(BuildContext context, ColorScheme colors, TextTheme textTheme) {
    // Use placeholder for isCompleted
    final bool isCompleted = widget.tomato['isCompleted'] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.04),
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isCompleted ? [
                    colors.primaryContainer.withValues(alpha: 0.8),
                    colors.tertiaryContainer.withValues(alpha: 0.6),
                  ] : [
                    colors.secondaryContainer.withValues(alpha: 0.8),
                    colors.surfaceContainerHighest.withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? colors.primary.withValues(alpha: 0.15)
                          : colors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_circle_rounded : Icons.schedule_rounded,
                      color: isCompleted ? colors.primary : colors.secondary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tomato['name'] ?? 'Tomato',
                          style: textTheme.headlineMedium?.copyWith(
                            color: isCompleted ? colors.onPrimaryContainer : colors.onSecondaryContainer,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: (isCompleted ? colors.primary : colors.secondary).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${isCompleted ? "100.0" : "0.0"}% Completed',
                            style: textTheme.labelLarge?.copyWith(
                              color: isCompleted ? colors.primary : colors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Duration',
                      _formatDuration(widget.tomato['actualDuration'] ?? Duration(minutes: 25)),
                      Icons.timer_rounded,
                      colors.primary,
                      colors,
                      textTheme,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      'Efficiency',
                      '${(widget.tomato['efficiencyPercentage'] ?? 100.0).toStringAsFixed(1)}%',
                      Icons.speed_rounded,
                      (widget.tomato['efficiencyPercentage'] ?? 100.0) >= 90 ? colors.tertiary : colors.error,
                      colors,
                      textTheme,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, ColorScheme colors, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, ColorScheme colors, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: colors.primary,
              backgroundColor: colors.primary.withValues(alpha: 0.1),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading activities...',
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ColorScheme colors, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.errorContainer.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: colors.error,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to load activities',
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage!,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            onPressed: _loadActivities,
            style: FilledButton.styleFrom(
              backgroundColor: colors.primaryContainer,
              foregroundColor: colors.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesList(BuildContext context, ColorScheme colors, TextTheme textTheme) {
    if (activities.isEmpty) {
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
                Icons.timeline_rounded,
                color: colors.onSurfaceVariant,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No activities recorded',
              style: textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No activity data available for this tomato session',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.04),
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.secondaryContainer.withValues(alpha: 0.8),
                    colors.tertiaryContainer.withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.timeline_rounded,
                      color: colors.secondary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Activity Timeline",
                          style: textTheme.headlineSmall?.copyWith(
                            color: colors.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.25,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Chronological session events",
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSecondaryContainer.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${activities.length}',
                      style: textTheme.labelLarge?.copyWith(
                        color: colors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: activities.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _buildActivityItem(context, activities[index], index, colors, textTheme);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, dynamic activity, int index, ColorScheme colors, TextTheme textTheme) {
    final String actionType = _getActivityProperty(activity, 'actionType')?.toString() ?? 'Unknown';
    final String activityType = _getActivityProperty(activity, 'activityType')?.toString() ?? 'Unknown';
    final DateTime? createdAt = _getActivityProperty(activity, 'createdAt') as DateTime?;

    final IconData activityIcon = _getActivityIcon(actionType, activityType);
    final Color activityColor = _getActivityColor(actionType, activityType, colors);

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: activityColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                activityIcon,
                color: activityColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatActionType(actionType, activityType),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    createdAt != null
                        ? DateFormat('HH:mm:ss').format(createdAt.toLocal())
                        : 'Unknown time',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: activityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '#${index + 1}',
                style: textTheme.labelSmall?.copyWith(
                  color: activityColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(String actionType, String activityType) {
    final normalizedAction = actionType.toUpperCase().trim();
    final normalizedType = activityType.toUpperCase().trim();

    switch (normalizedAction) {
      case 'START':
        return normalizedType == 'TIMER'
            ? Icons.play_circle_filled_rounded
            : Icons.coffee_rounded;
      case 'END':
        return normalizedType == 'TIMER'
            ? Icons.stop_circle_rounded
            : Icons.play_circle_filled_rounded;
      case 'PAUSE':
        return Icons.pause_circle_outline_rounded;
      case 'RESUME':
        return Icons.play_circle_outline_rounded;
      default:
        return Icons.radio_button_checked_rounded;
    }
  }

  Color _getActivityColor(String actionType, String activityType, ColorScheme colors) {
    final normalizedAction = actionType.toUpperCase().trim();

    switch (normalizedAction) {
      case 'START':
        return colors.primary;
      case 'END':
        return colors.tertiary;
      case 'PAUSE':
        return colors.error;
      case 'RESUME':
        return colors.secondary;
      default:
        return colors.outline;
    }
  }

  String _formatActionType(String actionType, String activityType) {
    final normalizedAction = actionType.toUpperCase().trim();
    final normalizedType = activityType.toUpperCase().trim();

    switch (normalizedAction) {
      case 'START':
        return normalizedType == 'TIMER'
            ? 'Timer Started'
            : 'Break Started';
      case 'END':
        return normalizedType == 'TIMER'
            ? 'Timer Completed'
            : 'Break Ended';
      case 'PAUSE':
        return 'Session Paused';
      case 'RESUME':
        return 'Session Resumed';
      default:
        // For debugging, show the actual values received
        print('WARN: Unknown actionType: "$actionType", activityType: "$activityType"');
        return 'Activity: $actionType';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
