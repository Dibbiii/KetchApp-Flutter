import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ketchapp_flutter/features/plan/presentation/pages/automatic/summary_state.dart';
import 'package:provider/provider.dart';

import '../bloc/timer_bloc.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    const int sessionDuration = 50;

    return BlocProvider(
      create: (context) => TimerBloc(),
      child: TimerView(sessionDuration: sessionDuration),
    );
  }
}

class TimerView extends StatefulWidget {
  final int sessionDuration;
  const TimerView({super.key, required this.sessionDuration});

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  bool rumoriBianchiAttivi = false;

  // Configuration constants
  late final int sessionDuration;
  final int breakDuration = 10;
  final int hourStart = 9;
  final int totalHours = 4;
  final int pomodoriCompletati = 2;

  late final int numeroPomodori;

  final List<TimerAction> _actions = [];
  DateTime? _startTime;
  DateTime? _endTime;
  Timer? _rebuildTimer;

  @override
  void initState() {
    super.initState();
    sessionDuration = widget.sessionDuration;
    numeroPomodori = (totalHours * 60 / sessionDuration).ceil();

    // Ensure bloc event and provider update are called after first layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Start the timer only after layout is complete
      context.read<TimerBloc>().add(TimerStarted(duration: sessionDuration * 60));
      setState(() {
        _startTime = DateTime.now();
        _actions.insert(0, TimerAction(type: 'start', timestamp: _startTime!));
      });

      final summaryState = Provider.of<SummaryState>(context, listen: false);
      summaryState.updateTotalCompletedHours(
        (pomodoriCompletati * sessionDuration) / 60,
      );
    });
  }

  @override
  void dispose() {
    _rebuildTimer?.cancel();
    super.dispose();
  }

  Future<bool> _logAction(String type) async {
    // Simula una chiamata API
    // In un'applicazione reale, qui dovresti effettuare una vera chiamata di rete
    // e gestire eventuali errori.
    print('Calling API for action: $type');
    await Future.delayed(const Duration(milliseconds: 200));
    print('API call successful for action: $type');
    return true;
  }

  void _handleTimerAction(String type) {
    _logAction(type).then((success) {
      if (success) {
        setState(() {
          _actions.insert(0, TimerAction(type: type, timestamp: DateTime.now()));
        });

        final bloc = context.read<TimerBloc>();
        switch (type) {
          case 'start':
            bloc.add(TimerStarted(duration: sessionDuration * 60));
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
    });
  }

  String formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        children: [
          BlocConsumer<TimerBloc, TimerState>(
            listener: (context, state) {
              if (state is TimerRunComplete) {
                _rebuildTimer?.cancel();
                setState(() {
                  _endTime = DateTime.now();
                });
              } else if (state is TimerRunPause) {
                _rebuildTimer =
                    Timer.periodic(const Duration(seconds: 1), (timer) {
                  if (mounted) {
                    setState(() {});
                  }
                });
              } else {
                _rebuildTimer?.cancel();
              }
            },
            builder: (context, state) {
              final isPaused = state is TimerRunPause;
              final predictedEndTime =
                  DateTime.now().add(Duration(seconds: state.duration));

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        formatTimer(state.duration),
                        style: TextStyle(
                          fontSize: 50,
                          color: colors.primary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (state is! TimerRunComplete)
                        IconButton(
                          onPressed: () {
                            if (isPaused) {
                              _handleTimerAction('resume');
                            } else {
                              _handleTimerAction('pause');
                            }
                          },
                          icon: Icon(
                            isPaused ? Icons.play_arrow : Icons.pause,
                            color: colors.primary,
                            size: 36,
                          ),
                          tooltip: isPaused ? 'Riprendi timer' : 'Pausa timer',
                        ),
                      if (state is! TimerRunComplete)
                        IconButton(
                          onPressed: () => _handleTimerAction('end'),
                          icon: const Icon(
                            Icons.stop,
                            color: Colors.red,
                            size: 36,
                          ),
                          tooltip: 'Finisci timer',
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_startTime != null)
                    Text(
                      'Timer Start: ${DateFormat('HH:mm').format(_startTime!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (_endTime != null)
                    Text(
                      'Timer End: ${DateFormat('HH:mm').format(_endTime!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (state is! TimerRunComplete && _startTime != null)
                    Text(
                      'End prevista: ${DateFormat('HH:mm:ss').format(predictedEndTime)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              );
            },
          ),

          // AAAA
          const SizedBox(height: 20),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                itemCount: _actions.length,
                itemBuilder: (context, index) {
                  final action = _actions[index];
                  return ListTile(
                    leading: Icon(action.icon),
                    title: Text('Action: ${action.type}'),
                    subtitle: Text('Time: ${action.formattedTimestamp}'),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
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
