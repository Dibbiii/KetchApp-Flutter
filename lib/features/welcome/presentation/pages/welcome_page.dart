import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';

// Imports for the new page view model files
import './page_one_view.dart';
import './page_two_view.dart';
import './page_three_view.dart';
import './page_four_auth_view.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _introKey = GlobalKey<IntroductionScreenState>();

  // REMOVED _buildPageViewModel method as it's now split into separate files
  // The old _buildPageViewModel logic is now in page_one_view.dart, page_two_view.dart, and page_three_view.dart
  // The inlined AuthOptionsPage logic is now in page_four_auth_view.dart

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    // REMOVED: final Size size = MediaQuery.of(context).size; // This is now handled within page_four_auth_view.dart if needed
    // REMOVED: final Gradient globalBackgroundGradient = LinearGradient(...); // This is now handled within page_four_auth_view.dart

    final List<PageViewModel> pages = [
      buildPageOneViewModel(
        // Called from page_one_view.dart
        colors: colors,
        primaryAccentColor: colors.primary,
      ),
      buildPageTwoViewModel(
        // Called from page_two_view.dart
        colors: colors,
        primaryAccentColor: colors.primary,
      ),
      buildPageThreeViewModel(
        // Called from page_three_view.dart
        colors: colors,
        primaryAccentColor: colors.primary,
      ),
      buildPageFourAuthViewModel(
        // Called from page_four_auth_view.dart
        context: context, // context is needed for MediaQuery and GoRouter
        colors: colors,
        textTheme: textTheme,
      ),
    ];

    // Function to navigate after intro completion or skip
    void goToLoginOrRegister(BuildContext ctx) {
      ctx.pushReplacement('/login'); // Navigate to login after intro
    }

    const SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: Scaffold(
        body: Container(
          color: Theme.of(context).colorScheme.background,
          child: IntroductionScreen(
            key: _introKey,
            // Assign the key here
            pages: pages,
            onDone: () => goToLoginOrRegister(context),
            // Updated navigation
            onSkip: () => goToLoginOrRegister(context),
            // Updated navigation
            showSkipButton: true,
            skip: TextButton(
              onPressed:
                  () => goToLoginOrRegister(context), // Updated navigation
              style: TextButton.styleFrom(
                foregroundColor: colors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18, // Increased padding
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ).copyWith(
                overlayColor: WidgetStateProperty.all(
                  Colors.yellow.withOpacity(0.15),
                ), // Yellow hover
              ),
              child: Text('Skip', style: textTheme.labelLarge),
            ),
            next: ElevatedButton(
              onPressed: () {
                _introKey.currentState?.next(); // Use key to go to next page
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16), // Increased padding
                shape: const CircleBorder(),
              ).copyWith(
                overlayColor: WidgetStateProperty.all(
                  Colors.yellow.withOpacity(0.15),
                ), // Yellow hover
              ),
              child: Icon(
                Icons.arrow_forward,
                size: 30, // Increased icon size
              ),
            ),
            done: FilledButton(
              onPressed:
                  () => goToLoginOrRegister(context), // Updated navigation
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 18, // Increased padding
                ),
              ).copyWith(
                overlayColor: WidgetStateProperty.all(
                  Colors.yellow.withOpacity(0.15),
                ), // Yellow hover
              ),
              child: Text(
                'Get Started', // Text for the done button
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            dotsDecorator: DotsDecorator(
              size: const Size.square(8.0),
              activeSize: const Size(20.0, 8.0),
              activeColor: colors.primary,
              color: colors.onSurface.withValues(alpha: 0.2),
              spacing: const EdgeInsets.symmetric(horizontal: 4.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
            // --- Behavior & Layout ---
            isProgressTap: false,
            freeze: false,
            bodyPadding: EdgeInsets.zero,
            // Let PageViewModel handle body padding
            controlsPadding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
            globalBackgroundColor: Colors.transparent,
            // When the last page is a custom widget (AuthOptionsPage),
            // the 'Done' button will appear on that slide.
            // The 'showDoneButton: true' is default.
            // If AuthOptionsPage has its own "proceed" buttons, you might hide the global 'Done' button
            // for the last slide using `overrideDone`.
            // For now, the global "Done" button will appear.
          ),
        ),
      ),
    );
  }
}
