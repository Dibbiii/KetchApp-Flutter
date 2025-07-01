import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ketchapp_flutter/models/tomato.dart';
import 'package:ketchapp_flutter/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:ketchapp_flutter/models/activity.dart';

import '../bloc/timer_bloc.dart';
import 'widgets/skip_timer_button.dart';

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
            tomatoes.sort((a, b) => a.id.compareTo(b.id));
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onTomatoSelected(int index) {
    setState(() {
      _currentTomatoIndex = index;
      _currentPomodoroIndex = 0;
    });
  }

  String formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int _getPomodoroDuration() {
    final currentTomato = widget.tomatoes[_currentTomatoIndex];
    print('TOMATO: start_at: ${currentTomato.startAt}, end_at: ${currentTomato.endAt}, pause_end: ${currentTomato.pauseEnd}');

    // The duration of the pomodoro is the difference between its end and start times.
    final duration = currentTomato.endAt.difference(currentTomato.startAt).inSeconds;
    return duration > 0 ? duration : 0;
  }

  int _getBreakDuration() {
    final currentTomato = widget.tomatoes[_currentTomatoIndex];

    // The break duration is the difference between the pause end time and the pomodoro end time.
    if (currentTomato.pauseEnd != null) {
      final duration = currentTomato.pauseEnd!.difference(currentTomato.endAt).inSeconds;
      return duration > 0 ? duration : 0;
    }
    return 0;
  }

  int _getBreakDurationForTomato(Tomato tomato) {
    if (tomato.pauseEnd != null) {
      final duration = tomato.pauseEnd!.difference(tomato.endAt).inSeconds;
      return duration > 0 ? duration : 0;
    }
    return 0;
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
          bloc.add(TimerLoaded(
            tomatoDuration: pomodoroDurationSeconds,
            breakDuration: breakDurationInSeconds,
          ));
          return bloc;
        }
        throw Exception('User not authenticated');
      },
      child: BlocListener<TimerBloc, TimerState>(
        listener: (context, state) {
          if (state is WaitingNextTomato) {
            final nextIndex = widget.tomatoes
                .indexWhere((tomato) => tomato.id == state.nextTomatoId);
            if (nextIndex != -1) {
              _onTomatoSelected(nextIndex);
            }
          } else if (state is TomatoSwitched) {
            // Nuovo listener per gestire il cambio automatico di tomato
            final nextIndex = widget.tomatoes
                .indexWhere((tomato) => tomato.id == state.newTomatoId);
            if (nextIndex != -1) {
              _onTomatoSelected(nextIndex);
            }
          } else if (state is SessionComplete) {
            // This case might be redundant if WaitingNextTomato handles all transitions.
            // However, keeping it as a fallback.
            final nextTomatoIndex = _currentTomatoIndex + 1;
            if (nextTomatoIndex < widget.tomatoes.length) {
              _onTomatoSelected(nextTomatoIndex);
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('${currentTomato.subject} #${currentTomato.id}'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/home', (Route<dynamic> route) => false);
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TomatoTimeline(
                  tomatoes: widget.tomatoes,
                  currentTomatoIndex: _currentTomatoIndex,
                  onTomatoSelected: _onTomatoSelected,
                  getBreakDurationForTomato: _getBreakDurationForTomato,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      BlocBuilder<TimerBloc, TimerState>(
                        builder: (context, state) {
                          print('BlocBuilder rebuilding with state: ${state.runtimeType}, duration: ${state.duration}');

                          final isBreak =
                              state is BreakTimerInProgress || state is BreakTimerPaused;
                          final totalDuration = isBreak
                              ? breakDurationInSeconds
                              : pomodoroDurationSeconds;

                          // Usa sempre la durata dallo stato del bloc, non ricalcolarla
                          final duration = state.duration;

                          final progress = totalDuration > 0 ? (totalDuration - duration) / totalDuration : 0.0;

                          print('Progress calculation: duration=$duration, totalDuration=$totalDuration, progress=$progress');

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 250,
                                height: 250,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 12,
                                  backgroundColor: colors.surface.withOpacity(0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isBreak ? Colors.green.shade300 : colors.primary,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isBreak) ...[
                                    Icon(Icons.local_cafe,
                                        size: 40, color: Colors.green.shade300),
                                    const SizedBox(height: 10),
                                  ],
                                  Text(
                                    formatTimer(duration),
                                    style: theme.textTheme.displayLarge?.copyWith(
                                      fontSize: 80,
                                      fontWeight: FontWeight.bold,
                                      color: colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      BlocBuilder<TimerBloc, TimerState>(
                        builder: (context, state) {
                          print('Button BlocBuilder rebuilding with state: ${state.runtimeType}');

                          final bloc = context.read<TimerBloc>();
                          if (state is WaitingFirstTomato ||
                              state is WaitingNextTomato ||
                              state is TomatoTimerReady) {
                            print('Showing START button');
                            return ElevatedButton.icon(
                              onPressed: () => bloc.add(const TimerStarted()),
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
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: const SkipTimerButton(),
        ),
      )
    );
  }
}

class _TomatoTimeline extends StatelessWidget {
  final List<Tomato> tomatoes;
  final int currentTomatoIndex;
  final Function(int) onTomatoSelected;
  final int Function(Tomato) getBreakDurationForTomato;

  const _TomatoTimeline({
    required this.tomatoes,
    required this.currentTomatoIndex,
    required this.onTomatoSelected,
    required this.getBreakDurationForTomato,
  });

  String formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      height: 120,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemCount: tomatoes.length,
        itemBuilder: (context, index) {
          final tomato = tomatoes[index];
          final isCompleted = index < currentTomatoIndex;
          final isCurrent = index == currentTomatoIndex;
          final breakDuration = getBreakDurationForTomato(tomato);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => onTomatoSelected(index),
                    borderRadius: BorderRadius.circular(30),
                    child: Column(
                      children: [
                        Container(
                          width: isCurrent ? 30 : 24,
                          height: isCurrent ? 30 : 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted
                                ? colors.primary
                                : isCurrent
                                    ? colors.primary.withOpacity(0.3)
                                    : Colors.transparent,
                            border: Border.all(
                              color: colors.primary,
                              width: isCurrent ? 2 : 1,
                            ),
                          ),
                          child: isCompleted
                              ? Icon(Icons.check,
                                  color: colors.onPrimary, size: 16)
                              : null,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('HH:mm').format(tomato.startAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isCurrent ? colors.primary : Colors.grey,
                          ),
                        ),
                        Text(
                          '${DateFormat('HH:mm').format(tomato.endAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isCurrent ? colors.primary : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (index < tomatoes.length - 1)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 1,
                      color: Colors.grey.shade300,
                      margin: const EdgeInsets.only(top: 14, left: 8, right: 8),
                    ),
                    if (breakDuration > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.local_cafe_outlined,
                                color: Colors.grey, size: 20),
                            const SizedBox(height: 2),
                            Text(
                              formatTimer(breakDuration),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (breakDuration > 0)
                      Container(
                        width: 40,
                        height: 1,
                        color: Colors.grey.shade300,
                        margin: const EdgeInsets.only(top: 14, left: 8, right: 8),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
