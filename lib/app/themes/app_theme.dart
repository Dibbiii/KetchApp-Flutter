import 'package:flutter/material.dart';
import 'app_colors.dart'; // Assumendo che tu abbia definito kPrimaryBlue, kDarkBackground, ecc.

// Tema Chiaro
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light, // Importante per l'adattamento del sistema
  colorScheme: ColorScheme.fromSeed(
    seedColor: kPrimaryBlue,
    primary: kPrimaryBlue,
    secondary: kPrimaryBlue.withAlpha(
      (0.8 * 255).toInt(),
    ), 
    error: kErrorRed,
    brightness: Brightness.light,
    surface: kWhite,
    onPrimary: kWhite,
    onSurface: kBlack,
    secondaryContainer: kSuccessGreen, // Success color
    tertiaryContainer: kWarningYellow, // Warning color
  ),
  scaffoldBackgroundColor: kWhite,
  appBarTheme: const AppBarTheme(
    backgroundColor: kPrimaryBlue,
    foregroundColor: kWhite,
  ),
  iconTheme: const IconThemeData(color: kBlack),
  // ... altre proprietà del tema chiaro ...
);

// Tema Scuro
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kPrimaryBlue,
    primary: kDarkPrimaryBlue,
    secondary: kDarkSecondaryBlue,
    error: kDarkErrorRed,
    brightness: Brightness.dark,
    surface: kDarkBackground,
    onPrimary: kDarkWhite,
    onSurface: kDarkWhite,
    secondaryContainer: kDarkSuccessGreen, // Slightly darker success color
    tertiaryContainer: kDarkWarningYellow, // Slightly darker warning color
  ),
  scaffoldBackgroundColor: kDarkBackground,
  appBarTheme: AppBarTheme(
    backgroundColor: kDarkPrimaryBlue,
    foregroundColor: kDarkWhite,
  ),
  iconTheme: const IconThemeData(color: kDarkGray),
  // ... altre proprietà del tema scuro ...
);
