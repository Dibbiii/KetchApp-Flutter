import 'package:flutter/material.dart';
import 'package:ketchapp_flutter/app/themes/app_colors.dart';
import 'package:intl/intl.dart';

import '../../plan/presentation/pages/automatic/summary_state.dart';
import 'package:provider/provider.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final List<String> _subjects = [];
  DateTime bestStudyDay = DateTime.now();
  double recordStudyHours = 0.0;

  @override
  void initState() {
    super.initState();
    // Inizializza il record con un valore di default (es. 0)
    recordStudyHours = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Size size = MediaQuery.of(context).size;

    final summaryState = Provider.of<SummaryState>(context);
    final double studyHours = summaryState.totalCompletedHours;

    // Confronta le ore studiate con il record e aggiorna se necessario
    if (studyHours > recordStudyHours) {
      recordStudyHours = studyHours;
      bestStudyDay = DateTime.now();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.1, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, size: 40, color: kGold),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (studyHours == 0.0)
                    Text(
                      "You haven't studied yet",
                      style: textTheme.titleMedium?.copyWith(color: colors.onSurface),
                    )
                  else
                    Text(
                      DateFormat('dd/MM/yyyy').format(bestStudyDay),
                      style: textTheme.titleMedium?.copyWith(color: colors.onSurface),
                    ),
                  Text(
                    '$recordStudyHours ore',
                    style: textTheme.bodyLarge?.copyWith(color: colors.onSurface),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Altre statistiche...',
          ),
        ],
      ),
    );
  }
}