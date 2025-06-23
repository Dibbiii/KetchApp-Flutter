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
      final List<String> routes = [
        '/home',
        '/statistics',
        '/ranking',
        '/profile'
      ];
      final String currentLocation = GoRouterState.of(context).matchedLocation;

      bool shouldNavigate = true;
      if (index >= 0 && index < routes.length) {
        if (currentLocation.startsWith(routes[index])) {
          shouldNavigate = false;
        }
      }

      if (index != _selectedIndex) {
        setState(() {
          _selectedIndex = index;
        });
      }

      if (shouldNavigate) {
        if (index >= 0 && index < routes.length) {
          context.go(routes[index]);
        }
      }
    }
  }

  Widget _buildIcon(IconData iconData, bool isSelected, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isSelected ? colors.primary.withOpacity(0.1) : Colors
            .transparent,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Icon(
        iconData,
        color: isSelected ? colors.primary : colors.onSurface,
      ),
    );
  }

  Widget _buildActiveIcon(IconData iconData, bool isSelected,
      ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Icon(iconData, color: colors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final BottomNavigationBarThemeData bottomNavBarTheme = Theme
        .of(context)
        .bottomNavigationBarTheme;

    const IconData homeOutlined = Icons.home_outlined;
    const IconData homeFilled = Icons.home;
    const IconData statsOutlined = Icons.bar_chart_outlined;
    const IconData statsFilled = Icons.bar_chart;
    const IconData trophyOutlined = Icons.emoji_events_outlined;
    const IconData trophyFilled = Icons.emoji_events;
    const IconData profileOutlined = Icons.person_outline;
    const IconData profileFilled = Icons.person;

    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: _buildIcon(homeOutlined, _selectedIndex == 0, colors),
          activeIcon: _buildActiveIcon(homeFilled, _selectedIndex == 0, colors),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon(statsOutlined, _selectedIndex == 1, colors),
          activeIcon:
          _buildActiveIcon(statsFilled, _selectedIndex == 1, colors),
          label: 'Statistics',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon(trophyOutlined, _selectedIndex == 2, colors),
          activeIcon:
          _buildActiveIcon(trophyFilled, _selectedIndex == 2, colors),
          label: 'Ranking', // Label was Trophy, changed to Ranking to match route
        ),
        BottomNavigationBarItem(
            icon: _buildIcon(profileOutlined, _selectedIndex == 3, colors),
            activeIcon:
            _buildActiveIcon(profileOutlined, _selectedIndex == 3, colors),
          label: 'Profile',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: colors.primary,
      unselectedItemColor: colors.onSurface,
      onTap: _onItemTapped,
      showUnselectedLabels: true,
      showSelectedLabels: true,
      backgroundColor: bottomNavBarTheme.backgroundColor,
      elevation: 4.0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 11, color: colors.primary),
      unselectedLabelStyle: TextStyle(
          fontSize: 11, color: colors.onSurface.withOpacity(0.7)),

    );
  }
}