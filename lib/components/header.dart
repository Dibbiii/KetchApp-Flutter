import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ketchapp_flutter/app/themes/theme_provider.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final AppBarTheme colors = Theme.of(context).appBarTheme;

    return AppBar(
      backgroundColor: colors.backgroundColor,
      title: const Text('Ketchapp AppBar'),
      actions: [
        PopupMenuButton<ThemeMode>(
          icon: const Icon(Icons.palette_outlined),
          tooltip: 'Seleziona Tema',
          onSelected: (ThemeMode newMode) {
            themeProvider.setThemeMode(newMode);
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<ThemeMode>>[
            const PopupMenuItem<ThemeMode>(
              value: ThemeMode.system,
              child: Text('Predefinito Sistema'),
            ),
            const PopupMenuItem<ThemeMode>(
              value: ThemeMode.light,
              child: Text('Chiaro'),
            ),
            const PopupMenuItem<ThemeMode>(
              value: ThemeMode.dark,
              child: Text('Scuro'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
