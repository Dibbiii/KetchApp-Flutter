import 'dart:async'; // Import for Timer

import 'package:confetti/confetti.dart'; // Import for confetti
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ketchapp_flutter/services/api_service.dart';

import 'package:ketchapp_flutter/features/rankings/bloc/ranking_bloc.dart';
import 'package:ketchapp_flutter/features/rankings/bloc/ranking_event.dart';
import 'package:ketchapp_flutter/features/rankings/bloc/ranking_state.dart';
import 'package:ketchapp_flutter/features/rankings/presentation/ranking_shrimmer_page.dart';

class UserRankData {
  final String name;
  final int rank;
  final int hours;

  UserRankData({required this.name, required this.rank, required this.hours});

  factory UserRankData.fromJson(Map<String, dynamic> json, int rank) {
    return UserRankData(
      name: json['username'] as String,
      hours: (json['totalHours'] as num).toInt(),
      rank: rank,
    );
  }
}

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {

  List<UserRankData> _allGlobalUsers = [];

  List<UserRankData> _activeList =
      [];
  List<UserRankData> _filteredUsers = [];
  String _currentSearchQuery = ''; // To store the current search query
  Timer? _debounce;
  late ConfettiController
      _confettiController;

  @override
  void initState() {
    super.initState();
    context.read<RankingBloc>().add(LoadRanking());
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    _setActiveListAndFilter();
  }

  void _setActiveListAndFilter() {
    if (mounted) {
      setState(() {
        _activeList = _allGlobalUsers;
        _performFiltering();
      });
    }
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
    _debounce?.cancel();
    _confettiController.dispose(); // Dispose confetti controller
    super.dispose();
  }

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

  void _performFiltering() {
    final listToFilter = _activeList;

    final filtered =
        listToFilter.where((userData) {
          return userData.name.toLowerCase().contains(
            _currentSearchQuery.toLowerCase(),
          );
        }).toList();

    if (mounted) {
      setState(() {
        _filteredUsers = filtered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RankingBloc, RankingState>(
      builder: (context, state) {
        if (state is RankingLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _allGlobalUsers = state.users;
                _activeList = _allGlobalUsers;
                _performFiltering();
              });
            }
          });
        }
        return SafeArea(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              if (state is RankingLoading)
                const RankingShrimmerPage(showSearchBar: true)
              else ...[
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 4.0),
                      child: Text(
                        'Global Ranking',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
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
                    minBlastForce: 5,
                    emissionFrequency: 0.12,
                    numberOfParticles: 30,
                    gravity: 0.08,
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
    );
  }

  Widget _buildRankingListBloc(RankingState state) {
    final users = _filteredUsers;
    final filter = state is RankingLoaded ? state.filter : RankingFilter.hours;
    List<UserRankData> sortedUsers = List.from(users);
    if (filter == RankingFilter.hours) {
      sortedUsers.sort((a, b) => b.hours.compareTo(a.hours));
    } else if (filter == RankingFilter.streak) {
    } else if (filter == RankingFilter.advancements) {
    }
    const int crystalThreshold = 6;
    const int goldThreshold = 5;
    const int ironThreshold = 4;
    const int bronzeThreshold = 3;
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
                    leading: SizedBox(
                      width: 50,
                      child: Center(
                        child: Text(
                          '#${userData.rank}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
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
                    trailing: (visuals['icon'] != null)
                        ? Icon(visuals['icon'], color: visuals['iconColor'])
                        : null,
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
