import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProfileShrimmerPage extends StatelessWidget {
  const ProfileShrimmerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Shimmer.fromColors(
            baseColor: colors.onSurface.withOpacity(0.08),
            highlightColor: colors.onSurface.withOpacity(0.18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    height: 108,
                    width: 108,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(height: 56, width: double.infinity, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                Container(height: 56, width: double.infinity, margin: const EdgeInsets.only(bottom: 32), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                Container(height: 28, width: 120, margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.8, // Più spazio verticale, coerente con la pagina reale
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.zero,
                    );
                  },
                ),
                const SizedBox(height: 24),
                Container(height: 48, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

