import 'package:flutter/material.dart';
import 'package:ketchapp_flutter/components/footer.dart';
import 'package:ketchapp_flutter/app/layouts/widgets/plan_sheet_widget.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      floatingActionButton: FloatingActionButton(
        heroTag: "main_layout_fab",
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => ShowBottomSheet(),
            isScrollControlled: true,
            enableDrag: true,
            showDragHandle: true,
            barrierColor: Colors.black.withOpacity(
              0.5,
            ),
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const Footer(),
    );
  }
}