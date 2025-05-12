import 'package:flutter/material.dart';
import 'app_colors.dart'; // Import the color definitions

final ThemeData lightTheme = ThemeData(
  // COLOR SCHEME
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: primaryColorLight,
    onPrimary: onPrimaryColorLight,
    primaryContainer: primaryContainerColorLight,
    onPrimaryContainer: onPrimaryContainerColorLight,
    secondary: secondaryColorLight,
    onSecondary: onSecondaryColorLight,
    secondaryContainer: secondaryContainerColorLight,
    onSecondaryContainer: onSecondaryContainerColorLight,
    tertiary: tertiaryColorLight,
    onTertiary: onTertiaryColorLight,
    tertiaryContainer: tertiaryContainerColorLight,
    onTertiaryContainer: onTertiaryContainerColorLight,
    error: errorColorLight,
    onError: onErrorColorLight,
    errorContainer: errorContainerColorLight,
    onErrorContainer: onErrorContainerColorLight,
    surface: surfaceColorLight,
    onSurface: onSurfaceColorLight,
    surfaceContainerHighest: surfaceVariantColorLight,
    onSurfaceVariant: onSurfaceVariantColorLight,
    outline: outlineColorLight,
    outlineVariant: outlineVariantColorLight,
    shadow: shadowColorLight,
    scrim: scrimColorLight,
    inverseSurface: inverseSurfaceColorLight,
    onInverseSurface: onInverseSurfaceColorLight,
    inversePrimary: inversePrimaryColorLight,
    surfaceTint: surfaceTintColorLight,
  ),
  // DEPRECATED COLORS (kept for reference or specific needs, prefer colorScheme)
  primaryColor: primaryColorLight,
  focusColor: focusColorLight,
  hoverColor: hoverColorLight,
  canvasColor: canvasColorLight,
  // scaffoldBackgroundColor is typically the same as colorScheme.background
  scaffoldBackgroundColor: backgroundColorLight,
  // bottomAppBarColor is now part of bottomAppBarTheme.color or use colorScheme.surface
  // cardColor is now part of cardTheme.color or use colorScheme.surface
  dividerColor: dividerColorLight,
  highlightColor: highlightColorLight,
  splashColor: splashColorLight,
  // selectedRowColor is deprecated, use widget-specific themes like DataTableThemeData
  unselectedWidgetColor: unselectedWidgetColorLight,
  disabledColor: disabledColorLight,
  // Secondary header color.
  secondaryHeaderColor: secondaryHeaderColorLight,
  // Text selection theme.
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: primaryColorLight,
    selectionColor: primaryColorLight.withValues(alpha: 0.4),
    selectionHandleColor: primaryColorLight,
  ),
  // TabBar indicator color.
  indicatorColor: primaryColorLight,
  // Hint text color in text fields.
  hintColor: onSurfaceColorLight.withValues(alpha: 0.6),
  // Toggleable active color is managed by component themes like checkboxTheme, radioTheme, switchTheme.

  // TYPOGRAPHY & ICONOGRAPHY
  // Default text theme.
  textTheme: const TextTheme(),
  // Customize as needed
  // Text theme for primary color backgrounds.
  primaryTextTheme: const TextTheme(),
  // Customize as needed
  // Default icon theme.
  iconTheme: IconThemeData(color: onSurfaceColorLight),
  // Icon theme for primary color backgrounds.
  primaryIconTheme: IconThemeData(color: onPrimaryColorLight),

  // COMPONENT THEMES
  // Theme for app bars.
  appBarTheme: AppBarTheme(
    backgroundColor: surfaceColorLight,
    // Or primaryColorLight if preferred
    foregroundColor: onSurfaceColorLight,
    // Or onPrimaryColorLight if backgroundColor is primaryColorLight
    elevation: elevationHeight,
    surfaceTintColor:
        Colors.transparent, // M3 surface tint, often transparent or primary
  ),
  // Theme for bottom app bars.
  bottomAppBarTheme: BottomAppBarTheme(
    color: surfaceColorLight,
    elevation: elevationHeight,
  ),
  // Theme for bottom navigation bars.
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: surfaceColorLight,
    selectedItemColor: primaryColorLight,
    unselectedItemColor: onSurfaceColorLight.withValues(alpha: 0.60),
    elevation: elevationHeight,
    type: BottomNavigationBarType.fixed,
    showSelectedLabels: true,
    showUnselectedLabels: true,
  ),
  // Theme for bottom sheet widgets.
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: surfaceColorLight,
    elevation: elevationHeight,
    modalBackgroundColor: surfaceColorLight,
    modalElevation: elevationHeight,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
    ),
  ),
  // Theme for cards.
  cardTheme: CardTheme(
    elevation: elevationHeight,
    color: surfaceColorLight,
    surfaceTintColor: Colors.transparent, // M3 surface tint
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0), // Consistent border radius
    ),
  ),
  // Theme for checkboxes.
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return primaryColorLight;
      }
      return null; // Use default
    }),
    checkColor: WidgetStateProperty.all(onPrimaryColorLight),
    side: BorderSide(color: onSurfaceColorLight.withValues(alpha: 0.6)),
  ),
  // Theme for chips.
  chipTheme: ChipThemeData(
    backgroundColor: surfaceColorLight.withValues(alpha: 0.8),
    deleteIconColor: onSurfaceColorLight.withValues(alpha: 0.7),
    disabledColor: disabledColorLight,
    selectedColor: primaryColorLight.withValues(alpha: 0.2),
    secondarySelectedColor: secondaryColorLight.withValues(alpha: 0.2),
    labelStyle: TextStyle(color: onSurfaceColorLight),
    secondaryLabelStyle: TextStyle(color: onSecondaryColorLight),
    // This might need onSecondaryColorLight if chip uses secondary color as base
    padding: const EdgeInsets.all(8.0),
    // Adjusted padding
    shape: StadiumBorder(
      side: BorderSide(color: outlineColorLight.withValues(alpha: 0.5)),
    ),
  ),
  // Theme for data tables.
  dataTableTheme: const DataTableThemeData(),
  // Customize as needed
  // Theme for dialogs.
  dialogTheme: DialogTheme(
    backgroundColor: surfaceColorLight,
    elevation: elevationHeight + 10,
    // Dialogs often have higher elevation
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    titleTextStyle: TextStyle(
      color: onSurfaceColorLight,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    contentTextStyle: TextStyle(color: onSurfaceColorLight, fontSize: 16),
  ),
  // Theme for dividers.
  dividerTheme: DividerThemeData(
    color: onSurfaceColorLight.withValues(alpha: 0.12),
    space: 1.0,
    thickness: 1.0,
  ),
  // Theme for drawer widgets.
  drawerTheme: DrawerThemeData(
    backgroundColor: surfaceColorLight,
    elevation: elevationHeight + 5,
  ),
  // Theme for dropdown menus.
  dropdownMenuTheme: DropdownMenuThemeData(
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surfaceColorLight,
      hoverColor: primaryColorLight.withValues(alpha: 0.1),
    ),
  ),
  // Theme for elevated buttons.
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColorLight,
      foregroundColor: onPrimaryColorLight,
      elevation: elevationHeight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
  // Theme for expansion tiles.
  expansionTileTheme: ExpansionTileThemeData(
    iconColor: primaryColorLight,
    collapsedIconColor: onSurfaceColorLight.withValues(alpha: 0.7),
    textColor: primaryColorLight,
    collapsedTextColor: onSurfaceColorLight,
  ),
  // Theme for floating action buttons.
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: primaryColorLight,
    foregroundColor: onPrimaryColorLight,
    elevation: elevationHeight,
    highlightElevation: elevationHeight + 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ), // M3 often uses more rounded FABs
  ),
  // Theme for icon buttons.
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(foregroundColor: primaryColorLight),
  ),
  // Theme for input decorations (used by text fields).
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: onSurfaceColorLight.withValues(alpha: 0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: onSurfaceColorLight.withValues(alpha: 0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: primaryColorLight, width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: errorColorLight, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: errorColorLight, width: 2.0),
    ),
    filled: true,
    fillColor: surfaceColorLight.withValues(alpha: 0.5),
    hintStyle: TextStyle(color: onSurfaceColorLight.withValues(alpha: 0.5)),
    labelStyle: TextStyle(color: onSurfaceColorLight.withValues(alpha: 0.7)),
    prefixIconColor: onSurfaceColorLight.withValues(alpha: 0.7),
    suffixIconColor: onSurfaceColorLight.withValues(alpha: 0.7),
  ),
  // Theme for list tiles.
  listTileTheme: ListTileThemeData(
    iconColor: primaryColorLight,
    textColor: onSurfaceColorLight,
    selectedColor: primaryColorLight,
    selectedTileColor: primaryColorLight.withValues(alpha: 0.1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
  ),
  // Theme for menus.
  menuTheme: MenuThemeData(
    style: MenuStyle(
      backgroundColor: WidgetStateProperty.all(surfaceColorLight),
      elevation: WidgetStateProperty.all(elevationHeight + 2),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    ),
  ),
  // Theme for menu bars.
  menuBarTheme: MenuBarThemeData(
    style: MenuStyle(
      backgroundColor: WidgetStateProperty.all(surfaceColorLight),
      elevation: WidgetStateProperty.all(elevationHeight),
    ),
  ),
  // Theme for navigation bars (Material 3).
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: surfaceColorLight,
    elevation: elevationHeight,
    indicatorColor: primaryColorLight.withValues(alpha: 0.2),
    iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return IconThemeData(color: primaryColorLight);
      }
      return IconThemeData(color: onSurfaceColorLight.withValues(alpha: 0.7));
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return TextStyle(color: primaryColorLight, fontWeight: FontWeight.bold);
      }
      return TextStyle(color: onSurfaceColorLight.withValues(alpha: 0.7));
    }),
  ),
  // Theme for navigation drawers (Material 3).
  navigationDrawerTheme: NavigationDrawerThemeData(
    backgroundColor: surfaceColorLight,
    elevation: elevationHeight + 2,
    indicatorColor: primaryColorLight.withValues(alpha: 0.2),
  ),
  // Theme for navigation rails.
  navigationRailTheme: NavigationRailThemeData(
    backgroundColor: surfaceColorLight,
    elevation: elevationHeight,
    selectedIconTheme: IconThemeData(color: primaryColorLight),
    unselectedIconTheme: IconThemeData(
      color: onSurfaceColorLight.withValues(alpha: 0.7),
    ),
    selectedLabelTextStyle: TextStyle(
      color: primaryColorLight,
      fontWeight: FontWeight.bold,
    ),
    unselectedLabelTextStyle: TextStyle(
      color: onSurfaceColorLight.withValues(alpha: 0.7),
    ),
  ),
  // Theme for outlined buttons.
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: primaryColorLight,
      side: BorderSide(color: primaryColorLight.withValues(alpha: 0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
  // Theme for popup menus.
  popupMenuTheme: PopupMenuThemeData(
    color: surfaceColorLight,
    elevation: elevationHeight,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    textStyle: TextStyle(color: onSurfaceColorLight),
  ),
  // Theme for progress indicators.
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: primaryColorLight,
    linearTrackColor: primaryColorLight.withValues(alpha: 0.2),
    circularTrackColor: primaryColorLight.withValues(alpha: 0.2),
  ),
  // Theme for radio buttons.
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return primaryColorLight;
      }
      return onSurfaceColorLight.withValues(alpha: 0.6);
    }),
  ),
  // Theme for scrollbars.
  scrollbarTheme: ScrollbarThemeData(
    thumbColor: WidgetStateProperty.all(
      primaryColorLight.withValues(alpha: 0.7),
    ),
    trackColor: WidgetStateProperty.all(
      primaryColorLight.withValues(alpha: 0.1),
    ),
    thickness: WidgetStateProperty.all(8.0),
    radius: const Radius.circular(4.0),
    interactive: true,
  ),
  // Theme for segmented buttons (Material 3).
  segmentedButtonTheme: SegmentedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return primaryColorLight.withValues(alpha: 0.2);
        }
        return surfaceColorLight;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return primaryColorLight;
        }
        return onSurfaceColorLight;
      }),
      side: WidgetStateProperty.all(BorderSide(color: outlineColorLight)),
    ),
  ),
  // Theme for sliders.
  sliderTheme: SliderThemeData(
    activeTrackColor: primaryColorLight,
    inactiveTrackColor: primaryColorLight.withValues(alpha: 0.3),
    thumbColor: primaryColorLight,
    overlayColor: primaryColorLight.withValues(alpha: 0.2),
    valueIndicatorColor: primaryColorLight.withValues(alpha: 0.8),
    valueIndicatorTextStyle: TextStyle(color: onPrimaryColorLight),
  ),
  // Theme for snack bars.
  snackBarTheme: SnackBarThemeData(
    backgroundColor: snackBarBackgroundColorLight,
    contentTextStyle: TextStyle(color: onSnackBarBackgroundColorLight),
    actionTextColor: primaryColorLight,
    // For better visibility of action button
    elevation: elevationHeight,
    behavior: SnackBarBehavior.floating,
    // Modern look
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
  ),
  // Theme for switches.
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return primaryColorLight;
      }
      return null; // Use default (often greyish)
    }),
    trackColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return primaryColorLight.withValues(alpha: 0.5);
      }
      return null; // Use default
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.focused)) {
        return primaryColorLight.withValues(alpha: 0.5);
      }
      return Colors.transparent; // Default behavior
    }),
  ),
  // Theme for tab bars.
  tabBarTheme: TabBarTheme(
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(width: 2.0, color: primaryColorLight),
    ),
    indicatorColor: primaryColorLight,
    // Often redundant with indicator but good for explicitness
    labelColor: primaryColorLight,
    unselectedLabelColor: onSurfaceColorLight.withValues(alpha: 0.7),
    dividerColor: Colors.transparent, // M3 often has no divider
  ),
  // Theme for text buttons.
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: primaryColorLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
  // Theme for time pickers.
  timePickerTheme: TimePickerThemeData(
    backgroundColor: surfaceColorLight,
    hourMinuteShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    dayPeriodShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    dialHandColor: primaryColorLight,
    dialBackgroundColor: primaryColorLight.withValues(alpha: 0.1),
    entryModeIconColor: primaryColorLight,
  ),
  // Theme for tooltips.
  tooltipTheme: TooltipThemeData(
    preferBelow: false,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    margin: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: onSurfaceColorLight.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(4.0),
    ),
    textStyle: TextStyle(color: surfaceColorLight, fontSize: 12),
  ),

  // MISCELLANEOUS
  // The platform that the material widgets should adapt to.
  platform: TargetPlatform.android,
  // The visual density for UI components.
  visualDensity: VisualDensity.adaptivePlatformDensity,
  // Whether to use Material 3.
  useMaterial3: true,
  // Defines ink splash appearance (InkSparkle.splashFactory for M3 effects).
  splashFactory: InkSparkle.splashFactory,
  // Updated for M3
  // Defines the default Material tap target size.
  materialTapTargetSize: MaterialTapTargetSize.padded,
  // Default page transition for different TargetPlatform.
  pageTransitionsTheme: const PageTransitionsTheme(),
);

// Dark Theme Definition
final ThemeData darkTheme = ThemeData(
  // COLOR SCHEME
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: primaryColorDark,
    onPrimary: onPrimaryColorDark,
    primaryContainer: primaryContainerColorDark,
    onPrimaryContainer: onPrimaryContainerColorDark,
    secondary: secondaryColorDark,
    onSecondary: onSecondaryColorDark,
    secondaryContainer: secondaryContainerColorDark,
    onSecondaryContainer: onSecondaryContainerColorDark,
    tertiary: tertiaryColorDark,
    onTertiary: onTertiaryColorDark,
    tertiaryContainer: tertiaryContainerColorDark,
    onTertiaryContainer: onTertiaryContainerColorDark,
    error: errorColorDark,
    onError: onErrorColorDark,
    errorContainer: errorContainerColorDark,
    onErrorContainer: onErrorContainerColorDark,
    surface: surfaceColorDark,
    onSurface: onSurfaceColorDark,
    surfaceContainerHighest: surfaceVariantColorDark,
    onSurfaceVariant: onSurfaceVariantColorDark,
    outline: outlineColorDark,
    outlineVariant: outlineVariantColorDark,
    shadow: shadowColorDark,
    scrim: scrimColorDark,
    inverseSurface: inverseSurfaceColorDark,
    onInverseSurface: onInverseSurfaceColorDark,
    inversePrimary: inversePrimaryColorDark,
    surfaceTint: surfaceTintColorDark,
  ),
  // DEPRECATED COLORS (kept for reference or specific needs, prefer colorScheme)
  primaryColor: primaryColorDark,
  focusColor: focusColorDark,
  hoverColor: hoverColorDark,
  canvasColor: canvasColorDark,
  scaffoldBackgroundColor: backgroundColorDark,
  dividerColor: dividerColorDark,
  highlightColor: highlightColorDark,
  splashColor: splashColorDark,
  unselectedWidgetColor: unselectedWidgetColorDark,
  disabledColor: disabledColorDark,
  secondaryHeaderColor: secondaryHeaderColorDark,
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: primaryColorDark,
    selectionColor: primaryColorDark.withValues(alpha: 0.4),
    selectionHandleColor: primaryColorDark,
  ),
  indicatorColor: primaryColorDark,
  hintColor: onSurfaceColorDark.withValues(alpha: 0.6),

  // TYPOGRAPHY & ICONOGRAPHY
  textTheme: const TextTheme(),
  // Customize for dark theme if needed
  primaryTextTheme: const TextTheme(),
  // Customize for dark theme if needed
  iconTheme: IconThemeData(color: onSurfaceColorDark),
  primaryIconTheme: IconThemeData(color: onPrimaryColorDark),

  // COMPONENT THEMES (Dark counterparts of lightTheme)
  appBarTheme: AppBarTheme(
    backgroundColor: surfaceColorDark, // Or primaryColorDark
    foregroundColor: onSurfaceColorDark, // Or onPrimaryColorDark
    elevation: elevationHeight,
    surfaceTintColor: Colors.transparent, // Or primaryColorDark for M3 tint
  ),
  bottomAppBarTheme: BottomAppBarTheme(
    color: surfaceColorDark,
    elevation: elevationHeight,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: surfaceColorDark,
    selectedItemColor: primaryColorDark,
    unselectedItemColor: onSurfaceColorDark.withValues(alpha: 0.60),
    elevation: elevationHeight,
    type: BottomNavigationBarType.fixed,
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: surfaceColorDark,
    elevation: elevationHeight,
    modalBackgroundColor: surfaceColorDark,
    modalElevation: elevationHeight,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
    ),
  ),
  cardTheme: CardTheme(
    elevation: elevationHeight,
    color: surfaceColorDark,
    surfaceTintColor: Colors.transparent, // Or primaryColorDark for M3 tint
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return primaryColorDark;
      }
      return null;
    }),
    checkColor: WidgetStateProperty.all(onPrimaryColorDark),
    side: BorderSide(color: onSurfaceColorDark.withValues(alpha: 0.6)),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: surfaceColorDark.withValues(alpha: 0.8),
    deleteIconColor: onSurfaceColorDark.withValues(alpha: 0.7),
    disabledColor: disabledColorDark,
    selectedColor: primaryColorDark.withValues(alpha: 0.2),
    secondarySelectedColor: secondaryColorDark.withValues(alpha: 0.2),
    labelStyle: TextStyle(color: onSurfaceColorDark),
    secondaryLabelStyle: TextStyle(color: onSecondaryColorDark),
    padding: const EdgeInsets.all(8.0),
    shape: StadiumBorder(
      side: BorderSide(color: outlineColorDark.withValues(alpha: 0.5)),
    ),
  ),
  dataTableTheme: const DataTableThemeData(),
  // Customize for dark theme
  dialogTheme: DialogTheme(
    backgroundColor: surfaceColorDark,
    elevation: elevationHeight + 10,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    titleTextStyle: TextStyle(
      color: onSurfaceColorDark,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    contentTextStyle: TextStyle(color: onSurfaceColorDark, fontSize: 16),
  ),
  dividerTheme: DividerThemeData(
    color: onSurfaceColorDark.withValues(alpha: 0.12),
    space: 1.0,
    thickness: 1.0,
  ),
  drawerTheme: DrawerThemeData(
    backgroundColor: surfaceColorDark,
    elevation: elevationHeight + 5,
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surfaceColorDark,
      hoverColor: primaryColorDark.withValues(alpha: 0.1),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColorDark,
      foregroundColor: onPrimaryColorDark,
      elevation: elevationHeight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
  expansionTileTheme: ExpansionTileThemeData(
    iconColor: primaryColorDark,
    collapsedIconColor: onSurfaceColorDark.withValues(alpha: 0.7),
    textColor: primaryColorDark,
    collapsedTextColor: onSurfaceColorDark,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: primaryColorDark,
    foregroundColor: onPrimaryColorDark,
    elevation: elevationHeight,
    highlightElevation: elevationHeight + 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(foregroundColor: primaryColorDark),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: onSurfaceColorDark.withValues(alpha: 0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: onSurfaceColorDark.withValues(alpha: 0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: primaryColorDark, width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: errorColorDark, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: errorColorDark, width: 2.0),
    ),
    filled: true,
    fillColor: surfaceColorDark.withValues(alpha: 0.5),
    hintStyle: TextStyle(color: onSurfaceColorDark.withValues(alpha: 0.5)),
    labelStyle: TextStyle(color: onSurfaceColorDark.withValues(alpha: 0.7)),
    prefixIconColor: onSurfaceColorDark.withValues(alpha: 0.7),
    suffixIconColor: onSurfaceColorDark.withValues(alpha: 0.7),
  ),
  listTileTheme: ListTileThemeData(
    iconColor: primaryColorDark,
    textColor: onSurfaceColorDark,
    selectedColor: primaryColorDark,
    selectedTileColor: primaryColorDark.withValues(alpha: 0.1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
  ),
  menuTheme: MenuThemeData(
    style: MenuStyle(
      backgroundColor: WidgetStateProperty.all(surfaceColorDark),
      elevation: WidgetStateProperty.all(elevationHeight + 2),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    ),
  ),
  menuBarTheme: MenuBarThemeData(
    style: MenuStyle(
      backgroundColor: WidgetStateProperty.all(surfaceColorDark),
      elevation: WidgetStateProperty.all(elevationHeight),
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: surfaceColorDark,
    elevation: elevationHeight,
    indicatorColor: primaryColorDark.withValues(alpha: 0.2),
    iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return IconThemeData(color: primaryColorDark);
      }
      return IconThemeData(color: onSurfaceColorDark.withValues(alpha: 0.7));
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return TextStyle(color: primaryColorDark, fontWeight: FontWeight.bold);
      }
      return TextStyle(color: onSurfaceColorDark.withValues(alpha: 0.7));
    }),
  ),
  navigationDrawerTheme: NavigationDrawerThemeData(
    backgroundColor: surfaceColorDark,
    elevation: elevationHeight + 2,
    indicatorColor: primaryColorDark.withValues(alpha: 0.2),
  ),
  navigationRailTheme: NavigationRailThemeData(
    backgroundColor: surfaceColorDark,
    elevation: elevationHeight,
    selectedIconTheme: IconThemeData(color: primaryColorDark),
    unselectedIconTheme: IconThemeData(
      color: onSurfaceColorDark.withValues(alpha: 0.7),
    ),
    selectedLabelTextStyle: TextStyle(
      color: primaryColorDark,
      fontWeight: FontWeight.bold,
    ),
    unselectedLabelTextStyle: TextStyle(
      color: onSurfaceColorDark.withValues(alpha: 0.7),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: primaryColorDark,
      side: BorderSide(color: primaryColorDark.withValues(alpha: 0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: surfaceColorDark,
    elevation: elevationHeight,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    textStyle: TextStyle(color: onSurfaceColorDark),
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: primaryColorDark,
    linearTrackColor: primaryColorDark.withValues(alpha: 0.2),
    circularTrackColor: primaryColorDark.withValues(alpha: 0.2),
  ),
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return primaryColorDark;
      }
      return onSurfaceColorDark.withValues(alpha: 0.6);
    }),
  ),
  scrollbarTheme: ScrollbarThemeData(
    thumbColor: WidgetStateProperty.all(
      primaryColorDark.withValues(alpha: 0.7),
    ),
    trackColor: WidgetStateProperty.all(
      primaryColorDark.withValues(alpha: 0.1),
    ),
    thickness: WidgetStateProperty.all(8.0),
    radius: const Radius.circular(4.0),
    interactive: true,
  ),
  segmentedButtonTheme: SegmentedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return primaryColorDark.withValues(alpha: 0.2);
        }
        return surfaceColorDark;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return primaryColorDark;
        }
        return onSurfaceColorDark;
      }),
      side: WidgetStateProperty.all(BorderSide(color: outlineColorDark)),
    ),
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: primaryColorDark,
    inactiveTrackColor: primaryColorDark.withValues(alpha: 0.3),
    thumbColor: primaryColorDark,
    overlayColor: primaryColorDark.withValues(alpha: 0.2),
    valueIndicatorColor: primaryColorDark.withValues(alpha: 0.8),
    valueIndicatorTextStyle: TextStyle(color: onPrimaryColorDark),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: snackBarBackgroundColorDark,
    contentTextStyle: TextStyle(color: onSnackBarBackgroundColorDark),
    actionTextColor: primaryColorDark,
    elevation: elevationHeight,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return primaryColorDark;
      }
      return null;
    }),
    trackColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return primaryColorDark.withValues(alpha: 0.5);
      }
      return null;
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.focused)) {
        return primaryColorDark.withValues(alpha: 0.5);
      }
      return Colors.transparent;
    }),
  ),
  tabBarTheme: TabBarTheme(
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(width: 2.0, color: primaryColorDark),
    ),
    indicatorColor: primaryColorDark,
    labelColor: primaryColorDark,
    unselectedLabelColor: onSurfaceColorDark.withValues(alpha: 0.7),
    dividerColor: Colors.transparent,
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: primaryColorDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: surfaceColorDark,
    hourMinuteShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    dayPeriodShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    dialHandColor: primaryColorDark,
    dialBackgroundColor: primaryColorDark.withValues(alpha: 0.1),
    entryModeIconColor: primaryColorDark,
  ),
  tooltipTheme: TooltipThemeData(
    preferBelow: false,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    margin: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: onSurfaceColorDark.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(4.0),
    ),
    textStyle: TextStyle(color: surfaceColorDark, fontSize: 12),
  ),

  // MISCELLANEOUS
  platform: TargetPlatform.android,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  useMaterial3: true,
  splashFactory: InkSparkle.splashFactory,
  materialTapTargetSize: MaterialTapTargetSize.padded,
  pageTransitionsTheme: const PageTransitionsTheme(),
);
