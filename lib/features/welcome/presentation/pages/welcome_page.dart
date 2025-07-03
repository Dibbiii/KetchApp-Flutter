import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  final _introKey = GlobalKey<IntroductionScreenState>();

  late AnimationController _fadeAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    // Start animations immediately
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fadeAnimationController.forward();
        _scaleAnimationController.forward();
      }
    });
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleAnimationController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
      HapticFeedback.lightImpact();
      ctx.pushReplacement('/login');
    }

    final SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: colors.brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
      statusBarBrightness: colors.brightness,
      systemNavigationBarColor: colors.surface,
      systemNavigationBarIconBrightness: colors.brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: Scaffold(
        backgroundColor: colors.surface,
        body: AnimatedBuilder(
          animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.surface,
                        colors.surfaceContainerHighest.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                  child: IntroductionScreen(
                    key: _introKey,
                    pages: pages,
                    onDone: () => goToLoginOrRegister(context),
                    onSkip: () => goToLoginOrRegister(context),
                    showSkipButton: true,
                    skip: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: colors.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: textTheme.labelLarge?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    next: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: colors.onPrimary,
                        size: 24,
                      ),
                    ),
                    done: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors.primary,
                            colors.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        'Get Started',
                        style: textTheme.titleMedium?.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    dotsDecorator: DotsDecorator(
                      size: const Size(10.0, 10.0),
                      activeSize: const Size(24.0, 10.0),
                      activeColor: colors.primary,
                      color: colors.outline.withValues(alpha: 0.4),
                      spacing: const EdgeInsets.symmetric(horizontal: 6.0),
                      activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    isProgressTap: false,
                    freeze: false,
                    bodyPadding: EdgeInsets.zero,
                    controlsPadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 48.0),
                    globalBackgroundColor: Colors.transparent,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
