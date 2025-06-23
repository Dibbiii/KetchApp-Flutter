// import 'dart:async'; // Removed unused import
import 'dart:math';
import 'package:flutter/material.dart';

String formatDurationFromHmm(double hmmHours, {String defaultText = "No time set"}) {
  if (hmmHours < 0) hmmHours = 0; // Ensure non-negative
  int hours = hmmHours.floor();
  int minutes = ((hmmHours - hours) * 100).round();

  if (minutes >= 60) {
    hours += (minutes ~/ 60);
    minutes %= 60;
  }

  if (hours == 0 && minutes == 0) {
    return defaultText;
  } else if (hours == 0) {
    return '$minutes m';
  } else {
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }
}

double fractionalHoursToHmm(double fractionalHours) {
  if (fractionalHours < 0) fractionalHours = 0;
  int hours = fractionalHours.floor();
  int minutes = ((fractionalHours - hours) * 60).round();

  if (minutes == 60) {
      hours +=1;
      minutes = 0;
  }
  return double.parse('$hours.${minutes.toString().padLeft(2, '0')}');
}

double hmmToFractionalHours(double hmmHours) {
  if (hmmHours < 0) hmmHours = 0;
  int hours = hmmHours.floor();
  int minutes = ((hmmHours - hours) * 100).round();

  if (minutes >= 60) {
    hours += (minutes ~/ 60);
    minutes %= 60;
  }
  return hours + (minutes / 60.0);
}


class MaterialClock extends StatefulWidget {
  final double initialSelectedHours;
  final ValueChanged<double> onTimeChanged;
  final double clockSize;

  const MaterialClock({
    super.key,
    this.initialSelectedHours = 0.0,
    required this.onTimeChanged,
    this.clockSize = 200.0,
  });

  @override
  State<MaterialClock> createState() => _MaterialClockState();
}

class _MaterialClockState extends State<MaterialClock> {
  double _hourAngle = 0.0;
  double _selectedHours = 0.0; // Stores H.MM format
  double _lastAngle = 0.0;
  int _turns = 0;

  @override
  void initState() {
    super.initState();
    _selectedHours = widget.initialSelectedHours;
    if (_selectedHours < 0) _selectedHours = 0;

    // Converto H.MM a frazioni di ore
    int h = _selectedHours.floor();
    int m = ((_selectedHours - h) * 100).round();
    double totalFractionalHours = h + (m / 60.0);

    _turns = totalFractionalHours.floor();
    _hourAngle = (totalFractionalHours - _turns) * 2 * pi;
    _lastAngle = _hourAngle;
  }

  void _updateHourHand(Offset localPosition) {
    final center = Offset(widget.clockSize / 2, widget.clockSize / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    double angle = atan2(dy, dx);
    angle = angle + pi / 2;
    if (angle < 0) angle += 2 * pi;

    double delta = angle - _lastAngle;
    if (delta < -pi) {
      _turns++;
    } else if (delta > pi) {
      _turns--;
    }
    _lastAngle = angle;

    double totalHours = _turns + angle / (2 * pi);
    if (totalHours < 0) totalHours = 0;

    int hoursPart = totalHours.floor();
    int minutesPart = ((totalHours - hoursPart) * 60).round();

    if (minutesPart == 60) {
      hoursPart += 1;
      minutesPart = 0;
    }

    setState(() {
      _hourAngle = angle;
      _selectedHours = double.parse('$hoursPart.${minutesPart.toString().padLeft(2, '0')}');
    });
    widget.onTimeChanged(_selectedHours);
  }

  void _onPanStartGesture(Offset localPosition) {
    final center = Offset(widget.clockSize / 2, widget.clockSize / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    double angle = atan2(dy, dx);
    angle = angle + pi / 2;
    if (angle < 0) angle += 2 * pi;

     _lastAngle = angle;
     _updateHourHand(localPosition);


  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: widget.clockSize,
      height: widget.clockSize,
      child: GestureDetector(
        onPanStart: (details) {
          RenderBox box = context.findRenderObject() as RenderBox;
          Offset local = box.globalToLocal(details.globalPosition);
          _onPanStartGesture(local);
        },
        onPanUpdate: (details) {
          RenderBox box = context.findRenderObject() as RenderBox;
          Offset local = box.globalToLocal(details.globalPosition);
          _updateHourHand(local);
        },
        child: CustomPaint(
          painter: _ClockPainter(
            hourAngle: _hourAngle,
            colors: colors,
          ),
        ),
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  final double hourAngle;
  final ColorScheme colors;

  _ClockPainter({
    required this.hourAngle,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    // 1. Draw clock face
    final facePaint = Paint()..color = colors.surface;
    canvas.drawCircle(center, radius, facePaint);

    // 2. Draw clock outline
    final outlinePaint = Paint()
      ..color = colors.outline.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, outlinePaint);

    // 3. Draw tick marks instead of numbers
    final tickPaint = Paint()..strokeCap = StrokeCap.round;
    const double tickPadding = 12.0;
    final double innerRadius = radius - tickPadding;

    for (int i = 0; i < 60; i++) {
      final angle = (i * 6) * (pi / 180); // 6 degrees per minute
      final isHourMark = i % 5 == 0;

      tickPaint.color = colors.onSurface.withOpacity(isHourMark ? 1.0 : 0.6);
      tickPaint.strokeWidth = isHourMark ? 2.5 : 1.5;

      final double tickStart = isHourMark ? innerRadius - 8.0 : innerRadius - 4.0;

      final startPoint = Offset(
        center.dx + tickStart * sin(angle),
        center.dy - tickStart * cos(angle),
      );
      final endPoint = Offset(
        center.dx + innerRadius * sin(angle),
        center.dy - innerRadius * cos(angle),
      );

      canvas.drawLine(startPoint, endPoint, tickPaint);
    }

    // 4. Draw hour hand with a thumb
    final handLength = radius * 0.85;
    final handEnd = Offset(
      center.dx + handLength * sin(hourAngle),
      center.dy - handLength * cos(hourAngle),
    );

    final handPaint = Paint()
      ..color = colors.primary
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, handEnd, handPaint);

    // 5. Draw the thumb at the end of the hand
    final thumbPaint = Paint()..color = colors.primary;
    canvas.drawCircle(handEnd, 10, thumbPaint);
    final thumbInnerPaint = Paint()..color = colors.surface;
    canvas.drawCircle(handEnd, 4, thumbInnerPaint);

    // 6. Draw center pivot
    final centerDotPaint = Paint()..color = colors.primary;
    canvas.drawCircle(center, 5, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) =>
      oldDelegate.hourAngle != hourAngle || oldDelegate.colors != colors;
}

