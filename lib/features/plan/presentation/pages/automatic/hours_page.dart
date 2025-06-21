import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ruler_picker/flutter_ruler_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class HoursPage extends StatefulWidget {
  const HoursPage({super.key});

  @override
  State<HoursPage> createState() => _HoursPageState();
}

class _HoursPageState extends State<HoursPage> {
  double selectedHour = 0;
  RulerPickerController? _rulerPickerController;
  final int maxMinutes = 24 * 60; // 1440

  @override
  void initState() {
    super.initState();
    _rulerPickerController = RulerPickerController(value: selectedHour * 60);
    _rulerPickerController?.addListener(() {
      setState(() {
        selectedHour = _rulerPickerController!.value.toDouble() / 60.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quante ore vuoi studiare?',
              style: TextStyle(fontSize: 20, color: colors.onSurface),
            ),
            const SizedBox(height: 24),
            Listener(
              onPointerSignal: (pointerSignal) {
                if (pointerSignal is PointerScrollEvent) {
                  const double scrollIncrement = 10.0;
                  double newValue = _rulerPickerController!.value.toDouble();
                  if (pointerSignal.scrollDelta.dy > 0) {
                    newValue -= scrollIncrement;
                  } else if (pointerSignal.scrollDelta.dy < 0) {
                    newValue += scrollIncrement;
                  }
                  _rulerPickerController!.value = newValue.clamp(0, maxMinutes);
                }
              },
              child: GestureDetector(
                onPanUpdate: (details) {
                  final double dragSensitivity = 0.8;
                  final double currentVal =
                      _rulerPickerController!.value.toDouble();
                  final newValue =
                      currentVal - details.delta.dx * dragSensitivity;
                  _rulerPickerController!.value = newValue.clamp(0, maxMinutes);
                },
                child: _buildPlatformRulerPicker(context, colors),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ore selezionate: ${_formatDuration(Duration(minutes: (selectedHour * 60).round()))}',
              style: TextStyle(fontSize: 16, color: colors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformRulerPicker(BuildContext context, ColorScheme colors) {
    final _rulerPickerController = (context as Element)
        .findAncestorStateOfType<_HoursPageState>()?._rulerPickerController;
    final int maxMinutes = 24 * 60;
    final double selectedHour =
        (context as Element).findAncestorStateOfType<_HoursPageState>()?.selectedHour ?? 0;

    Widget picker = RulerPicker(
      controller: _rulerPickerController!,
      ranges: [RulerRange(begin: 0, end: maxMinutes, scale: 10)],
      onValueChanged: (value) {
        (context as Element).findAncestorStateOfType<_HoursPageState>()?.setState(() {
          (context as Element).findAncestorStateOfType<_HoursPageState>()?.selectedHour = value.toDouble() / 60.0;
        });
      },
      rulerBackgroundColor: Colors.transparent,
      width: MediaQuery.of(context).size.width - 32,
      height: 80,
      marker: Container(
        width: 4,
        height: 60,
        color: colors.primary,
      ),
      scaleLineStyleList: const [
        ScaleLineStyle(
          color: Colors.yellow,
          width: 2,
          height: 30,
          scale: 6,
        ),
        ScaleLineStyle(
          color: Colors.orange,
          width: 1.5,
          height: 25,
          scale: 3,
        ),
        ScaleLineStyle(
          color: Colors.green,
          width: 1.2,
          height: 20,
          scale: 1,
        ),
      ], onBuildRulerScaleText: (int index, num rulerScaleValue) {
        return rulerScaleValue.toString();
      },
    );

    if (kIsWeb || (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      return MouseRegion(
        cursor: SystemMouseCursors.resizeLeftRight,
        child: picker,
      );
    } else {
      return picker;
    }
  }
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  String result = '';

  if (hours > 0) {
    result += '${hours}h';
  }

  if (hours > 0 || minutes > 0) {
    if (result.isNotEmpty) {
      result += ' e ';
    }
    result += '${minutes}m';
  }

  if (result.isEmpty) {
    return '0h e 0m';
  }
  return result;
}
