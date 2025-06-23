import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';

// Imports for the new page view model files
import './page_one_view.dart';
import './page_two_view.dart';
import './page_three_view.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _introKey = GlobalKey<IntroductionScreenState>();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final List<PageViewModel> pages = [
      buildPageOneViewModel(
        colors: colors,
        primaryAccentColor: colors.primary,
      ),
      buildPageTwoViewModel(
        colors: colors,
        primaryAccentColor: colors.primary,
      ),
      buildPageThreeViewModel(
        colors: colors,
        primaryAccentColor: colors.primary,
      ),
    ];

    void goToLoginOrRegister(BuildContext ctx) {
      ctx.pushReplacement('/login');
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
            // Assign the key
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
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ).copyWith(
                overlayColor: WidgetStateProperty.all(
                  Colors.yellow.withOpacity(0.15),
                ),
              ),
              child: Text('Skip', style: textTheme.labelLarge),
            ),
            next: ElevatedButton(
              onPressed: () {
                _introKey.currentState?.next();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: const CircleBorder(),
              ).copyWith(
                overlayColor: WidgetStateProperty.all(
                  Colors.yellow.withOpacity(0.15),
                ), // Yellow hover
              ),
              child: Icon(
                Icons.arrow_forward,
                size: 30,
              ),
            ),
            done: Center(
              child: FilledButton(
                onPressed: () => goToLoginOrRegister(context),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(240, 66),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                  ),
                ).copyWith(
                  overlayColor: WidgetStateProperty.all(
                    Colors.yellow.withOpacity(0.15),
                  ),
                ),
                child: Text(
                  'Start',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            dotsDecorator: DotsDecorator(
              size: const Size.square(8.0),
              activeSize: const Size(20.0, 8.0),
              activeColor: colors.primary,
              spacing: const EdgeInsets.symmetric(horizontal: 4.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
            isProgressTap: false,
            freeze: false,
            bodyPadding: EdgeInsets.zero,
            controlsPadding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
            globalBackgroundColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
