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
              baseColor: colors.onSurface.withOpacity(0.08),
              highlightColor: colors.onSurface.withOpacity(0.18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(height: 60, width: 60, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30))),
                  Container(height: 28, width: double.infinity, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                  Container(height: 20, width: double.infinity, margin: const EdgeInsets.only(bottom: 32), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                  Container(height: 56, width: double.infinity, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                  Container(height: 48, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

