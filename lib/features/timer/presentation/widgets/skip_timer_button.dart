import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/timer_bloc.dart';

/// Floating Action Button che permette di far avanzare rapidamente il timer corrente
/// (pomodoro o break) lasciando solo 10 secondi rimanenti.
///
/// Il button appare solo quando c'è un timer attivo (in progress o in pausa).
class SkipTimerButton extends StatelessWidget {
  const SkipTimerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        // Il button è sempre visibile, ma abilitato solo quando il timer è attivo
        final isTimerActive = state is TomatoTimerInProgress ||
            state is TomatoTimerPaused ||
            state is BreakTimerInProgress ||
            state is BreakTimerPaused;

        return FloatingActionButton(
          onPressed: isTimerActive ? () {
            context.read<TimerBloc>().add(const TimerSkipToEnd());
          } : null, // Disabilita il button quando il timer non è attivo
          backgroundColor: isTimerActive ? Colors.orange : Colors.grey,
          child: Icon(
            Icons.fast_forward,
            color: isTimerActive ? Colors.white : Colors.white70,
          ),
          tooltip: isTimerActive ? 'Salta a 10 secondi' : 'Timer non attivo',
        );
      },
    );
  }
}
