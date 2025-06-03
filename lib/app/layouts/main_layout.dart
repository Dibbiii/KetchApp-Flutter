import 'package:flutter/material.dart';
import 'package:ketchapp_flutter/components/clock_widget.dart';
import 'package:ketchapp_flutter/components/footer.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => const _ShowBottomSheet(),
            isScrollControlled: true,
            enableDrag: true,
            // Allows dragging the sheet itself
            showDragHandle: true,
            // Displays the drag handle
            barrierColor: Colors.black.withOpacity(
              0.5,
            ), // Make background darker
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const Footer(),
    );
  }
}

class _ShowBottomSheet extends StatefulWidget {
  const _ShowBottomSheet(); // Removed super.key as it's not used

  @override
  State<_ShowBottomSheet> createState() => _ShowBottomSheetState();
}

class _ShowBottomSheetState extends State<_ShowBottomSheet> {
  int selectedType = 0; // 0: Event, 1: Task, 2: Birthday
  final List<TextEditingController> _subjectControllers = [];
  final List<FocusNode> _subjectFocusNodes = [];
  final List<TextEditingController> _appointmentControllers = [];
  final List<FocusNode> _appointmentFocusNodes = [];
  late TextEditingController _sessionTimeController;
  late TextEditingController _pauseTimeController;
  final List<String> _selectedFriends = [];

  double _dialogPauseSelectedHours = 0.0;

  @override
  void initState() {
    super.initState();
    _sessionTimeController = TextEditingController(text: 'Add session time');
    _pauseTimeController = TextEditingController(text: 'Add pause time');

    _addSubject();
    _addAppointment();
  }

  @override
  void dispose() {
    for (var controller in _subjectControllers) {
      controller.dispose();
    }
    for (var focusNode in _subjectFocusNodes) {
      focusNode.dispose();
    }
    for (var controller in _appointmentControllers) {
      controller.dispose();
    }
    for (var focusNode in _appointmentFocusNodes) {
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

  void _addAppointment() {
    final newController = TextEditingController();
    final newFocusNode = FocusNode();
    setState(() {
      _appointmentControllers.add(newController);
      _appointmentFocusNodes.add(newFocusNode);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      newFocusNode.requestFocus();
    });
  }

  void _removeAppointmentAt(int idx) {
    setState(() {
      _appointmentControllers[idx].dispose();
      _appointmentFocusNodes[idx].dispose();
      _appointmentControllers.removeAt(idx);
      _appointmentFocusNodes.removeAt(idx);
    });
  }

  Future<void> _showSessionTimePickerDialog() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select Session time:',
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        final String hours = pickedTime.hour.toString().padLeft(2, '0');
        final String minutes = pickedTime.minute.toString().padLeft(2, '0');
        _sessionTimeController.text = '${hours}ore e ${minutes}minuti';
      });
    }
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
          title: const Text('Imposta Durata Pausa'),
          contentPadding: const EdgeInsets.all(16.0),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter dialogSetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    formatDurationFromHmm(
                      tempSelectedHmmPauseHours,
                      defaultText: "Nessuna pausa",
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
              child: const Text('Annulla'),
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
                    defaultText: "Aggiungi pausa",
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
                    onPressed: () {
                      // TODO: Save logic
                      Navigator.pop(context);
                    },
                    child: const Text('Save', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 42),
              child: const TextField(
                style: TextStyle(fontSize: 22),
                decoration: InputDecoration(
                  hintText: 'Add Title',
                  border: InputBorder.none,
                  filled: true,
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
                                    child: TextField(
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
            const Divider(), // ! Appointments Section
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
                if (_appointmentControllers.isNotEmpty)
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children:
                          _appointmentControllers.asMap().entries.map((entry) {
                            int idx = entry.key;
                            TextEditingController controller = entry.value;
                            FocusNode focusNode = _appointmentFocusNodes[idx];
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
                                      decoration: const InputDecoration(
                                        hintText: 'Enter appointment',
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
                                    onPressed: () => _removeAppointmentAt(idx),
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
              onTap: _addAppointment,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 58.0,
                ),
                child: Row(
                  children: [
                    Text(
                      'Add appointment',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(), // ! Session Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  child: Container(
                    margin: const EdgeInsets.only(right: 12.0, bottom: 4.0),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withAlpha(128),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _sessionTimeController,
                      readOnly: true,
                      onTap: _showSessionTimePickerDialog,
                      decoration: const InputDecoration(
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
                  child: InkWell(
                    onTap: _showPauseClockDialog,
                    child: Container(
                      margin: const EdgeInsets.only(
                        right: 12.0,
                        top: 8.0,
                        bottom: 8.0,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withAlpha(128),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _pauseTimeController.text,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
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
            const Divider(),
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
