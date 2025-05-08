import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import BlocProvider
import 'package:go_router/go_router.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart'; // Import AuthBloc and AuthLogoutRequested
import 'package:ketchapp_flutter/app/themes/app_colors.dart'; // Import app_colors
import 'dart:ui'; // For ImageFilter

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
    } else if (location.startsWith('/ranking')) { //
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
      final String currentLocation = GoRouterState
          .of(context)
          .matchedLocation;
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
          // TODO: Implement navigation for Trophy if it has a route
          // context.go('/trophy');
            print("Trophy navigation triggered (if route exists)");
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

    // Use BottomAppBar for integration with centerDocked FAB
    return BottomAppBar(
      // Revert background to kTomatoRed
      color: kTomatoRed,
      elevation: 8.0,
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
          _buildNavItem(
            context: context,
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
            index: 0,
            isSelected: _selectedIndex == 0,
            onTap: () => _onItemTapped(0),
          ),
          const Spacer(),
          _buildNavItem(
            context: context,
            icon: Icons.insert_chart_outlined,
            activeIcon: Icons.insert_chart,
            label: 'Statistics',
            index: 1,
            isSelected: _selectedIndex == 1,
            onTap: () => _onItemTapped(1),
          ),
          const Spacer(),
          _buildNavItem(
            context: context,
            icon: Icons.emoji_events_outlined,
            activeIcon: Icons.emoji_events,
            label: 'Ranking',
            index: 2,
            isSelected: _selectedIndex == 2,
            onTap: () => _onItemTapped(2),
          ),
          const Spacer(),
          _buildNavItem(
            context: context,
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
            index: 3,
            isSelected: _selectedIndex == 3,
            onTap: () => _onItemTapped(3),
          ),
        ],
      ),
    );
  }

  // Helper method to build standard navigation items
  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    IconData? activeIcon,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final ColorScheme colors = Theme
        .of(context)
        .colorScheme;
    final TextTheme textTheme = Theme
        .of(context)
        .textTheme;
    // Colors for dark background (kTomatoRed)
    final Color selectedColor = colors.onPrimary; // White
    final Color unselectedColor = colors.onPrimary.withOpacity(
        0.7); // Slightly faded white
    final Color itemColor = isSelected ? selectedColor : unselectedColor;
    final Color iconColor = isSelected ? selectedColor : unselectedColor;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        // Use default highlight/splash effect
        // customBorder: const CircleBorder(), // Optional: circular tap area
        child: AnimatedContainer( // Add subtle animation for selection change
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
          // Add a subtle background highlight for the selected item
          decoration: BoxDecoration(
            color: isSelected ? colors.onPrimary.withOpacity(0.15) : Colors
                .transparent,
            borderRadius: BorderRadius.circular(12), // Rounded highlight
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? (activeIcon ?? icon) : icon,
                color: iconColor,
                size: 24,
              ),
              const SizedBox(height: 4), // Slightly more space
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: itemColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 10,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}