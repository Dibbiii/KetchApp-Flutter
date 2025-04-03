import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Footer extends StatefulWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 255, 245, 156),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                context.go('/login'); // Navigazione con GoRouter
              },
              icon: const Icon(Icons.home),
            ),
            IconButton(
              onPressed: () {
                context.go('/register'); // Navigazione con GoRouter
              },
              icon: const Icon(Icons.bar_chart),
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.emoji_events)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.person)),
          ],
        ),
      ),
    );
  }
}
