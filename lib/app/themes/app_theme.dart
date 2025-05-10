import 'package:flutter/material.dart';
import 'app_colors.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: seedColor,
    primary: primaryColor,
    onPrimary: onPrimaryColor,
    secondary: secondaryColor,
    onSecondary: onSecondaryColor,
    tertiary: tertiaryColor,
    onTertiary: onTertiaryColor,
    error: errorColor,
    onError: onErrorColor,
    surface: surfaceColor,
    onSurface: onSurfaceColor,
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: snackBarBackgroundColor,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
    elevation: elevationHeight,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: backgroundColor,
    selectedItemColor: secondaryColor,
    unselectedItemColor: primaryColor,
    elevation: elevationHeight,
  ),
  useMaterial3: true,
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: seedColor,
    primary: primaryColor,
    onPrimary: onPrimaryColor,
    secondary: secondaryColor,
    onSecondary: onSecondaryColor,
    tertiary: tertiaryColor,
    onTertiary: onTertiaryColor,
    error: errorColor,
    onError: onErrorColor,
    surface: surfaceColor,
    onSurface: onSurfaceColor,
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: snackBarBackgroundColor,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
    elevation: elevationHeight,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: backgroundColor,
    selectedItemColor: secondaryColor,
    unselectedItemColor: primaryColor,
    elevation: elevationHeight,
  ),
  useMaterial3: true,
);
