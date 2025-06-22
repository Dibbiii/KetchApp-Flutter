import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // Import for date formatting

import '../../../components/clock_widget.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/plan/models/plan_model.dart';
import '../../../services/api_service.dart';
import '../../../services/calendar_service.dart'; // Import CalendarService

class ShowBottomSheet extends StatefulWidget {
  const ShowBottomSheet({super.key}); // Removed super.key as it's not used

  @override
  State<ShowBottomSheet> createState() => _ShowBottomSheetState();
}

class _ShowBottomSheetState extends State<ShowBottomSheet> {
  int selectedType = 0; // 0: Event, 1: Task, 2: Birthday
  final List<TextEditingController> _subjectControllers = [];
  final List<FocusNode> _subjectFocusNodes = [];

  // Add fixed calendar events for Lunch, Dinner, and Sleep to the UI as editable events
  final List<TextEditingController> _calendarControllers = [
    TextEditingController(text: 'Lunch'),
    TextEditingController(text: 'Dinner'),
    TextEditingController(text: 'Sleep'),
  ];
  final List<FocusNode> _calendarFocusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];
  late TextEditingController _sessionTimeController;
  late TextEditingController _pauseTimeController;
  final List<String> _selectedFriends = [];

  double _dialogPauseSelectedHours = 0.0;
  double _dialogSessionSelectedHours = 0.0;

  // Add controllers for all main inputs
  final TextEditingController _titleController = TextEditingController();

  // You already have _subjectControllers, _calendarControllers, etc.
  // Add variables for config, calendar, tomatoes, rules
  final Map<String, dynamic> _config = {
    'notifications': {'enabled': true, 'sound': 'default', 'vibration': true},
  };

  // Define fixed calendar events for Lunch, Dinner, and Sleep
  final List<Map<String, String>> _fixedCalendarEvents = [
  ];

  // Store calendar times by index
  final Map<int, Map<String, String>> _calendarTimes = {
    0: {'start_at': '12:30', 'end_at': '13:30'}, // Lunch
    1: {'start_at': '19:30', 'end_at': '20:30'}, // Dinner
    2: {'start_at': '23:30', 'end_at': '07:30'}, // Sleep
  };
  bool _syncWithGoogleCalendar = false;

  // Keep track of which calendars are from Google Calendar
  final Set<int> _googleCalendarEvents = {};

  // Calendar service for fetching Google Calendar events
  final CalendarService _calendarService = CalendarService();

  String? _subjectErrorText;
  String? _sessionTimeErrorText;
  String? _pauseTimeErrorText;

  @override
  void initState() {
    super.initState();
    _sessionTimeController = TextEditingController(text: 'Add session time');
    _pauseTimeController = TextEditingController(text: 'Add pause time');

    _addSubject();
    _addcalendar();
    // Non aggiungere più eventi fissi qui
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var controller in _subjectControllers) {
      controller.dispose();
    }
    for (var focusNode in _subjectFocusNodes) {
      focusNode.dispose();
    }
    for (var controller in _calendarControllers) {
      controller.dispose();
    }
    for (var focusNode in _calendarFocusNodes) {
      focusNode.dispose();
    }
    _sessionTimeController.dispose();
    _pauseTimeController.dispose();
    super.dispose();
  }

  void _addSubject() {
    final newController = TextEditingController();
    final newFocusNode = FocusNode();
    setState(() {
      _subjectControllers.add(newController);
      _subjectFocusNodes.add(newFocusNode);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      newFocusNode.requestFocus();
    });
  }

  void _removeSubjectAt(int idx) {
    setState(() {
      _subjectControllers[idx].dispose();
      _subjectFocusNodes[idx].dispose();
      _subjectControllers.removeAt(idx);
      _subjectFocusNodes.removeAt(idx);
    });
  }

  void _addcalendar() {
    final newController = TextEditingController();
    final newFocusNode = FocusNode();
    setState(() {
      _calendarControllers.add(newController);
      _calendarFocusNodes.add(newFocusNode);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      newFocusNode.requestFocus();
    });
  }

  void _removecalendarAt(int idx) {
    setState(() {
      _calendarControllers[idx].dispose();
      _calendarFocusNodes[idx].dispose();
      _calendarControllers.removeAt(idx);
      _calendarFocusNodes.removeAt(idx);
    });
  }

  void _showSessionClockDialog() {
    double initialFractionalHours = 0.0;
    if (_sessionTimeController.text.contains('h') ||
        _sessionTimeController.text.contains('m')) {
      try {
        if (_sessionTimeController.text.contains('h')) {
          List<String> parts = _sessionTimeController.text
              .replaceAll(' h', '')
              .split(':');
          int hours = int.parse(parts[0]);
          int minutes = parts.length > 1 ? int.parse(parts[1]) : 0;
          initialFractionalHours = hours + (minutes / 60.0);
        } else if (_sessionTimeController.text.contains('m')) {
          int minutes = int.parse(
            _sessionTimeController.text.replaceAll(' m', ''),
          );
          initialFractionalHours = minutes / 60.0;
        }
      } catch (e) {
        initialFractionalHours = 0.0;
      }
    }
    double initialHmmHours = fractionalHoursToHmm(initialFractionalHours);
    double tempSelectedHmmSessionHours = initialHmmHours;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Set Session Duration'),
          contentPadding: const EdgeInsets.all(16.0),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter dialogSetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    formatDurationFromHmm(
                      tempSelectedHmmSessionHours,
                      defaultText: "No session",
                    ),
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  MaterialClock(
                    initialSelectedHours: tempSelectedHmmSessionHours,
                    onTimeChanged: (selectedHmm) {
                      dialogSetState(() {
                        tempSelectedHmmSessionHours = selectedHmm;
                      });
                    },
                    clockSize: 200.0,
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                setState(() {
                  _dialogSessionSelectedHours = tempSelectedHmmSessionHours;
                  _sessionTimeController.text = formatDurationFromHmm(
                    _dialogSessionSelectedHours,
                    defaultText: "Add session time",
                  );
                });
                Navigator.pop(dialogContext);
              },
            ),
          ],
        );
      },
    );
  }

  void _showPauseClockDialog() {
    double initialFractionalHours = 0.0;
    if (_pauseTimeController.text.contains('h') ||
        _pauseTimeController.text.contains('m')) {
      try {
        if (_pauseTimeController.text.contains('h')) {
          List<String> parts = _pauseTimeController.text
              .replaceAll(' h', '')
              .split(':');
          int hours = int.parse(parts[0]);
          int minutes = parts.length > 1 ? int.parse(parts[1]) : 0;
          initialFractionalHours = hours + (minutes / 60.0);
        } else if (_pauseTimeController.text.contains('m')) {
          int minutes = int.parse(
            _pauseTimeController.text.replaceAll(' m', ''),
          );
          initialFractionalHours = minutes / 60.0;
        }
      } catch (e) {
        initialFractionalHours = 0.0;
      }
    }
    double initialHmmHours = fractionalHoursToHmm(initialFractionalHours);
    double tempSelectedHmmPauseHours = initialHmmHours;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Set Break Duration'),
          contentPadding: const EdgeInsets.all(16.0),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter dialogSetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    formatDurationFromHmm(
                      tempSelectedHmmPauseHours,
                      defaultText: "No break",
                    ),
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  MaterialClock(
                    initialSelectedHours: tempSelectedHmmPauseHours,
                    onTimeChanged: (selectedHmm) {
                      dialogSetState(() {
                        tempSelectedHmmPauseHours = selectedHmm;
                      });
                    },
                    clockSize: 200.0,
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                setState(() {
                  _dialogPauseSelectedHours = tempSelectedHmmPauseHours;
                  _pauseTimeController.text = formatDurationFromHmm(
                    _dialogPauseSelectedHours,
                    defaultText: "Add break",
                  );
                });
                Navigator.pop(dialogContext);
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddFriendsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return _AddFriendsDialog(
          selectedFriends: _selectedFriends,
          onFriendSelected: (String friend) {
            setState(() {
              if (!_selectedFriends.contains(friend)) {
                _selectedFriends.add(friend);
              }
            });
          },
        );
      },
    );
  }

  void _removeFriend(String friend) {
    setState(() {
      _selectedFriends.remove(friend);
    });
  }

  String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.Hm(); // 'HH:mm'
    return format.format(dt);
  }

  Future<void> _createPlan() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You must be logged in to create a plan.')),
        );
      }
      return;
    }

    try {
      final firebaseUid = authState.user.uid;
      final userUuid = await ApiService().getUserUUIDByFirebaseUid(firebaseUid);
      final calendar = <CalendarEntry>[];
      _calendarControllers.asMap().forEach((idx, controller) {
        final title = controller.text.trim();
        if (title.isNotEmpty) {
          final times = _calendarTimes[idx] ?? {'start_at': '', 'end_at': ''};
          final startAt = times['start_at']!;
          final endAt = times['end_at']!;
          calendar.add(
              CalendarEntry(startAt: startAt, endAt: endAt, title: title));
        }
      });

      final tomatoes = _subjectControllers
          .where((c) => c.text.trim().isNotEmpty)
          .map((controller) => TomatoEntry(
                title: controller.text,
                subject: controller.text,
              ))
          .toList();

      final notificationsConfig =
          _config['notifications'] as Map<String, dynamic>? ?? {};
      final config = Config(
        notifications: Notifications(
          enabled: notificationsConfig['enabled'] as bool? ?? true,
          sound: notificationsConfig['sound'] as String? ?? 'default',
          vibration: notificationsConfig['vibration'] as bool? ?? true,
        ),
        session:
            formatDurationFromHmm(_dialogSessionSelectedHours, defaultText: '0m'),
        pause:
            formatDurationFromHmm(_dialogPauseSelectedHours, defaultText: '0m'),
      );

      final plan = PlanModel(
        userId: userUuid,
        config: config,
        calendar: calendar,
        tomatoes: tomatoes,
      );

      await ApiService().createPlan(plan);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create plan: $e')),
        );
      }
    }
  }

  void _fetchGoogleCalendarEvents() {
    setState(() {
      // _isLoadingCalendarEvents = true;
    });
    _calendarService
        .getEvents()
        .then((events) {
          setState(() {
            // _isLoadingCalendarEvents = false;
            // Clear existing events
            for (var idx in _googleCalendarEvents) {
              if (idx < _calendarControllers.length) {
                _calendarControllers[idx].dispose();
                _calendarFocusNodes[idx].dispose();
              }
            }
            _calendarControllers.clear();
            _calendarFocusNodes.clear();
            _googleCalendarEvents.clear();

            // Add new events
            for (var event in events) {
              final startTime = event.start?.dateTime?.toLocal();
              final endTime = event.end?.dateTime?.toLocal();

              if (startTime != null && endTime != null) {
                final controller = TextEditingController(
                  text: event.summary ?? 'No title',
                );
                _calendarControllers.add(controller);
                _calendarFocusNodes.add(FocusNode());
                _calendarTimes[_calendarControllers.length - 1] = {
                  'start_at': DateFormat('HH:mm').format(startTime),
                  'end_at': DateFormat('HH:mm').format(endTime),
                  'date': DateFormat('E, d MMM', 'it_IT').format(startTime),
                };
                _googleCalendarEvents.add(_calendarControllers.length - 1);
              }
            }
          });
        })
        .catchError((error) {
          setState(() {
            // _isLoadingCalendarEvents = false;
          });
          // Handle error (e.g., show a snackbar)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch events: $error')),
          );
        });
  }

  void _clearGoogleCalendarEvents() {
    // Create a copy of the indices to avoid concurrent modification issues
    final List<int> googleEventIndices = _googleCalendarEvents.toList()..sort();

    // Remove Google Calendar events starting from the highest index to avoid shifting issues
    for (int i = googleEventIndices.length - 1; i >= 0; i--) {
      final idx = googleEventIndices[i];
      if (idx < _calendarControllers.length) {
        // Dispose controllers and focus nodes
        _calendarControllers[idx].dispose();
        _calendarFocusNodes[idx].dispose();

        // Remove from lists
        _calendarControllers.removeAt(idx);
        _calendarFocusNodes.removeAt(idx);

        // Remove from calendar times
        _calendarTimes.remove(idx);

        // Update times map indices to reflect the removal
        final Map<int, Map<String, String>> updatedTimes = {};
        _calendarTimes.forEach((key, value) {
          if (key > idx) {
            updatedTimes[key - 1] = value;
          } else {
            updatedTimes[key] = value;
          }
        });
        _calendarTimes.clear();
        _calendarTimes.addAll(updatedTimes);
      }
    }

    // Clear the set of Google Calendar events
    _googleCalendarEvents.clear();

    // ignore: avoid_print
    print('Cleared Google Calendar events...');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.9,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      minimumSize: const Size(0, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () async {
                      final subjects = _subjectControllers
                          .map((c) => c.text.trim())
                          .where((t) => t.isNotEmpty)
                          .toList();

                      final subjectError =
                          subjects.isEmpty ? 'Please add at least one subject.' : null;
                      final sessionError = _dialogSessionSelectedHours == 0.0
                          ? 'Session time must be greater than 0.'
                          : null;
                      final pauseError = _dialogPauseSelectedHours == 0.0
                          ? 'Pause time must be greater than 0.'
                          : null;

                      setState(() {
                        _subjectErrorText = subjectError;
                        _sessionTimeErrorText = sessionError;
                        _pauseTimeErrorText = pauseError;
                      });

                      if (subjectError != null ||
                          sessionError != null ||
                          pauseError != null) {
                        return;
                      }
                      // Call your API here before closing the sheet
                      await _createPlan();
                      Navigator.pop(context);
                    },
                    child: const Text('Save', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
            const Divider(), // ! Friends Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12.0,
                  ),
                  child: Icon(
                    Icons.people_outline,
                    size: 22,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap:
                        _selectedFriends.isEmpty ? _showAddFriendsDialog : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      margin: EdgeInsets.only(
                        right: _selectedFriends.isEmpty ? 12.0 : 0.0,
                      ),
                      child:
                          _selectedFriends.isEmpty
                              ? Text(
                                'Add friends',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: colors.onSurfaceVariant,
                                ),
                              )
                              : Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Chip(
                                    label: const Text('You'),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                      vertical: 0.0,
                                    ),
                                  ),
                                  ..._selectedFriends.map(
                                    (friend) => Chip(
                                      label: Text(friend),
                                      onDeleted: () => _removeFriend(friend),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0,
                                        vertical: 0.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                ),
                if (_selectedFriends.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, right: 8.0),
                    child: IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: colors.primary,
                      ),
                      onPressed: _showAddFriendsDialog,
                      tooltip: 'Add more friends',
                      splashRadius: 20.0,
                    ),
                  ),
              ],
            ),
            const Divider(), // ! Sync with Google Calendar Section
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is Authenticated && state.isGoogleSignIn) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.sync, color: colors.onSurfaceVariant, size: 22),
                        const SizedBox(width: 16),
                        Text(
                          'Sync with Google Calendar',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _syncWithGoogleCalendar,
                          onChanged: (bool value) {
                            setState(() {
                              _syncWithGoogleCalendar = value;
                              if (_syncWithGoogleCalendar) {
                                _fetchGoogleCalendarEvents();
                              } else {
                                _clearGoogleCalendarEvents();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const Divider(), // ! Events Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Icon(
                    Icons.event_note,
                    size: 22,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Show fixed calendars first
                      ..._fixedCalendarEvents.map(
                        (fixed) => Container(
                          margin: const EdgeInsets.only(
                            bottom: 4.0,
                            right: 12.0,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest.withAlpha(
                              128,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: TextEditingController(
                                    text: fixed['title'],
                                  ),
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    hintText: 'Enter calendar event',
                                    border: InputBorder.none,
                                    isDense: true,
                                    prefixIcon: Icon(
                                      Icons.lock_clock,
                                      size: 16,
                                      color: colors.primary.withAlpha(
                                        (0.7 * 255).toInt(),
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colors.onSurface.withAlpha(
                                      (0.8 * 255).toInt(),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 8.0,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primaryContainer,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: colors.primary,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '${fixed['start_at']} - ${fixed['end_at']}',
                                  style: TextStyle(
                                    color: colors.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              // No delete button for fixed calendars
                            ],
                          ),
                        ),
                      ),
                      // ...existing code for user calendars...
                      ..._calendarControllers.asMap().entries.map((entry) {
                        int idx = entry.key;
                        TextEditingController controller = entry.value;
                        FocusNode focusNode = _calendarFocusNodes[idx];
                        final startAt = _calendarTimes[idx]?['start_at'] ?? '';
                        final endAt = _calendarTimes[idx]?['end_at'] ?? '';
                        return Container(
                          margin: const EdgeInsets.only(
                            bottom: 4.0,
                            right: 12.0,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest.withAlpha(
                              128,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  readOnly: _googleCalendarEvents.contains(idx),
                                  // Make Google Calendar events read-only
                                  decoration: InputDecoration(
                                    hintText: 'Enter calendar',
                                    border: InputBorder.none,
                                    isDense: true,
                                    prefixIcon:
                                        _googleCalendarEvents.contains(idx)
                                            ? Icon(
                                              Icons.calendar_today_rounded,
                                              size: 16,
                                              color: colors.primary.withAlpha(
                                                (0.7 * 255).toInt(),
                                              ),
                                            )
                                            : null,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        _googleCalendarEvents.contains(idx)
                                            ? colors.onSurface.withAlpha(
                                              (0.8 * 255).toInt(),
                                            )
                                            : colors.onSurface,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  final result =
                                      await showDialog<Map<String, String>>(
                                        context: context,
                                        builder:
                                            (context) => _calendarTimeDialog(
                                              initialStart: startAt,
                                              initialEnd: endAt,
                                              isGoogleCalendarEvent:
                                                  _googleCalendarEvents
                                                      .contains(
                                                        idx,
                                                      ), // Pass directly
                                            ),
                                      );
                                  if (result != null) {
                                    setState(() {
                                      _calendarTimes[idx] = result;
                                    });
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 8.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.primaryContainer,
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(
                                      color: colors.primary,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    (startAt.isNotEmpty && endAt.isNotEmpty)
                                        ? '$startAt - $endAt'
                                        : 'Set time',
                                    style: TextStyle(
                                      color: colors.onPrimaryContainer,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                splashRadius: 18,
                                onPressed: () => _removecalendarAt(idx),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: _addcalendar,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 58.0,
                ),
                child: Row(
                  children: [
                    Text(
                      'Add calendar',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(), // ! Subjects Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Icon(
                    Icons.subject,
                    size: 22,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (_subjectControllers.isNotEmpty)
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children:
                          _subjectControllers.asMap().entries.map((entry) {
                            int idx = entry.key;
                            TextEditingController controller = entry.value;
                            FocusNode focusNode = _subjectFocusNodes[idx];
                            return Container(
                              margin: const EdgeInsets.only(
                                bottom: 4.0,
                                right: 12.0,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest.withAlpha(
                                  128,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: controller,
                                      focusNode: focusNode,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter subject',
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                      ),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 20),
                                    splashRadius: 18,
                                    onPressed: () => _removeSubjectAt(idx),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ),
              ],
            ),
            InkWell(
              onTap: _addSubject,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 58.0,
                ),
                child: Row(
                  children: [
                    Text(
                      'Add subject',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_subjectErrorText != null)
              Padding(
                padding: const EdgeInsets.only(left: 58.0, right: 12.0, bottom: 8.0),
                child: Text(
                  _subjectErrorText!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error, fontSize: 12),
                ),
              ),
            const Divider(), // ! Session Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Icon(
                    Icons.meeting_room_outlined,
                    size: 22,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: TextFormField(
                      controller: _sessionTimeController,
                      readOnly: true,
                      onTap: _showSessionClockDialog,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        errorText: _sessionTimeErrorText,
                        filled: true,
                        fillColor: colors.surfaceContainerHighest.withAlpha(128),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(), // ! Pause Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Icon(
                    Icons.pause_circle_outline_rounded,
                    size: 22,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: TextFormField(
                      controller: _pauseTimeController,
                      readOnly: true,
                      onTap: _showPauseClockDialog,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        errorText: _pauseTimeErrorText,
                        filled: true,
                        fillColor: colors.surfaceContainerHighest.withAlpha(128),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(), // ! Config Section
            const Divider(), // ! Rules Section
          ],
        ),
      ),
    );
  }
}

class _AddFriendsDialog extends StatefulWidget {
  final List<String> selectedFriends;
  final Function(String) onFriendSelected;

  const _AddFriendsDialog({
    required this.selectedFriends,
    required this.onFriendSelected,
  });

  @override
  State<_AddFriendsDialog> createState() => _AddFriendsDialogState();
}

class _AddFriendsDialogState extends State<_AddFriendsDialog> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode =
      FocusNode(); // Added for manual focus if needed later
  final List<String> _allFriends = [
    'Alice Wonderland',
    'Bob The Builder',
    'Charlie Brown',
    'David Copperfield',
    'Eve Harrington',
    'Fiona Gallagher',
    'George Costanza',
    'Harry Potter',
    'Ivy Dickens',
    'Jack Sparrow',
    'Katherine Pierce',
    'Leo Fitz',
  ];
  List<String> _filteredFriends = [];

  @override
  void initState() {
    super.initState();
    _filteredFriends = _allFriends;
    _searchController.addListener(_filterFriends);
    // Optionally, request focus after the frame is built if autofocus behavior is critical
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) {
    //     _searchFocusNode.requestFocus();
    //   }
    // });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterFriends);
    _searchController.dispose();
    _searchFocusNode.dispose(); // Dispose the focus node
    super.dispose();
  }

  void _filterFriends() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFriends =
          _allFriends.where((friend) {
            return friend.toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AlertDialog(
      backgroundColor: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
      titlePadding: const EdgeInsets.only(
        top: 24.0,
        left: 24.0,
        right: 24.0,
        bottom: 0,
      ),
      titleTextStyle: theme.textTheme.headlineSmall?.copyWith(
        color: colors.onSurface,
      ),
      title: const Text('Add Friends'),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.45,
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _searchController,
              focusNode: _searchFocusNode, // Assign the focus node
              // autofocus: true, // Removed autofocus
              decoration: InputDecoration(
                hintText: 'Search friends...',
                hintStyle: TextStyle(color: colors.onSurfaceVariant),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colors.onSurfaceVariant,
                ),
                filled: true,
                fillColor: colors.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
                isDense: true,
              ),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
                  child:
                  _filteredFriends.isEmpty
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No friends found.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _filteredFriends.length,
                        itemBuilder: (BuildContext context, int index) {
                          final friend = _filteredFriends[index];
                          final isSelected = widget.selectedFriends.contains(
                            friend,
                          );
                          return ListTile(
                            title: Text(
                              friend,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colors.onSurface,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                              vertical: 6.0,
                            ),
                            trailing:
                                isSelected
                                    ? Icon(
                                      Icons.check_circle_rounded,
                                      color: colors.primary,
                                    )
                                    : Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: colors.outline,
                                    ),
                            onTap: () {
                              if (!isSelected) {
                                widget.onFriendSelected(friend);
                                Navigator.pop(context);
                              }
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            tileColor: Colors.transparent,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _calendarTimeDialog extends StatefulWidget {
  final String initialStart;
  final String initialEnd;
  final bool isGoogleCalendarEvent; // Added

  const _calendarTimeDialog({
    this.initialStart = '',
    this.initialEnd = '',
    required this.isGoogleCalendarEvent, // Made required
    Key? key,
  }) : super(key: key);

  @override
  State<_calendarTimeDialog> createState() => _calendarTimeDialogState();
}

class _calendarTimeDialogState extends State<_calendarTimeDialog> {
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  late TextEditingController _startTimeTextController;
  late TextEditingController _endTimeTextController;
  bool _didChangeDependencies =
      false; // Flag to control didChangeDependencies logic
  String? _selectedDate;
  late bool
  _isGoogleCalendarEvent; // Changed from: bool _isGoogleCalendarEvent = false;

  @override
  void initState() {
    super.initState();
    _isGoogleCalendarEvent =
        widget.isGoogleCalendarEvent; // Initialize from widget

    _startTime = _parseTime(widget.initialStart);
    _endTime = _parseTime(widget.initialEnd);
    // Initialize controllers with empty text or a non-context-dependent placeholder
    _startTimeTextController = TextEditingController(
      text: widget.initialStart.isNotEmpty ? widget.initialStart : "HH:MM",
    );
    _endTimeTextController = TextEditingController(
      text: widget.initialEnd.isNotEmpty ? widget.initialEnd : "HH:MM",
    );
    // REMOVED: WidgetsBinding.instance.addPostFrameCallback block that previously fetched 'isGoogleCalendarEvent'
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Format and set text only once after dependencies are available
    if (!_didChangeDependencies) {
      // Now it's safe to use context for formatting
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
    if (tod == null) return 'HH:MM'; // Placeholder
    return '${tod.hour.toString().padLeft(2, '0')}:${tod.minute.toString().padLeft(2, '0')}';
  }

  String _formatTimeForReturn(BuildContext context, TimeOfDay? tod) {
    if (tod == null) return ""; // Empty for no selection
    return '${tod.hour.toString().padLeft(2, '0')}:${tod.minute.toString().padLeft(2, '0')}';
  }

  void _showTimeSelectionInfo() {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text(
          'You cannot change the time of a Google Calendar event',
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
      initialTime:
          isStartTime
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
      title: const Text('Appointment Details'),
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
            'Start Time',
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
            onTap:
                () =>
                    _isGoogleCalendarEvent
                        ? _showTimeSelectionInfo()
                        : _selectTime(context, true),
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'End Time',
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
            onTap:
                () =>
                    _isGoogleCalendarEvent
                        ? _showTimeSelectionInfo()
                        : _selectTime(context, false),
            style: textTheme.bodyLarge,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
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
          child: const Text('Confirm'),
          onPressed: () {
            Navigator.of(context).pop({
              'start_at': _formatTimeForReturn(context, _startTime),
              'end_at': _formatTimeForReturn(context, _endTime),
              'date':
                  _selectedDate ??
                  DateFormat('E, d MMM', 'it_IT').format(DateTime.now()),
            });
          },
        ),
      ],
    );
  }
}
