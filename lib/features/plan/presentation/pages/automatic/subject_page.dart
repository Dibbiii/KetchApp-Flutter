import 'package:flutter/material.dart';

class SubjectPage extends StatefulWidget{
  const SubjectPage({super.key});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  final List<String> _subjects = []; // Lista delle materie

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final subjectName = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    String input = '';
                    return AlertDialog(
                      title: const Text('Aggiungi Materia'),
                      content: TextField(
                        onChanged: (value) {
                          input = value;
                        },
                        decoration: const InputDecoration(hintText: 'Inserisci la Materia'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                          Navigator.of(context).pop(null);
                          },
                          style: TextButton.styleFrom(
                          foregroundColor: colors.error, // Imposta il colore su Colors.red
                          ),
                          child: const Text('Annulla'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(input);
                          },
                          child: const Text('Aggiungi'),
                        ),
                      ],
                    );
                  },
                );

                if (subjectName != null && subjectName.isNotEmpty) {
                  setState(() {
                    _subjects.add(subjectName); // Aggiungi la materia alla lista
                  });
                }
              },
              child: const Text('+ Aggiungi Materia'),
            ),
            const SizedBox(height: 16),
            // Mostra l'elenco delle materie aggiunte
            ListView.builder(
              shrinkWrap: true,
              itemCount: _subjects.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Center(child: Text(_subjects[index])),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}