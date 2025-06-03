// import 'dart:async'; // Removed unused import
import 'dart:math';
import 'package:flutter/material.dart';

// Helper function to format selected duration (H.MM format) to a display string like "1:30 h" or "30 m"
String formatDurationFromHmm(double hmmHours, {String defaultText = "Nessuna pausa"}) {
  if (hmmHours < 0) hmmHours = 0; // Ensure non-negative
  int hours = hmmHours.floor();
  int minutes = ((hmmHours - hours) * 100).round();

  // Correct minutes if they round up to 60 due to precision issues or H.MM like 1.60
  if (minutes >= 60) {
    hours += (minutes ~/ 60);
    minutes %= 60;
  }

  if (hours == 0 && minutes == 0) {
    return defaultText;
  } else if (hours == 0) {
    return '$minutes m';
  } else {
    return '$hours:${minutes.toString().padLeft(2, '0')} h';
  }
}

// Helper to convert fractional hours (e.g., 1.5 for 1h 30m) to H.MM format (e.g., 1.30)
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

// Helper to convert H.MM format (e.g., 1.30) to fractional hours (e.g., 1.5)
double hmmToFractionalHours(double hmmHours) {
  if (hmmHours < 0) hmmHours = 0;
  int hours = hmmHours.floor();
  int minutes = ((hmmHours - hours) * 100).round();

  if (minutes >= 60) { // Should ideally not happen if H.MM is well-formed (e.g. not 1.60, 1.75)
    // This handles cases like 1.75 (intended as 1h 75m by mistake) -> 2.15 (H.MM) -> 2 + 15/60 fractional
    hours += (minutes ~/ 60);
    minutes %= 60;
  }
  return hours + (minutes / 60.0);
}


class MaterialClock extends StatefulWidget {
  final double initialSelectedHours; // Expected in H.MM format (e.g., 1.30 for 1h 30m)
  final ValueChanged<double> onTimeChanged; // Returns H.MM format
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

    // Convert H.MM to total fractional hours for angle calculation
    int h = _selectedHours.floor();
    int m = ((_selectedHours - h) * 100).round();
    double totalFractionalHours = h + (m / 60.0);

    _turns = totalFractionalHours.floor(); // Each turn represents 1 full hour
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

    // totalHours is actual total hours in fractional form (e.g., 1.5 for 1h 30m)
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
      // Store selectedHours in H.MM format
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

    // Reset turns and selected hours when a new drag starts
    // This makes the clock behave like setting a duration from zero each time,
    // or from the initial value if we decide to preserve turns based on initial.
    // For simplicity, let's reset turns based on the new starting angle.
    // This means dragging always starts from the current visual angle as "0 turns".
    // To make it behave like session_page (reset to 0 on pan start):
    // setState(() {
    //   _lastAngle = angle;
    //   _turns = 0;
    //   _hourAngle = angle;
    //   _selectedHours = double.parse('0.${(((angle / (2*pi)) * 60).round()).toString().padLeft(2,'0')}');
    // });
    // widget.onTimeChanged(_selectedHours);

    // More intuitive: start from current position without resetting turns immediately,
    // turns adjust based on subsequent movement.
    // The _updateHourHand will correctly calculate based on this _lastAngle.
     _lastAngle = angle; // just update the last angle
     // To make it snap to the nearest minute or so on start:
     _updateHourHand(localPosition);


  }

  @override
  Widget build(BuildContext context) {
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
            // Potentially pass theme colors to painter
          ),
        ),
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  final double hourAngle;
  final Color faceColor;
  final Color handColor;
  final Color numberColor;
  final Color centerDotColor;

  _ClockPainter({
    required this.hourAngle,
    this.faceColor = Colors.white,
    this.handColor = Colors.blue,
    this.numberColor = Colors.black,
    this.centerDotColor = Colors.black,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = faceColor;
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    // Draw clock face
    canvas.drawCircle(center, radius, paint);

    // Draw outline
    final outlinePaint = Paint()
      ..color = numberColor.withAlpha(50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, outlinePaint);


    // Draw clock numbers
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    final double numberRadius = radius - (radius * 0.15); // Adjust number distance from edge
    final double fontSize = radius * 0.1; // Adjust font size based on radius


    for (int i = 1; i <= 12; i++) {
      final angle = (i * 30) * (pi / 180); // Angle for 12-hour clock numbers
      // Numbers are positioned as on a standard clock (12 at top, 3 at right)
      // sin for x, -cos for y to start 12 at top and go clockwise
      final x = center.dx + numberRadius * sin(angle);
      final y = center.dy - numberRadius * cos(angle);

      textPainter.text = TextSpan(
        text: i.toString(),
        style: TextStyle(color: numberColor, fontSize: fontSize),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }

    // Draw hour hand
    final handPaint = Paint()
      ..color = handColor
      ..strokeWidth = max(2.0, radius * 0.03) // Make stroke width responsive
      ..strokeCap = StrokeCap.round;

    final handLength = radius * 0.6; // Adjust hand length
    // The hourAngle is 0 at 12 o'clock, positive clockwise.
    // cos(angle - pi/2) for x, sin(angle - pi/2) for y if angle is from positive x-axis.
    // If hourAngle is 0 at 12 (positive y-axis), then:
    // x = handLength * sin(hourAngle)
    // y = -handLength * cos(hourAngle)
    final handX = center.dx + handLength * sin(hourAngle);
    final handY = center.dy - handLength * cos(hourAngle);

    canvas.drawLine(center, Offset(handX, handY), handPaint);

    // Draw center dot
    final centerDotPaint = Paint()..color = centerDotColor;
    canvas.drawCircle(center, max(2.0, radius * 0.04), centerDotPaint); // Make dot responsive
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) =>
      oldDelegate.hourAngle != hourAngle ||
      oldDelegate.faceColor != faceColor ||
      oldDelegate.handColor != handColor ||
      oldDelegate.numberColor != numberColor ||
      oldDelegate.centerDotColor != centerDotColor;
}

// The old ClockWidget (displaying current time) has been removed from this file.
// If needed, it should be a separate widget.
// This file now provides MaterialClock for duration selection.

/*
Original ClockWidget for reference (if needed to be recreated elsewhere):

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClockWidget extends StatefulWidget {
  const ClockWidget({super.key});

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  late Timer _timer;
  late String _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => _getTime(),
    );
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    if (mounted) {
      setState(() {
        _currentTime = formattedDateTime;
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime); // Example format: 23:59:59
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center( // Center the clock text
      child: Text(
        _currentTime,
        style: TextStyle(
          fontSize: 28, // Increased font size
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary, // Use primary color from theme
          shadows: [
            Shadow(
              blurRadius: 2.0,
              color: Colors.black.withOpacity(0.3), // Consider Theme.of(context).shadowColor or similar
              offset: const Offset(1.0, 1.0),
            ),
          ],
        ),
      ),
    );
  }
}
*/
