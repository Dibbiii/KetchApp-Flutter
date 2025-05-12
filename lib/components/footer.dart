import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  // Index mapping: 0: Home, 1: Statistics, 2: Trophy, 3: Profile
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String location = GoRouterState.of(context).matchedLocation;
    int newIndex = 0;
    if (location.startsWith('/home')) {
      newIndex = 0;
    } else if (location.startsWith('/statistics')) {
      newIndex = 1;
    } else if (location.startsWith('/ranking')) {
      //
      newIndex = 2;
    } else if (location.startsWith('/profile')) {
      newIndex = 3;
    }
    if (newIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = newIndex;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 0 || index == 1 || index == 2 || index == 3) {
      final String currentLocation = GoRouterState.of(context).matchedLocation;
      bool shouldNavigate = true;
      if (index == 0 && currentLocation.startsWith('/home'))
        shouldNavigate = false;
      if (index == 1 && currentLocation.startsWith('/statistics'))
        shouldNavigate = false;
      if (index == 2 && currentLocation.startsWith('/ranking'))
        shouldNavigate = false; // Assuming '/trophy' route
      if (index == 3 && currentLocation.startsWith('/profile'))
        shouldNavigate = false;

      if (index != _selectedIndex) {
        setState(() {
          _selectedIndex = index;
        });
      }

      if (shouldNavigate) {
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/statistics');
            break;
          case 2:
            context.go('/ranking');
            break;
          case 3:
            context.go('/profile');
            break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme texts = Theme.of(context).textTheme;

    // Use BottomAppBar for integration with centerDocked FAB
    return BottomAppBar(
      // Change background to a light gray
      color: const Color(0xFFF0F3F8), // Custom light gray (#F0F3F8)
      elevation: 4.0,
      // Add back some elevation for depth
      shape: const CircularNotchedRectangle(),
      // Use CircularNotchedRectangle for notch
      notchMargin: 10.0,
      // Increase notch margin slightly
      // Add vertical padding inside the bar
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Home Item
          _buildNavItem(
            outlinedIconData: Icons.home_outlined,
            filledIconData: Icons.home,
            label: "Home",
            index: 0,
            selectedIndex: _selectedIndex,
            colors: colors,
            texts: texts,
          ),
          // Statistics Item
          _buildNavItem(
            outlinedIconData:
                Icons.bar_chart_outlined, // Or Icons.insert_chart_outlined
            filledIconData: Icons.bar_chart, // Or Icons.insert_chart
            label: "Statistics",
            index: 1,
            selectedIndex: _selectedIndex,
            colors: colors,
            texts: texts,
          ),
          // Ranking Item
          _buildNavItem(
            outlinedIconData: Icons.leaderboard_outlined,
            filledIconData: Icons.leaderboard,
            label: "Ranking",
            index: 2,
            selectedIndex: _selectedIndex,
            colors: colors,
            texts: texts,
          ),
          // Profile Item
          _buildNavItem(
            outlinedIconData: Icons.person_outline,
            filledIconData: Icons.person,
            label: "Profile",
            index: 3,
            selectedIndex: _selectedIndex,
            colors: colors,
            texts: texts,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData outlinedIconData,
    required IconData filledIconData,
    required String label,
    required int index,
    required int selectedIndex,
    required ColorScheme colors,
    required TextTheme texts,
  }) {
    final bool isSelected = selectedIndex == index;

    // Define colors based on the new style
    final Color pillBackgroundColor =
        isSelected ? colors.primary.withOpacity(0.1) : Colors.transparent;
    final Color contentColor = // Combined icon and text color
        isSelected ? colors.primary : colors.onSurface;

    // Adjusted hover and splash to better match the new theme
    final Color hoverColor =
        isSelected
            ? colors.primary.withOpacity(0.3)
            : colors.onSurface.withOpacity(0.05);
    final Color splashColor =
        isSelected
            ? colors.primary.withOpacity(0.2)
            : colors.onSurface.withOpacity(0.1);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _onItemTapped(index),
              borderRadius: BorderRadius.circular(20.0),
              hoverColor: hoverColor,
              splashColor: splashColor,
              highlightColor: splashColor.withOpacity(
                0.5,
              ), // Can be same as splash or slightly different
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 2.0, // As per your selection
                ),
                decoration: BoxDecoration(
                  color: pillBackgroundColor,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Icon(
                  isSelected
                      ? filledIconData
                      : outlinedIconData, // Conditional icon
                  color: contentColor, // Use combined contentColor
                  size: 24.0,
                ),
              ),
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            label,
            style: texts.labelSmall?.copyWith(
              color: contentColor,
              fontSize: 10,
            ), // Use combined contentColor
          ),
        ],
      ),
    );
  }
}
