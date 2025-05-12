import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';

PageViewModel buildPageFourAuthViewModel({
  required BuildContext context,
  required ColorScheme colors,
  required TextTheme textTheme,
}) {
  final Size size = MediaQuery.of(context).size;
  final Gradient globalBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [colors.surface.withOpacity(0.0), colors.primary.withOpacity(0.4)],
    stops: const [0.0, 1.0],
  );

  return PageViewModel(
    title: "Create Account or Sign In",
    bodyWidget: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(gradient: globalBackgroundGradient),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_stories_outlined,
                  size: 40,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Log in to your account or create a new one to get started.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colors.onSurface.withOpacity(0.8),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              FilledButton(
                onPressed: () => context.go('/login'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ).copyWith(
                  overlayColor: const MaterialStatePropertyAll(
                    Colors.transparent,
                  ),
                ),
                child: Text(
                  'Log In',
                  style: textTheme.labelLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => context.go('/register'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  foregroundColor: colors.primary,
                  side: BorderSide(color: colors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ).copyWith(
                  overlayColor: const MaterialStatePropertyAll(
                    Colors.transparent,
                  ),
                ),
                child: Text(
                  'Register',
                  style: textTheme.labelLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    decoration: const PageDecoration(
      pageColor: Colors.transparent,
      bodyPadding: EdgeInsets.zero,
      imagePadding: EdgeInsets.zero,
    ),
    useScrollView: false,
  );
}
