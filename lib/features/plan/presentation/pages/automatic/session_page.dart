import 'dart:math';
import 'package:flutter/material.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  double sessionHourAngle = 0;
  double sessionSelectedHours = 0;
  double _sessionLastAngle = 0;
  int _sessionTurns = 0;

  double breakHourAngle = 0;
  double breakSelectedHours = 0;
  double _breakLastAngle = 0;
  int _breakTurns = 0;

  static const double minClockSize = 80.0; //così non diventa troppo piccolo su schermi piccoli
  static const double maxClockSize = 200.0; //così non diventa troppo grande su schermi grandi
  static const double verticalPadding = 24 + 32 + 24 + 32 + 2 * (20 + 16); //calcola quanto spazio c'è sopra e sotto i due orologi -> adatta la dim degli orologi in base a quello -> evita overflow

  void _updateHourHand({
    required Offset localPosition,
    required Size size,
    required bool isSession,
  }) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    double angle = atan2(dy, dx);
    angle = angle + pi / 2; // l'angolo di norma partirebbe ruotato di 90° in senso antiorario -> lo porto sul 12
    if (angle < 0) angle += 2 * pi; //la funzione atan2 può restituire angoli negativi -> li rendiamo positivi (da 0 a 360°)

    if (isSession) {
      double delta = angle - _sessionLastAngle;

      if (delta < -pi) { 
        _sessionTurns++;
        
      }
      else if (delta > pi) {
        _sessionTurns--;
      }

      _sessionLastAngle = angle;
      setState(() {
        sessionHourAngle = angle; 
        sessionSelectedHours = _sessionTurns + angle / (2 * pi); 
      });
    } else {
      double delta = angle - _breakLastAngle;

      if (delta < -pi) {
        _breakTurns++;
      } else if (delta > pi) {
        _breakTurns--;
      }

      _breakLastAngle = angle;
      setState(() {
        breakHourAngle = angle;
        breakSelectedHours = _breakTurns + angle / (2 * pi);
      });
    }
  }

  void _onPanStart({ //la funzione viene chiamata quando inizia il movimento del dito sullo schermo
    required Offset local,
    required Size size,
    required bool isSession,
  }) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = local.dx - center.dx; //differenza tra la posizione del dito e il centro dell'orologio
    final dy = local.dy - center.dy;
    double angle = atan2(dy, dx); // restituisce l'angolo -> così aggiorno la posizione della lancetta in base al movimento del dito
    angle = angle + pi / 2; //l'angolo zero viene posizionato sul 12 -> perchè atan2 restituisce un angolo ruotato di 90° in senso antiorario
    if (angle < 0) angle += 2 * pi; //porta l'angolo da 0 a 2π -> da 0 a 360°
    setState(() { //appena inizio a muovere la lancetta
      if (isSession) {
        _sessionLastAngle = angle; //angolo di partenza
        // Reset anche i turni per partire sempre da zero
        _sessionTurns = 0;
        sessionSelectedHours = 0;
      } else {
        _breakLastAngle = angle;
        _breakTurns = 0;
        breakSelectedHours = 0;
      }
    });
  }

  Widget _clockSection({
    required String title,
    required double selectedHours,
    required double hourAngle,
    required void Function(Offset) onPanUpdate,
    required void Function(TapDownDetails) onPanStart,
    required double clockSize,
    required ColorScheme colors,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, color: colors.onSurface),
        ),
        Text(
          'Ore selezionate: ${selectedHours.toStringAsFixed(2)}', // Mostra le ore selezionate con 2 decimali
          style: TextStyle(fontSize: 16, color: colors.primary),
        ),
        SizedBox(
          height: clockSize,
          width: clockSize,
          child: _buildClock(
            hourAngle: hourAngle,
            onPanUpdate: onPanUpdate,
            onPanStart: onPanStart,
          ),
        ),
      ],
    );
  }

  Widget _buildClock({
    required double hourAngle,
    required ValueChanged<Offset> onPanUpdate,
    required GestureTapDownCallback onPanStart,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanUpdate: (details) {
            RenderBox box = context.findRenderObject() as RenderBox;
            Offset local = box.globalToLocal(details.globalPosition);
            onPanUpdate(local);
          },
          onPanStart: (details) {
            RenderBox box = context.findRenderObject() as RenderBox;
            Offset local = box.globalToLocal(details.globalPosition);
            onPanStart(TapDownDetails(globalPosition: details.globalPosition));
          },
          child: CustomPaint(
            painter: _ClockPainter(
              color: Colors.white,
              hourAngle: hourAngle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.maxHeight - verticalPadding;
        final double clockSize = (availableHeight / 2).clamp(minClockSize, maxClockSize);

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 24),
              _clockSection(
                title: 'Sessione',
                selectedHours: sessionSelectedHours,
                hourAngle: sessionHourAngle,
                clockSize: clockSize,
                colors: colors,
                onPanUpdate: (local) => _updateHourHand(
                  localPosition: local,
                  size: Size(clockSize, clockSize),
                  isSession: true,
                ),
                onPanStart: (details) => _onPanStart(
                  local: (context.findRenderObject() as RenderBox)
                      .globalToLocal(details.globalPosition),
                  size: Size(clockSize, clockSize),
                  isSession: true,
                ),
              ),
              const SizedBox(height: 32),
              _clockSection(
                title: 'Pausa',
                selectedHours: breakSelectedHours,
                hourAngle: breakHourAngle,
                clockSize: clockSize,
                colors: colors,
                onPanUpdate: (local) => _updateHourHand(
                  localPosition: local,
                  size: Size(clockSize, clockSize),
                  isSession: false,
                ),
                onPanStart: (details) => _onPanStart(
                  local: (context.findRenderObject() as RenderBox)
                      .globalToLocal(details.globalPosition),
                  size: Size(clockSize, clockSize),
                  isSession: false,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _ClockPainter extends CustomPainter {
  final Color color;
  final double hourAngle;
  _ClockPainter({required this.color, required this.hourAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    // Draw clock face
    canvas.drawCircle(center, radius, paint);

    // Draw clock numbers (in senso orario)
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    for (int i = 1; i <= 12; i++) {
      final angle = (i * 30) * (pi / 180);
      final x = center.dx + (radius - 20) * sin(angle);
      final y = center.dy - (radius - 20) * cos(angle);

      textPainter.text = TextSpan(
        text: i.toString(),
        style: const TextStyle(color: Colors.black, fontSize: 16),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }

    // Draw hour hand (movable)
    final handPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final handLength = radius * 0.7;
    final handX = center.dx + handLength * cos(hourAngle - pi / 2);
    final handY = center.dy + handLength * sin(hourAngle - pi / 2);

    canvas.drawLine(center, Offset(handX, handY), handPaint);

    // Draw center dot
    final centerDotPaint = Paint()..color = Colors.black;
    canvas.drawCircle(center, 6, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) =>
      oldDelegate.hourAngle != hourAngle || oldDelegate.color != color;
}