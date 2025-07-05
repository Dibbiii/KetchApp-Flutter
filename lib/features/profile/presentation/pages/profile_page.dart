
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:ketchapp_flutter/features/profile/bloc/profile_bloc.dart';
import 'package:ketchapp_flutter/features/profile/bloc/profile_event.dart';
import 'package:ketchapp_flutter/features/profile/bloc/profile_state.dart';
import 'package:ketchapp_flutter/services/api_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'profile_shrimmer_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  bool _showShimmer = true;
  String? _username;

  late AnimationController _fadeAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final ScrollController _achievementsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchUsernameAndLoadProfile();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showShimmer = false;
        });
        _fadeAnimationController.forward();
        _scaleAnimationController.forward();
      }
    });
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
  }

  @override
  void dispose() {
    _achievementsScrollController.dispose();
    _fadeAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsernameAndLoadProfile() async {
    final authState = context.read<AuthBloc>().state;
    String? userUuid;
    if (authState is Authenticated) {
      userUuid = authState.userUuid;
    }
    if (userUuid != null) {
      try {
        final apiService = context.read<ApiService>();
        final userData = await apiService.fetchData('users/$userUuid');
        setState(() {
          _username = userData['username'] as String?;
        });
      } catch (e) {
        setState(() {
          _username = null;
        });
      }
    }
    context.read<ProfileBloc>().add(LoadProfile());
  }

  void _dispatchPickImage(ImageSource source) async {
    final currentBlocState = context.read<ProfileBloc>().state;
    if (currentBlocState is ProfileLoaded && currentBlocState.isUploadingImage) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Operazione immagine già in corso...')),
        );
      return;
    }
    PermissionStatus status;
    if (source == ImageSource.camera) {
      if (Platform.isAndroid || Platform.isIOS) {
        status = await Permission.camera.request();
      } else {
        status = PermissionStatus.granted;
      }
      if (status.isPermanentlyDenied) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: const Text('Permesso fotocamera negato in modo permanente. Abilitalo dalle impostazioni.'),
              action: SnackBarAction(
                label: 'Impostazioni',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        return;
      }
      if (!status.isGranted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Permesso fotocamera negato.')),
          );
        return;
      }
    } else if (source == ImageSource.gallery) {
      if (Platform.isAndroid) {
        status = await Permission.storage.request();
      } else if (Platform.isIOS) {
        status = await Permission.photos.request();
      } else {
        status = PermissionStatus.granted;
      }
      if (status.isPermanentlyDenied) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: const Text('Permesso libreria foto negato in modo permanente. Abilitalo dalle impostazioni.'),
              action: SnackBarAction(
                label: 'Impostazioni',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        return;
      }
      if (!status.isGranted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Permesso libreria foto negato.')),
          );
        return;
      }
    }
    context.read<ProfileBloc>().add(ProfileImagePickRequested(source));
  }

  void _dispatchDeleteProfileImage() {
    final currentBlocState = context.read<ProfileBloc>().state;
    if (currentBlocState is ProfileLoaded && currentBlocState.isUploadingImage) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Operazione immagine già in corso...')),
        );
      return;
    }
    context.read<ProfileBloc>().add(ProfileImageDeleteRequested());
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
      child: Scaffold(
        backgroundColor: colors.surface,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.primary.withAlpha((255 * 0.05).round()),
                colors.surface,
              ],
            ),
          ),
          child: BlocListener<ProfileBloc, ProfileState>(
            listener: _handleProfileStateChanges,
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (_showShimmer || state is ProfileLoading) {
                  return const ProfileShrimmerPage();
                }

                if (state is ProfileError) {
                  return _buildErrorState(context, state.message, colors, textTheme);
                }

                if (state is ProfileLoaded) {
                  return _buildLoadedState(context, state, colors, textTheme);
                }

                return _buildInitializingState(context, colors, textTheme);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleProfileStateChanges(BuildContext context, ProfileState state) {
    final colors = Theme.of(context).colorScheme;

    if (state is ProfileUpdateSuccess) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(state.message),
          backgroundColor: colors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
    } else if (state is ProfileError) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(state.message),
          backgroundColor: colors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
    }
  }

  Widget _buildInitializingState(BuildContext context, ColorScheme colors, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withAlpha((255 * 0.8).round()),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withAlpha((255 * 0.1).round()),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: colors.primary,
              backgroundColor: colors.primary.withAlpha((255 * 0.1).round()),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your profile...',
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error, ColorScheme colors, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.errorContainer.withAlpha((255 * 0.8).round()),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.error.withAlpha((255 * 0.1).round()),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.person_off_outlined,
                color: colors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to load profile',
              style: textTheme.headlineSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                error,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              onPressed: () => context.read<ProfileBloc>().add(LoadProfile()),
              style: FilledButton.styleFrom(
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.onPrimaryContainer,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, ProfileLoaded state, ColorScheme colors, TextTheme textTheme) {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildProfileHeader(context, state, colors, textTheme),
                    const SizedBox(height: 24),
                    _buildProfileInfoSection(context, state, colors, textTheme),
                    const SizedBox(height: 24),
                    _buildAchievementsSection(context, state, colors, textTheme),
                    const SizedBox(height: 24),
                    _buildLogoutSection(context, colors, textTheme),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileLoaded state, ColorScheme colors, TextTheme textTheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.primary.withAlpha((255 * 0.15).round()),
                colors.tertiary.withAlpha((255 * 0.1).round()),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.primary.withAlpha((255 * 0.15).round()),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: _buildProfileAvatar(state, colors),
        ),
      ],
    );
  }

  Widget _buildProfileAvatar(ProfileLoaded state, ColorScheme colors) {
    Widget avatarContent;

    if (state.localPreviewFile != null) {
      avatarContent = CircleAvatar(
        radius: 36,
        backgroundImage: FileImage(state.localPreviewFile!),
      );
    } else if (state.photoUrl != null) {
      avatarContent = CircleAvatar(
        radius: 36,
        backgroundColor: colors.surfaceContainerHighest,
        child: ClipOval(
          child: Image.network(
            state.photoUrl!,
            fit: BoxFit.cover,
            width: 72,
            height: 72,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.account_circle_rounded,
                size: 72,
                color: colors.onSurfaceVariant.withAlpha((255 * 0.6).round()),
              );
            },
          ),
        ),
      );
    } else {
      avatarContent = Icon(
        Icons.account_circle_rounded,
        size: 72,
        color: colors.onSurfaceVariant.withAlpha((255 * 0.6).round()),
      );
    }

    if (state.isUploadingImage) {
      avatarContent = Stack(
        alignment: Alignment.center,
        children: [
          avatarContent,
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.surface.withAlpha((255 * 0.8).round()),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.primary,
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        avatarContent,
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.surface,
                width: 2,
              ),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.edit_rounded,
                size: 18,
                color: colors.onPrimaryContainer,
              ),
              offset: const Offset(0, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (String result) {
                if (result == 'take_photo') {
                  _dispatchPickImage(ImageSource.camera);
                } else if (result == 'library_photo') {
                  _dispatchPickImage(ImageSource.gallery);
                } else if (result == 'delete_photo') {
                  _dispatchDeleteProfileImage();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'take_photo',
                  child: ListTile(
                    leading: Icon(Icons.photo_camera_rounded, color: colors.primary),
                    title: const Text('Take Photo'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'library_photo',
                  child: ListTile(
                    leading: Icon(Icons.photo_library_rounded, color: colors.primary),
                    title: const Text('Photo Library'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (state.photoUrl != null || state.localPreviewFile != null)
                  PopupMenuItem<String>(
                    value: 'delete_photo',
                    child: ListTile(
                      leading: Icon(Icons.delete_rounded, color: colors.error),
                      title: Text(
                        'Delete Photo',
                        style: TextStyle(color: colors.error),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfoSection(BuildContext context, ProfileLoaded state, ColorScheme colors, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colors.outline.withAlpha((255 * 0.08).round()),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withAlpha((255 * 0.04).round()),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.primaryContainer.withAlpha((255 * 0.8).round()),
                    colors.tertiaryContainer.withAlpha((255 * 0.6).round()),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.primary.withAlpha((255 * 0.15).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: colors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Personal Informations",
                          style: textTheme.titleLarge?.copyWith(
                            color: colors.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.25,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Your account details",
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onPrimaryContainer.withAlpha((255 * 0.8).round()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoField(
                    'Username',
                    _username ?? 'N/A',
                    Icons.person_outline_rounded,
                    colors,
                    textTheme,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoField(
                    'Email',
                    state.email ?? 'N/A',
                    Icons.email_outlined,
                    colors,
                    textTheme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value, IconData icon, ColorScheme colors, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh.withAlpha((255 * 0.6).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outline.withAlpha((255 * 0.1).round()),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.primaryContainer.withAlpha((255 * 0.8).round()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: colors.primary,
            size: 20,
          ),
        ),
        title: Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context, ProfileLoaded state, ColorScheme colors, TextTheme textTheme) {
    final completedCount = state.completedAchievementTitles.length;
    final totalCount = state.allAchievements.length;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: colors.outline.withAlpha((255 * 0.08).round()),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withAlpha((255 * 0.04).round()),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.primary.withAlpha((255 * 0.12).round()),
                    colors.secondary.withAlpha((255 * 0.08).round()),
                    colors.tertiary.withAlpha((255 * 0.06).round()),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colors.primary.withAlpha((255 * 0.2).round()),
                          colors.secondary.withAlpha((255 * 0.15).round()),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withAlpha((255 * 0.15).round()),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: colors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Achievements",
                          style: textTheme.titleLarge?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.25,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Your focus milestones",
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colors.primaryContainer,
                          colors.secondaryContainer.withAlpha((255 * 0.8).round()),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.primary.withAlpha((255 * 0.2).round()),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withAlpha((255 * 0.1).round()),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$completedCount',
                          style: textTheme.titleMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '/$totalCount',
                          style: textTheme.titleMedium?.copyWith(
                            color: colors.onPrimaryContainer.withAlpha((255 * 0.8).round()),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5 * 80.0,
              child: Stack(
                children: [
                  _buildAchievementsGrid(
                    state,
                    colors,
                    textTheme,
                  ),

                  Positioned.fill(
                    child: IgnorePointer(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Scrollbar(
                            thumbVisibility: true,
                            thickness: 5,
                            radius: const Radius.circular(8),
                            child: Container(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsGrid(ProfileLoaded state, ColorScheme colors, TextTheme textTheme) {
    if (state.achievementsLoading) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withAlpha((255 * 0.3).round()),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: colors.primary,
                backgroundColor: colors.primary.withAlpha((255 * 0.2).round()),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading achievements...',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (state.achievementsError != null) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.errorContainer.withAlpha((255 * 0.3).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: colors.error,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to load achievements',
              style: textTheme.titleSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              state.achievementsError!,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Scrollbar(
        controller: _achievementsScrollController,
        thumbVisibility: true,
        thickness: 5,
        radius: const Radius.circular(8),
        child: GridView.builder(
          controller: _achievementsScrollController,
          shrinkWrap: false,
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: state.allAchievements.length,
          itemBuilder: (context, index) {
            final achievement = state.allAchievements[index];
            final isCompleted = achievement['completed'] == true;
            return _buildAchievementCard(achievement, isCompleted, colors, textTheme);
          },
        ),
      ),
    );
  }

  Widget _buildAchievementCard(dynamic achievement, bool isCompleted, ColorScheme colors, TextTheme textTheme) {
    final description = achievement['description'] ?? 'No description';
    final iconUrl = achievement['icon'] ?? '';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCompleted
              ? [
                  colors.primaryContainer.withAlpha((255 * 0.9).round()),
                  colors.secondaryContainer.withAlpha((255 * 0.7).round()),
                ]
              : [
                  colors.surfaceContainerHigh.withAlpha((255 * 0.8).round()),
                  colors.surfaceContainer.withAlpha((255 * 0.6).round()),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? colors.primary.withAlpha((255 * 0.4).round())
              : colors.outline.withAlpha((255 * 0.15).round()),
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCompleted
                ? colors.primary.withAlpha((255 * 0.15).round())
                : colors.shadow.withAlpha((255 * 0.05).round()),
            blurRadius: isCompleted ? 8 : 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    description,
                    style: textTheme.bodyMedium?.copyWith(
                      color: isCompleted ? colors.onPrimaryContainer : colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.left,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isCompleted)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.primary,
                        colors.secondary,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withAlpha((255 * 0.3).round()),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: colors.secondary,
                      width: 2.5,
                    ),
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: colors.onPrimary,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildLogoutSection(BuildContext context, ColorScheme colors, TextTheme textTheme) {
    return FilledButton.icon(
      icon: const Icon(Icons.logout_rounded),
      label: const Text('Logout'),
      onPressed: () {
        context.read<AuthBloc>().add(AuthLogoutRequested());
        context.go('/');
      },
      style: FilledButton.styleFrom(
        backgroundColor: colors.error,
        foregroundColor: colors.onError,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        textStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
