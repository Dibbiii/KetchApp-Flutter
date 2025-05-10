import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ketchapp_flutter/features/home/bloc/home_bloc.dart';
import 'package:ketchapp_flutter/app/themes/app_colors.dart'; // Import app_colors
import 'package:ketchapp_flutter/features/home/models/session_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Avoid potential build context issues in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Check if the widget is still in the tree
        context.read<HomeBloc>().add(LoadHomeData());
      }
    });
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
              // Access the sessions list directly from the state.
              // No need for '??' as HomeLoaded requires sessions.
              final List<Session> todaySessions = state.sessions;

              return SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, // Slightly reduced horizontal padding
                    vertical: 16.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30), // Adjusted spacing
                      Container(
                        padding: const EdgeInsets.all(18), // Adjusted padding
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lightbulb_outline,
                          // Changed icon to represent 'focus'
                          size: 60.0, // Adjusted size
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(height: 16), // Adjusted spacing
                      Text(
                        'Welcome Back!', // Or use state.userName if available
                        style: textTheme.headlineMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600, // Slightly less bold
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6), // Adjusted spacing
                      Text(
                        "Here's your focus for today.",
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24), // Adjusted spacing
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
                              if (todaySessions.isEmpty)
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
                                    itemCount: todaySessions.length,
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
                                          todaySessions[index]; // session is now a Session object
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
                      const Spacer(), // Pushes content above towards top
                    ],
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
}
