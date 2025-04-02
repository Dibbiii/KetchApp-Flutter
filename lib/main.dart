import 'package:flutter/material.dart';
import 'package:ketchapp_flutter/register.dart';
import 'package:ketchapp_flutter/welcome.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(backgroundColor: Colors.amber),
        body: Center(child: Register()),
      ),
    );
  }
}
