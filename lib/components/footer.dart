import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  @override
  Widget build(BuildContext context) {
    // Accedi ai colori tramite il tema
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color iconColor = Theme.of(context).iconTheme.color ?? colors.onSurface;

    return Container(
      color: colors.primary,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.home, color: colors.onPrimary), // Colore icona su sfondo primario
            onPressed: () {
              context.go('/home');
            },
          ),
          IconButton(
            icon: Icon(Icons.bar_chart, color: colors.onPrimary),
            onPressed: () {
              context.go('/statistics');
            },
          ),
          IconButton(
            icon: Icon(Icons.emoji_events, color: colors.onPrimary),
            onPressed: () {
              context.go('/rankings');
            },
          ),
          IconButton(
            icon: Icon(Icons.person, color: colors.onPrimary),
            onPressed: () {
              context.go('/profile');
            },
          ),
        ],
      ),
    );
  }
}
