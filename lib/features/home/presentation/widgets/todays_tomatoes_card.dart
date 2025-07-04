import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:ketchapp_flutter/models/tomato.dart';
import 'package:ketchapp_flutter/services/api_service.dart';

class TodaysTomatoesCard extends StatefulWidget {
  const TodaysTomatoesCard({super.key});

  @override
  State<TodaysTomatoesCard> createState() => _TodaysTomatoesCardState();
}

class _TodaysTomatoesCardState extends State<TodaysTomatoesCard>
    with TickerProviderStateMixin {
  late Future<List<Tomato>> _tomatoesFuture;
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 1) {
      return "less than a minute";
    }
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    var parts = <String>[];
    if (hours > 0) {
      parts.add('$hours hour${hours > 1 ? 's' : ''}');
    }
    if (minutes > 0) {
      parts.add('$minutes minute${minutes > 1 ? 's' : ''}');
    }
    return parts.join(' and ');
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _tomatoesFuture = ApiService().getTodaysTomatoes(authState.userUuid);
    } else {
      _tomatoesFuture = Future.value([]);
    }
  }

  void _initializeAnimation() {
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));
    _pulseAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          setState(() {
            _tomatoesFuture = ApiService()
                .getTodaysTomatoes(state.userUuid)
                .then((tomatoes) {
              final uniqueSubjects = <String, Tomato>{};
              for (final tomato in tomatoes) {
                uniqueSubjects[tomato.subject] = tomato;
              }
              return uniqueSubjects.values.toList();
            });
          });
        }
      },
      child: FutureBuilder<List<Tomato>>(
        future: _tomatoesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState(context);
          } else if (snapshot.hasError) {
            return _buildErrorState(context, snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(context);
          } else {
            return _buildTomatoesList(context, snapshot.data!);
          }
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: colors.primary,
              backgroundColor: colors.primary.withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your schedule...',
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.errorContainer.withOpacity(0.8),
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
            'Unable to load schedule',
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.surfaceContainerHighest,
                  colors.surfaceContainerHigh,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.schedule_outlined,
              color: colors.onSurfaceVariant,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No sessions today',
            style: textTheme.headlineSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Create your first focus session to get started',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTomatoesList(BuildContext context, List<Tomato> tomatoes) {
    final uniqueSubjects = <String, Tomato>{};
    for (final tomato in tomatoes) {
      uniqueSubjects[tomato.subject] = tomato;
    }
    final filteredTomatoes = uniqueSubjects.values.toList();
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredTomatoes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        final tomato = filteredTomatoes[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.surfaceContainerHighest.withOpacity(0.92),
                colors.surfaceContainerHigh.withOpacity(0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withOpacity(0.10),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: colors.primary.withOpacity(0.13),
              width: 1.4,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.book_rounded, color: Colors.red, size: 30),
            ),
            title: Text(
              tomato.subject,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
                letterSpacing: -0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 18, color: colors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Start: ${TimeOfDay.fromDateTime(tomato.startAt.toLocal()).format(context)}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios_rounded, color: colors.primary, size: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            onTap: () {
              context.go('/timer/${tomato.id}');
            },
          ),
        );
      },
    );
  }

  void _showStartDialog(BuildContext context, Tomato nextTomato, DateTime now) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isEarly = now.isBefore(nextTomato.startAt);
    final isLate = now.isAfter(nextTomato.startAt);

    Duration difference;
    if (isEarly) {
      difference = nextTomato.startAt.difference(now);
    } else {
      difference = now.difference(nextTomato.startAt);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.rocket_launch_outlined,
                  color: colors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Start Session',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready to focus on:',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      nextTomato.subject,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              if (isEarly || isLate) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isEarly ? colors.tertiaryContainer : colors.errorContainer).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isEarly ? Icons.schedule_outlined : Icons.warning_amber_rounded,
                        color: isEarly ? colors.tertiary : colors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: isEarly ? 'You are ' : 'You are ',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: _formatDuration(difference),
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isEarly ? colors.tertiary : colors.error,
                                ),
                              ),
                              TextSpan(
                                text: isEarly ? ' early' : ' late',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: colors.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Now'),
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/timer');
              },
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
