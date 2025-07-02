import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _RankingPageState extends State<RankingPage>
    with TickerProviderStateMixin {
  List<UserRankData> _allGlobalUsers = [];
  List<UserRankData> _activeList = [];
  List<UserRankData> _filteredUsers = [];
  String _currentSearchQuery = '';
  Timer? _debounce;
  late ConfettiController _confettiController;

  late AnimationController _fadeAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    context.read<RankingBloc>().add(LoadRanking());
    _initializeAnimations();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _setActiveListAndFilter();
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleAnimationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimationController.forward();
    _scaleAnimationController.forward();
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
    _confettiController.dispose();
    _fadeAnimationController.dispose();
    _scaleAnimationController.dispose();
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
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: colors.brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
      statusBarBrightness: colors.brightness,
      systemNavigationBarColor: colors.surface,
      systemNavigationBarIconBrightness: colors.brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: BlocBuilder<RankingBloc, RankingState>(
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

          return Scaffold(
            backgroundColor: colors.surface,
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.primary.withOpacity(0.05),
                    colors.surface,
                  ],
                ),
              ),
              child: SafeArea(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    if (state is RankingLoading)
                      const RankingShrimmerPage(showSearchBar: true)
                    else
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: _buildLoadedContent(context, state, colors, textTheme),
                        ),
                      ),
                    // Confetti widgets
                    if (_filteredUsers.isNotEmpty &&
                        _filteredUsers.first.rank == 1 &&
                        _currentSearchQuery.isEmpty) ...[
                      _buildConfettiEffects(),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, RankingState state, ColorScheme colors, TextTheme textTheme) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
            child: Column(
              children: [
                _buildRankingHeader(context, colors, textTheme),
                const SizedBox(height: 32),
                _buildSearchSection(context, colors, textTheme),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildRankingList(state, colors, textTheme),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  Widget _buildRankingHeader(BuildContext context, ColorScheme colors, TextTheme textTheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.primary.withOpacity(0.15),
                colors.tertiary.withOpacity(0.1),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.primary.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.leaderboard_outlined,
            size: 72,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Global Ranking',
          style: textTheme.displaySmall?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.outline.withOpacity(0.1),
            ),
          ),
          child: Text(
            "Compete with focus masters worldwide",
            style: textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection(BuildContext context, ColorScheme colors, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.outline.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for focus champions...',
          hintStyle: textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.search_rounded,
              color: colors.primary,
              size: 20,
            ),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
        style: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        onChanged: _filterUsers,
      ),
    );
  }

  Widget _buildRankingList(RankingState state, ColorScheme colors, TextTheme textTheme) {
    final users = _filteredUsers;
    final filter = state is RankingLoaded ? state.filter : RankingFilter.hours;
    List<UserRankData> sortedUsers = List.from(users);

    if (filter == RankingFilter.hours) {
      sortedUsers.sort((a, b) => b.hours.compareTo(a.hours));
    }

    // Define tier thresholds
    const int diamondThreshold = 100;
    const int goldThreshold = 70;
    const int silverThreshold = 40;
    const int bronzeThreshold = 15;

    List<UserRankData> diamond = [];
    List<UserRankData> gold = [];
    List<UserRankData> silver = [];
    List<UserRankData> bronze = [];
    List<UserRankData> starter = [];

    for (final user in sortedUsers) {
      if (user.hours >= diamondThreshold) {
        diamond.add(user);
      } else if (user.hours >= goldThreshold) {
        gold.add(user);
      } else if (user.hours >= silverThreshold) {
        silver.add(user);
      } else if (user.hours >= bronzeThreshold) {
        bronze.add(user);
      } else {
        starter.add(user);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildTierSection('Diamond Elite', '100+ Hours', diamond, Icons.diamond_outlined, colors.primary, colors, textTheme),
          _buildTierSection('Gold Masters', '70+ Hours', gold, Icons.emoji_events_outlined, const Color(0xFFFFD700), colors, textTheme),
          _buildTierSection('Silver Champions', '40+ Hours', silver, Icons.military_tech_outlined, const Color(0xFFC0C0C0), colors, textTheme),
          _buildTierSection('Bronze Warriors', '15+ Hours', bronze, Icons.workspace_premium_outlined, const Color(0xFFCD7F32), colors, textTheme),
          _buildTierSection('Rising Stars', '0+ Hours', starter, Icons.star_outline_rounded, colors.tertiary, colors, textTheme),
        ],
      ),
    );
  }

  Widget _buildTierSection(String tierName, String requirement, List<UserRankData> users, IconData icon, Color tierColor, ColorScheme colors, TextTheme textTheme) {
    if (users.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colors.outline.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tierColor.withOpacity(0.15),
                    tierColor.withOpacity(0.08),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: tierColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      color: tierColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tierName,
                          style: textTheme.titleLarge?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.25,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          requirement,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: tierColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${users.length}',
                      style: textTheme.labelLarge?.copyWith(
                        color: tierColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final userData = users[index];
                return _buildEnhancedUserTile(userData, tierColor, colors, textTheme);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedUserTile(UserRankData userData, Color tierColor, ColorScheme colors, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outline.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tierColor.withOpacity(0.2),
                tierColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: tierColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              '#${userData.rank}',
              style: textTheme.titleMedium?.copyWith(
                color: tierColor,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          userData.name,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        subtitle: Text(
          '${userData.hours} hours focused',
          style: textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: tierColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.trending_up_rounded,
            color: tierColor,
            size: 16,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildConfettiEffects() {
    return Stack(
      children: [
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
    );
  }
}
