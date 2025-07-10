import 'package:flutter/material.dart';

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
  late TextEditingController _startTimeTextController;
  late TextEditingController _endTimeTextController;

  @override
  void initState() {
    super.initState();
    _startTimeTextController = TextEditingController(text: widget.initialStart);
    _endTimeTextController = TextEditingController(text: widget.initialEnd);
  }

  @override
  void dispose() {
    _startTimeTextController.dispose();
    _endTimeTextController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTimeTextController.text = picked.format(context);
        } else {
          _endTimeTextController.text = picked.format(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Time'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _startTimeTextController,
            readOnly: true,
            onTap: () => _selectTime(context, true),
            decoration: const InputDecoration(labelText: 'Start Time'),
          ),
          TextField(
            controller: _endTimeTextController,
            readOnly: true,
            onTap: () => _selectTime(context, false),
            decoration: const InputDecoration(labelText: 'End Time'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop({
              'start': _startTimeTextController.text,
              'end': _endTimeTextController.text,
            });
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
