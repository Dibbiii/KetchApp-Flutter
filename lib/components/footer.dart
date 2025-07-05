import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).matchedLocation;
    int newIndex = 0;
    if (location.startsWith('/home')) {
      newIndex = 0;
    } else if (location.startsWith('/statistics')) {
      newIndex = 1;
    }
    else if (location.startsWith('/ranking')) {
      newIndex = 2;
    }
    else if (location.startsWith('/profile')) {
      newIndex = 3;
      if (newIndex != _selectedIndex) {
        setState(() { _selectedIndex = newIndex; });
      }
    }
  }

  void _onItemTapped(int index) {
    final routes = ['/home', '/statistics', '/ranking', '/profile'];
    final currentLocation = GoRouterState.of(context).matchedLocation;
    if (index != _selectedIndex) setState(() { _selectedIndex = index; });
    if (index >= 0 && index < routes.length && !currentLocation.startsWith(routes[index])) {
      context.go(routes[index]);
    }
  }

  Widget _buildIcon(IconData iconData, bool isSelected, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? colors.primary.withValues(alpha:0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(iconData, color: isSelected ? colors.primary : colors.onSurface),
    );
  }

  Widget _buildActiveIcon(IconData iconData, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(iconData, color: colors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bottomNavBarTheme = Theme.of(context).bottomNavigationBarTheme;
    const homeOutlined = Icons.home_outlined;
    const homeFilled = Icons.home;
    const statsOutlined = Icons.bar_chart_outlined;
    const statsFilled = Icons.bar_chart;
    const trophyOutlined = Icons.emoji_events_outlined;
    const trophyFilled = Icons.emoji_events;
    const profileOutlined = Icons.person_outline;
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: _buildIcon(homeOutlined, _selectedIndex == 0, colors),
          activeIcon: _buildActiveIcon(homeFilled, colors),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon(statsOutlined, _selectedIndex == 1, colors),
          activeIcon: _buildActiveIcon(statsFilled, colors),
          label: 'Statistics',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon(trophyOutlined, _selectedIndex == 2, colors),
          activeIcon: _buildActiveIcon(trophyFilled, colors),
          label: 'Ranking',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon(profileOutlined, _selectedIndex == 3, colors),
          activeIcon: _buildActiveIcon(profileOutlined, colors),
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
      unselectedLabelStyle: TextStyle(fontSize: 11, color: colors.onSurface.withValues(alpha:0.7)),
    );
  }
}