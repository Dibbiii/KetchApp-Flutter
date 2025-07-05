import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarTimeDialog extends StatefulWidget {
  final String initialStart;
  final String initialEnd;
  final bool isGoogleCalendarEvent;

  const CalendarTimeDialog({
    this.initialStart = '',
    this.initialEnd = '',
    required this.isGoogleCalendarEvent,
    super.key,
  });

  @override
  State<CalendarTimeDialog> createState() => _CalendarTimeDialogState();
}

class _CalendarTimeDialogState extends State<CalendarTimeDialog> {
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  late TextEditingController _startTimeTextController;
  late TextEditingController _endTimeTextController;
  bool _didChangeDependencies = false;
  String? _selectedDate;
  late bool _isGoogleCalendarEvent;

  @override
  void initState() {
    super.initState();
    _isGoogleCalendarEvent = widget.isGoogleCalendarEvent;

    _startTime = _parseTime(widget.initialStart);
    _endTime = _parseTime(widget.initialEnd);

    _startTimeTextController = TextEditingController(
      text: widget.initialStart.isNotEmpty ? widget.initialStart : "HH:MM",
    );
    _endTimeTextController = TextEditingController(
      text: widget.initialEnd.isNotEmpty ? widget.initialEnd : "HH:MM",
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didChangeDependencies) {
      _startTimeTextController.text = _formatTimeForDisplay(
        context,
        _startTime,
      );
      _endTimeTextController.text = _formatTimeForDisplay(context, _endTime);
      _didChangeDependencies = true;
    }
  }

  @override
  void dispose() {
    _startTimeTextController.dispose();
    _endTimeTextController.dispose();
    super.dispose();
  }

  TimeOfDay? _parseTime(String t) {
    if (t.isEmpty) return null;
    final parts = t.split(":");
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTimeForDisplay(BuildContext context, TimeOfDay? tod) {
    if (tod == null) return 'HH:MM';
    return '${tod.hour.toString().padLeft(2, '0')}:${tod.minute.toString().padLeft(2, '0')}';
  }

  String _formatTimeForReturn(BuildContext context, TimeOfDay? tod) {
    if (tod == null) return "";
    return '${tod.hour.toString().padLeft(2, '0')}:${tod.minute.toString().padLeft(2, '0')}';
  }

  void _showTimeSelectionInfo() {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text(
          'Non è possibile modificare l\'orario di un appuntamento di Google Calendar',
        ),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          onPressed: scaffold.hideCurrentSnackBar,
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    if (_isGoogleCalendarEvent) {
      _showTimeSelectionInfo();
      return;
    }

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
          _startTimeTextController.text = _formatTimeForDisplay(
            context,
            pickedTime,
          );
        } else {
          _endTime = pickedTime;
          _endTimeTextController.text = _formatTimeForDisplay(
            context,
            pickedTime,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: const Text('Dettagli Appuntamento'),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 20.0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Orario Inizio',
            style: textTheme.labelLarge?.copyWith(color: colors.primary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _startTimeTextController,
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'HH:MM',
              border: const OutlineInputBorder(),
              suffixIcon: Icon(
                _isGoogleCalendarEvent ? Icons.lock_clock : Icons.access_time,
                color: colors.onSurfaceVariant,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              filled: true,
              fillColor: colors.surfaceContainerHighest.withAlpha(
                (0.3 * 255).toInt(),
              ),
            ),
            onTap: () => _isGoogleCalendarEvent
                ? _showTimeSelectionInfo()
                : _selectTime(context, true),
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Orario Fine',
            style: textTheme.labelLarge?.copyWith(color: colors.primary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _endTimeTextController,
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'HH:MM',
              border: const OutlineInputBorder(),
              suffixIcon: Icon(
                _isGoogleCalendarEvent ? Icons.lock_clock : Icons.access_time,
                color: colors.onSurfaceVariant,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              filled: true,
              fillColor: colors.surfaceContainerHighest.withAlpha(
                (0.3 * 255).toInt(),
              ),
            ),
            onTap: () => _isGoogleCalendarEvent
                ? _showTimeSelectionInfo()
                : _selectTime(context, false),
            style: textTheme.bodyLarge,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Annulla'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          child: const Text('Conferma'),
          onPressed: () {
            Navigator.of(context).pop({
              'start_at': _formatTimeForReturn(context, _startTime),
              'end_at': _formatTimeForReturn(context, _endTime),
              'date': _selectedDate ??
                  DateFormat('E, d MMM', 'it_IT').format(DateTime.now()),
            });
          },
        ),
      ],
    );
  }
}

