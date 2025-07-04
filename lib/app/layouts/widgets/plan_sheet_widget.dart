import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../components/clock_widget.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/plan/models/plan_model.dart';
import '../../../services/api_service.dart';
import '../../../services/calendar_service.dart';

class ShowBottomSheet extends StatefulWidget {
  const ShowBottomSheet({super.key});

  @override
  State<ShowBottomSheet> createState() => _ShowBottomSheetState();
}

class _ShowBottomSheetState extends State<ShowBottomSheet>
    with TickerProviderStateMixin {
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


  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _sessionTimeController = TextEditingController(text: 'Add session time');
    _breakTimeController = TextEditingController(text: 'Add break time');
    _addSubject();

    // Start animations
    _fadeAnimationController.forward();
    _slideAnimationController.forward();
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    // Remove _titleController disposal since we're removing the title section
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
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  void _addSubject() {
    final newController = TextEditingController();
    final newFocusNode = FocusNode();

    setState(() {
      _subjectControllers.add(newController);
      _subjectFocusNodes.add(newFocusNode);
      _subjectDurations[_subjectControllers.length - 1] = 1.0; // Default 1 hour
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
                if (!mounted) return;
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
              .replaceAll('h', '')
              .split(':');
          int hours = int.parse(parts[0]);
          int minutes = parts.length > 1 ? int.parse(parts[1]) : 0;
          initialFractionalHours = hours + (minutes / 60.0);
        } else if (_sessionTimeController.text.contains('m')) {
          int minutes = int.parse(
            _sessionTimeController.text.replaceAll('m', ''),
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
                if (!mounted) return;
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
              .replaceAll('h', '')
              .split(':');
          int hours = int.parse(parts[0]);
          int minutes = parts.length > 1 ? int.parse(parts[1]) : 0;
          initialFractionalHours = hours + (minutes / 60.0);
        } else if (_breakTimeController.text.contains('m')) {
          int minutes = int.parse(
            _breakTimeController.text.replaceAll('m', ''),
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
                if (!mounted) return;
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
    if (!_formKey.currentState!.validate()) {
      // Show error if form is not valid
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

      if (mounted) {
        Navigator.of(context).pop(); // Close the bottom sheet
        context.push('/plan-creation-loading', extra: plan);
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
    // Remove only Google events
    final List<int> googleEventIndices = _googleCalendarEvents.toList()..sort();
    for (int i = googleEventIndices.length - 1; i >= 0; i--) {
      final idx = googleEventIndices[i];
      if (idx < _calendarControllers.length) {
        _calendarControllers[idx].dispose();
        _calendarFocusNodes[idx].dispose();
        _calendarControllers.removeAt(idx);
        _calendarFocusNodes.removeAt(idx);
        _calendarTimes.remove(idx);
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
    _googleCalendarEvents.clear();
    setState(() {});
  }

  void _syncGoogleCalendar() async {
    if (!mounted) return;

    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Syncing with Google Calendar...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Clear existing Google Calendar events first
      _clearGoogleCalendarEvents();

      // Fetch events from Google Calendar
      final events = await _calendarService.getEvents();

      if (!mounted) return;

      setState(() {
        // Add new Google Calendar events
        for (var event in events) {
          final startTime = event.start?.dateTime?.toLocal();
          final endTime = event.end?.dateTime?.toLocal();

          if (startTime != null && endTime != null) {
            final controller = TextEditingController(
              text: event.summary ?? 'Untitled Event',
            );
            final focusNode = FocusNode();

            _calendarControllers.add(controller);
            _calendarFocusNodes.add(focusNode);

            final newIndex = _calendarControllers.length - 1;
            _calendarTimes[newIndex] = {
              'start_at': DateFormat('HH:mm').format(startTime),
              'end_at': DateFormat('HH:mm').format(endTime),
              'date': DateFormat('E, d MMM').format(startTime),
            };
            _googleCalendarEvents.add(newIndex);
          }
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully synced ${events.length} events from Google Calendar'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sync with Google Calendar: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Turn off the sync toggle if it failed
        setState(() {
          _syncWithGoogleCalendar = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: _formKey,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context, colors, textTheme),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSubjectsSection(context, colors, textTheme),
                        const SizedBox(height: 24),
                        _buildTimingSection(context, colors, textTheme),
                        const SizedBox(height: 24),
                        _buildCalendarSection(context, colors, textTheme),
                        const SizedBox(height: 32),
                        _buildActionButtons(context, colors, textTheme)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colors, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primaryContainer.withValues(alpha: 0.8),
            colors.tertiaryContainer.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Removed all clippers (drag handle and close button at the top)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.event_note_rounded,
                  color: colors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Plan Your Focus",
                      style: textTheme.headlineSmall?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Create your perfect study schedule",
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onPrimaryContainer.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildSubjectsSection(BuildContext context, ColorScheme colors, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.subject_rounded,
                    color: colors.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Study Subjects',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_subjectControllers.length}',
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _subjectControllers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildSubjectItem(context, index, colors, textTheme);
              },
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.2),
                  style: BorderStyle.solid,
                ),
              ),
              child: TextButton.icon(
                onPressed: _addSubject,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Subject'),
                style: TextButton.styleFrom(
                  foregroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            if (_subjectControllers.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  'At least one subject is required',
                  style: textTheme.bodySmall?.copyWith(color: colors.error, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectItem(BuildContext context, int index, ColorScheme colors, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.book_rounded,
                    color: colors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    child: TextFormField(
                      controller: _subjectControllers[index],
                      focusNode: _subjectFocusNodes[index],
                      decoration: InputDecoration(
                        hintText: 'Enter subject name...',
                        hintStyle: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colors.onSurface,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Subject name is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (_subjectControllers.length > 1)
                  Container(
                    decoration: BoxDecoration(
                      color: colors.errorContainer.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () => _removeSubjectAt(index),
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                      iconSize: 20,
                      color: colors.error,
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showSubjectDurationDialog(index),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.tertiaryContainer.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.schedule_rounded,
                            color: colors.tertiary,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Study Duration',
                                style: textTheme.labelMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatDurationFromHmm(
                                  _subjectDurations[index] ?? 1.0,
                                  defaultText: "1h",
                                ),
                                style: textTheme.titleMedium?.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.access_time_rounded,
                          color: colors.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget _buildTimingSection(BuildContext context, ColorScheme colors, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.tertiaryContainer.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.schedule_rounded,
                    color: colors.tertiary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Session Settings',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimingField(
                    context,
                    'Focus Time',
                    _sessionTimeController,
                    Icons.play_circle_filled_rounded,
                    colors.primary,
                    colors,
                    textTheme,
                    () => _showSessionClockDialog(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimingField(
                    context,
                    'Break Time',
                    _breakTimeController,
                    Icons.pause_circle_filled_rounded,
                    colors.secondary,
                    colors,
                    textTheme,
                    () => _showBreakClockDialog(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon,
    Color iconColor,
    ColorScheme colors,
    TextTheme textTheme,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.text == 'Add session time' || controller.text == 'Add break time'
                      ? 'Set time'
                      : controller.text,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (label == 'Focus Time' && (_dialogSessionSelectedHours <= 0))
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Session time must be > 0',
                      style: textTheme.bodySmall?.copyWith(color: colors.error, fontWeight: FontWeight.w600),
                    ),
                  ),
                if (label == 'Break Time' && (_dialogBreakSelectedHours <= 0))
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Break time must be > 0',
                      style: textTheme.bodySmall?.copyWith(color: colors.error, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
        ),
      )
    );
  }

  Widget _buildCalendarSection(BuildContext context, ColorScheme colors, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.tertiaryContainer.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    color: colors.tertiary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Calendar Events',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.tertiary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_calendarControllers.length}',
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.sync_rounded,
                      color: colors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sync with Google Calendar',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Switch(
                      value: _syncWithGoogleCalendar,
                      onChanged: (value) {
                        setState(() {
                          _syncWithGoogleCalendar = value;
                        });
                        if (value) {
                          _syncGoogleCalendar();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _calendarControllers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildCalendarItem(context, index, colors, textTheme);
              },
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.2),
                  style: BorderStyle.solid,
                ),
              ),
              child: TextButton.icon(
                onPressed: _addcalendar,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Custom Event'),
                style: TextButton.styleFrom(
                  foregroundColor: colors.tertiary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarItem(BuildContext context, int index, ColorScheme colors, TextTheme textTheme) {
    final isGoogleEvent = _googleCalendarEvents.contains(index);
    final isFixedEvent = index < 3; // 0: Lunch, 1: Dinner, 2: Sleep

    // Define icon, color, and label for fixed events
    IconData? fixedIcon;
    Color? fixedColor;
    String? fixedLabel;
    if (isFixedEvent) {
      switch (index) {
        case 0:
          fixedIcon = Icons.lunch_dining_rounded;
          fixedColor = Colors.orangeAccent;
          fixedLabel = 'Lunch';
          break;
        case 1:
          fixedIcon = Icons.dinner_dining_rounded;
          fixedColor = Colors.deepPurpleAccent;
          fixedLabel = 'Dinner';
          break;
        case 2:
          fixedIcon = Icons.nightlight_round;
          fixedColor = Colors.blueAccent;
          fixedLabel = 'Sleep';
          break;
      }
    }

    return Container(
      decoration: BoxDecoration(
        gradient: isFixedEvent
            ? LinearGradient(
                colors: [
                  fixedColor!.withValues(alpha: 0.12),
                  colors.surfaceContainerHigh.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: !isFixedEvent
            ? colors.surfaceContainerHigh.withValues(alpha: 0.6)
            : null,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isGoogleEvent
              ? colors.primary.withValues(alpha: 0.3)
              : isFixedEvent
                  ? fixedColor!.withValues(alpha: 0.3)
                  : colors.outline.withValues(alpha: 0.1),
          width: isGoogleEvent || isFixedEvent ? 1.8 : 1,
        ),
        boxShadow: isFixedEvent
            ? [
                BoxShadow(
                  color: fixedColor!.withValues(alpha: 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: isFixedEvent
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: fixedColor!.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(fixedIcon, color: fixedColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                fixedLabel!,
                                style: textTheme.titleMedium?.copyWith(
                                  color: fixedColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded),
                              color: colors.error,
                              tooltip: 'Rimuovi',
                              onPressed: () {
                                setState(() {
                                  // Rimuovi l'evento fisso dalla UI
                                  _calendarControllers.removeAt(index);
                                  _calendarFocusNodes.removeAt(index);
                                  _calendarTimes.remove(index);
                                  // Shift down gli altri eventi fissi se necessario
                                  for (int i = index + 1; i < 3; i++) {
                                    if (_calendarTimes.containsKey(i)) {
                                      _calendarTimes[i - 1] = _calendarTimes[i]!;
                                      _calendarTimes.remove(i);
                                    }
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              'Orario:',
                              style: textTheme.labelMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_calendarTimes[index]?['start_at']} - ${_calendarTimes[index]?['end_at']}',
                              style: textTheme.bodyMedium?.copyWith(
                                color: fixedColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => _editCalendarTime(context, index),
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          label: const Text('Modifica orario'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: fixedColor,
                            side: BorderSide(color: fixedColor),
                            textStyle: textTheme.labelLarge,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isGoogleEvent
                          ? colors.primaryContainer
                          : isFixedEvent
                              ? fixedColor!.withValues(alpha: 0.18)
                              : colors.errorContainer.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isGoogleEvent
                          ? Icons.sync_rounded
                          : isFixedEvent
                              ? fixedIcon
                              : Icons.event_rounded,
                      color: isGoogleEvent
                          ? colors.primary
                          : isFixedEvent
                              ? fixedColor
                              : colors.error,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextFormField(
                      controller: _calendarControllers[index],
                      focusNode: _calendarFocusNodes[index],
                      enabled: !isGoogleEvent && !isFixedEvent, // Fixed events are not editable
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (!isFixedEvent && !isGoogleEvent && (value == null || value.trim().isEmpty)) {
                          return 'Event name cannot be empty';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        hintText: isFixedEvent ? fixedLabel : null,
                        hintStyle: textTheme.bodyLarge?.copyWith(color: fixedColor?.withValues(alpha: 0.7)),
                        errorStyle: textTheme.bodySmall?.copyWith(color: colors.error, fontWeight: FontWeight.w600),
                      ),
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isGoogleEvent
                            ? colors.onSurfaceVariant
                            : isFixedEvent
                                ? fixedColor
                                : colors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isFixedEvent ? fixedColor!.withValues(alpha: 0.10) : colors.surfaceContainerHigh.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_calendarTimes[index]?['start_at']} - ${_calendarTimes[index]?['end_at']}',
                      style: textTheme.bodySmall?.copyWith(
                        color: isFixedEvent ? fixedColor : colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Show trash for all events (fixed, custom, google)
                  IconButton(
                    onPressed: () => _removecalendarAt(index),
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    iconSize: 18, // Match subject delete button
                    color: colors.error,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    tooltip: 'Delete',
                  ),
                  if (!isFixedEvent)
                    IconButton(
                      onPressed: () => _editCalendarTime(context, index),
                      icon: const Icon(Icons.edit_rounded),
                      iconSize: 18,
                      color: colors.onSurfaceVariant,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
      ),
    );
  }


  void _removeSubject(int index) {
    setState(() {
      _subjectControllers[index].dispose();
      _subjectFocusNodes[index].dispose();
      _subjectControllers.removeAt(index);
      _subjectFocusNodes.removeAt(index);
      _subjectDurations.remove(index);

      // Reindex the remaining durations
      final newDurations = <int, double>{};
      for (int i = 0; i < _subjectControllers.length; i++) {
        if (i < index) {
          newDurations[i] = _subjectDurations[i] ?? 1.0;
        } else {
          newDurations[i] = _subjectDurations[i + 1] ?? 1.0;
        }
      }
      _subjectDurations.clear();
      _subjectDurations.addAll(newDurations);
    });
  }

  void _showSessionTimeDialog(BuildContext context) {
    // Implementation for session time dialog
  }

  void _showBreakTimeDialog(BuildContext context) {
    // Implementation for break time dialog
  }

  void _editCalendarTime(BuildContext context, int index) {
    final currentTimes = _calendarTimes[index] ?? {'start_at': '12:00', 'end_at': '13:00'};

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String startTime = currentTimes['start_at']!;
        String endTime = currentTimes['end_at']!;

        return AlertDialog(
          title: Text('Edit Event Time'),
          contentPadding: const EdgeInsets.all(20),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter dialogSetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.play_circle_outline_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text('Start Time'),
                      subtitle: Text(startTime),
                      trailing: Icon(Icons.edit_rounded),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: dialogContext,
                          initialTime: TimeOfDay(
                            hour: int.parse(startTime.split(':')[0]),
                            minute: int.parse(startTime.split(':')[1]),
                          ),
                        );
                        if (picked != null) {
                          dialogSetState(() {
                            startTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.stop_circle_outlined,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      title: Text('End Time'),
                      subtitle: Text(endTime),
                      trailing: Icon(Icons.edit_rounded),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: dialogContext,
                          initialTime: TimeOfDay(
                            hour: int.parse(endTime.split(':')[0]),
                            minute: int.parse(endTime.split(':')[1]),
                          ),
                        );
                        if (picked != null) {
                          dialogSetState(() {
                            endTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                          });
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _calendarTimes[index] = {
                    'start_at': startTime,
                    'end_at': endTime,
                  };
                });
                Navigator.pop(dialogContext);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colors, TextTheme textTheme) {
    final bool hasFormErrors = _formKey.currentState == null || !_formKey.currentState!.validate();
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.outline.withValues(alpha: 0.2),
              ),
            ),
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
              label: const Text('Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: colors.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primary,
                  colors.primary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FilledButton.icon(
              onPressed: hasFormErrors ? null : _createPlan,
              icon: const Icon(Icons.rocket_launch_rounded),
              label: const Text('Create Plan'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: colors.onPrimary,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
