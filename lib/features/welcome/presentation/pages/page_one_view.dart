import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

PageViewModel buildPageOneViewModel({
  required ColorScheme colors,
  required Color primaryAccentColor,
}) {
  const String title = 'Track Your Progress';
  const String body =
      'Monitor your study sessions and visualize your improvements over time with detailed analytics and insights.';

  return PageViewModel(
    title: title,
    body: body,
    image: Center(
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background glow effect
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryAccentColor.withValues(alpha: 0.2),
                    primaryAccentColor.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
            // Main image container
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primaryContainer,
                boxShadow: [
                  BoxShadow(
                    color: primaryAccentColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    'assets/images/Progress_Image.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Decorative floating elements
            Positioned(
              top: 20,
              right: 30,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: primaryAccentColor.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 20,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: primaryAccentColor.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    decoration: PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.w800,
        color: colors.onSurface,
        height: 1.2,
        letterSpacing: -0.5,
      ),
      bodyTextStyle: TextStyle(
        fontSize: 18.0,
        color: colors.onSurface.withValues(alpha: 0.7),
        height: 1.6,
        fontWeight: FontWeight.w400,
      ),
      imagePadding: const EdgeInsets.only(top: 80, bottom: 40),
      titlePadding: const EdgeInsets.only(top: 32, bottom: 16),
      bodyPadding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
      pageColor: Colors.transparent,
    ),
  );
}
