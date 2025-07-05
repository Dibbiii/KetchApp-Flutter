import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

String formatDurationFromHmm(double hmmHours, {String defaultText = "No time set"}) {
  if (hmmHours < 0) hmmHours = 0;
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
    hours += 1;
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
  const MaterialClock({super.key, this.initialSelectedHours = 0.0, required this.onTimeChanged, this.clockSize = 200.0});
  @override
  State<MaterialClock> createState() => _MaterialClockState();
}

class _MaterialClockState extends State<MaterialClock> with SingleTickerProviderStateMixin {
  double _hourAngle = 0.0;
  double _selectedHours = 0.0;
  double _lastAngle = 0.0;
  int _turns = 0;
  late AnimationController _controller;
  late Animation<double> _handAnimation;
  @override
  void initState() {
    super.initState();
    _selectedHours = widget.initialSelectedHours;
    if (_selectedHours < 0) _selectedHours = 0;
    int h = _selectedHours.floor();
    int m = ((_selectedHours - h) * 100).round();
    double totalFractionalHours = h + (m / 60.0);
    _turns = totalFractionalHours.floor();
    _hourAngle = (totalFractionalHours - _turns) * 2 * pi;
    _lastAngle = _hourAngle;
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _handAnimation = Tween<double>(begin: _hourAngle, end: _hourAngle).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  void _updateHourHand(Offset localPosition, {bool animate = false}) {
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
      if (animate) {
        _handAnimation = Tween<double>(begin: _handAnimation.value, end: _hourAngle).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
        _controller.forward(from: 0);
      } else {
        _handAnimation = AlwaysStoppedAnimation(_hourAngle);
      }
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
    _updateHourHand(localPosition, animate: false);
  }
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: widget.clockSize,
      height: widget.clockSize + 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: widget.clockSize + 32,
            height: widget.clockSize + 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.clockSize),
              gradient: LinearGradient(
                colors: [colors.primaryContainer.withValues(alpha: .25), colors.surface.withValues(alpha:0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha:0.10),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: colors.primary.withValues(alpha:0.08),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.clockSize),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: const SizedBox(),
              ),
            ),
          ),
          GestureDetector(
            onPanStart: (details) {
              RenderBox box = context.findRenderObject() as RenderBox;
              Offset local = box.globalToLocal(details.globalPosition);
              _onPanStartGesture(local);
            },
            onPanUpdate: (details) {
              RenderBox box = context.findRenderObject() as RenderBox;
              Offset local = box.globalToLocal(details.globalPosition);
              _updateHourHand(local, animate: false);
            },
            onPanEnd: (details) {},
            child: AnimatedBuilder(
              animation: _handAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ClockPainter(
                    hourAngle: _handAnimation.value,
                    colors: colors,
                  ),
                  size: Size(widget.clockSize, widget.clockSize),
                );
              },
            ),
          ),
          Positioned(
            top: widget.clockSize / 2 - 32,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha:0.85),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha:0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                formatDurationFromHmm(_selectedHours, defaultText: "Set time"),
                style: textTheme.headlineSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  final double hourAngle;
  final ColorScheme colors;
  _ClockPainter({required this.hourAngle, required this.colors});
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final faceRect = Rect.fromCircle(center: center, radius: radius);
    final facePaint = Paint()
      ..shader = LinearGradient(
        colors: [colors.surface, colors.primaryContainer.withValues(alpha:0.18)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(faceRect);
    canvas.drawCircle(center, radius, facePaint);
    final outlinePaint = Paint()
      ..color = colors.primary.withValues(alpha:0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, outlinePaint);
    final tickPaint = Paint()..strokeCap = StrokeCap.round;
    const double tickPadding = 12.0;
    final double innerRadius = radius - tickPadding;
    for (int i = 0; i < 60; i++) {
      final angle = (i * 6) * (pi / 180);
      final isHourMark = i % 5 == 0;
      tickPaint.color = isHourMark ? colors.primary : colors.onSurface.withValues(alpha:0.25);
      tickPaint.strokeWidth = isHourMark ? 3.2 : 1.2;
      final double tickStart = isHourMark ? innerRadius - 10.0 : innerRadius - 4.0;
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
    final handLength = radius * 0.82;
    final handEnd = Offset(
      center.dx + handLength * sin(hourAngle),
      center.dy - handLength * cos(hourAngle),
    );
    final handPaint = Paint()
      ..color = colors.primary
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2.5);
    canvas.drawLine(center, handEnd, handPaint);
    final thumbPaint = Paint()
      ..color = colors.primary
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawCircle(handEnd, 13, thumbPaint);
    final thumbInnerPaint = Paint()..color = colors.surface;
    canvas.drawCircle(handEnd, 6, thumbInnerPaint);
    final centerDotPaint = Paint()..color = colors.primary;
    canvas.drawCircle(center, 7, centerDotPaint);
    final centerDotInnerPaint = Paint()..color = colors.surface;
    canvas.drawCircle(center, 3, centerDotInnerPaint);
  }
  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) =>
      oldDelegate.hourAngle != hourAngle || oldDelegate.colors != colors;
}
