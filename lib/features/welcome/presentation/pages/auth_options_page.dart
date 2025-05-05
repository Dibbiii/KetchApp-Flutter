import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services
import 'package:go_router/go_router.dart';
import 'package:ketchapp_flutter/app/themes/app_colors.dart'; // Import app_colors

class AuthOptionsPage extends StatefulWidget {
  const AuthOptionsPage({super.key});

  @override
  State<AuthOptionsPage> createState() => _AuthOptionsPageState();
}

class _AuthOptionsPageState extends State<AuthOptionsPage> {
  // Removed _isLoginPressed and _isRegisterPressed state variables

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Size size = MediaQuery.of(context).size;

    // Define the global gradient like in WelcomePage
    final Gradient globalBackgroundGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        colors.surface.withOpacity(0.0), // Start transparent
        kTomatoRed.withOpacity(0.4), // Slightly stronger accent at bottom
      ],
      stops: const [0.0, 1.0], // Control gradient spread
    );

    // Define SystemUiOverlayStyle like in WelcomePage
    const SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      // Match WelcomePage
      statusBarBrightness: Brightness.light,
      // For iOS
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark, // Match WelcomePage
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: Scaffold(
        // Removed explicit background color to let gradient show
        body: Container(
          // Wrap body content with gradient container
          width: double.infinity, // Ensure container fills width
          height: double.infinity, // Ensure container fills height
          decoration: BoxDecoration(gradient: globalBackgroundGradient),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Placeholder (Styled like WelcomePage icons)
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: kTomatoRed.withOpacity(0.1),
                      // Use accent color background
                      shape:
                          BoxShape.circle, // Make it circular like WelcomePage
                    ),
                    child: Icon(
                      Icons.auto_stories_outlined,
                      // Example: Use a relevant icon
                      size: 40,
                      color: kTomatoRed, // Use accent color for icon
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    // Changed text to English
                    'Log in to your account or create a new one to get started.',
                    style: textTheme.bodyLarge?.copyWith(
                      // Match text style/opacity from WelcomePage
                      color: colors.onSurface.withOpacity(0.8),
                      height: 1.5, // Match line height from WelcomePage
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),

                  // --- Login Button (Styled as FilledButton like WelcomePage 'Done') ---
                  FilledButton(
                    // Changed from ElevatedButton
                    onPressed:
                        () => {
                          context.go('/login'), // Use onPressed directly
                        },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: kTomatoRed,
                      // Use kTomatoRed
                      foregroundColor: colors.onPrimary,
                      // Match WelcomePage
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ), // Match WelcomePage
                      ),
                      padding: const EdgeInsets.symmetric(
                        // Match WelcomePage padding
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ).copyWith(
                      // Remove splash/highlight like WelcomePage
                      overlayColor: const MaterialStatePropertyAll(
                        Colors.transparent,
                      ),
                    ),
                    child: Text(
                      // Changed text to English
                      'Log In',
                      style: textTheme.labelLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold, // Match WelcomePage 'Done'
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Register Button (Styled as OutlinedButton) ---
                  OutlinedButton(
                    onPressed:
                        () => {
                          context.go('/register'), // Use onPressed directly
                        },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      foregroundColor: kTomatoRed,
                      // Use kTomatoRed
                      side: BorderSide(color: kTomatoRed, width: 1.5),
                      // Use kTomatoRed
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ), // Match WelcomePage radius
                      ),
                      padding: const EdgeInsets.symmetric(
                        // Match WelcomePage padding
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ).copyWith(
                      // Remove splash/highlight like WelcomePage
                      overlayColor: const MaterialStatePropertyAll(
                        Colors.transparent,
                      ),
                    ),
                    child: Text(
                      // Changed text to English
                      'Register',
                      style: textTheme.labelLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold, // Make consistent
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
