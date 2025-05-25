import 'dart:async'; // Import for Timer

import 'package:confetti/confetti.dart'; // Import for confetti
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ketchapp_flutter/features/rankings/bloc/ranking_bloc.dart';
import 'package:ketchapp_flutter/features/rankings/bloc/ranking_event.dart';
import 'package:ketchapp_flutter/features/rankings/bloc/ranking_state.dart';
import 'package:ketchapp_flutter/features/rankings/presentation/ranking_shrimmer_page.dart';

// Define a class to hold user data including rank and hours
class UserRankData {
  final String name;
  final int rank;
  final int hours;

  UserRankData({required this.name, required this.rank, required this.hours});

  static List<UserRankData> mockList() {
    // Puoi personalizzare questa lista per test
    return List.generate(50, (index) {
      final name = 'User ${index + 1}';
      final rank = index + 1;
      final hours = 120 - index * 2;
      return UserRankData(name: name, rank: rank, hours: hours);
    });
  }
}

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage>
    with SingleTickerProviderStateMixin {
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

  List<UserRankData> _activeList =
      []; // This will point to either _allFriendsUsers or _allGlobalUsers
  List<UserRankData> _filteredUsers = [];
  late TabController _tabController;
  String _currentSearchQuery = ''; // To store the current search query
  Timer? _debounce; // Timer for debouncing search input
  VoidCallback? _tabListener; // To store the tab listener for proper removal
  late ConfettiController
  _confettiController; // Controller for confetti animation

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    ); // Initialize confetti controller

    _tabListener = () {
      // Ensure listener is called only when tab index has finished changing
      if (!_tabController.indexIsChanging) {
        if (mounted) {
          // Check if widget is still in the tree
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
    _performFiltering();
    // Play confetti if there's a top-ranked user
    if (_filteredUsers.isNotEmpty &&
        _filteredUsers.first.rank == 1 &&
        _currentSearchQuery.isEmpty) {
      if (_confettiController.state != ConfettiControllerState.playing) {
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
    _performFiltering();
    // Play confetti if there's a top-ranked user
    if (_filteredUsers.isNotEmpty &&
        _filteredUsers.first.rank == 1 &&
        _currentSearchQuery.isEmpty) {
      if (_confettiController.state != ConfettiControllerState.playing) {
        _confettiController.play();
      }
    } else {
      _confettiController.stop();
    }
  }

  // Performs the actual filtering logic
  void _performFiltering() {
    final listToFilter = _activeList;

    final filtered =
        listToFilter.where((userData) {
          return userData.name.toLowerCase().contains(
            _currentSearchQuery.toLowerCase(),
          );
        }).toList();

    if (mounted) {
      // Check mounted before calling setState
      setState(() {
        _filteredUsers = filtered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RankingBloc()..add(LoadRanking()),
      child: BlocBuilder<RankingBloc, RankingState>(
        builder: (context, state) {
          return SafeArea(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (state is RankingLoading)
                  const RankingShrimmerPage(showSearchBar: true)
                else ...[
                  Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        tabs: const [Tab(text: 'Friends'), Tab(text: 'Global')],
                        labelColor: Theme.of(context).colorScheme.primary,
                        unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        indicatorColor: Theme.of(context).colorScheme.primary,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 20.0,
                        ),
                        child: Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(16.0),
                          color: Theme.of(context).colorScheme.surface,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Cerca utente...',
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 0,
                                    ),
                                  ),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  onChanged: _filterUsers,
                                ),
                              ),
                              DropdownButton<RankingFilter>(
                                value: state is RankingLoaded ? state.filter : RankingFilter.hours,
                                underline: SizedBox.shrink(),
                                icon: Icon(
                                  Icons.filter_list,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: RankingFilter.advancements,
                                    child: Text('Advancements'),
                                  ),
                                  DropdownMenuItem(
                                    value: RankingFilter.hours,
                                    child: Text('Hours'),
                                  ),
                                  DropdownMenuItem(
                                    value: RankingFilter.streak,
                                    child: Text('Streak'),
                                  ),
                                ],
                                onChanged: (filter) {
                                  if (filter != null) {
                                    context.read<RankingBloc>().add(
                                      ChangeRankingFilter(filter),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            context.read<RankingBloc>().add(
                              RefreshRanking(),
                            );
                          },
                          child: _buildRankingListBloc(state),
                        ),
                      ),
                    ],
                  ),
                ],
                if (_filteredUsers.isNotEmpty &&
                    _filteredUsers.first.rank == 1 &&
                    _currentSearchQuery.isEmpty) ...[
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirection: 3.14 / 2,
                      maxBlastForce: 10,
                      // increased
                      minBlastForce: 5,
                      // increased
                      emissionFrequency: 0.12,
                      // more frequent
                      numberOfParticles: 30,
                      // more particles
                      gravity: 0.08,
                      // slightly slower fall
                      shouldLoop: false,
                      colors: const [
                        Colors.green,
                        Colors.blue,
                        Colors.pink,
                        Colors.orange,
                        Colors.purple,
                        Colors.amber,
                        Colors.red,
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirection: 0,
                      // right
                      maxBlastForce: 8,
                      minBlastForce: 4,
                      emissionFrequency: 0.08,
                      numberOfParticles: 15,
                      gravity: 0.09,
                      shouldLoop: false,
                      colors: const [
                        Colors.green,
                        Colors.blue,
                        Colors.pink,
                        Colors.orange,
                        Colors.purple,
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirection: 3.14,
                      // left
                      maxBlastForce: 8,
                      minBlastForce: 4,
                      emissionFrequency: 0.08,
                      numberOfParticles: 15,
                      gravity: 0.09,
                      shouldLoop: false,
                      colors: const [
                        Colors.green,
                        Colors.blue,
                        Colors.pink,
                        Colors.orange,
                        Colors.purple,
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRankingListBloc(RankingState state) {
    // Use _filteredUsers for display
    final users = _filteredUsers;
    final filter = state is RankingLoaded ? state.filter : RankingFilter.hours;
    // Ordina in base al filtro
    List<UserRankData> sortedUsers = List.from(users);
    if (filter == RankingFilter.hours) {
      sortedUsers.sort((a, b) => b.hours.compareTo(a.hours));
    } else if (filter == RankingFilter.streak) {
      // Qui puoi aggiungere la logica per streak se hai il dato
    } else if (filter == RankingFilter.advancements) {
      // Qui puoi aggiungere la logica per advancements se hai il dato
    }
    // Soglie di ore per ogni rank
    const int crystalThreshold = 100;
    const int goldThreshold = 70;
    const int ironThreshold = 40;
    const int bronzeThreshold = 15;
    List<UserRankData> crystal = [];
    List<UserRankData> gold = [];
    List<UserRankData> iron = [];
    List<UserRankData> bronze = [];
    List<UserRankData> rest = [];
    for (int i = 0; i < sortedUsers.length; i++) {
      final user = sortedUsers[i];
      if (user.hours >= crystalThreshold) {
        crystal.add(user);
      } else if (user.hours >= goldThreshold) {
        gold.add(user);
      } else if (user.hours >= ironThreshold) {
        iron.add(user);
      } else if (user.hours >= bronzeThreshold) {
        bronze.add(user);
      } else {
        rest.add(user);
      }
    }
    Widget buildSection(String title, List<UserRankData> users) {
      if (users.isEmpty) return SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            itemCount: users.length,
            separatorBuilder:
                (context, index) => Divider(
                  height: 0,
                  thickness: 0.3,
                  indent: 24,
                  endIndent: 24,
                  color: Theme.of(context).dividerColor.withOpacity(0.08),
                ),
            itemBuilder: (context, index) {
              final userData = users[index];
              final visuals = _getRankVisualsBySection(title);
              Color ringColor = visuals['ringColor'];
              double ringWidth = visuals['ringWidth'];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 2.0,
                  horizontal: 16.0,
                ),
                child: Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  color: visuals['bg'],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: ringColor, width: ringWidth),
                      ),
                      child: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.08),
                        child: Text(
                          userData.name.isNotEmpty ? userData.name[0] : '',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    title: Text(
                      userData.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      '${userData.hours} hrs',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (visuals['icon'] != null)
                          Icon(visuals['icon'], color: visuals['iconColor']),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '#${userData.rank}',
                            style: Theme.of(
                              context,
                            ).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 12,
                    ),
                    dense: true,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              );
            },
          ),
        ],
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        buildSection('100 Hours', crystal),
        buildSection('70 Hours', gold),
        buildSection('40 Hours', iron),
        buildSection('15 Hours', bronze),
        buildSection('0 Hours', rest),
      ],
    );
  }

  Map<String, dynamic> _getRankVisualsBySection(String section) {
    switch (section) {
      case '100 Hours':
        return {
          'icon': Icons.brightness_5,
          'iconColor': Colors.cyan[400],
          'bg': Colors.cyan.withOpacity(0.13),
          'ringColor': Colors.cyan[400],
          'ringWidth': 3.0,
        };
      case '70 Hours':
        return {
          'icon': Icons.circle,
          'iconColor': Colors.amber[400],
          'bg': Colors.amber.withOpacity(0.10),
          'ringColor': Colors.amber[400],
          'ringWidth': 3.0,
        };
      case '40 Hours':
        return {
          'icon': Icons.circle,
          'iconColor': Colors.grey[400],
          'bg': Colors.grey.withOpacity(0.10),
          'ringColor': Colors.grey[400],
          'ringWidth': 3.0,
        };
      case '15 Hours':
        return {
          'icon': Icons.circle,
          'iconColor': Colors.brown[400],
          'bg': Colors.brown.withOpacity(0.10),
          'ringColor': Colors.brown[400],
          'ringWidth': 3.0,
        };
      default:
        return {
          'icon': null,
          'iconColor': null,
          'bg': Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withOpacity(0.10),
          'ringColor': Colors.transparent,
          'ringWidth': 0.0,
        };
    }
  }
}
