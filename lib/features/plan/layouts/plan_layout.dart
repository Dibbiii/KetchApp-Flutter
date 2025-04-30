import 'package:flutter/material.dart';
import 'package:ketchapp_flutter/features/plan/presentation/pages/automatic/appointments_page.dart';
import 'package:ketchapp_flutter/features/plan/presentation/pages/automatic/session_page.dart';
import 'package:ketchapp_flutter/features/plan/presentation/pages/automatic/subject_page.dart';

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

    final List<Widget> automaticList = [SubjectPage(), SessionPage()];
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
          // Mostra "Indietro" solo dallo step 2 in poi
          if (currentIndex > 0)
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: SizedBox(
                width: 100,
                height: 32, // Più basso
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
            const SizedBox(width: 100), // Spazio vuoto per allineamento

          SizedBox(
            width: 100,
            height: 32, // Più basso
            child: FloatingActionButton(
              backgroundColor: colors.primary,
              onPressed: currentIndex < list.length - 1
                  ? () => setState(() => currentIndex++)
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fine del percorso!')),
                      );
                    },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                currentIndex < list.length - 1 ? 'Successivo' : 'Vai', 
                style: TextStyle(fontSize: 14, color: colors.onPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
