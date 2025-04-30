import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SummaryPage extends StatefulWidget{
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  bool rumoriBianchiAttivi = false;
  int remainingSeconds = 0;
  Timer? _timer;
  bool isPaused = false; 

  void _pauseOrResumeTimer() {
    setState(() {
      if (isPaused) {
        _startTimer();
      } else {
        _timer?.cancel();
      }
      isPaused = !isPaused;
    });
  }

  @override
  void initState() {
    super.initState();
    remainingSeconds = sessionDuration * 60; // Imposta il timer a 50 minuti in secondi
    _startTimer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final int sessionDuration = 50;
  final int breakDuration = 10;
  final int hourStart = 9;
  final int totalHours = 4;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) { 
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String formatTimer(int seconds) { // mostra il timer in formato mm:ss
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    // Calcolo numero di pomodori necessari per coprire totalHours
    final totalMinutes = totalHours * 60;
    int numeroPomodori = (totalMinutes / sessionDuration).ceil();
    int pomodoriCompletati = 2;

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Timer sopra allo step con pulsante pausa a fianco
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  formatTimer(remainingSeconds),
                  style: TextStyle(
                    fontSize: 50,
                    color: colors.primary,
                    fontFeatures: [FontFeature.tabularFigures()],
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
            Text(
              'Step',
              style: TextStyle(fontSize: 20, color: colors.onSurface),
            ),
            Text(
              '1/$numeroPomodori',
              style: TextStyle(fontSize: 32, color: colors.onSurface),
            ),
            const SizedBox(height: 16),
            // Pomodoro grande centrale
            Icon(Icons.apple, color: Colors.red, size: 48),
            const SizedBox(height: 24),
            // Pomodori piccoli in fila con orari allineati sotto
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(numeroPomodori, (index) {
                final bool isCompletato = index < pomodoriCompletati;
                final start = DateTime(2020, 1, 1, hourStart, 0)
                    .add(Duration(minutes: index * (sessionDuration + breakDuration)));
                final end = start.add(Duration(minutes: sessionDuration));
                String formatTime(DateTime t) =>
                    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                
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
                            Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 28,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 60,
                      child: Column(
                        children: [
                          Text(
                            formatTime(start),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: colors.onSurface),
                          ),
                          Text(
                            formatTime(end),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: colors.onSurface),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 32),
            // Switch rumori bianchi
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
          ],
        ),
      ),
    );
  }
}