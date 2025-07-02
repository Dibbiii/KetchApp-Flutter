import 'package:flutter/material.dart';
import 'package:ketchapp_flutter/models/tomato_session_stats.dart';

class TimerSummaryPage extends StatelessWidget {
  final SessionSummary sessionSummary;
  final VoidCallback onGoHome;
  final VoidCallback onPlanAgain;

  const TimerSummaryPage({
    Key? key,
    required this.sessionSummary,
    required this.onGoHome,
    required this.onPlanAgain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Riepilogo Sessione'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSessionOverview(context),
            const SizedBox(height: 24),
            _buildTomatoList(context),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionOverview(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: colors.primary, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Panoramica Sessione',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              'Pomodori Completati',
              '${sessionSummary.completedTomatoes}/${sessionSummary.totalTomatoes}',
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatRow(
              'Tasso di Completamento',
              '${sessionSummary.completionRate.toStringAsFixed(1)}%',
              Icons.trending_up,
              Colors.blue,
            ),
            _buildStatRow(
              'Efficienza Generale',
              '${sessionSummary.overallEfficiency.toStringAsFixed(1)}%',
              Icons.speed,
              sessionSummary.overallEfficiency >= 90 ? Colors.green : Colors.orange,
            ),
            _buildStatRow(
              'Tempo Totale Pianificato',
              _formatDuration(sessionSummary.totalPlannedTime),
              Icons.schedule,
              Colors.grey,
            ),
            _buildStatRow(
              'Tempo Totale Effettivo',
              _formatDuration(sessionSummary.totalActualTime),
              Icons.timer,
              Colors.purple,
            ),
            _buildStatRow(
              'Tempo Totale di Pausa',
              _formatDuration(sessionSummary.totalPausedTime),
              Icons.pause_circle,
              Colors.red,
            ),
            _buildStatRow(
              'Pause Totali',
              sessionSummary.totalPauses.toString(),
              Icons.pause,
              Colors.red,
            ),
            if (sessionSummary.totalOvertimeDuration > Duration.zero)
              _buildStatRow(
                'Tempo Extra Totale',
                _formatDuration(sessionSummary.totalOvertimeDuration),
                Icons.access_time,
                Colors.orange,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTomatoList(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list, color: colors.primary, size: 28),
            const SizedBox(width: 8),
            Text(
              'Dettagli Pomodori',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...sessionSummary.tomatoStats.map((stats) => _buildTomatoCard(context, stats)),
      ],
    );
  }

  Widget _buildTomatoCard(BuildContext context, TomatoStats stats) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  stats.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: stats.isCompleted ? Colors.green : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    stats.tomatoName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (stats.wasOvertime)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'OVERTIME',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTomatoStat(
                    'Pianificato',
                    _formatDuration(stats.plannedDuration),
                    Icons.schedule,
                    Colors.grey,
                  ),
                ),
                Expanded(
                  child: _buildTomatoStat(
                    'Effettivo',
                    _formatDuration(stats.actualDuration),
                    Icons.timer,
                    stats.wasOvertime ? Colors.orange : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTomatoStat(
                    'Pause',
                    '${stats.pauseCount}x (${_formatDuration(stats.totalPausedTime)})',
                    Icons.pause_circle,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildTomatoStat(
                    'Efficienza',
                    '${stats.efficiencyPercentage.toStringAsFixed(1)}%',
                    Icons.speed,
                    stats.efficiencyPercentage >= 90 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            if (stats.wasOvertime) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.orange, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Tempo extra: ${_formatDuration(stats.overtimeDuration)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTomatoStat(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: onPlanAgain,
            icon: const Icon(Icons.refresh),
            label: const Text('Pianifica Nuova Sessione'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: onGoHome,
            icon: const Icon(Icons.home),
            label: const Text('Torna alla Home'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
