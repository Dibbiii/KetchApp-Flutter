import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class StatisticsShrimmerPage extends StatelessWidget {
  const StatisticsShrimmerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Shimmer.fromColors(
        baseColor: colors.surfaceContainerHigh,
        highlightColor: colors.surfaceContainerHighest,
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Column(
                    children: [
                      _buildStatsHeaderShimmer(),
                      const SizedBox(height: 40),
                      _buildWeekNavigatorShimmer(),
                      const SizedBox(height: 24),
                      _buildHistogramSectionShimmer(),
                      const SizedBox(height: 32),
                      _buildSubjectsSectionShimmer(),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsHeaderShimmer() {
    return Column(
      children: [
        Container(
          width: 128,
          height: 128,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: 220,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 180,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekNavigatorShimmer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistogramSectionShimmer() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
    );
  }

  Widget _buildSubjectsSectionShimmer() {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
    );
  }
}
