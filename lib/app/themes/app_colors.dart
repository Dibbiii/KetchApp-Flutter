import 'package:flutter/material.dart';

// Google App Style Color definitions
const Color seedColor = Color(0xFF0062E2); // A Google-esque Blue
const Color primaryColor = Color(0xFF0062E2); // Primary actions, buttons
const Color onPrimaryColor = Color(0xFFFFFFFF); // Text/icons on primaryColor

const Color secondaryColor = Color(0xFF555F71); // Secondary elements, accents
const Color onSecondaryColor = Color(
  0xFFFFFFFF,
); // Text/icons on secondaryColor

const Color tertiaryColor = Color(0xFF6B5778); // Tertiary elements, accents
const Color onTertiaryColor = Color(0xFFFFFFFF); // Text/icons on tertiaryColor

const Color errorColor = Color(0xFFB00020); // Standard Material error red
const Color onErrorColor = Color(0xFFFFFFFF); // Text/icons on errorColor

const Color surfaceColor = Color(0xFFFDFBFF); // Backgrounds for cards, sheets
const Color onSurfaceColor = Color(0xFF1A1C1E); // Text/icons on surfaceColor

const Color backgroundColor = Color(0xFFFDFBFF); // Main screen background
// For AppBar foreground, ensure it contrasts with AppBar's effective background
// If AppBar uses primaryColor, this would be onPrimaryColor.
// If AppBar is surface, this would be onSurfaceColor.
// Let's assume AppBar might use surface or a light color, so onSurfaceColor is a safe bet.
const Color foregroundColor = Color(0xFF1A1C1E);

const Color snackBarBackgroundColor = Color(
  0xFF323232,
); // Dark background for snackbars

const double elevationHeight =
    0.0; // Google style often prefers flatter UIs, reduce default elevation

// Existing custom color, can be kept if used for specific non-theme elements
const Color kTomatoRed = Color(0xFFD9534F);
