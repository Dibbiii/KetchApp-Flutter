import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ketchapp_flutter/features/home/bloc/home_bloc.dart';
import 'package:ketchapp_flutter/features/home/models/session_model.dart';
import 'package:ketchapp_flutter/services/calendar_service.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  // List<Session> todaySessions = []; // This might be redundant if HomeBloc provides sessions
  // bool isLoadingSessions = true; // This might be redundant

  // Aggiunte per Google Calendar
  final CalendarService _calendarService = CalendarService();
  List<cal.Event> _calendarEvents = [];
  bool _isLoadingCalendarEvents = false;

  @override
  void initState() {
    super.initState();
    // _fetchTodaySessions(); // Consider if this is still needed or handled by HomeBloc
    _fetchCalendarEvents(); // Chiama il metodo per caricare gli eventi del calendario
  }

  // Future<void> _fetchTodaySessions() async { // Consider removing if redundant
  //   // ...existing code...
  // }

  Future<void> _fetchCalendarEvents() async {
    if (!mounted) return;
    setState(() {
      _isLoadingCalendarEvents = true;
    });
    try {
      final events = await _calendarService.getEvents();
      if (!mounted) return;
      setState(() {
        _calendarEvents = events;
      });
    } catch (e) {
      if (!mounted) return;
      print("Errore nel caricare gli eventi da Google Calendar: $e");
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingCalendarEvents = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Size size = MediaQuery.of(context).size;

    final SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: colors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: Scaffold(
        backgroundColor: colors.surface,
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            // --- Loading State ---
            if (state is HomeLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: colors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Loading your focus...', // Slightly more descriptive
                      style: TextStyle(
                        color: colors.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              );
            }
            // --- Loaded State ---
            else if (state is HomeLoaded) {
              final List<Session> todaySessionsFromBloc = state.sessions;

              return SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: SingleChildScrollView( // Wrap with SingleChildScrollView
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lightbulb_outline,
                            size: 60.0,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Welcome Back!', // Or use state.userName if available
                          style: textTheme.headlineMedium?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w600, // Slightly less bold
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Here's your focus for today.",
                          style: textTheme.bodyLarge?.copyWith(
                            color: colors.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        // --- Middle Section (Daily Summary Card) ---
                        Card(
                          elevation: 1.5,
                          // Further reduced elevation
                          margin: EdgeInsets.zero,
                          // Remove card margin, use Padding margin
                          clipBehavior: Clip.antiAlias,
                          // Clip content to rounded corners
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            // Slightly larger radius
                            side: BorderSide(
                              // Add a subtle border
                              color: colors.outline.withOpacity(0.2),
                              width: 1.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            // Only vertical padding here
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              // Stretch children horizontally
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  // Add padding for the title
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Text(
                                    "Today's Focus",
                                    style: textTheme.titleLarge?.copyWith(
                                      color: colors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Space before divider or content
                                if (todaySessionsFromBloc.isEmpty)
                                  Padding(
                                    // Improved Empty State
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 24.0,
                                      horizontal: 16.0,
                                    ),
                                    child: Column(
                                      // Use column for icon + text
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.add_task_rounded,
                                          size: 40,
                                          color: colors.onSurface.withOpacity(
                                            0.4,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          "Nothing planned yet!\nTap '+' below to create a study plan.",
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: colors.onSurfaceVariant,
                                            height: 1.4, // Improve line spacing
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                                else ...[
                                  // Use spread operator for list content
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                    indent: 16,
                                    endIndent: 16,
                                  ), // Divider below title
                                  ConstrainedBox(
                                    // Keep constrained box for scrollable list
                                    constraints: BoxConstraints(
                                      // Max height based on screen size, but capped
                                      maxHeight: math.min(
                                        size.height * 0.35,
                                        300,
                                      ), // Example: max 35% or 300px
                                    ),
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      // Remove ListView padding
                                      itemCount: todaySessionsFromBloc.length,
                                      separatorBuilder:
                                          (_, __) => Divider(
                                            height: 1,
                                            thickness: 1,
                                            // Make divider slightly thicker
                                            color: colors.outline.withOpacity(
                                              0.2,
                                            ),
                                            // Subtle divider
                                            indent: 16,
                                            // Indent divider
                                            endIndent: 16,
                                          ),
                                      itemBuilder: (context, index) {
                                        final session =
                                            todaySessionsFromBloc[index]; // session is now a Session object
                                        return ListTile(
                                          dense: false,
                                          // Make list tiles slightly taller
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                vertical: 6.0,
                                                // Adjust vertical padding
                                                horizontal:
                                                    16.0, // Match card padding
                                              ),
                                          leading: Icon(
                                            // Use specific icons per subject? (Future idea)
                                            Icons.menu_book_rounded,
                                            // Consistent icon
                                            color: colors.primary.withOpacity(0.9),
                                            size: 22,
                                          ),
                                          title: Text(
                                            session.subject,
                                            // Access subject property
                                            style: textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: colors.onSurface,
                                            ),
                                          ),
                                          subtitle: Text(
                                            session.task,
                                            // Access task property
                                            style: textTheme.bodyMedium?.copyWith(
                                              color: colors.onSurfaceVariant,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          // Add trailing icon/action later (e.g., checkbox, arrow)
                                          // trailing: Icon(Icons.chevron_right),
                                          // onTap: () { /* Navigate to session details? */ },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16), // Spazio tra le card

                        // Card per gli eventi di Google Calendar
                        Card(
                          elevation: 2, // Consistent elevation
                          margin: const EdgeInsets.symmetric(vertical: 8.0), // Consistent margin
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // Consistent shape
                          ),
                          color: colors.surfaceContainerLowest, // Consistent color
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Prossimi impegni dal calendario',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (_isLoadingCalendarEvents)
                                  const Center(child: CircularProgressIndicator())
                                else if (_calendarEvents.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                                    child: Center(
                                      child: Text(
                                        'Nessun impegno imminente nel calendario.',
                                        textAlign: TextAlign.center,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colors.onSurfaceVariant.withOpacity(0.7),
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(), // Important for nested lists
                                    padding: EdgeInsets.zero,
                                    itemCount: _calendarEvents.length,
                                    separatorBuilder: (_, __) => Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: colors.outline.withOpacity(0.2),
                                      indent: 16,
                                      endIndent: 16,
                                    ),
                                    itemBuilder: (context, index) {
                                      final event = _calendarEvents[index];
                                      final startTime = event.start?.dateTime?.toLocal() ?? event.start?.date?.toLocal();
                                      final endTime = event.end?.dateTime?.toLocal() ?? event.end?.date?.toLocal();
                                      String eventTimeDisplay = "Orario non specificato";
                                      if (startTime != null) {
                                        if (event.start?.date != null && event.end?.date != null && endTime != null && endTime.difference(startTime).inDays >=1) {
                                           eventTimeDisplay = "${DateFormat('E, d MMM', 'it_IT').format(startTime)}";
                                           if (endTime.difference(startTime).inDays > 0 && endTime.isAfter(startTime.add(Duration(days:1)))) { // Check if it's truly multi-day
                                             eventTimeDisplay += " - ${DateFormat('E, d MMM', 'it_IT').format(endTime.subtract(Duration(days:1)))}";
                                           } else if (endTime.difference(startTime).inDays == 1 && event.start?.date != null && event.end?.date != null) {
                                             // Single all-day event, no need for end date if it's the same day effectively
                                           }
                                        } else {
                                          eventTimeDisplay = DateFormat('E, d MMM HH:mm', 'it_IT').format(startTime);
                                          if (endTime != null && endTime != startTime) {
                                            eventTimeDisplay += " - ${DateFormat('HH:mm', 'it_IT').format(endTime)}";
                                          }
                                        }
                                      }

                                      return ListTile(
                                        dense: false,
                                        contentPadding: const EdgeInsets.symmetric(
                                          vertical: 6.0,
                                          horizontal: 16.0,
                                        ),
                                        leading: Icon(
                                          Icons.calendar_today_rounded,
                                          color: colors.primary.withOpacity(0.9),
                                          size: 22,
                                        ),
                                        title: Text(
                                          event.summary ?? 'Nessun titolo',
                                          style: textTheme.bodyLarge?.copyWith(
                                            color: colors.onSurface,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        subtitle: Text(
                                          eventTimeDisplay,
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colors.onSurfaceVariant,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                        // const Spacer(), // You might not need Spacer if SingleChildScrollView is used
                        const SizedBox(height: 30), // Add some padding at the bottom
                      ],
                    ),
                  ),
                ),
              );
            }
            // --- Error State ---
            else if (state is HomeError) {
              // (Error state code remains largely the same, ensure styling is consistent)
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: colors.error, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Oops! Something went wrong.',
                        style: textTheme.titleMedium?.copyWith(
                          color: colors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: textTheme.bodyMedium?.copyWith(
                          color:
                              colors
                                  .onSurfaceVariant, // Use a readable color on surface
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        onPressed:
                            () => context.read<HomeBloc>().add(LoadHomeData()),
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            // --- Initial or Unknown State ---
            else {
              return Center(
                child: Text(
                  'Initializing...',
                  style: TextStyle(color: colors.onSurface.withOpacity(0.7)),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // Remove the _buildHomeContent method as it's no longer used
  // Widget _buildHomeContent(BuildContext context, ColorScheme colors, TextTheme textTheme) { ... }
}
