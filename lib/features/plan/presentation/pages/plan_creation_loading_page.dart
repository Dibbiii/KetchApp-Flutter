import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ketchapp_flutter/features/plan/models/plan_model.dart';
import 'package:ketchapp_flutter/services/api_service.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:math';

class PlanCreationLoadingPage extends StatefulWidget {
  final PlanModel plan;

  const PlanCreationLoadingPage({super.key, required this.plan});

  @override
  State<PlanCreationLoadingPage> createState() =>
      _PlanCreationLoadingPageState();
}

class _PlanCreationLoadingPageState extends State<PlanCreationLoadingPage> {
  @override
  void initState() {
    super.initState();
    _createPlanAndNavigate();
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        context.go('/home?refresh=true');
      }
    });
  }

  Future<void> _createPlanAndNavigate() async {
    try {
      await ApiService().createPlan(widget.plan);
      final api = ApiService();
      final tomatoes = await api.getTodaysTomatoes();
      if (mounted && tomatoes.isNotEmpty) {
        context.go('/timer/${tomatoes.first.id}');
      } else if (mounted) {
        context.go('/home?refresh=true');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create plan: $e')));
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 120, height: 120, child: _AnimatedGoogleShapes()),
            const SizedBox(height: 40),
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'Creating your plan...',
                  textStyle: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  speed: Duration(milliseconds: 60),
                ),
                TypewriterAnimatedText(
                  'Optimizing your study schedule...',
                  textStyle: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  speed: Duration(milliseconds: 60),
                ),
                TypewriterAnimatedText(
                  'Almost done!',
                  textStyle: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  speed: Duration(milliseconds: 60),
                ),
              ],
              repeatForever: true,
              pause: Duration(milliseconds: 800),
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
            ),
            const SizedBox(height: 40),
            AnimatedRotation(
              turns: 1,
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              child: Icon(
                Icons.rocket_launch_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedGoogleShapes extends StatefulWidget {
  @override
  State<_AnimatedGoogleShapes> createState() => _AnimatedGoogleShapesState();
}

class _AnimatedGoogleShapesState extends State<_AnimatedGoogleShapes>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _controller.value * 2 * pi;
        return Stack(
          alignment: Alignment.center,
          children: [
            _buildShape(angle, 0, Colors.blue, Colors.cyan),
            _buildShape(angle, 1, Colors.red, Colors.orange),
            _buildShape(angle, 2, Colors.green, Colors.lightGreenAccent),
            _buildShape(angle, 3, Colors.yellow.shade700, Colors.amber),
          ],
        );
      },
    );
  }

  Widget _buildShape(double angle, int index, Color color1, Color color2) {
    final double radius = 40;

    final double shapeAngle = angle + (index * 3.1415926 / 2);

    final double x = radius * 1.5 * cos(shapeAngle);
    final double y = radius * 1.5 * sin(shapeAngle);
    return Transform.translate(
      offset: Offset(x, y),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}
