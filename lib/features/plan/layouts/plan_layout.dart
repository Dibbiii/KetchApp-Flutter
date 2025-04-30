import 'package:flutter/material.dart';
import 'package:ketchapp_flutter/features/plan/presentation/pages/automatic/hours_page.dart';
import 'package:ketchapp_flutter/features/plan/presentation/pages/automatic/session_page.dart';
import 'package:ketchapp_flutter/features/plan/presentation/pages/automatic/subject_page.dart';

import '../presentation/pages/automatic/appointments_page.dart';
import '../presentation/pages/automatic/summary_page.dart';

enum PlanMode { automatic, manual }

class PlanLayout extends StatefulWidget {
  final PlanMode mode;

  const PlanLayout({super.key, required this.mode});

  @override
  State<PlanLayout> createState() => _PlanLayoutState();
}

class _PlanLayoutState extends State<PlanLayout> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final List<Widget> automaticList = [
      SubjectPage(),
      AppointmentsPage(),
      HoursPage(),
      SummaryPage()];
    final List<Widget> manualList = [SubjectPage()];
    final bool isAutomatic = widget.mode == PlanMode.automatic;
    final List<Widget> list = isAutomatic ? automaticList : manualList;

    return Scaffold(
      appBar: AppBar(title: const Text('Plan Layout')),
      body: Column(
        children: [ 
          const SizedBox(height: 16),
          Text(
            'Step: ${currentIndex + 1}/${list.length}',
            style: TextStyle(fontSize: 20, color: colors.onSurface),
            textAlign: TextAlign.center,
          ),
          Expanded(child: Center(child: list[currentIndex])),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (currentIndex > 0 && currentIndex < list.length - 1)
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: SizedBox(
                width: 100,
                height: 32,
                child: FloatingActionButton(
                  backgroundColor: colors.primary,
                  onPressed: () => setState(() => currentIndex--),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Indietro',
                    style: TextStyle(fontSize: 14, color: colors.onPrimary),
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 100),

          if (currentIndex < list.length - 1)
            SizedBox(
              width: 100,
              height: 32,
              child: FloatingActionButton(
                backgroundColor: colors.primary,
                onPressed: () {
                  // Se siamo nella penultima pagina, vai all'ultima
                    setState(() => currentIndex++);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currentIndex < list.length - 2 ? 'Successivo' : 'Vai',
                  style: TextStyle(fontSize: 14, color: colors.onPrimary),
                ),
              ),
            )
          else
            const SizedBox(width: 100),
        ],
      ),
    );
  }
}
