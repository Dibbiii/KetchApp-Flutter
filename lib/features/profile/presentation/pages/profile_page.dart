import 'dart:io'; // For File
import 'package:flutter/material.dart';
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
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _showShimmer = true;
  String? _username;

  @override
  void initState() {
    super.initState();
    _fetchUsernameAndLoadProfile();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showShimmer = false;
        });
      }
    });
    // Carica achievements tramite bloc
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileBloc>().add(LoadAchievements());
    });
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
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    InputDecoration styledInputDecoration({
      required String labelText,
      required IconData iconData,
      bool readOnly = true,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
                  backgroundColor: colors.surfaceContainerHighest,
                  child: ClipOval(
                    child: Image.network(
                      state.photoUrl!,
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.account_circle, size: 100, color: colors.onSurfaceVariant.withAlpha(153));
                      },
                    ),
                  ),
                );
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
                        initialValue: _username ?? 'N/A',
                        readOnly: true,
                        decoration: styledInputDecoration(
                          labelText: 'Username',
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
                      Builder(
                        builder: (context) {
                          if (state is ProfileLoaded) {
                            final achievementsLoading = state.achievementsLoading;
                            final achievementsError = state.achievementsError;
                            final allAchievements = state.allAchievements;
                            final completedAchievementTitles = state.completedAchievementTitles;
                            if (achievementsLoading) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (achievementsError != null) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(achievementsError, style: textTheme.bodyMedium?.copyWith(color: colors.error)),
                              );
                            } else {
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: allAchievements.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 1.8,
                                ),
                                itemBuilder: (context, index) {
                                  final achievement = allAchievements[index];
                                  final isCompleted = completedAchievementTitles.contains(achievement.title);
                                  return Card(
                                    color: isCompleted
                                        ? colors.primaryContainer.withAlpha(179)
                                        : colors.surfaceContainer.withAlpha(179),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: isCompleted ? colors.primary.withAlpha(128) : colors.outline.withAlpha(51),
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
                                            child: achievement.iconUrl.isNotEmpty
                                                ? Image.network(achievement.iconUrl, height: 28, width: 28, color: isCompleted ? colors.onPrimaryContainer : colors.onSurfaceVariant)
                                                : Icon(Icons.emoji_events_outlined, color: isCompleted ? colors.onPrimaryContainer : colors.onSurfaceVariant, size: 28),
                                          ),
                                          const SizedBox(height: 8),
                                          Flexible(
                                            child: Text(
                                              achievement.title,
                                              textAlign: TextAlign.center,
                                              style: textTheme.bodySmall?.copyWith(
                                                color: isCompleted ? colors.onPrimaryContainer : colors.onSurfaceVariant,
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
                              );
                            }
                          }
                          return const SizedBox.shrink();
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
            return const Center(child: Text('Stato sconosciuto.'));
          },
        ),
      ),
    );
  }
}

