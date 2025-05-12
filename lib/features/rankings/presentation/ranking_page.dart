import 'dart:async'; // Import for Timer
import 'dart:math'; // Import for pi for confetti
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart'; // Import for confetti

// Define a class to hold user data including rank and hours
class UserRankData {
  final String name;
  final int rank;
  final int hours;

  UserRankData({required this.name, required this.rank, required this.hours});
}

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> with SingleTickerProviderStateMixin {
  // Define separate lists for friends and global users using UserRankData
  final List<UserRankData> _allFriendsUsers = List.generate(10, (index) {
    final name = 'Friend ${9 - index}';
    final rank = index + 1;
    final hours = (10 - index) * 2; // Example hours logic
    return UserRankData(name: name, rank: rank, hours: hours);
  });

  final List<UserRankData> _allGlobalUsers = List.generate(50, (index) {
    final name = 'Global User ${49 - index}';
    final rank = index + 1;
    final hours = (50 - index) * 2; // Example hours logic
    return UserRankData(name: name, rank: rank, hours: hours);
  });
  
  List<UserRankData> _activeList = []; // This will point to either _allFriendsUsers or _allGlobalUsers
  List<UserRankData> _filteredUsers = [];
  late TabController _tabController;
  String _currentSearchQuery = ''; // To store the current search query
  Timer? _debounce; // Timer for debouncing search input
  VoidCallback? _tabListener; // To store the tab listener for proper removal
  late ConfettiController _confettiController; // Controller for confetti animation

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 2)); // Initialize confetti controller
    
    _tabListener = () {
      // Ensure listener is called only when tab index has finished changing
      if (!_tabController.indexIsChanging) {
        if (mounted) { // Check if widget is still in the tree
          _setActiveListAndFilter();
        }
      }
    };
    _tabController.addListener(_tabListener!);
    
    // Set initial list based on tab 0 and perform initial filtering
    _setActiveListAndFilter(); 
  }

  void _setActiveListAndFilter() {
    if (_tabController.index == 0) {
      _activeList = _allFriendsUsers;
    } else {
      _activeList = _allGlobalUsers;
    }
    // Cancel any pending debounce from typing in the previous tab
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    // Filter immediately with the current search query for the new active list
    _performFiltering();

    // Play confetti if there's a top-ranked user
    if (_filteredUsers.isNotEmpty && _filteredUsers.first.rank == 1) {
      if (_confettiController.state != ConfettiControllerState.playing) { // Play only if not already playing
         _confettiController.play();
      }
    } else {
      _confettiController.stop();
    }
  }

  @override
  void dispose() {
    if (_tabListener != null) {
      _tabController.removeListener(_tabListener!);
    }
    _debounce?.cancel(); // Cancel the timer if it's active
    _tabController.dispose();
    _confettiController.dispose(); // Dispose confetti controller
    super.dispose();
  }

  // Called when text changes in TextField
  void _filterUsers(String query) {
    _currentSearchQuery = query;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) { // Check mounted before performing filter logic
        _performFiltering();
      }
    });
  }

  // Performs the actual filtering logic
  void _performFiltering() {
    final listToFilter = _activeList;

    final filtered = listToFilter.where((userData) {
      return userData.name.toLowerCase().contains(_currentSearchQuery.toLowerCase());
    }).toList();

    if (mounted) { // Check mounted before calling setState
      setState(() {
        _filteredUsers = filtered;
      });
    }
    // After filtering, check again if confetti should play for the new filtered list
    // This ensures confetti plays/stops correctly after search
    if (_filteredUsers.isNotEmpty && _filteredUsers.first.rank == 1 && _currentSearchQuery.isEmpty) { // Only play if no search query or top user is still #1
        if (_confettiController.state != ConfettiControllerState.playing && _tabController.indexIsChanging == false) {
             // Check if tab is not changing to avoid playing during swipe
            _confettiController.play();
        }
    } else {
        _confettiController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Friends'),
            Tab(text: 'Global'),
          ],
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          indicatorColor: Theme.of(context).colorScheme.primary, // Reverted to simple indicator color
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceVariant, // Use theme color
            ),
            onChanged: _filterUsers,
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRankingList(),
              _buildRankingList(),
            ],
          ),
        ),
      ],
    );
  }

  // Helper widget to build the list view, to avoid duplication in TabBarView
  Widget _buildRankingList() {
    if (_filteredUsers.isEmpty && _currentSearchQuery.isNotEmpty) {
      return Center(child: Text('No users found for "$_currentSearchQuery"'));
    }
    if (_filteredUsers.isEmpty && _currentSearchQuery.isEmpty) {
      if (_activeList.isEmpty) {
        return const Center(child: Text('There are no users in this category.'));
      }
      return const Center(child: Text('No users in this list.'));
    }

    final UserRankData topUser = _filteredUsers.first;
    final List<UserRankData> restOfUsers = _filteredUsers.length > 1 ? _filteredUsers.sublist(1) : [];
    
    // Conditionally play confetti here if not handled by _setActiveListAndFilter or _performFiltering
    // This ensures it plays when the list is built with a rank 1 user.
    // However, the logic in _setActiveListAndFilter and _performFiltering should be preferred.

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Column(
          children: <Widget>[
            // Top User Section (only if rank is 1)
            if (topUser.rank == 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: Column(
                  children: <Widget>[
                    Icon(Icons.emoji_events, size: 50, color: Colors.amber[600]),
                    const SizedBox(height: 8),
                    Text(
                      topUser.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Rank: ${topUser.rank}',
                      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
                    ),
                    Text(
                      '${topUser.hours} hrs',
                      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
            if (topUser.rank == 1) const Divider(height: 1),

            // Rest of the list
            Expanded(
              child: ListView.builder(
                itemCount: topUser.rank == 1 ? restOfUsers.length : _filteredUsers.length,
                itemBuilder: (context, index) {
                  final userData = topUser.rank == 1 ? restOfUsers[index] : _filteredUsers[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 8.0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        // color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5), // Optional: item background
                      ),
                      child: ListTile(
                        leading: Text(
                          '${userData.rank}', // Use pre-calculated rank
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        title: Text(userData.name), // Use name from userData
                        trailing: Text('${userData.hours} hrs'), // Use pre-calculated hours
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        // Confetti Widget - aligned to top center
        if (topUser.rank == 1) // Only show confetti if top user is rank 1
         Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2, // Downwards
            maxBlastForce: 5, // Default is 20, Set a lower force
            minBlastForce: 2, // Default is 5
            emissionFrequency: 0.03, // How often it emits
            numberOfParticles: 10, // Number of particles
            gravity: 0.1, // How fast they fall
            shouldLoop: false,
            colors: const [
              Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple
            ],
            // createParticlePath: drawStar, // Optional: custom particle shape
          ),
        ),
      ],
    );
  }
}

// Optional: Helper function to draw a star path for confetti particles (example from package)
// Path drawStar(Size size) {
//   // Method to convert degree to radians
//   double degToRad(double deg) => deg * (pi / 180.0);

//   const numberOfPoints = 5;
//   final halfWidth = size.width / 2;
//   final externalRadius = halfWidth;
//   final internalRadius = halfWidth / 2.5;
//   final degreesPerPoint = 360 / numberOfPoints;
//   final halfDegreesPerPoint = degreesPerPoint / 2;
//   final path = Path();
//   final fullAngle = degToRad(360);
//   path.moveTo(size.width, halfWidth);

//   for (double step = 0; step < fullAngle; step += fullAngle / numberOfPoints) {
//     path.lineTo(halfWidth + externalRadius * cos(step),
//         halfWidth + externalRadius * sin(step));
//     path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerPoint),
//         halfWidth + internalRadius * sin(step + halfDegreesPerPoint));
//   }
//   path.close();
//   return path;
// }
