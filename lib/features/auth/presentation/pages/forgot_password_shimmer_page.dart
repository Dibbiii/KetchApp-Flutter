import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ForgotPasswordShimmerPage extends StatelessWidget {
  const ForgotPasswordShimmerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Container(height: 24, width: 120, color: Colors.white, margin: const EdgeInsets.symmetric(vertical: 8)),
        backgroundColor: colors.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.onSurface),
      ),
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Shimmer.fromColors(
              baseColor: colors.surfaceVariant,
              highlightColor: colors.surface,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 28,
                    width: 180,
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 20,
                    width: 220,
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    height: 56,
                    width: double.infinity,
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 48,
                    width: double.infinity,
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8),
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
