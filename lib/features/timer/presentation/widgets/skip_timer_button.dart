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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        // Il button è sempre visibile, ma abilitato solo quando il timer è attivo
        final isTimerActive = state is TomatoTimerInProgress ||
            state is TomatoTimerPaused ||
            state is BreakTimerInProgress ||
            state is BreakTimerPaused;

        final isBreak = state is BreakTimerInProgress || state is BreakTimerPaused;

        if (!isTimerActive) {
          return const SizedBox.shrink(); // Hide button when timer is not active
        }

        return FloatingActionButton.extended(
          heroTag: "skip_timer_fab", // Aggiungi un tag unico
          onPressed: () {
            context.read<TimerBloc>().add(const TimerSkipToEnd());
          },
          backgroundColor: isBreak ? colors.secondaryContainer : colors.tertiaryContainer,
          foregroundColor: isBreak ? colors.onSecondaryContainer : colors.onTertiaryContainer,
          elevation: 2,
          extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
          icon: Icon(
            Icons.fast_forward_rounded,
            size: 20,
          ),
          label: Text(
            'Skip to 10s',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          tooltip: 'Skip to last 10 seconds',
        );
      },
    );
  }
}
