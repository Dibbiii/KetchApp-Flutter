import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import BlocProvider
import 'package:go_router/go_router.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart'; // Import AuthBloc and AuthLogoutRequested

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  int _selectedIndex = 0; // Initialize with a default value if needed

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update selectedIndex based on the current route
    final String location = GoRouterState.of(context).matchedLocation;
    setState(() {
      if (location == '/home') {
        _selectedIndex = 0;
      } else if (location.startsWith('/plan')) {
        // Example for search/plan
        _selectedIndex = 1;
      } else if (location == '/profile') {
        _selectedIndex = 2;
      } else {
        // Handle other cases or set a default index if no match
        // _selectedIndex = 0; // Or another appropriate default
      }
      // Note: Logout button doesn't have a persistent selected state
    });
  }

  void _onItemTapped(int index) {
    // Don't update _selectedIndex visually for the logout button
    if (index != 3) {
      setState(() {
        _selectedIndex = index;
      });
    }

    switch (index) {
      case 0:
        context.go('/home'); // Navigate to home
        break;
      case 1:
        // Decide where the 'search' button should go, e.g., a dedicated search page or plan
        context.push('/plan/automatic'); // Example: Go to plan creation
        break;
      case 2:
        context.go('/profile'); // Navigate to profile
        break;
      case 3: // Logout action
        // Access AuthBloc and dispatch the logout event
        context.read<AuthBloc>().add(AuthLogoutRequested());
        // GoRouter's redirect logic will handle navigation after logout
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      // Use fixed type if you have more than 3 items
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        // /home
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Plan',
        ),
        // Changed icon/label
        // /plan/...
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        // /profile
        BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        // Logout button
        // Action, no specific route
      ],
      // Optional: Customize colors for selected/unselected items if needed
      // selectedItemColor: colors.primary,
      // unselectedItemColor: colors.onSurface.withOpacity(0.6),
    );
  }
}
