import 'package:flutter/material.dart';

// Google App Style Color definitions
const Color seedColor = Color(0xFF0062E2); // Seed color for Material 3

// Light Theme Colors
const Color primaryColorLight = Color(0xFF0062E2); // Primary actions, buttons
const Color onPrimaryColorLight = Color(
  0xFFFFFFFF,
); // Text/icons on primaryColor

const Color secondaryColorLight = Color(
  0xFF555F71,
); // Secondary elements, accents
const Color onSecondaryColorLight = Color(
  0xFFFFFFFF,
); // Text/icons on secondaryColor

const Color tertiaryColorLight = Color(
  0xFF6B5778,
); // Tertiary elements, accents
const Color onTertiaryColorLight = Color(
  0xFFFFFFFF,
); // Text/icons on tertiaryColor

const Color errorColorLight = Color(0xFFB00020); // Standard Material error red
const Color onErrorColorLight = Color(0xFFFFFFFF); // Text/icons on errorColor

const Color surfaceColorLight = Color(
  0xFFFDFBFF,
); // Backgrounds for cards, sheets
const Color onSurfaceColorLight = Color(
  0xFF1A1C1E,
); // Text/icons on surfaceColor

const Color backgroundColorLight = Color(0xFFFDFBFF);
const Color onBackgroundColorLight = Color(
  0xFF1A1C1E,
); // Text/icons on backgroundColor

const Color snackBarBackgroundColorLight = Color(
  0xFF323232,
); // SnackBar background
const Color onSnackBarBackgroundColorLight = Color(
  0xFFFFFFFF,
); // SnackBar text/icons

const Color primaryContainerColorLight = Color(0xFFD1E4FF);
const Color onPrimaryContainerColorLight = Color(0xFF001D36);
const Color secondaryContainerColorLight = Color(0xFFD2E4FF);
const Color onSecondaryContainerColorLight = Color(0xFF001D36);
const Color tertiaryContainerColorLight = Color(0xFFFFD8E4);
const Color onTertiaryContainerColorLight = Color(0xFF31111D);
const Color errorContainerColorLight = Color(0xFFFFDAD6);
const Color onErrorContainerColorLight = Color(0xFF410002);
const Color surfaceVariantColorLight = Color(0xFFDFE2EB);
const Color onSurfaceVariantColorLight = Color(0xFF42474E);
const Color outlineColorLight = Color(0xFF73777F);
const Color outlineVariantColorLight = Color(0xFFC2C6CF);
const Color scrimColorLight = Color(0xFF000000);
const Color inverseSurfaceColorLight = Color(0xFF2F3033);
const Color onInverseSurfaceColorLight = Color(0xFFF0F0F3);
const Color inversePrimaryColorLight = Color(0xFFA0C9FF);
const Color surfaceTintColorLight = primaryColorLight;
const Color shadowColorLight = Color(0xFF000000);
const Color focusColorLight = Color(
  0x1F000000,
); // Typically a translucent version of a color
const Color hoverColorLight = Color(
  0x0A000000,
); // Typically a very translucent version of a color
const Color canvasColorLight = Color(0xFFFAFAFA); // Light grey/white for canvas
const Color dividerColorLight = Color(
  0x1F000000,
); // Typically a translucent black or grey
const Color highlightColorLight = Color(0x66BCBCBC); // Semi-transparent grey
const Color splashColorLight = Color(0x66C8C8C8); // Semi-transparent grey
const Color unselectedWidgetColorLight = Color(
  0x8A000000,
); // Semi-transparent black
const Color disabledColorLight = Color(0x61000000); // Semi-transparent black
const Color secondaryHeaderColorLight = Color(
  0xFFE3F2FD,
); // Light blue, often used for secondary headers

// Dark Theme Colors
const Color primaryColorDark = Color(
  0xFF74AEFF,
); // A lighter blue for dark mode
const Color onPrimaryColorDark = Color(
  0xFF003062,
); // Darker text/icons on primaryColorDark

const Color secondaryColorDark = Color(
  0xFFB8C8DC,
); // Lighter secondary for dark mode
const Color onSecondaryColorDark = Color(
  0xFF283241,
); // Darker text/icons on secondaryColorDark

const Color tertiaryColorDark = Color(
  0xFFD7BDE2,
); // Lighter tertiary for dark mode
const Color onTertiaryColorDark = Color(
  0xFF3B2948,
); // Darker text/icons on tertiaryColorDark

const Color errorColorDark = Color(
  0xFFFFB4AB,
); // Lighter error red for dark mode
const Color onErrorColorDark = Color(
  0xFF690005,
); // Darker text/icons on errorColorDark

const Color surfaceColorDark = Color(
  0xFF121316,
); // Dark background for cards, sheets
const Color onSurfaceColorDark = Color(
  0xFFE2E2E6,
); // Lighter text/icons on surfaceColorDark

const Color backgroundColorDark = Color(0xFF121316); // Dark background
const Color onBackgroundColorDark = Color(
  0xFFE2E2E6,
); // Lighter text/icons on backgroundColorDark

const Color snackBarBackgroundColorDark = Color(
  0xFFE2E2E6,
); // SnackBar background (light for contrast)
const Color onSnackBarBackgroundColorDark = Color(
  0xFF121316,
); // SnackBar text/icons (dark for contrast)

const Color primaryContainerColorDark = Color(0xFF004788);
const Color onPrimaryContainerColorDark = Color(0xFFD1E4FF);
const Color secondaryContainerColorDark = Color(0xFF3E4758);
const Color onSecondaryContainerColorDark = Color(0xFFD2E4FF);
const Color tertiaryContainerColorDark = Color(0xFF533F5F);
const Color onTertiaryContainerColorDark = Color(0xFFFFD8E4);
const Color errorContainerColorDark = Color(0xFF93000A);
const Color onErrorContainerColorDark = Color(0xFFFFDAD6);
const Color surfaceVariantColorDark = Color(0xFF42474E);
const Color onSurfaceVariantColorDark = Color(0xFFC2C6CF);
const Color outlineColorDark = Color(0xFF8C9199);
const Color outlineVariantColorDark = Color(0xFF42474E);
const Color scrimColorDark = Color(0xFF000000);
const Color inverseSurfaceColorDark = Color(0xFFE2E2E6);
const Color onInverseSurfaceColorDark = Color(0xFF2F3033);
const Color inversePrimaryColorDark = Color(0xFF005CB2);
const Color surfaceTintColorDark = primaryColorDark;
const Color shadowColorDark = Color(
  0xFF000000,
); // Shadow color can often be the same
const Color focusColorDark = Color(
  0x1FFFFFFF,
); // Typically a translucent version of a color (light for dark theme)
const Color hoverColorDark = Color(
  0x0AFFFFFF,
); // Typically a very translucent version of a color (light for dark theme)
const Color canvasColorDark = Color(0xFF1E1E1E); // Dark grey for canvas
const Color dividerColorDark = Color(
  0x1FFFFFFF,
); // Typically a translucent white or grey
const Color highlightColorDark = Color(
  0x40CCCCCC,
); // Semi-transparent light grey
const Color splashColorDark = Color(0x40CCCCCC); // Semi-transparent light grey
const Color unselectedWidgetColorDark = Color(
  0x8AFFFFFF,
); // Semi-transparent white
const Color disabledColorDark = Color(0x61FFFFFF); // Semi-transparent white
const Color secondaryHeaderColorDark = Color(
  0xFF1E2A3A,
); // Dark blue, often used for secondary headers

// Common
const double elevationHeight = 4.0; // Standard elevation height for shadows
const double elevationHeight2 = 8.0; // Elevated surfaces 2
const double elevationHeight3 = 12.0; // Elevated surfaces 3
const double elevationHeight4 = 16.0; // Elevated surfaces 4
const double elevationHeight5 = 24.0; // Elevated surfaces 5
