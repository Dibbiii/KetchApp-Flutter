import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:ketchapp_flutter/app/themes/app_colors.dart'; // Import app_colors

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  // Helper method to build page view models with enhanced styling
  PageViewModel _buildPageViewModel({
    required String title,
    required String body,
    required IconData icon,
    required ColorScheme colors, // Base colorscheme
    required Color primaryAccentColor, // Specific accent color (kTomatoRed)
    // Removed backgroundGradient parameter
  }) {
    return PageViewModel(
      title: title,
      body: body,
      image: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: primaryAccentColor.withOpacity(0.1), // Use accent color
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 80.0,
            color: primaryAccentColor, // Use accent color
          ),
        ),
      ),
      decoration: PageDecoration(
        // Keep PageDecoration for text styles etc.
        titleTextStyle: TextStyle(
          fontSize: 26.0,
          fontWeight: FontWeight.bold,
          color: colors.onSurface, // Ensure contrast on surface
        ),
        bodyTextStyle: TextStyle(
          fontSize: 16.0,
          color: colors.onSurface.withOpacity(0.8), // Slightly muted text
          height: 1.5,
        ),
        imagePadding: const EdgeInsets.only(top: 80, bottom: 30),
        bodyPadding: const EdgeInsets.symmetric(horizontal: 32.0),
        // Removed boxDecoration to let global gradient show through
        // Ensure page itself is transparent
        pageColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Define a global gradient for the entire screen background
    final Gradient globalBackgroundGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        kTomatoRed.withOpacity(0.1), // Start with a light red tint
        kTomatoRed.withOpacity(0.7), // Increase opacity for more visibility
      ],
      stops: const [0.0, 1.0], // Control gradient spread
    );

    // Removed gradient1, gradient2, gradient3 definitions

    final List<PageViewModel> pages = [
      _buildPageViewModel(
        title: 'Track Your Progress',
        // Using English text as per previous changes
        body:
            'Monitor your study sessions and visualize your improvements over time.',
        icon: Icons.trending_up,
        colors: colors,
        primaryAccentColor: kTomatoRed,
        // Removed backgroundGradient argument
      ),
      _buildPageViewModel(
        title: 'Pomodoro Technique',
        body: 'Use customizable timers to optimize concentration and breaks.',
        icon: Icons.timer,
        colors: colors,
        primaryAccentColor: kTomatoRed,
        // Removed backgroundGradient argument
      ),
      _buildPageViewModel(
        title: 'Smart Planning',
        body: 'Let the app generate a study plan tailored to your goals.',
        icon: Icons.auto_awesome,
        colors: colors,
        primaryAccentColor: kTomatoRed,
        // Removed backgroundGradient argument
      ),
    ];

    // Function to navigate to the auth options page
    void goToAuthOptions(BuildContext ctx) {
      ctx.pushReplacement('/auth-options');
    }

    // Define SystemUiOverlayStyle based on the top part of the gradient
    const SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      // Assuming the top part (transparent surface) is light
      statusBarColor: Colors.transparent,
      // Make status bar transparent
      statusBarIconBrightness: Brightness.dark,
      // Icons for light background
      statusBarBrightness: Brightness.light,
      // For iOS
      systemNavigationBarColor: Colors.transparent,
      // Make nav bar transparent
      systemNavigationBarIconBrightness:
          Brightness.dark, // Icons for light background
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Wrap with AnnotatedRegion
      value: systemUiOverlayStyle,
      child: Scaffold(
        // Scaffold background is transparent by default when wrapped
        body: Container(
          decoration: BoxDecoration(
            gradient: globalBackgroundGradient, // Apply global gradient here
          ),
          child: IntroductionScreen(
            pages: pages,
            onDone: () => goToAuthOptions(context),
            onSkip: () => goToAuthOptions(context),
            showSkipButton: true,
            // --- Footer Customization with Tomato Red ---
            skip: TextButton(
              onPressed: () => goToAuthOptions(context),
              style: TextButton.styleFrom(
                foregroundColor: kTomatoRed, // Use kTomatoRed
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ).copyWith(
                // Restore subtle overlay for feedback
                overlayColor: MaterialStatePropertyAll(
                  kTomatoRed.withOpacity(0.1),
                ),
              ),
              child: Text('Skip', style: textTheme.labelLarge),
            ),
            next: IconButton(
              onPressed: null,
              // Handled by the package
              icon: const Icon(Icons.arrow_forward),
              iconSize: 24,
              color: kTomatoRed,
              style: IconButton.styleFrom(
                backgroundColor: kTomatoRed.withOpacity(0.1),
                padding: const EdgeInsets.all(12),
                shape: const CircleBorder(),
              ).copyWith(
                // Restore subtle overlay for feedback
                overlayColor: MaterialStatePropertyAll(
                  kTomatoRed.withOpacity(0.1),
                ),
              ),
              tooltip: 'Next',
            ),
            done: FilledButton(
              onPressed: () => goToAuthOptions(context),
              style: FilledButton.styleFrom(
                backgroundColor: kTomatoRed,
                foregroundColor: colors.onPrimary, // Ensure text contrast
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ).copyWith(
                // Restore subtle overlay for feedback (using white for contrast)
                overlayColor: MaterialStatePropertyAll(kWhite.withOpacity(0.1)),
              ),
              child: Text(
                'Get Started',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            dotsDecorator: DotsDecorator(
              size: const Size.square(8.0),
              activeSize: const Size(20.0, 8.0),
              activeColor: kTomatoRed,
              color: colors.onSurface.withOpacity(0.2),
              spacing: const EdgeInsets.symmetric(horizontal: 4.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
            // --- Behavior & Layout ---
            isProgressTap: false,
            // Prevent tap on dots from changing page
            freeze: false,
            // Allow swiping
            bodyPadding: EdgeInsets.zero,
            // Let PageDecoration handle padding
            controlsPadding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
            globalBackgroundColor: Colors.transparent, // Keep this transparent
          ),
        ),
      ),
    );
  }
}
