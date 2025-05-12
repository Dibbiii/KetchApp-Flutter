import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

PageViewModel buildPageTwoViewModel({
  required ColorScheme colors,
  required Color primaryAccentColor,
}) {
  const String title = 'Pomodoro Technique';
  const String body =
      'Use customizable timers to optimize concentration and breaks.';

  return PageViewModel(
    title: title,
    body: body,
    image: Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: primaryAccentColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.network(
            'https://picsum.photos/seed/\${title.hashCode}/200/200',
            width: 200.0,
            height: 200.0,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => Icon(
                  Icons.broken_image,
                  size: 200.0,
                  color: primaryAccentColor,
                ),
          ),
        ),
      ),
    ),
    decoration: PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 26.0,
        fontWeight: FontWeight.bold,
        color: colors.onSurface,
        height: 1.3,
      ),
      bodyTextStyle: TextStyle(
        fontSize: 16.0,
        color: colors.onSurface.withOpacity(0.8),
        height: 1.5,
      ),
      imagePadding: const EdgeInsets.only(top: 60, bottom: 20),
      titlePadding: const EdgeInsets.only(top: 24, bottom: 12),
      bodyPadding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
      pageColor: Colors.transparent,
    ),
  );
}
