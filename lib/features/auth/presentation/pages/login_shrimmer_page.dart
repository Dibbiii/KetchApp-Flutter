
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoginShimmerPage extends StatelessWidget {
  const LoginShimmerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: colors.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
          child: Shimmer.fromColors(
            baseColor: colors.onSurface.withOpacity(0.08),
            highlightColor: colors.onSurface.withOpacity(0.18),
            child: Column(
              children: [
                Container(height: 64, width: 64, margin: const EdgeInsets.only(bottom: 32), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50))),
                Container(height: 32, width: 120, margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                Container(height: 20, width: 180, margin: const EdgeInsets.only(bottom: 32), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                Container(height: 56, width: double.infinity, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                Container(height: 56, width: double.infinity, margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(height: 20, width: 120, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                ),
                Container(height: 48, width: double.infinity, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                Container(height: 48, width: double.infinity, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                Container(height: 20, width: 220, margin: const EdgeInsets.only(bottom: 0), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

