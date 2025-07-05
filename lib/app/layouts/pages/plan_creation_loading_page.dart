import 'package:flutter/material.dart';

class PlanCreationLoadingPage extends StatefulWidget {
  final Future<void> Function() createPlan;

  const PlanCreationLoadingPage({super.key, required this.createPlan});

  @override
  State<PlanCreationLoadingPage> createState() => _PlanCreationLoadingPageState();
}

class _PlanCreationLoadingPageState extends State<PlanCreationLoadingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _createPlanAndNavigate();
  }

  Future<void> _createPlanAndNavigate() async {
    try {
      await widget.createPlan();

    } catch (e) {

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _controller,
              child: Icon(
                Icons.sync,
                size: 64,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Creating your plan...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait a moment.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

