import 'package:flutter/material.dart';
import 'package:ketchapp_flutter/components/clock_widget.dart';
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
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => ShowBottomSheet(),
            isScrollControlled: true,
            enableDrag: true,
            // Allows dragging the sheet itself
            showDragHandle: true,
            // Displays the drag handle
            barrierColor: Colors.black.withOpacity(
              0.5,
            ), // Make background darker
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const Footer(),
    );
  }
}