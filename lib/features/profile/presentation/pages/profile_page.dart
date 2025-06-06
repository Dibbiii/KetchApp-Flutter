import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart'; // For ImageSource
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:ketchapp_flutter/features/profile/bloc/profile_bloc.dart';
import 'package:ketchapp_flutter/features/profile/bloc/profile_event.dart';
import 'package:ketchapp_flutter/features/profile/bloc/profile_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'profile_shrimmer_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _showShimmer = true;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfile());
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showShimmer = false;
        });
      }
    });
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
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    InputDecoration styledInputDecoration({
      required String labelText,
      required IconData iconData,
      bool readOnly = true, // Assuming fields are read-only for now
    }) {
      return InputDecoration(
        labelText: labelText,
        labelStyle: textTheme.bodyLarge?.copyWith(
          color: colors.onSurfaceVariant,
        ),
        prefixIcon: Icon(iconData, color: colors.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.outline.withAlpha(128)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.outline.withAlpha(128)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: readOnly
            ? colors.surfaceContainerHighest.withAlpha(25)
            : colors.surfaceContainerHighest.withAlpha(76),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
      );
    }

    final List<Achievement> achievements = [
      Achievement(icon: Icons.timer_outlined, title: 'Study for 5 hours', isCompleted: true),
      Achievement(icon: Icons.self_improvement_outlined, title: 'Distraction-free session', isCompleted: false),
      Achievement(icon: Icons.leaderboard_outlined, title: 'Top 10 Global Ranking', isCompleted: false),
      Achievement(icon: Icons.check_circle_outline, title: 'Complete all Tomatoes', isCompleted: true),
      Achievement(icon: Icons.whatshot_outlined, title: 'Continue the Streak', isCompleted: false),
      Achievement(icon: Icons.radar_outlined, title: 'Achieve 90% focus rate during the study session', isCompleted: false),
      Achievement(icon: Icons.share_outlined, title: 'Share your achievements', isCompleted: false),
      Achievement(icon: Icons.star_outline, title: 'Rate the app', isCompleted: false),
    ];


    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Impostazioni',
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ));
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: colors.error,
              ));
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (_showShimmer || state is ProfileLoading) {
              return const ProfileShrimmerPage();
            }

            if (state is ProfileError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Errore: ${state.message}', textAlign: TextAlign.center),
                ),
              );
            }

            if (state is ProfileLoaded) {
              Widget avatarContent;
              if (state.localPreviewFile != null) {
                avatarContent = CircleAvatar(
                    radius: 50,
                    backgroundImage: FileImage(state.localPreviewFile!));
              } else if (state.photoUrl != null) {
                avatarContent = CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(state.photoUrl!));
              } else {
                avatarContent = Icon(Icons.account_circle,
                    size: 100, color: colors.onSurfaceVariant.withAlpha(153));
              }

              if (state.isUploadingImage) {
                avatarContent = Stack(
                  alignment: Alignment.center,
                  children: [
                    avatarContent,
                    const CircularProgressIndicator(),
                  ],
                );
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Padding( // Add padding to ensure spinner doesn't overlap popup button too much
                              padding: const EdgeInsets.all(4.0),
                              child: avatarContent,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: colors.surfaceContainerHighest,
                                child: PopupMenuButton<String>(
                                  icon: Icon(Icons.edit, size: 18, color: colors.primary), // Adjusted size
                                  offset: const Offset(0, 40), // Adjust offset as needed
                                  onSelected: (String result) {
                                    if (result == 'take_photo') {
                                      _dispatchPickImage(ImageSource.camera);
                                    } else if (result == 'library_photo') {
                                      _dispatchPickImage(ImageSource.gallery);
                                    } else if (result == 'delete_photo') {
                                      _dispatchDeleteProfileImage();
                                    }
                                  },
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: 'take_photo',
                                      child: ListTile(
                                        leading: Icon(Icons.photo_camera),
                                        title: Text('Scatta foto'),
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'library_photo',
                                      child: ListTile(
                                        leading: Icon(Icons.photo_library),
                                        title: Text('Libreria foto'),
                                      ),
                                    ),
                                    if (state.photoUrl != null || state.localPreviewFile != null)
                                      const PopupMenuItem<String>(
                                        value: 'delete_photo',
                                        child: ListTile(
                                          leading: Icon(Icons.delete, color: Colors.red),
                                          title: Text(
                                            'Elimina foto',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        initialValue: state.displayName ?? 'N/A',
                        readOnly: true,
                        decoration: styledInputDecoration(
                          labelText: 'Display Name',
                          iconData: Icons.person_outline,
                        ),
                        style: textTheme.bodyLarge?.copyWith(color: colors.onSurface),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: state.email ?? 'N/A',
                        readOnly: true,
                        decoration: styledInputDecoration(
                          labelText: 'Email',
                          iconData: Icons.email_outlined,
                        ),
                         style: textTheme.bodyLarge?.copyWith(color: colors.onSurface),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Achievements',
                        style: textTheme.titleLarge?.copyWith(color: colors.onSurface),
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: achievements.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.8, // Più spazio verticale
                        ),
                        itemBuilder: (context, index) {
                          final achievement = achievements[index];
                          return Card(
                            color: achievement.isCompleted
                                ? colors.primaryContainer.withAlpha(179)
                                : colors.surfaceContainer.withAlpha(179),
                            elevation: 0,
                             shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: achievement.isCompleted ? colors.primary.withAlpha(128) : colors.outline.withAlpha(51),
                                  width: 1,
                                ),
                              ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Icon(
                                      achievement.icon,
                                      color: achievement.isCompleted ? colors.onPrimaryContainer : colors.onSurfaceVariant,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Flexible(
                                    child: Text(
                                      achievement.title,
                                      textAlign: TextAlign.center,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: achievement.isCompleted ? colors.onPrimaryContainer : colors.onSurfaceVariant,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        onPressed: () {
                          context.read<AuthBloc>().add(AuthLogoutRequested());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.errorContainer,
                          foregroundColor: colors.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            // Fallback for any unhandled state
            return const Center(child: Text('Stato sconosciuto.'));
          },
        ),
      ),
    );
  }
}

// Helper class for Achievements (if not already defined elsewhere)
class Achievement {
  final IconData icon;
  final String title;
  final bool isCompleted;

  Achievement({
    required this.icon,
    required this.title,
    required this.isCompleted,
  });
}

