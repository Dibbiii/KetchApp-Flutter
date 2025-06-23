import 'package:flutter/material.dart';
import 'package:ketchapp_flutter/services/calendar_service.dart'; // Importa il servizio
import 'package:googleapis/calendar/v3.dart' as cal; // Per il tipo Event

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final List<String> _subjects = []; // Lista delle materie
  final CalendarService _calendarService = CalendarService(); // Istanza del servizio
  List<cal.Event> _calendarEvents = [];
  bool _isLoadingCalendarEvents = false;

  @override
  void initState() {
    super.initState();
    _fetchCalendarEvents();
  }

  Future<void> _fetchCalendarEvents() async {
    setState(() {
      _isLoadingCalendarEvents = true;
    });
    try {
      final events = await _calendarService.getEvents();
      setState(() {
        _calendarEvents = events;
      });
    } catch (e) {
      print("Errore nel caricare gli eventi da Google Calendar: $e");
    } finally {
      setState(() {
        _isLoadingCalendarEvents = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Size size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.1, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.menu_book,
              size: 60.0,
            ),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            'Add Your Appointments',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Description
          Text(
            'Add your appointments for the day',
            style: textTheme.bodyLarge?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add appointment'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  8,
                ),
              ),
              textStyle: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).copyWith(
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            ),
            onPressed: () async {
              final subjectName = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  String input = '';
                  return AlertDialog(
                    title: const Text('Add Appointment'),
                    content: TextField(
                      onChanged: (value) {
                        input = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Enter Appointment',
                      ),
                      autofocus: true,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(null);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: colors.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          if (input.trim().isNotEmpty) {

                            Navigator.of(context).pop(input.trim());
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor:
                              colors.primary,
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  );
                },
              );

              if (subjectName != null && subjectName.isNotEmpty) {
                setState(() {
                  if (!_subjects.contains(subjectName)) {
                    // Avoid duplicates
                    _subjects.add(subjectName);
                  }
                });
              }
            },
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoadingCalendarEvents
                ? const Center(child: CircularProgressIndicator())
                : _calendarEvents.isEmpty && _subjects.isEmpty
                    ? Center(
                        child: Text(
                          'No appointments added yet.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface.withOpacity(0.6),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _subjects.length + _calendarEvents.length,
                        itemBuilder: (context, index) {
                          if (index < _subjects.length) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              color: colors.surfaceContainerHighest.withOpacity(0.5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: colors.outline.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                title: Text(
                                  _subjects[index],
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: colors.onSurfaceVariant.withOpacity(0.7),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _subjects.removeAt(index);
                                    });
                                  },
                                  tooltip: 'Remove Appointment',
                                ),
                              ),
                            );
                          } else {
                            final eventIndex = index - _subjects.length;
                            final event = _calendarEvents[eventIndex];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              color: colors.surfaceContainer.withOpacity(0.7), // Colore diverso per eventi Google
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: colors.outline.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                leading: Icon(Icons.calendar_today, color: colors.primary),
                                title: Text(
                                  event.summary ?? 'Nessun titolo',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colors.onSurface,
                                  ),
                                ),
                                subtitle: Text(
                                  '${event.start?.dateTime?.toLocal() ?? event.start?.date?.toLocal() ?? 'Data non specificata'}',
                                  style: textTheme.bodySmall,
                                ),
                              ),
                            );
                          }
                        },
                      ),
          ),
        ],
      ),
    );
  }
}