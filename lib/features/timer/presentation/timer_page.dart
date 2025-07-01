import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ketchapp_flutter/models/tomato.dart';
import 'package:ketchapp_flutter/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart';

import '../bloc/timer_bloc.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authState = context.watch<AuthBloc>().state;

    if (authState is Authenticated) {
      return FutureBuilder<List<Tomato>>(
        future: apiService.getTodaysTomatoes(authState.userUuid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('No tomatoes for today!')),
            );
          } else {
            final tomatoes = snapshot.data!;
            return TimerView(tomatoes: tomatoes);
          }
        },
      );
    } else {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}

class TimerView extends StatefulWidget {
  final List<Tomato> tomatoes;
  const TimerView({super.key, required this.tomatoes});

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  int _currentTomatoIndex = 0;
  int _currentPomodoroIndex = 0;
  late TimerBloc _timerBloc;

  @override
  void initState() {
    super.initState();
    _createNewBloc();
  }

  void _createNewBloc() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _timerBloc = TimerBloc(
        apiService: apiService,
        userUUID: authState.userUuid,
        tomatoId: widget.tomatoes[_currentTomatoIndex].id,
      );
    }
  }

  @override
  void dispose() {
    _timerBloc.close();
    super.dispose();
  }

  /*
  void _onTomatoSelected(int index) {
    setState(() {
      _currentTomatoIndex = index;
      _currentPomodoroIndex = 0;
      _timerBloc.close();
      _createNewBloc();
    });
  }
  */

  String formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final currentTomato = widget.tomatoes[_currentTomatoIndex];
    final numPomodoros = 1; // Default to 1 if not available
    // Calcola la pausa in minuti tra endAt e pauseEnd (se pauseEnd esiste)
    int pauseMinutes = 0;
    if (currentTomato.pauseEnd != null) {
      pauseMinutes = currentTomato.endAt.difference(currentTomato.pauseEnd!).inMinutes;
      if (pauseMinutes < 0) pauseMinutes = 0;
    }
    final totalDurationInSeconds =
        currentTomato.endAt.difference(currentTomato.startAt).inSeconds;

    int pomodoroDurationSeconds;
    int breakDurationInSeconds;

    if (currentTomato.pauseEnd != null &&
        currentTomato.pauseEnd!.isBefore(currentTomato.endAt) &&
        numPomodoros > 0) {
      pomodoroDurationSeconds =
          currentTomato.endAt.difference(currentTomato.pauseEnd!).inSeconds;

      final totalPomodorosDuration = pomodoroDurationSeconds * numPomodoros;
      final totalBreaksDuration =
          totalDurationInSeconds - totalPomodorosDuration;

      if (numPomodoros > 1) {
        breakDurationInSeconds = (totalBreaksDuration / (numPomodoros - 1)).round();
        if (breakDurationInSeconds < 0) {
          breakDurationInSeconds = 0;
        }
      } else {
        breakDurationInSeconds = 0;
      }
    } else {
      // Fallback to old logic if pauseEnd is not available or invalid
      breakDurationInSeconds = pauseMinutes * 60;
      final totalBreakDurationInSeconds =
          (numPomodoros > 1 ? numPomodoros - 1 : 0) * breakDurationInSeconds;
      pomodoroDurationSeconds = numPomodoros > 0
          ? ((totalDurationInSeconds - totalBreakDurationInSeconds) /
          numPomodoros)
          .round()
          .clamp(0, totalDurationInSeconds)
          : 0;
    }

    return BlocProvider.value(
      value: _timerBloc,
      child: BlocListener<TimerBloc, TimerState>(
        listener: (context, state) {
          if (state is SessionComplete) {
            if (_currentTomatoIndex < widget.tomatoes.length - 1) {
              setState(() {
                _currentTomatoIndex++;
                _currentPomodoroIndex = 0;
                _timerBloc.close();
                _createNewBloc();
              });
            }
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 40,
                  child: Center(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.tomatoes.length,
                      itemBuilder: (context, index) {
                        final isCompleted = index < _currentTomatoIndex;
                        final isCurrent = index == _currentTomatoIndex;

                        return Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted || isCurrent
                                ? Colors.red
                                : Colors.transparent,
                            border: Border.all(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentTomato.subject,
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.schedule,
                                size: 18, color: colors.onSurfaceVariant),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.tomatoes.length} sessioni',
                              style: theme.textTheme.bodyLarge,
                            ),
                            const Spacer(),
                            Icon(Icons.local_cafe_outlined,
                                size: 18, color: colors.onSurfaceVariant),
                            const SizedBox(width: 8),
                            Text(
                              '$pauseMinutes min pause',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                          List.generate(numPomodoros, (i) {
                            return Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: i < _currentPomodoroIndex
                                    ? colors.primary
                                    : i == _currentPomodoroIndex
                                        ? colors.primary // No opacity for now
                                        : colors.surfaceContainerHighest,
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BlocBuilder<TimerBloc, TimerState>(
                        builder: (context, state) {
                          final duration =
                          (state is WaitingFirstTomato || state is WaitingNextTomato)
                              ? pomodoroDurationSeconds
                              : state.duration;
                          return Text(
                            formatTimer(duration),
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      BlocBuilder<TimerBloc, TimerState>(
                        builder: (context, state) {
                          final bloc = context.read<TimerBloc>();
                          if (state is WaitingFirstTomato ||
                              state is WaitingNextTomato) {
                            return ElevatedButton.icon(
                              onPressed: () => bloc.add(TimerStarted(
                                  tomatoDuration: pomodoroDurationSeconds,
                                  breakDuration: breakDurationInSeconds)),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('START'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primary,
                                foregroundColor: colors.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                textStyle: theme.textTheme.titleLarge,
                              ),
                            );
                          } else if (state is TomatoTimerInProgress ||
                              state is BreakTimerInProgress) {
                            return ElevatedButton.icon(
                              onPressed: () => bloc.add(const TimerPaused()),
                              icon: const Icon(Icons.pause),
                              label: const Text('PAUSE'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primary,
                                foregroundColor: colors.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                textStyle: theme.textTheme.titleLarge,
                              ),
                            );
                          } else if (state is TomatoTimerPaused ||
                              state is BreakTimerPaused) {
                            return ElevatedButton.icon(
                              onPressed: () => bloc.add(const TimerResumed()),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('RESUME'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primary,
                                foregroundColor: colors.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                textStyle: theme.textTheme.titleLarge,
                              ),
                            );
                          } else if (state is SessionComplete) {
                            return Text(
                              "Well done!",
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(color: colors.secondary),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
