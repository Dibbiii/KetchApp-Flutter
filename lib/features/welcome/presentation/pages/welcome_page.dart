import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';

// import 'package:ketchapp_flutter/app/themes/app_colors.dart'; // Removed unused import
import './auth_options_page.dart'; // Ensure AuthOptionsPage is imported

class WelcomePage extends StatefulWidget {
  // Changed to StatefulWidget
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState(); // Create state
}

class _WelcomePageState extends State<WelcomePage> {
  // State class
  final _introKey =
      GlobalKey<IntroductionScreenState>(); // Key for IntroductionScreen

  // Helper method to build page view models with enhanced styling
  PageViewModel _buildPageViewModel({
    required String title,
    required String body,
    required IconData icon, // Kept for semantic meaning, not direct display
    required ColorScheme colors, // Base colorscheme
    required Color primaryAccentColor, // Specific accent color (primary)
  }) {
    return PageViewModel(
      title: title,
      body: body,
      image: Center(
        child: Container(
          padding: const EdgeInsets.all(
            4,
          ), // Adjust padding if needed for images
          decoration: BoxDecoration(
            color: primaryAccentColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            // Clip image to be circular
            child: Image.network(
              'https://picsum.photos/seed/${title.hashCode}/200/200',
              // Use title hashcode for a unique seed, increased size
              width: 200.0, // Increased width
              height: 200.0, // Increased height
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Icon(
                    Icons.broken_image, // Corrected fallback icon
                    size: 200.0, // Match image size
                    color: primaryAccentColor,
                  ),
            ),
          ),
        ),
      ),
      decoration: PageDecoration(
        // Keep PageDecoration for text styles etc.
        titleTextStyle: TextStyle(
          fontSize: 26.0,
          fontWeight: FontWeight.bold,
          color: colors.onSurface, // Ensure contrast on surface
          height: 1.3, // Adjusted line height
        ),
        bodyTextStyle: TextStyle(
          fontSize: 16.0,
          color: colors.onSurface.withOpacity(0.8), // Slightly muted text
          height: 1.5,
        ),
        // Adjust padding for better visual balance and centering
        imagePadding: const EdgeInsets.only(top: 60, bottom: 20),
        titlePadding: const EdgeInsets.only(top: 24, bottom: 12),
        bodyPadding: const EdgeInsets.symmetric(
          horizontal: 32.0,
          vertical: 12.0,
        ),
        pageColor: Colors.transparent, // Ensure page itself is transparent
        // Content is centered by default by the package.
        // Use contentFlex and imageFlex for proportional sizing if needed.
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final List<PageViewModel> pages = [
      _buildPageViewModel(
        title: 'Track Your Progress',
        body:
            'Monitor your study sessions and visualize your improvements over time.',
        icon: Icons.trending_up,
        colors: colors,
        primaryAccentColor: colors.primary,
      ),
      _buildPageViewModel(
        title: 'Pomodoro Technique',
        body: 'Use customizable timers to optimize concentration and breaks.',
        icon: Icons.timer,
        colors: colors,
        primaryAccentColor: colors.primary,
      ),
      _buildPageViewModel(
        title: 'Smart Planning',
        body: 'Let the app generate a study plan tailored to your goals.',
        icon: Icons.auto_awesome,
        colors: colors,
        primaryAccentColor: colors.primary,
      ),
      PageViewModel(
        // Added AuthOptionsPage
        title: "Create Account or Sign In",
        bodyWidget: const AuthOptionsPage(),
        decoration: const PageDecoration(
          pageColor: Colors.transparent,
          bodyPadding:
              EdgeInsets.zero, // AuthOptionsPage handles its own padding
          fullScreen: true,
          imagePadding: EdgeInsets.zero, // No image for this page type
        ),
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
                overlayColor: MaterialStateProperty.all(
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
                overlayColor: MaterialStateProperty.all(
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
                overlayColor: MaterialStateProperty.all(
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
              color: colors.onSurface.withOpacity(0.2),
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
