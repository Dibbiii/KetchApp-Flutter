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
  late TimerBloc _timerBloc;

  @override
  void initState() {
    super.initState();
    _createNewBloc();
    _timerBloc.add(TimerLoaded(
      tomatoDuration: _getPomodoroDuration(),
      breakDuration: _getBreakDuration(),
    ));
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
    _timerBloc.add(const TimerPaused());
    _timerBloc.close();
    super.dispose();
  }


  void _onTomatoSelected(int index) {
    setState(() {
      _currentTomatoIndex = index;
      _currentPomodoroIndex = 0;
      _timerBloc.close();
      _createNewBloc();
      _timerBloc.add(TimerLoaded(
        tomatoDuration: _getPomodoroDuration(),
        breakDuration: _getBreakDuration(),
      ));
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final currentTomato = widget.tomatoes[_currentTomatoIndex];
    final pomodoroDurationSeconds = _getPomodoroDuration();
    final breakDurationInSeconds = _getBreakDuration();

    return BlocProvider.value(
      value: _timerBloc,
      child: BlocListener<TimerBloc, TimerState>(
        listener: (context, state) {
          if (state is WaitingNextTomato) {
            final nextIndex = widget.tomatoes
                .indexWhere((tomato) => tomato.id == state.nextTomatoId);
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
                SizedBox(
                  height: 80,
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.tomatoes.length * 2 - 1,
                            itemBuilder: (context, index) {
                              if (index.isOdd) {
                                final tomatoIndex = index ~/ 2;
                                final tomato = widget.tomatoes[tomatoIndex];
                                final breakDuration = _getBreakDuration();
                                final breakStartTime = tomato.endAt;
                                final breakEndTime = breakStartTime.add(Duration(seconds: breakDuration));
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.local_cafe_outlined, color: Colors.grey, size: 24),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${DateFormat.Hms().format(breakStartTime)} - ${DateFormat.Hms().format(breakEndTime)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        '(${formatTimer(breakDuration)})',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              final tomatoIndex = index ~/ 2;
                              final tomato = widget.tomatoes[tomatoIndex];
                              final isCompleted = tomatoIndex < _currentTomatoIndex;
                              final isCurrent = tomatoIndex == _currentTomatoIndex;

                              return InkWell(
                                onTap: () => _onTomatoSelected(tomatoIndex),
                                borderRadius: BorderRadius.circular(20),
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: isCurrent ? 30 : 24,
                                          height: isCurrent ? 30 : 24,
                                          margin:
                                              const EdgeInsets.symmetric(horizontal: 4),
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
                                              ? Icon(Icons.check, color: colors.onPrimary, size: 16)
                                              : null,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${DateFormat('HH:mm').format(tomato.startAt)} - ${DateFormat('HH:mm').format(tomato.endAt)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isCurrent ? Colors.red : Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          'ID: ${tomato.id}',
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: isCurrent ? Colors.red : Colors.grey,
                                          ),
                                        ),
                                        if (tomato.nextTomatoId != null)
                                          Text(
                                            'Next ID: ${tomato.nextTomatoId}',
                                            style: TextStyle(
                                              fontSize: 8,
                                              color: isCurrent ? Colors.red : Colors.grey,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      BlocBuilder<TimerBloc, TimerState>(
                        builder: (context, state) {
                          final isBreak =
                              state is BreakTimerInProgress || state is BreakTimerPaused;
                          final totalDuration = isBreak
                              ? breakDurationInSeconds
                              : pomodoroDurationSeconds;

                          final duration = (state is WaitingFirstTomato ||
                                  state is WaitingNextTomato ||
                                  state is TomatoTimerReady)
                              ? totalDuration
                              : state.duration;

                          final progress = totalDuration > 0 ? duration / totalDuration : 1.0;

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
                          final bloc = context.read<TimerBloc>();
                          if (state is WaitingFirstTomato ||
                              state is WaitingNextTomato ||
                              state is TomatoTimerReady) {
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
        ),
      )
    );
  }
}
