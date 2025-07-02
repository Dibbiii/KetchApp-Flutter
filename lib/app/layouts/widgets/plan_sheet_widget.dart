import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  final Map<int, double> _subjectDurations = {};

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
  late TextEditingController _breakTimeController;

  double _dialogBreakSelectedHours = 0.0;
  double _dialogSessionSelectedHours = 0.0;

  // Add controllers for all main inputs
  final TextEditingController _titleController = TextEditingController();

  // You already have _subjectControllers, _calendarControllers, etc.
  // Add variables for calendar, subjects, rules

  // Define fixed calendar events for Lunch, Dinner, and Sleep
  final List<Map<String, String>> _fixedCalendarEvents = [];

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
  String? _breakTimeErrorText;
  bool _saveAttempted = false;

  @override
  void initState() {
    super.initState();
    _sessionTimeController = TextEditingController(text: 'Add session time');
    _breakTimeController = TextEditingController(text: 'Add break time');

    _addSubject();
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
    _breakTimeController.dispose();
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
      _subjectDurations.remove(idx);
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
      _calendarTimes.remove(idx);
    });
  }

  void _showSubjectDurationDialog(int subjectIndex) {
    double initialHmmHours = _subjectDurations[subjectIndex] ?? 0.0;
    double tempSelectedHmmHours = initialHmmHours;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Set Study Duration'),
          contentPadding: const EdgeInsets.all(16.0),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter dialogSetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    formatDurationFromHmm(
                      tempSelectedHmmHours,
                      defaultText: "No duration set",
                    ),
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  MaterialClock(
                    initialSelectedHours: tempSelectedHmmHours,
                    onTimeChanged: (selectedHmm) {
                      dialogSetState(() {
                        tempSelectedHmmHours = selectedHmm;
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
                  _subjectDurations[subjectIndex] = tempSelectedHmmHours;
                });
                Navigator.pop(dialogContext);
              },
            ),
          ],
        );
      },
    );
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

  void _showBreakClockDialog() {
    double initialFractionalHours = 0.0;
    if (_breakTimeController.text.contains('h') ||
        _breakTimeController.text.contains('m')) {
      try {
        if (_breakTimeController.text.contains('h')) {
          List<String> parts = _breakTimeController.text
              .replaceAll(' h', '')
              .split(':');
          int hours = int.parse(parts[0]);
          int minutes = parts.length > 1 ? int.parse(parts[1]) : 0;
          initialFractionalHours = hours + (minutes / 60.0);
        } else if (_breakTimeController.text.contains('m')) {
          int minutes = int.parse(
            _breakTimeController.text.replaceAll(' m', ''),
          );
          initialFractionalHours = minutes / 60.0;
        }
      } catch (e) {
        initialFractionalHours = 0.0;
      }
    }
    double initialHmmHours = fractionalHoursToHmm(initialFractionalHours);
    double tempSelectedHmmBreakHours = initialHmmHours;

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
                      tempSelectedHmmBreakHours,
                      defaultText: "No break",
                    ),
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  MaterialClock(
                    initialSelectedHours: tempSelectedHmmBreakHours,
                    onTimeChanged: (selectedHmm) {
                      dialogSetState(() {
                        tempSelectedHmmBreakHours = selectedHmm;
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
                  _dialogBreakSelectedHours = tempSelectedHmmBreakHours;
                  _breakTimeController.text = formatDurationFromHmm(
                    _dialogBreakSelectedHours,
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

      final subjects = _subjectControllers
          .asMap()
          .entries
          .where((entry) => entry.value.text.trim().isNotEmpty)
          .map((entry) {
        final idx = entry.key;
        final controller = entry.value;
        final durationHmm = _subjectDurations[idx] ?? 0.0;
        final durationString =
            formatDurationFromHmm(durationHmm, defaultText: '0m');

        return SubjectEntry(
          subject: controller.text,
          duration: durationHmm > 0 ? durationString : null,
        );
      }).toList();

      final plan = PlanModel(
        userUUID: userUuid,
        session:
            formatDurationFromHmm(_dialogSessionSelectedHours, defaultText: '0m'),
        breakDuration:
            formatDurationFromHmm(_dialogBreakSelectedHours, defaultText: '0m'),
        calendar: calendar,
        subjects: subjects,
      );

      await ApiService().createPlan(plan);

      // Fetch and print today's tomatoes
      final todaysTomatoes = await ApiService().getTodaysTomatoes(userUuid);
      if (mounted && todaysTomatoes.isNotEmpty) {
        context.go('/timer/${todaysTomatoes.first.id}');
      }
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
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildSaveButton(),
    );
  }

  Widget _buildBody() {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.9,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(),
            _buildGoogleSync(),
            const Divider(),
            _buildSectionTitle("Your Appointments"),
            _buildCalendarSection(),
            const Divider(),
            _buildSectionTitle("Subjects to Study"),
            _buildSubjectsSection(),
            const Divider(),
            _buildSectionTitle("Timer Settings"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Text(
                'Set the duration for your study sessions and breaks.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
            _buildTimerSettingsSection(),
            const Divider(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Create New Plan',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleSync() {
    final colors = Theme.of(context).colorScheme;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated &&
            state.user.providerData
                .any((userInfo) => userInfo.providerId == 'google.com')) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCalendarSection() {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._calendarControllers.asMap().entries.map((entry) {
          int idx = entry.key;
          TextEditingController controller = entry.value;
          FocusNode focusNode = _calendarFocusNodes[idx];
          final startAt = _calendarTimes[idx]?['start_at'] ?? '';
          final endAt = _calendarTimes[idx]?['end_at'] ?? '';
          final bool showError =
              _saveAttempted && (startAt.isEmpty || endAt.isEmpty);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withAlpha(128),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        readOnly: _googleCalendarEvents.contains(idx),
                        decoration: InputDecoration(
                          hintText: 'Enter calendar event',
                          border: InputBorder.none,
                          isDense: true,
                          prefixIcon: _googleCalendarEvents.contains(idx)
                              ? Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                  color: colors.primary
                                      .withAlpha((0.7 * 255).toInt()),
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          color: _googleCalendarEvents.contains(idx)
                              ? colors.onSurface.withAlpha((0.8 * 255).toInt())
                              : colors.onSurface,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final result = await showDialog<Map<String, String>>(
                          context: context,
                          builder: (context) => _calendarTimeDialog(
                            initialStart: startAt,
                            initialEnd: endAt,
                            isGoogleCalendarEvent:
                                _googleCalendarEvents.contains(idx),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            _calendarTimes[idx] = result;
                          });
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: showError
                              ? colors.errorContainer.withOpacity(0.5)
                              : colors.primaryContainer,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                              color: showError ? colors.error : colors.primary,
                              width: 1),
                        ),
                        child: Text(
                          (startAt.isNotEmpty && endAt.isNotEmpty)
                              ? '$startAt - $endAt'
                              : 'Set time',
                          style: TextStyle(
                            color: showError
                                ? colors.onErrorContainer
                                : colors.onPrimaryContainer,
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
              ),
              if (showError)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 16, 8),
                  child: Text(
                    'Please set a time for this event.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          );
        }).toList(),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8),
          child: TextButton.icon(
            onPressed: _addcalendar,
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: const Text('Add event'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectsSection() {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Text(
            'Add the subjects you want to study and specify how long you want to study each one.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 8),
        if (_subjectControllers.isNotEmpty)
          ..._subjectControllers.asMap().entries.map((entry) {
            int idx = entry.key;
            TextEditingController controller = entry.value;
            FocusNode focusNode = _subjectFocusNodes[idx];
            final durationHmm = _subjectDurations[idx] ?? 0.0;
            final durationText =
                formatDurationFromHmm(durationHmm, defaultText: '');
            final bool isDurationSet = durationHmm > 0;
            final bool showError = _saveAttempted && !isDurationSet;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withAlpha(128),
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
                                horizontal: 16, vertical: 12),
                          ),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showSubjectDurationDialog(idx),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: showError
                                ? colors.errorContainer.withOpacity(0.5)
                                : colors.primaryContainer,
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color:
                                  showError ? colors.error : colors.primary,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 16,
                                color: showError
                                    ? colors.onErrorContainer
                                    : colors.onPrimaryContainer,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isDurationSet ? durationText : 'Set Duration',
                                style: TextStyle(
                                  color: showError
                                      ? colors.onErrorContainer
                                      : colors.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        splashRadius: 18,
                        onPressed: () => _removeSubjectAt(idx),
                      ),
                    ],
                  ),
                ),
                if (showError)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 16, 8),
                    child: Text(
                      'Please set a duration for this subject.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          }).toList(),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8),
          child: TextButton.icon(
            onPressed: _addSubject,
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: const Text('Add subject'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerSettingsSection() {
    final colors = Theme.of(context).colorScheme;
    final bool showSessionError =
        _saveAttempted && _dialogSessionSelectedHours == 0.0;
    final bool showBreakError = _saveAttempted && _dialogBreakSelectedHours == 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _sessionTimeController,
              readOnly: true,
              onTap: _showSessionClockDialog,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: "Session",
                errorText: _sessionTimeErrorText,
                filled: true,
                fillColor: showSessionError
                    ? colors.errorContainer.withOpacity(0.5)
                    : colors.surfaceContainerHighest.withAlpha(128),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: showSessionError
                      ? BorderSide(color: colors.error)
                      : BorderSide.none,
                ),
                prefixIcon: Icon(
                  Icons.timelapse_rounded,
                  color: showSessionError
                      ? colors.error
                      : colors.onSurfaceVariant,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: _breakTimeController,
              readOnly: true,
              onTap: _showBreakClockDialog,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: "Break",
                errorText: _breakTimeErrorText,
                filled: true,
                fillColor: showBreakError
                    ? colors.errorContainer.withOpacity(0.5)
                    : colors.surfaceContainerHighest.withAlpha(128),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: showBreakError
                      ? BorderSide(color: colors.error)
                      : BorderSide.none,
                ),
                prefixIcon: Icon(
                  Icons.pause_circle_outline_rounded,
                  color: showBreakError
                      ? colors.error
                      : colors.onSurfaceVariant,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: FilledButton.icon(
        icon: const Icon(Icons.save),
        label: const Text('Save Plan'),
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          setState(() {
            _saveAttempted = true;
          });

          final subjects = _subjectControllers
              .asMap()
              .entries
              .where((entry) => entry.value.text.trim().isNotEmpty)
              .toList();

          String? subjectError;
          if (subjects.isEmpty) {
            subjectError = 'Please add at least one subject.';
          } else {
            final allDurationsSet = subjects.every((entry) {
              final idx = entry.key;
              return (_subjectDurations[idx] ?? 0.0) > 0.0;
            });

            if (!allDurationsSet) {
              subjectError = 'Please set a duration for every subject.';
            }
          }

          final sessionError = _dialogSessionSelectedHours == 0.0
              ? 'Session time must be greater than 0.'
              : null;
          final breakError = _dialogBreakSelectedHours == 0.0
              ? 'Break time must be greater than 0.'
              : null;

          setState(() {
            _subjectErrorText = subjectError;
            _sessionTimeErrorText = sessionError;
            _breakTimeErrorText = breakError;
          });

          if (subjectError != null ||
              sessionError != null ||
              breakError != null) {
            return;
          }

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

          final subjectsWithDuration = _subjectControllers
              .asMap()
              .entries
              .where((entry) => entry.value.text.trim().isNotEmpty)
              .map((entry) {
            final idx = entry.key;
            final controller = entry.value;
            final durationHmm = _subjectDurations[idx] ?? 0.0;
            final durationString =
                formatDurationFromHmm(durationHmm, defaultText: '0m');

            return SubjectEntry(
              subject: controller.text,
              duration: durationHmm > 0 ? durationString : null,
            );
          }).toList();

          final plan = PlanModel(
            userUUID: userUuid,
            session:
                formatDurationFromHmm(_dialogSessionSelectedHours, defaultText: '0m'),
            breakDuration:
                formatDurationFromHmm(_dialogBreakSelectedHours, defaultText: '0m'),
            calendar: calendar,
            subjects: subjectsWithDuration,
          );

          if (mounted) {
            context.go('/plan-creation-loading', extra: plan);
          }
        },
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
