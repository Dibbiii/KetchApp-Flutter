import 'package:flutter/material.dart';

class BreakTimer extends StatelessWidget {
  final int remainingSeconds;
  final bool isPaused;
  final VoidCallback onPauseOrResume;

  const BreakTimer({
    super.key,
    required this.remainingSeconds,
    required this.isPaused,
    required this.onPauseOrResume,
  });

  String formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          formatTimer(remainingSeconds),
          style: TextStyle(
            fontSize: 50,
            color: colors.secondary,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: onPauseOrResume,
          icon: Icon(
            isPaused ? Icons.play_arrow : Icons.pause,
            color: colors.secondary,
            size: 36,
          ),
          tooltip: isPaused ? 'Riprendi timer' : 'Pausa timer',
        ),
      ],
    );
  }
}