import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ketchapp_flutter/features/plan/models/plan_model.dart';
import 'package:ketchapp_flutter/services/api_service.dart';

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
  }

  Future<void> _createPlanAndNavigate() async {
    try {
      await ApiService().createPlan(widget.plan);
      if (mounted) {
        context.go('/home?refresh=true');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create plan: $e')),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Creating your plan...'),
          ],
        ),
      ),
    );
  }
}
