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
    // Used for cards, dialogs, etc.
    onSurface: onSurfaceColor,
    // Text on surface
    background: backgroundColor,
    // Main background of the app
    onBackground: onSurfaceColor, // Text on background
  ),
  scaffoldBackgroundColor:
  backgroundColor,
  // Explicitly set scaffold background
  appBarTheme: const AppBarTheme(
    backgroundColor: surfaceColor,
    // AppBars with surface color
    foregroundColor: onSurfaceColor,
    // Text and icons on AppBar
    elevation: elevationHeight,
    // Flatter AppBar
    scrolledUnderElevation: 0.5,
    // Subtle elevation when content scrolls under
    surfaceTintColor: Colors.transparent, // Avoid tinting on scroll with M3
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: surfaceColor,
    // Or Material 3 navigation bar color
    selectedItemColor: primaryColor,
    // Selected icon/text uses primary color
    unselectedItemColor: onSurfaceColor.withOpacity(
      0.60,
    ),
    // Unselected items are less prominent
    elevation: elevationHeight,
    // Flatter navigation bar
    type: BottomNavigationBarType.fixed,
    // Consistent behavior
    showSelectedLabels: true,
    showUnselectedLabels: true,
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: snackBarBackgroundColor,
    contentTextStyle: TextStyle(
      color: onPrimaryColor,
    ), // Assuming snackbar uses a dark background
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: primaryColor,
    foregroundColor: onPrimaryColor,
    elevation: elevationHeight, // Consistent elevation
    highlightElevation: elevationHeight + 2,
  ),
  cardTheme: CardTheme(
    elevation: elevationHeight, // Flatter cards
    color: surfaceColor,
    surfaceTintColor: Colors.transparent, // M3: avoid tinting
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        12.0,
      ), // Common Google style card radius
      side: BorderSide(
        color: onSurfaceColor.withOpacity(0.12), // Subtle border for cards
        width: 1,
      ),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: onPrimaryColor,
      elevation: elevationHeight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // Consistent button shape
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: primaryColor,
      side: BorderSide(color: primaryColor.withOpacity(0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: onSurfaceColor.withOpacity(0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: onSurfaceColor.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: primaryColor, width: 2.0),
    ),
    filled: true,
    fillColor: surfaceColor.withOpacity(0.5), // Subtle fill
  ),
  useMaterial3: true,
);

// Define dark theme colors based on the new palette
// Material 3 dark themes often use desaturated colors and very dark surfaces.
final Color darkSurfaceColorM3 = Colors.grey[850]!; // A common dark surface
final Color onDarkSurfaceColorM3 = Colors.white.withOpacity(
  0.87,
); // High emphasis text
final Color darkBackgroundColorM3 =
Colors.grey[900]!; // A common dark background

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: seedColor,
    // Use the same seed color
    brightness: Brightness.dark,
    // Important for dark theme generation
    primary:
    primaryColor,
    // Or a slightly lighter variant if needed: primaryColor.shade300
    onPrimary: onPrimaryColor,
    secondary: secondaryColor,
    // Or a lighter variant
    onSecondary: onSecondaryColor,
    tertiary: tertiaryColor,
    // Or a lighter variant
    onTertiary: onTertiaryColor,
    error: errorColor,
    // Standard error red
    onError: onErrorColor,
    surface: darkSurfaceColorM3,
    onSurface: onDarkSurfaceColorM3,
    background: darkBackgroundColorM3,
    onBackground: onDarkSurfaceColorM3,
  ),
  scaffoldBackgroundColor: darkBackgroundColorM3,
  appBarTheme: AppBarTheme(
    backgroundColor: darkSurfaceColorM3,
    foregroundColor: onDarkSurfaceColorM3,
    elevation: elevationHeight,
    scrolledUnderElevation: 0.5,
    surfaceTintColor: Colors.transparent,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor:
    darkSurfaceColorM3,
    // Or Material 3 navigation bar color for dark
    selectedItemColor: primaryColor,
    // Selected icon/text
    unselectedItemColor: onDarkSurfaceColorM3.withOpacity(
      0.60,
    ),
    // Unselected items
    elevation: elevationHeight,
    type: BottomNavigationBarType.fixed,
    showSelectedLabels: true,
    showUnselectedLabels: true,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Colors.grey[700], // Darker snackbar for dark theme
    contentTextStyle: TextStyle(color: onDarkSurfaceColorM3),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: primaryColor,
    foregroundColor: onPrimaryColor,
    elevation: elevationHeight,
    highlightElevation: elevationHeight + 2,
  ),
  cardTheme: CardTheme(
    elevation: elevationHeight,
    color: darkSurfaceColorM3,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
      side: BorderSide(
        color: onDarkSurfaceColorM3.withOpacity(
          0.12,
        ), // Subtle border for cards
        width: 1,
      ),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: onPrimaryColor,
      elevation: elevationHeight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: primaryColor, // Or a lighter primary for dark theme
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: primaryColor, // Or a lighter primary
      side: BorderSide(
        color: primaryColor.withOpacity(0.7),
      ), // More visible border on dark
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: onDarkSurfaceColorM3.withOpacity(0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: onDarkSurfaceColorM3.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(
        color: primaryColor,
        width: 2.0,
      ), // Or lighter primary
    ),
    filled: true,
    fillColor: darkSurfaceColorM3.withOpacity(0.5), // Subtle fill for dark
  ),
  useMaterial3: true,
);
