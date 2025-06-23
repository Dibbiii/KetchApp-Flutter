import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ketchapp_flutter/features/plan/presentation/pages/automatic/summary_state.dart';
import 'package:provider/provider.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  // State variables
  bool rumoriBianchiAttivi = false;
  int remainingSeconds = 0;
  Timer? _timer;
  bool isPaused = false;

  final int sessionDuration = 50;
  final int breakDuration = 10;
  final int hourStart = 9;
  final int totalHours = 4;
  final int pomodoriCompletati = 2;

  late final int numeroPomodori;

  @override
  void initState() {
    super.initState();
    remainingSeconds = sessionDuration * 60;
    numeroPomodori = (totalHours * 60 / sessionDuration).ceil();
    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final summaryState = Provider.of<SummaryState>(context, listen: false);
      summaryState.updateTotalCompletedHours(
        (pomodoriCompletati * sessionDuration) / 60,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _pauseOrResumeTimer() {
    setState(() {
      isPaused = !isPaused;
      if (isPaused) {
        _timer?.cancel();
      } else {
        _startTimer();
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formatTimer(remainingSeconds),
                style: TextStyle(
                  fontSize: 50,
                  color: colors.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _pauseOrResumeTimer,
                icon: Icon(
                  isPaused ? Icons.play_arrow : Icons.pause,
                  color: colors.primary,
                  size: 36,
                ),
                tooltip: isPaused ? 'Riprendi timer' : 'Pausa timer',
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Icon(Icons.apple, color: Colors.red, size: 48),
          const SizedBox(height: 24),
          _PomodoroTimeline(
            numeroPomodori: numeroPomodori,
            pomodoriCompletati: pomodoriCompletati,
            hourStart: hourStart,
            sessionDuration: sessionDuration,
            breakDuration: breakDuration,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ATTIVA I RUMORI BIANCHI',
                style: TextStyle(fontSize: 16, color: colors.onSurface),
              ),
              const SizedBox(width: 16),
              Switch(
                value: rumoriBianchiAttivi,
                onChanged: (value) {
                  setState(() {
                    rumoriBianchiAttivi = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<SummaryState>(
            builder:
                (context, summaryState, child) => Text(
                  'Ore completate oggi: ${summaryState.totalCompletedHours.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, color: colors.primary),
                ),
          ),
        ],
      ),
    );
  }
}

class _PomodoroTimeline extends StatelessWidget {
  const _PomodoroTimeline({
    required this.numeroPomodori,
    required this.pomodoriCompletati,
    required this.hourStart,
    required this.sessionDuration,
    required this.breakDuration,
  });

  final int numeroPomodori;
  final int pomodoriCompletati;
  final int hourStart;
  final int sessionDuration;
  final int breakDuration;

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(numeroPomodori, (index) {
        final bool isCompletato = index < pomodoriCompletati;
        final start = DateTime(
          2020,
          1,
          1,
          hourStart,
          0,
        ).add(Duration(minutes: index * (sessionDuration + breakDuration)));
        final end = start.add(Duration(minutes: sessionDuration));

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.circle_outlined,
                    color: colors.onSurface,
                    size: 32,
                  ),
                  if (isCompletato)
                    const Icon(Icons.circle, color: Colors.red, size: 28),
                ],
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 60,
              child: Column(
                children: [
                  Text(
                    _formatTime(start),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: colors.onSurface),
                  ),
                  Text(
                    _formatTime(end),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: colors.onSurface),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
