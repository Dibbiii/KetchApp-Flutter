import 'package:flutter/material.dart';
import 'package:flutter_ruler_picker/flutter_ruler_picker.dart';

class HoursPage extends StatefulWidget {
  const HoursPage({super.key});

  @override
  State<HoursPage> createState() => _HoursPageState();
}

class _HoursPageState extends State<HoursPage> {
  double selectedHour = 1.0;
  RulerPickerController? _rulerPickerController;

  @override
  void initState() {
    super.initState();
    _rulerPickerController = RulerPickerController(value: selectedHour);
    _rulerPickerController?.addListener(() {
      setState(() {
        selectedHour = _rulerPickerController!.value.toDouble();
      });
    });
  }

  String get formattedHour {
    int hours = selectedHour.floor();
    int minutes = ((selectedHour - hours) * 60).round();
    return '${hours}h${minutes.toString().padLeft(2, '0')}';
  }

  Widget _buildPositionBtn(num value) {
    return InkWell(
      onTap: () {
        _rulerPickerController?.value = value;
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        color: Colors.blue,
        child: Text(value.toString(), style: TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quante ore vuoi studiare?',
              style: TextStyle(fontSize: 20, color: colors.onSurface),
            ),
            const SizedBox(height: 24),
            RulerPicker(
              controller: _rulerPickerController!,
              ranges: [RulerRange(begin: 0, end: 1440, scale: 15)], // 15 minuti
              onValueChanged: (value) {
                setState(() {
                  selectedHour = value / 60.0; // salva il valore in ore
                });
              },
              rulerBackgroundColor: Colors.transparent,
              width: MediaQuery.of(context).size.width - 32,
              height: 80,
              marker: Container(width: 4, height: 60, color: colors.primary),
              scaleLineStyleList: const [
                ScaleLineStyle(
                  color: Colors.grey,
                  width: 1.5,
                  height: 30,
                  scale: 0, // Tacche principali (ogni ora = 60 minuti)
                ),
                ScaleLineStyle(
                  color: Colors.grey,
                  width: 1,
                  height: 20,
                  scale: 1, // Tacche ogni 15 minuti
                ),
              ],
              onBuildRulerScaleText: (int index, num rulerScaleValue) {
                // Mostra il numero solo ogni ora (multipli di 60 minuti)
                if (rulerScaleValue > 0 && rulerScaleValue % 60 == 0 && rulerScaleValue <= 1440) {
                  return (rulerScaleValue ~/ 60).toString();
                }
                return '';
              },
            ),
            const SizedBox(height: 16),
            _buildPositionBtn(8),
            const SizedBox(height: 16),
            Text(
              'Ore selezionate: $formattedHour',
              style: TextStyle(fontSize: 16, color: colors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
