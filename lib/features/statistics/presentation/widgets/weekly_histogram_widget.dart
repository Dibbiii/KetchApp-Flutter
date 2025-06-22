// filepath: lib/features/statistics/presentation/widgets/weekly_histogram_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For DateUtils

// Helper function to get days in the week, starting from Monday
List<DateTime> _getDaysInWeekForHistogram(DateTime dateInWeek) {
  DateTime startOfWeek = dateInWeek.subtract(
    Duration(days: dateInWeek.weekday - DateTime.monday),
  );
  return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
}

class WeeklyHistogramWidget extends StatelessWidget {
  final DateTime displayedCalendarDate;
  final List<double> weeklyStudyData;
  final Function(DateTime) onDateSelected;

  const WeeklyHistogramWidget({
    Key? key,
    required this.displayedCalendarDate,
    required this.weeklyStudyData,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<DateTime> weekDaysForHistogram = _getDaysInWeekForHistogram(
      displayedCalendarDate,
    );
    final List<String> dayLabels = [
      'Lun',
      'Mar',
      'Mer',
      'Gio',
      'Ven',
      'Sab',
      'Dom',
    ];

    const double yAxisLabelWidth = 28.0;
    const double dayLabelHeight = 20.0; // Height for "Lun", "Mar", etc.
    const double xAxisElementsCombinedHeight =
        dayLabelHeight; // Total height for x-axis text (only day label now)
    const double plotAreaHeight = 130.0;
    const double totalHistogramHeight =
        plotAreaHeight +
        xAxisElementsCombinedHeight +
        8.0; // Adjusted total height
    const double maxYAxisValue = 9.0;
    const List<double> yAxisTicks = [0, 3, 6, 9];

    final List<double> currentWeekData = List.generate(
      7,
      (i) =>
          i < weeklyStudyData.length
              ? weeklyStudyData[i].clamp(0.0, maxYAxisValue)
              : 0.0,
    );

    return Container(
      height: totalHistogramHeight,
      padding: const EdgeInsets.only(top: 8.0),
      child: Stack(
        children: [
          // Y-Axis Grid Lines
          Positioned.fill(
            left: 0,
            right: yAxisLabelWidth + 4,
            top: 0,
            bottom:
                xAxisElementsCombinedHeight, // Adjusted bottom for grid lines
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double availableHeight = constraints.maxHeight;
                return Stack(
                  children:
                      yAxisTicks.map((tickValue) {
                        final double lineYPosition =
                            availableHeight -
                            ((tickValue / maxYAxisValue) * availableHeight);
                        final double clampedY = lineYPosition.clamp(
                          0.0,
                          availableHeight - 1.0,
                        );
                        return Positioned(
                          top: clampedY,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 1.0,
                            color: colors.outlineVariant.withOpacity(0.2),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ),
          // Y-Axis Labels
          Positioned(
            top: 0,
            bottom:
                xAxisElementsCombinedHeight, // Adjusted bottom for Y-axis labels
            right: 0,
            width: yAxisLabelWidth,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children:
                      yAxisTicks.reversed.map((tickValue) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Text(
                            '${tickValue.toInt()}h',
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant.withOpacity(0.8),
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ),
          // Bars and X-Axis Labels (Day and Hours)
          Positioned(
            left: 0,
            right: yAxisLabelWidth + 4,
            top: 0,
            bottom: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final dayData = currentWeekData[index];
                final barHeight = (dayData / maxYAxisValue) * plotAreaHeight;
                final currentBarDate = weekDaysForHistogram[index];
                final isToday = DateUtils.isSameDay(
                  currentBarDate,
                  DateTime.now(),
                );
                final isDisplayedNavigationDate = DateUtils.isSameDay(
                  currentBarDate,
                  displayedCalendarDate,
                );

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onDateSelected(currentBarDate),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: barHeight >= 0 ? barHeight : 0,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            color:
                                isDisplayedNavigationDate
                                    ? colors.primary.withOpacity(0.5)
                                    : colors.primary.withOpacity(0.2),
                          ),
                        ),
                        SizedBox(
                          height: dayLabelHeight,
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                dayLabels[index],
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color:
                                      isToday
                                          ? colors.primary
                                          : colors.onSurfaceVariant,
                                  fontWeight:
                                      isToday || isDisplayedNavigationDate
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
