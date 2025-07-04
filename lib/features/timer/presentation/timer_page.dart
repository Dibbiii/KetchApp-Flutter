import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ketchapp_flutter/models/tomato.dart';
import 'package:ketchapp_flutter/services/api_service.dart';
import 'package:ketchapp_flutter/services/session_stats_service.dart';
import 'package:provider/provider.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart';

import '../bloc/timer_bloc.dart';
import 'tomato_activity_details_page.dart';

class TimerPage extends StatelessWidget {
  final int? tomatoId;

  const TimerPage({super.key, required this.tomatoId});

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    if (tomatoId == null) {
      return _buildErrorState(context, 'No tomatoId provided');
    }
    return FutureBuilder<List<Tomato>>(
      future: apiService.getTomatoChain(tomatoId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(context);
        } else if (snapshot.hasError) {
          return _buildErrorState(context, snapshot.error.toString());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(context);
        } else {
          final tomatoes = snapshot.data!;
          return TimerView(tomatoes: tomatoes);
        }
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.primary.withValues(alpha: 0.08),
              colors.primaryContainer.withValues(alpha: 0.05),
              colors.surface,
              colors.secondaryContainer.withValues(alpha: 0.03),
              colors.tertiaryContainer.withValues(alpha: 0.02),
            ],
            stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.primary.withValues(alpha: 0.15),
                      colors.primaryContainer.withValues(alpha: 0.2),
                      colors.surfaceContainerHigh.withValues(alpha: 0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.3),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                      spreadRadius: -5,
                    ),
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: 0.15),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  color: colors.primary,
                  backgroundColor: colors.primary.withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.surfaceContainerHigh.withValues(alpha: 0.9),
                      colors.surfaceContainerHighest.withValues(alpha: 0.7),
                      colors.primaryContainer.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Caricamento sessione...',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Preparando i tuoi pomodori',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.errorContainer.withValues(alpha: 0.3),
              colors.surface,
              colors.surfaceContainerHighest.withValues(alpha: 0.4),
              colors.errorContainer.withValues(alpha: 0.1),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.errorContainer.withValues(alpha: 0.9),
                        colors.errorContainer.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: colors.error.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: colors.shadow.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: colors.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.surfaceContainerHigh.withValues(alpha: 0.8),
                        colors.surfaceContainerHighest.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colors.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Errore nel caricamento',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        error,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.primary,
                        colors.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Torna alla Home'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primaryContainer.withValues(alpha: 0.4),
              colors.secondaryContainer.withValues(alpha: 0.3),
              colors.surface,
              colors.tertiaryContainer.withValues(alpha: 0.2),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.surfaceContainerHigh.withValues(alpha: 0.9),
                        colors.surfaceContainerHighest.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: colors.shadow.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.schedule_rounded,
                    size: 64,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.surfaceContainerHigh.withValues(alpha: 0.8),
                        colors.surfaceContainerHighest.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colors.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Nessun pomodoro oggi',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Non hai pianificato pomodori per oggi.\nPianifica la tua sessione per iniziare!',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.primary,
                        colors.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Pianifica Sessione'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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
}

class TimerView extends StatefulWidget {
  final List<Tomato> tomatoes;

  const TimerView({super.key, required this.tomatoes});

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> with TickerProviderStateMixin {
  int _currentTomatoIndex = 0;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  TimerBloc? _timerBloc;
  bool _whiteNoiseEnabled = false;
  AudioPlayer? _audioPlayer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timerBloc = context.read<TimerBloc?>();
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    // Put timer in pause when leaving the page
    if (_timerBloc != null) {
      _timerBloc!.add(const TimerPaused());
    }
    _pulseController.dispose();
    _fadeController.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  void _onTomatoSelected(int index) {
    setState(() {
      _currentTomatoIndex = index;
    });
  }

  // New function to navigate to tomato activity details
  void _onTomatoClicked(BuildContext context, Tomato tomato) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => TomatoActivityDetailsPage(
              tomato: tomato,
              apiService: apiService,
            ),
      ),
    );
  }

  Future<void> _navigateToSummary(
    BuildContext context,
    List<int> completedTomatoIds,
  ) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final sessionStatsService = SessionStatsService(apiService);
      final sessionSummary = await sessionStatsService.calculateSessionStats(
        completedTomatoIds,
      );
    } catch (e) {
      // Optionally handle error
    }
  }

  Future<void> _toggleWhiteNoise(bool enable) async {
    if (enable) {
      _audioPlayer ??= AudioPlayer();
      await _audioPlayer!.setReleaseMode(ReleaseMode.loop);
      if (kIsWeb) {
        // Use a .wav file for web compatibility and loop manually
        await _audioPlayer!.play(AssetSource('audio/music_web.wav'));
        _audioPlayer!.onPlayerComplete.listen((event) async {
          if (_whiteNoiseEnabled) {
            await _audioPlayer!.seek(Duration.zero);
            await _audioPlayer!.resume();
          }
        });
      } else {
        await _audioPlayer!.play(AssetSource('audio/music.mp3'));
      }
    } else {
      await _audioPlayer?.stop();
    }
  }

  // --- Pomodoro and Break Duration Helpers ---
  int _getPomodoroDuration() {
    // Default Pomodoro duration: 25 minutes
    return 25 * 60;
  }

  int _getBreakDuration() {
    // Default break duration: 5 minutes
    return 5 * 60;
  }

  int _getBreakDurationForTomato(Tomato tomato) {
    // You can customize this logic per tomato if needed
    return _getBreakDuration();
  }

  String formatTimer(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final currentTomato = widget.tomatoes[_currentTomatoIndex];
    final pomodoroDurationSeconds = _getPomodoroDuration();
    final breakDurationInSeconds = _getBreakDuration();

    return BlocProvider<TimerBloc>(
      create: (context) {
        final apiService = Provider.of<ApiService>(context, listen: false);
        final authState = context.read<AuthBloc>().state;
        if (authState is Authenticated) {
          final bloc = TimerBloc(
            apiService: apiService,
            userUUID: authState.userUuid,
            tomatoId: widget.tomatoes[_currentTomatoIndex].id,
          );
          bloc.add(
            TimerLoaded(
              tomatoDuration: pomodoroDurationSeconds,
              breakDuration: breakDurationInSeconds,
            ),
          );
          return bloc;
        }
        // Show an error widget if not authenticated
        throw FlutterError(
          'User not authenticated. Please log in to continue.',
        );
      },
      child: BlocListener<TimerBloc, TimerState>(
        listener: _handleTimerStateChanges,
        child: Scaffold(
          backgroundColor: colors.surface,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.primary.withValues(alpha: 0.06),
                  colors.primaryContainer.withValues(alpha: 0.04),
                  colors.surface,
                  colors.secondaryContainer.withValues(alpha: 0.02),
                  colors.tertiaryContainer.withValues(alpha: 0.01),
                ],
                stops: const [0.0, 0.25, 0.5, 0.8, 1.0],
              ),
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context, currentTomato, colors, theme),
                    const SizedBox(height: 24),
                    Expanded(
                      child: _buildTimerSection(
                        context,
                        pomodoroDurationSeconds,
                        breakDurationInSeconds,
                        colors,
                        theme,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: null,
        ),
      ),
    );
  }

  void _handleTimerStateChanges(BuildContext context, TimerState state) {
    print('🔄 Timer state changed to: ${state.runtimeType}');
    print('   Duration: ${state.duration} seconds');

    switch (state.runtimeType) {
      case WaitingNextTomato:
        _handleNextTomato(state as WaitingNextTomato);
        break;
      case TomatoSwitched:
        _handleTomatoSwitch(state as TomatoSwitched);
        break;
      case WaitingForScheduledTime:
        _handleScheduledWait(state as WaitingForScheduledTime);
        break;
      case NavigatingToSummary:
        _handleNavigationToSummary(context, state as NavigatingToSummary);
        break;
      case BreakTimerInProgress:
        print(
          '🟢 Break timer started with ${state.duration} seconds and nextTomatoId: ${(state as BreakTimerInProgress).nextTomatoId}',
        );
        break;
      case TimerError:
        print('❌ Timer error: ${(state as dynamic).message}');
        break;
    }
  }

  void _handleNextTomato(WaitingNextTomato state) {
    final nextIndex = widget.tomatoes.indexWhere(
      (tomato) => tomato.id == state.nextTomatoId,
    );
    if (nextIndex != -1) {
      _onTomatoSelected(nextIndex);
    }
  }

  void _handleTomatoSwitch(TomatoSwitched state) {
    final nextIndex = widget.tomatoes.indexWhere(
      (tomato) => tomato.id == state.newTomatoId,
    );
    if (nextIndex != -1) {
      _onTomatoSelected(nextIndex);
    }
  }

  void _handleScheduledWait(WaitingForScheduledTime state) {
    final nextIndex = widget.tomatoes.indexWhere(
      (tomato) => tomato.id == state.nextTomatoId,
    );
    if (nextIndex != -1) {
      _onTomatoSelected(nextIndex);
    }
  }

  void _handleNavigationToSummary(
    BuildContext context,
    NavigatingToSummary state,
  ) {
    // Naviga direttamente alla pagina di riepilogo usando il primo tomatoId completato
    if (state.completedTomatoIds.isNotEmpty) {
      final firstTomatoId = state.completedTomatoIds.first;
      GoRouter.of(context).go('/timer-summary/$firstTomatoId');
    }
  }

  Widget _buildHeader(
    BuildContext context,
    Tomato currentTomato,
    ColorScheme colors,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surfaceContainerHigh.withValues(alpha: 0.95),
            colors.surfaceContainerHighest.withValues(alpha: 0.8),
            colors.primaryContainer.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.primary.withValues(alpha: 0.2),
                      colors.primary.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.psychology_outlined,
                  color: colors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Focus Session',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentTomato.subject,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        fontSize: 18,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Unificata la timeline qui
          _ModernTomatoTimeline(
            tomatoes: widget.tomatoes,
            currentTomatoIndex: _currentTomatoIndex,
            onTomatoSelected: _onTomatoSelected,
            onTomatoClicked: _onTomatoClicked,
            getBreakDurationForTomato: _getBreakDurationForTomato,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primaryContainer.withValues(alpha: 0.8),
                  colors.primaryContainer.withValues(alpha: 0.6),
                  colors.secondaryContainer.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatChip(
                      'Durata',
                      '${_getPomodoroDuration() ~/ 60} min',
                      Icons.timer_rounded,
                      colors.primary,
                      colors,
                      theme,
                    ),
                    _buildStatChip(
                      'Pausa',
                      '${_getBreakDuration() ~/ 60} min',
                      Icons.local_cafe_rounded,
                      colors.tertiary,
                      colors,
                      theme,
                    ),
                    _buildStatChip(
                      'Totale',
                      '${widget.tomatoes.length}',
                      Icons.spa_rounded,
                      colors.secondary,
                      colors,
                      theme,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.surround_sound, color: colors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('Rumore bianco', style: theme.textTheme.bodyMedium),
                    const SizedBox(width: 8),
                    Switch(
                      value: _whiteNoiseEnabled,
                      onChanged: (val) async {
                        setState(() {
                          _whiteNoiseEnabled = val;
                        });
                        await _toggleWhiteNoise(val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    ColorScheme colors,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.onPrimaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.onPrimaryContainer.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerSection(
    BuildContext context,
    int pomodoroDurationSeconds,
    int breakDurationInSeconds,
    ColorScheme colors,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: _buildTimerDisplay(
              context,
              pomodoroDurationSeconds,
              breakDurationInSeconds,
              colors,
              theme,
            ),
          ),
          const SizedBox(height: 32),
          _buildTimerControls(context, colors, theme),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(
    BuildContext context,
    int pomodoroDurationSeconds,
    int breakDurationInSeconds,
    ColorScheme colors,
    ThemeData theme,
  ) {
    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        final isBreak =
            state is BreakTimerInProgress || state is BreakTimerPaused;
        final totalDuration =
            isBreak ? breakDurationInSeconds : pomodoroDurationSeconds;
        final duration = state.duration;
        final progress =
            totalDuration > 0
                ? (totalDuration - duration) / totalDuration
                : 0.0;

        if (state is TomatoTimerInProgress || state is BreakTimerInProgress) {
          _pulseController.repeat(reverse: true);
        } else {
          _pulseController.stop();
        }

        return Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    isBreak
                        ? [
                          colors.tertiaryContainer.withValues(alpha: 0.9),
                          colors.tertiaryContainer.withValues(alpha: 0.7),
                          colors.surfaceContainerHigh.withValues(alpha: 0.5),
                        ]
                        : [
                          colors.primaryContainer.withValues(alpha: 0.9),
                          colors.primaryContainer.withValues(alpha: 0.7),
                          colors.surfaceContainerHigh.withValues(alpha: 0.5),
                        ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: (isBreak ? colors.tertiary : colors.primary).withValues(
                  alpha: 0.2,
                ),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isBreak ? colors.tertiary : colors.primary)
                      .withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                  spreadRadius: -1,
                ),
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isBreak) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ), // ancora più compatto
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors.tertiary.withValues(alpha: 0.2),
                          colors.tertiary.withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6), // più compatto
                      border: Border.all(
                        color: colors.tertiary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_cafe_rounded,
                          size: 9, // più piccolo
                          color: colors.tertiary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Pausa ${breakDurationInSeconds ~/ 60}min',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onTertiaryContainer,
                            fontWeight: FontWeight.w600,
                            fontSize: 8, // più piccolo
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6), // meno spazio
                ],
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale:
                          state is TomatoTimerInProgress ||
                                  state is BreakTimerInProgress
                              ? _pulseAnimation.value
                              : 1.0,
                      child: Container(
                        width: 130, // più piccolo
                        height: 130, // più piccolo
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colors.surface.withValues(alpha: 0.95),
                              colors.surfaceContainerHigh.withValues(
                                alpha: 0.8,
                              ),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadow.withValues(alpha: 0.08),
                              blurRadius: 10, // più compatto
                              offset: const Offset(0, 3),
                              spreadRadius: -2,
                            ),
                            BoxShadow(
                              color: (isBreak
                                      ? colors.tertiary
                                      : colors.primary)
                                  .withValues(alpha: 0.05),
                              blurRadius: 5, // più compatto
                              offset: const Offset(0, 2),
                              spreadRadius: -1,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 110, // più piccolo
                              height: 110, // più piccolo
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 5,
                                // più sottile
                                backgroundColor: colors.outlineVariant
                                    .withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isBreak ? colors.tertiary : colors.primary,
                                ),
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isBreak) ...[
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    // più compatto
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          colors.tertiary.withValues(
                                            alpha: 0.15,
                                          ),
                                          colors.tertiary.withValues(
                                            alpha: 0.1,
                                          ),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.local_cafe_rounded,
                                      size: 12, // più piccolo
                                      color: colors.tertiary,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                ],
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 80,
                                  ), // più stretto
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      formatTimer(duration),
                                      style: theme.textTheme.displaySmall
                                          ?.copyWith(
                                            fontSize: 22,
                                            // più piccolo
                                            fontWeight: FontWeight.w300,
                                            color:
                                                isBreak
                                                    ? colors.tertiary
                                                    : colors.primary,
                                            letterSpacing: -1.0,
                                            height: 1.0,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 1,
                                  ),
                                  // più compatto
                                  decoration: BoxDecoration(
                                    color: (isBreak
                                            ? colors.tertiaryContainer
                                            : colors.primaryContainer)
                                        .withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(
                                      3,
                                    ), // più compatto
                                  ),
                                  child: Text(
                                    'rimanenti',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colors.onSurface.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 7, // più piccolo
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerControls(
    BuildContext context,
    ColorScheme colors,
    ThemeData theme,
  ) {
    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        final bloc = context.read<TimerBloc>();

        return Column(
          children: [
            _buildPrimaryControl(context, state, bloc, colors, theme),
            const SizedBox(height: 16),
            _buildSecondaryInfo(context, state, colors, theme),
          ],
        );
      },
    );
  }

  Widget _buildPrimaryControl(
    BuildContext context,
    TimerState state,
    TimerBloc bloc,
    ColorScheme colors,
    ThemeData theme,
  ) {
    // Debug: stampiamo il tipo di stato ricevuto
    print('🎯 Current state in _buildPrimaryControl: ${state.runtimeType}');

    if (state is WaitingFirstTomato ||
        state is WaitingNextTomato ||
        state is TomatoTimerReady) {
      print('🎯 Showing start button');
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primary,
              colors.primary.withValues(alpha: 0.9),
              colors.primaryContainer.withValues(alpha: 0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FilledButton.icon(
          onPressed: () {
            HapticFeedback.mediumImpact();
            bloc.add(const TimerStarted());
          },
          icon: const Icon(Icons.play_arrow_rounded, size: 28),
          label: const Text('Inizia Focus'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: colors.onPrimary,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 20),
            textStyle: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      );
    }

    if (state is TomatoTimerInProgress) {
      print('🎯 Showing pause/skip buttons');
      return Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.secondaryContainer.withValues(alpha: 0.9),
                    colors.secondaryContainer.withValues(alpha: 0.7),
                    colors.surfaceContainerHigh.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.secondary.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.secondary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: -1,
                  ),
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: FilledButton.tonalIcon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  bloc.add(const TimerPaused());
                },
                icon: const Icon(Icons.pause_rounded, size: 24),
                label: const Text('Pausa'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: colors.onSecondaryContainer,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.tertiary.withValues(alpha: 0.9),
                    colors.tertiary.withValues(alpha: 0.7),
                    colors.tertiaryContainer.withValues(alpha: 0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.tertiary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.tertiary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: -1,
                  ),
                ],
              ),
              child: FilledButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  bloc.add(const TimerSkipToEnd());
                },
                icon: const Icon(Icons.skip_next_rounded, size: 24),
                label: const Text('Salta'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: colors.onTertiary,
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

    if (state is BreakTimerInProgress) {
      return Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.tertiaryContainer.withValues(alpha: 0.9),
                    colors.tertiaryContainer.withValues(alpha: 0.7),
                    colors.surfaceContainerHigh.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.tertiary.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.tertiary.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FilledButton.tonalIcon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  bloc.add(const TimerPaused());
                },
                icon: const Icon(Icons.pause_rounded, size: 24),
                label: const Text('Pausa'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: colors.onTertiaryContainer,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.tertiary,
                    colors.tertiary.withValues(alpha: 0.9),
                    colors.tertiaryContainer.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colors.tertiary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: -1,
                  ),
                ],
              ),
              child: FilledButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  bloc.add(const TimerSkipToEnd());
                },
                icon: const Icon(Icons.skip_next_rounded, size: 24),
                label: const Text('Salta'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: colors.onTertiary,
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

    if (state is TomatoTimerPaused) {
      print('🎯 Showing resume/skip buttons');
      return Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.primary,
                    colors.primary.withValues(alpha: 0.9),
                    colors.primaryContainer.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FilledButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  bloc.add(const TimerResumed());
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 24),
                label: const Text('Riprendi'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: colors.onPrimary,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.tertiary.withValues(alpha: 0.9),
                    colors.tertiary.withValues(alpha: 0.7),
                    colors.tertiaryContainer.withValues(alpha: 0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.tertiary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.tertiary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: -1,
                  ),
                ],
              ),
              child: FilledButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  bloc.add(const TimerSkipToEnd());
                },
                icon: const Icon(Icons.skip_next_rounded, size: 24),
                label: const Text('Salta'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: colors.onTertiary,
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

    if (state is SessionComplete) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.tertiaryContainer.withValues(alpha: 0.9),
              colors.tertiaryContainer.withValues(alpha: 0.7),
              colors.surfaceContainerHigh.withValues(alpha: 0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.tertiary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.tertiary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: -3,
            ),
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.tertiary.withValues(alpha: 0.2),
                    colors.tertiary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colors.tertiary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.celebration_rounded,
                size: 48,
                color: colors.tertiary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sessione Completata!',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colors.onTertiaryContainer,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Ben fatto! Hai completato tutti i pomodori.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onTertiaryContainer.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state is NavigatingToSummary) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primaryContainer.withValues(alpha: 0.9),
              colors.primaryContainer.withValues(alpha: 0.7),
              colors.surfaceContainerHigh.withValues(alpha: 0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary.withValues(alpha: 0.2),
                    colors.primary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: CircularProgressIndicator(
                color: colors.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Preparando il riepilogo...',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Caricamento statistiche sessione',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onPrimaryContainer.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    print('🎯 No matching state found, showing empty widget');
    return const SizedBox.shrink();
  }

  Widget _buildSecondaryInfo(
    BuildContext context,
    TimerState state,
    ColorScheme colors,
    ThemeData theme,
  ) {
    if (state is WaitingForScheduledTime) {
      final waitTime = state.remainingWaitTime;
      final formattedWaitTime = _formatDuration(waitTime);

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.secondaryContainer.withValues(alpha: 0.9),
              colors.secondaryContainer.withValues(alpha: 0.7),
              colors.surfaceContainerHigh.withValues(alpha: 0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.secondary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.secondary.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.secondary.withValues(alpha: 0.2),
                    colors.secondary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    color: colors.onSecondaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Prossimo pomodoro tra:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              formattedWaitTime,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSecondaryContainer,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Programmato: ${DateFormat('HH:mm').format(state.scheduledStartTime.toLocal())}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSecondaryContainer.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
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

class _ModernTomatoTimeline extends StatelessWidget {
  final List<Tomato> tomatoes;
  final int currentTomatoIndex;
  final Function(int) onTomatoSelected;
  final Function(BuildContext, Tomato) onTomatoClicked;
  final int Function(Tomato) getBreakDurationForTomato;

  const _ModernTomatoTimeline({
    required this.tomatoes,
    required this.currentTomatoIndex,
    required this.onTomatoSelected,
    required this.onTomatoClicked, // Add navigation callback
    required this.getBreakDurationForTomato,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 70, // Ensures ListView has a fixed height
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tomatoes.length,
            itemBuilder:
                (context, index) =>
                    _buildTomatoItem(context, tomatoes[index], index),
          ),
        ),
      ),
    );
  }

  Widget _buildTomatoItem(BuildContext context, Tomato tomato, int index) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isCompleted = index < currentTomatoIndex;
    final isCurrent = index == currentTomatoIndex;
    final breakDuration = getBreakDurationForTomato(tomato);

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () {
          // If it's a completed tomato, navigate to activity details
          if (isCompleted) {
            onTomatoClicked(context, tomato);
          } else {
            // For current or future tomatoes, just select them
            onTomatoSelected(index);
          }
        },
        child: SizedBox(
          width: 60, // Fixed width to prevent horizontal overflow
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isCurrent ? 28 : 24, // Further reduced to save space
                height: isCurrent ? 28 : 24,
                decoration: BoxDecoration(
                  color: _getTomatoColor(colors, isCompleted, isCurrent),
                  shape: BoxShape.circle,
                  boxShadow:
                      isCurrent
                          ? [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                          : null,
                ),
                child: _buildTomatoIcon(colors, isCompleted, isCurrent),
              ),
              const SizedBox(height: 3), // Further reduced spacing
              Flexible(
                child: Text(
                  DateFormat('HH:mm').format(tomato.startAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                    color:
                        isCurrent
                            ? colors.primary
                            : colors.onSurface.withValues(alpha: 0.7),
                    fontSize: 9, // Smaller font
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (breakDuration > 0 && index < tomatoes.length - 1) ...[
                const SizedBox(height: 1),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 0.5,
                    ),
                    decoration: BoxDecoration(
                      color: colors.tertiaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '${breakDuration ~/ 60}m',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 7, // Very small font for break duration
                        color: colors.onTertiaryContainer,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getTomatoColor(ColorScheme colors, bool isCompleted, bool isCurrent) {
    if (isCompleted) {
      return colors.primary;
    } else if (isCurrent) {
      return colors.primary;
    } else {
      return colors.outlineVariant.withValues(alpha: 0.5);
    }
  }

  Widget _buildTomatoIcon(
    ColorScheme colors,
    bool isCompleted,
    bool isCurrent,
  ) {
    if (isCompleted) {
      return Icon(
        Icons.check_rounded,
        size: isCurrent ? 24 : 20,
        color: colors.onPrimary,
      );
    } else {
      return Icon(
        Icons.schedule_rounded,
        size: isCurrent ? 24 : 20,
        color:
            isCurrent
                ? colors.onPrimary
                : colors.onSurface.withValues(alpha: 0.6),
      );
    }
  }
}
