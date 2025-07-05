import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TimerShrimmerPage extends StatelessWidget {
  const TimerShrimmerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.primary.withValues(alpha: 0.06),
              colors.primaryContainer.withValues(alpha: 0.04),
              colors.surface,
              colors.secondaryContainer.withValues(alpha: 0.02),
              colors.tertiaryContainer.withValues(alpha: 0.01),
            ],
            stops: const [0.0, 0.25, 0.5, 0.8, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeaderShimmer(colors, theme),
              const SizedBox(height: 24),
              _buildTimelineShimmer(colors),
              Expanded(
                child: _buildTimerSectionShimmer(colors, theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderShimmer(ColorScheme colors, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surfaceContainerHigh.withValues(alpha: 0.95),
            colors.surfaceContainerHighest.withValues(alpha: 0.8),
            colors.primaryContainer.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Shimmer.fromColors(
                baseColor: colors.primary.withValues(alpha: 0.1),
                highlightColor: colors.primary.withValues(alpha: 0.2),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: colors.primaryContainer.withValues(alpha: 0.3),
                      highlightColor: colors.primaryContainer.withValues(alpha: 0.6),
                      child: Container(
                        width: 80,
                        height: 17,
                        decoration: BoxDecoration(
                          color: colors.primaryContainer.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Shimmer.fromColors(
                      baseColor: colors.onSurface.withValues(alpha: 0.1),
                      highlightColor: colors.onSurface.withValues(alpha: 0.2),
                      child: Container(
                        width: 160,
                        height: 22,
                        decoration: BoxDecoration(
                          color: colors.onSurface.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Shimmer.fromColors(
                baseColor: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                highlightColor: colors.surfaceContainer.withValues(alpha: 0.6),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primaryContainer.withValues(alpha: 0.8),
                  colors.primaryContainer.withValues(alpha: 0.6),
                  colors.secondaryContainer.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatChipShimmer(colors),
                _buildStatChipShimmer(colors),
                _buildStatChipShimmer(colors),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChipShimmer(ColorScheme colors) {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: colors.primary.withValues(alpha: 0.1),
          highlightColor: colors.primary.withValues(alpha: 0.2),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Shimmer.fromColors(
          baseColor: colors.onPrimaryContainer.withValues(alpha: 0.2),
          highlightColor: colors.onPrimaryContainer.withValues(alpha: 0.4),
          child: Container(
            width: 30,
            height: 16,
            decoration: BoxDecoration(
              color: colors.onPrimaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Shimmer.fromColors(
          baseColor: colors.onPrimaryContainer.withValues(alpha: 0.1),
          highlightColor: colors.onPrimaryContainer.withValues(alpha: 0.3),
          child: Container(
            width: 40,
            height: 12,
            decoration: BoxDecoration(
              color: colors.onPrimaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineShimmer(ColorScheme colors) {
    return Container(
      height: 112,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                Shimmer.fromColors(
                  baseColor: colors.primary.withValues(alpha: 0.1),
                  highlightColor: colors.primary.withValues(alpha: 0.3),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: colors.onSurface.withValues(alpha: 0.1),
                  highlightColor: colors.onSurface.withValues(alpha: 0.2),
                  child: Container(
                    width: 50,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Shimmer.fromColors(
                  baseColor: colors.onSurface.withValues(alpha: 0.1),
                  highlightColor: colors.onSurface.withValues(alpha: 0.2),
                  child: Container(
                    width: 40,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colors.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimerSectionShimmer(ColorScheme colors, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: _buildTimerDisplayShimmer(colors),
          ),
          const SizedBox(height: 32),
          _buildTimerControlsShimmer(colors),
        ],
      ),
    );
  }

  Widget _buildTimerDisplayShimmer(ColorScheme colors) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primaryContainer.withValues(alpha: 0.9),
              colors.primaryContainer.withValues(alpha: 0.7),
              colors.surfaceContainerHigh.withValues(alpha: 0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.surface.withValues(alpha: 0.95),
                    colors.surfaceContainerHigh.withValues(alpha: 0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Shimmer.fromColors(
                    baseColor: colors.primary.withValues(alpha: 0.1),
                    highlightColor: colors.primary.withValues(alpha: 0.3),
                    child: SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: 0.6,
                        strokeWidth: 6,
                        backgroundColor: colors.outlineVariant.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors.primary.withValues(alpha: 0.5),
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Shimmer.fromColors(
                        baseColor: colors.primary.withValues(alpha: 0.2),
                        highlightColor: colors.primary.withValues(alpha: 0.4),
                        child: Container(
                          width: 80,
                          height: 32,
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Shimmer.fromColors(
                        baseColor: colors.primaryContainer.withValues(alpha: 0.2),
                        highlightColor: colors.primaryContainer.withValues(alpha: 0.4),
                        child: Container(
                          width: 50,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors.primaryContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerControlsShimmer(ColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Shimmer.fromColors(
          baseColor: colors.primary.withValues(alpha: 0.2),
          highlightColor: colors.primary.withValues(alpha: 0.4),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),

        Shimmer.fromColors(
          baseColor: colors.surfaceContainerHigh.withValues(alpha: 0.3),
          highlightColor: colors.surfaceContainerHigh.withValues(alpha: 0.5),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
