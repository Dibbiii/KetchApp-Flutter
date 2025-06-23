import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ketchapp_flutter/models/tomato.dart';
import 'package:ketchapp_flutter/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart';

import '../bloc/timer_bloc.dart';

class TimerPage extends StatelessWidget {
  final String tomatoId;
  const TimerPage({super.key, required this.tomatoId});

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authState = context.watch<AuthBloc>().state;

    if (authState is Authenticated) {
      final tomatoIdInt = int.parse(tomatoId);
      return BlocProvider(
        create: (context) => TimerBloc(
          apiService: apiService,
          userUUID: authState.userUuid,
          tomatoId: tomatoIdInt,
        ),
        child: TimerView(tomatoId: tomatoId),
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
  final String tomatoId;
  const TimerView({super.key, required this.tomatoId});

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  late Future<Tomato> _tomatoFuture;

  final List<TimerAction> _actions = [];
  DateTime? _startTime;
  DateTime? _endTime;
  Timer? _rebuildTimer;

  @override
  void initState() {
    super.initState();
    _tomatoFuture = ApiService().getTomatoById(int.parse(widget.tomatoId));
  }

  @override
  void dispose() {
    _rebuildTimer?.cancel();
    super.dispose();
  }

  void _handleTimerAction(String type) {
    setState(() {
      _actions.insert(0, TimerAction(type: type, timestamp: DateTime.now()));
    });

    final bloc = context.read<TimerBloc>();
    switch (type) {
      case 'start':
        break;
      case 'pause':
        bloc.add(const TimerPaused());
        break;
      case 'resume':
        bloc.add(const TimerResumed());
        break;
      case 'end':
        bloc.add(const TimerFinished());
        break;
    }
  }

  String formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return FutureBuilder<Tomato>(
        future: _tomatoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasError) {
            return Scaffold(
                body: Center(child: Text('Error: ${snapshot.error}')));
          } else if (snapshot.hasData) {
            final tomato = snapshot.data!;
            var sessionDurationInSeconds =
                tomato.endAt.difference(tomato.startAt).inSeconds;

            if (sessionDurationInSeconds <= 0) {
              sessionDurationInSeconds = 1500; // 25 minutes
            }

            if (context.watch<TimerBloc>().state is TimerInitial) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                context
                    .read<TimerBloc>()
                    .add(TimerStarted(duration: sessionDurationInSeconds));
                setState(() {
                  _startTime = DateTime.now();
                  _actions.insert(
                      0, TimerAction(type: 'start', timestamp: _startTime!));
                });
              });
            }

            return BlocConsumer<TimerBloc, TimerState>(
              listener: (context, state) {
                if (state is TimerRunComplete) {
                  _rebuildTimer?.cancel();
                  setState(() {
                    _endTime = DateTime.now();
                  });
                } else if (state is! TimerRunPause) {
                  _rebuildTimer?.cancel();
                } else {
                  _rebuildTimer =
                      Timer.periodic(const Duration(seconds: 1), (timer) {
                    if (mounted) {
                      setState(() {});
                    }
                  });
                }
              },
              builder: (context, state) {
                final isPaused = state is TimerRunPause;
                final predictedEndTime =
                    DateTime.now().add(Duration(seconds: state.duration));
                final double progress = (sessionDurationInSeconds == 0)
                    ? 1.0
                    : 1 - (state.duration / sessionDurationInSeconds);

                TimerAction? lastPauseAction;
                try {
                  lastPauseAction =
                      _actions.firstWhere((a) => a.type == 'pause');
                } catch (e) {
                  lastPauseAction = null;
                }

                TimerAction? lastResumeAction;
                try {
                  lastResumeAction =
                      _actions.firstWhere((a) => a.type == 'resume');
                } catch (e) {
                  lastResumeAction = null;
                }
                return SafeArea(
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text(tomato.subject),
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                    ),
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.centerFloat,
                    floatingActionButton: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (state is! TimerRunComplete)
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: FloatingActionButton(
                              heroTag: "pause_resume",
                              onPressed: () {
                                if (isPaused) {
                                  _handleTimerAction('resume');
                                } else {
                                  _handleTimerAction('pause');
                                }
                              },
                              child: Icon(
                                  isPaused ? Icons.play_arrow : Icons.pause,
                                  size: 40),
                            ),
                          ),
                        const SizedBox(width: 24),
                        if (state is! TimerRunComplete)
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: FloatingActionButton(
                              heroTag: "end",
                              onPressed: () => _handleTimerAction('end'),
                              backgroundColor: Colors.red,
                              child: const Icon(Icons.stop, size: 40),
                            ),
                          ),
                        if (state is TimerRunComplete)
                          FloatingActionButton.extended(
                            heroTag: "done",
                            onPressed: () => context.go('/home'),
                            label: const Text('Done', style: TextStyle(fontSize: 20)),
                            icon: const Icon(Icons.check, size: 30),
                          ),
                      ],
                    ),
                    body: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 220,
                            height: 220,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 12,
                                  backgroundColor:
                                      colors.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      colors.primary),
                                ),
                                Center(
                                  child: Text(
                                    formatTimer(state.duration),
                                    style: textTheme.displayMedium?.copyWith(
                                        color: colors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures()
                                        ]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 24.0),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest
                                  .withAlpha(128),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                if (_startTime != null)
                                  Column(
                                    children: [
                                      Text('Started At',
                                          style: textTheme.titleSmall),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('HH:mm')
                                            .format(_startTime!),
                                        style: textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colors.primary),
                                      ),
                                      Text('UTC', style: textTheme.bodySmall),
                                    ],
                                  ),
                                if (state is! TimerRunComplete &&
                                    _startTime != null)
                                  Column(
                                    children: [
                                      Text('Predicted End',
                                          style: textTheme.titleSmall),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('HH:mm')
                                            .format(predictedEndTime),
                                        style: textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colors.primary),
                                      ),
                                      Text('UTC', style: textTheme.bodySmall),
                                    ],
                                  ),
                                if (_endTime != null)
                                  Column(
                                    children: [
                                      Text('Ended At',
                                          style: textTheme.titleSmall),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('HH:mm')
                                            .format(_endTime!),
                                        style: textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colors.primary),
                                      ),
                                      Text('UTC', style: textTheme.bodySmall),
                                    ],
                                  ),
                                if (lastPauseAction != null)
                                  Column(
                                    children: [
                                      Text('Paused At',
                                          style: textTheme.titleSmall),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('HH:mm').format(
                                            lastPauseAction.timestamp),
                                        style: textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colors.primary),
                                      ),
                                      Text('UTC', style: textTheme.bodySmall),
                                    ],
                                  ),
                                if (lastResumeAction != null &&
                                    lastPauseAction != null &&
                                    lastResumeAction.timestamp
                                        .isAfter(lastPauseAction.timestamp))
                                  Column(
                                    children: [
                                      Text('Resumed At',
                                          style: textTheme.titleSmall),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('HH:mm').format(
                                            lastResumeAction.timestamp),
                                        style: textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colors.primary),
                                      ),
                                      Text('UTC', style: textTheme.bodySmall),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: List.generate(
                                    tomato.pomodoros > 0
                                        ? tomato.pomodoros
                                        : 4, (index) {
                                  final int currentPomodoro = 1; // Placeholder
                                  final breakStartTime = predictedEndTime.add(
                                      Duration(
                                          minutes: (tomato.shortBreak +
                                                  tomato.endAt
                                                      .difference(
                                                          tomato.startAt)
                                                      .inMinutes) *
                                              index));
                                  final nextTomatoStartTime =
                                      breakStartTime.add(Duration(
                                          minutes: tomato.shortBreak));

                                  return Column(
                                    children: [
                                      Icon(
                                        index < currentPomodoro
                                            ? Icons.circle
                                            : Icons.circle_outlined,
                                        color: Colors.red.shade400,
                                        size: 20,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Break Start",
                                        style: textTheme.bodySmall,
                                      ),
                                      Text(
                                        DateFormat('HH:mm')
                                            .format(breakStartTime),
                                        style: textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Tomato Start",
                                        style: textTheme.bodySmall,
                                      ),
                                      Text(
                                        DateFormat('HH:mm')
                                            .format(nextTomatoStartTime),
                                        style: textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ],
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Scaffold(
                body: Center(child: Text('No tomato data found.')));
          }
        });
  }
}

class TimerAction {
  final String type;
  final DateTime timestamp;

  TimerAction({required this.type, required this.timestamp});

  String get formattedTimestamp =>
      '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';

  IconData get icon {
    switch (type) {
      case 'start':
        return Icons.play_arrow;
      case 'pause':
        return Icons.pause;
      case 'resume':
        return Icons.play_circle_outline;
      case 'end':
        return Icons.stop;
      default:
        return Icons.help_outline;
    }
  }
}
