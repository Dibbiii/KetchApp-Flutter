import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ketchapp_flutter/components/footer.dart'; // Import Footer
import 'package:ketchapp_flutter/app/themes/app_colors.dart'; // Import app_colors
import 'package:ketchapp_flutter/components/animated_gradient_text.dart'; // Import the new widget

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextStyle? bottomSheetTextStyle = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(color: colors.onSurface); // Get default style

    // Define the gradient colors
    const List<Color> gradientColors = <Color>[
      kTomatoRed,
      Colors.orangeAccent,
      Colors.purpleAccent,
      kTomatoRed, // Add start color at the end for smoother loop
    ];

    return Scaffold(
      // The body will be the specific page (like HomePage, ProfilePage)
      body: child,

      // Remove the wrapping Container, define the FAB directly
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show the bottom sheet with plan options
          showModalBottomSheet(
            context: context, // Use the context from MainLayout
            backgroundColor: colors.surface, // Match FAB background
            builder:
                (modalContext) => Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.edit_note, color: kTomatoRed),
                        title: Text(
                          'Create Manual Plan',
                          style: bottomSheetTextStyle, // Apply consistent style
                        ),
                        onTap: () {
                          Navigator.pop(modalContext); // Close bottom sheet
                          // Use context.push from the MainLayout's context
                          context.push('/plan/manual');
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.auto_awesome, color: kTomatoRed),
                        // Use the AnimatedGradientText widget
                        title: AnimatedGradientText(
                          text: 'Plan with AI',
                          colors: gradientColors,
                          style: bottomSheetTextStyle?.copyWith(
                            fontWeight: FontWeight.bold,
                          ), // Make AI text bold and inherit color for mask
                          duration: const Duration(seconds: 4), // Adjust speed
                        ),
                        onTap: () {
                          Navigator.pop(modalContext); // Close bottom sheet
                          // Use context.push from the MainLayout's context
                          context.push('/plan/automatic');
                        },
                      ),
                    ],
                  ),
                ),
          );
        },
        // Restore original FAB styling
        backgroundColor: colors.surface,
        foregroundColor: kTomatoRed,
        tooltip: 'Create Plan',
        shape: const CircleBorder(),
        // Make the FAB circular
        child: const Icon(Icons.add, size: 28),
      ),
      // Set the location for the FAB
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Assign the Footer to the bottomNavigationBar
      bottomNavigationBar: const Footer(),
    );
  }
}
