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
  // Index mapping: 0: Home, 1: Profile, 2: Explore, 3: Logout
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String location = GoRouterState.of(context).matchedLocation;
    int newIndex = 0;
    if (location.startsWith('/home')) {
      newIndex = 0;
    } else if (location.startsWith('/profile')) {
      newIndex = 1;
    } else if (location.startsWith('/explore')) { // Assuming '/explore' route
      newIndex = 2;
    }
    if (newIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = newIndex;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 0 || index == 1 || index == 2) {
      final String currentLocation = GoRouterState
          .of(context)
          .matchedLocation;
      bool shouldNavigate = true;
      if (index == 0 && currentLocation.startsWith('/home'))
        shouldNavigate = false;
      if (index == 1 && currentLocation.startsWith('/profile'))
        shouldNavigate = false;
      if (index == 2 && currentLocation.startsWith('/explore'))
        shouldNavigate = false; // Assuming '/explore' route

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
            context.go('/profile');
            break;
          case 2:
          // TODO: Implement navigation for Explore if it has a route
          // context.go('/explore');
            print("Explore navigation triggered (if route exists)");
            break;
        }
      }
    } else if (index == 3) { // Logout Action
      context.read<AuthBloc>().add(AuthLogoutRequested());
    } else if (index == 2 && !GoRouterState
        .of(context)
        .matchedLocation
        .startsWith('/explore')) {
      print("Explore action tapped!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Explore tapped!'), duration: Duration(seconds: 1)),
      );
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
          _buildNavItem(
            context: context,
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
            index: 1,
            isSelected: _selectedIndex == 1,
            onTap: () => _onItemTapped(1),
          ),
          // Increased Spacer width to better accommodate larger notch margin
          const SizedBox(width: 70),
          _buildNavItem(
            context: context,
            icon: Icons.explore_outlined,
            activeIcon: Icons.explore,
            label: 'Explore',
            index: 2,
            isSelected: _selectedIndex == 2,
            onTap: () => _onItemTapped(2),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.logout,
            label: 'Logout',
            index: 3,
            isSelected: false,
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