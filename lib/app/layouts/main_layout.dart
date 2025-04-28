import 'package:flutter/material.dart';
import 'package:ketchapp_flutter/components/footer.dart';
import 'package:ketchapp_flutter/components/header.dart';

class MainLayout extends StatelessWidget {
  final Widget child; 
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(),
      body: child,
      bottomNavigationBar: const Footer(),
    );
  }
}