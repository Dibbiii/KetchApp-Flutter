import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ketchapp_flutter/app/themes/theme_provider.dart';
import 'package:ketchapp_flutter/app/themes/app_colors.dart'; // Import app_colors

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final ColorScheme colors = Theme
        .of(context)
        .colorScheme;
    final TextTheme textTheme = Theme
        .of(context)
        .textTheme;

    // Removed the gradient definition

    return AppBar(
      // Removed flexibleSpace
      backgroundColor: kTomatoRed, // Set solid background color like footer
      elevation: 0, // Remove shadow for a flatter look
      title: Text(
        'Ketchapp', // App Title
        style: textTheme.titleLarge?.copyWith(
          // Use color that contrasts with kTomatoRed (likely white)
          color: colors.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        PopupMenuButton<ThemeMode>(
          icon: Icon(
            Icons.palette_outlined,
            // Use color that contrasts with kTomatoRed
            color: colors.onPrimary,
          ),
          tooltip: 'Select Theme',
          // English tooltip
          color: colors.surface,
          // Background color for the popup menu
          onSelected: (ThemeMode newMode) {
            themeProvider.setThemeMode(newMode);
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<ThemeMode>>[
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.system,
              child: Text(
                'System Default', // English text
                style: textTheme.bodyMedium?.copyWith(color: colors.onSurface),
              ),
            ),
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.light,
              child: Text(
                'Light', // English text
                style: textTheme.bodyMedium?.copyWith(color: colors.onSurface),
              ),
            ),
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.dark,
              child: Text(
                'Dark', // English text
                style: textTheme.bodyMedium?.copyWith(color: colors.onSurface),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}