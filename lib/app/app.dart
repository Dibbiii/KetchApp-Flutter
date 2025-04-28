import 'package:flutter/material.dart';
import 'package:ketchapp_flutter/app/router.dart';
import 'package:ketchapp_flutter/app/themes/app_theme.dart'; // Importa i tuoi ThemeData
import 'package:ketchapp_flutter/app/themes/theme_provider.dart'; // Importa il tuo ThemeProvider
import 'package:provider/provider.dart'; // Importa provider

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ascolta le modifiche del ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      title: 'KetchApp',
      // Imposta themeMode, theme e darkTheme dinamicamente dal provider
      themeMode: themeProvider.themeMode,
      theme: lightTheme, // Il tuo tema chiaro definito in app_theme.dart
      darkTheme: darkTheme, // <-- Assicurati di avere un tema scuro definito
      routerConfig: router,
    );
  }
}

// Assicurati di avere anche un ThemeData per la modalità scura
// definito nel tuo file app_theme.dart (o altrove)
// Esempio:
// final ThemeData darkAppThemeData = ThemeData.dark().copyWith(
//   colorScheme: ColorScheme.fromSeed(
//     seedColor: kPrimaryBlue, // O un colore seme per il tema scuro
//     brightness: Brightness.dark,
//     // ... altre personalizzazioni per il tema scuro
//   ),
//   // ...
// );