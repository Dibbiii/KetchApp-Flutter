import 'dart:io'; // Required for File type
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Potrebbe essere utile per passare l'utente

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String? username;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final bool isUploadingImage; //  Per gestire lo stato di caricamento/eliminazione dell'immagine
  final File? localPreviewFile;
  // Achievements
  final List<dynamic> allAchievements;
  final Set<String> completedAchievementTitles;
  final bool achievementsLoading;
  final String? achievementsError;

  const ProfileLoaded({
    this.username,
    this.displayName,
    this.email,
    this.photoUrl,
    this.isUploadingImage = false,
    this.localPreviewFile, // Added
    this.allAchievements = const [],
    this.completedAchievementTitles = const {},
    this.achievementsLoading = false,
    this.achievementsError,
  });

  ProfileLoaded copyWith({
    String? username,
    String? displayName,
    String? email,
    String? photoUrl,
    bool? isUploadingImage,
    File? localPreviewFile,
    bool clearLocalPreviewFile = false,
    List<dynamic>? allAchievements,
    Set<String>? completedAchievementTitles,
    bool? achievementsLoading,
    String? achievementsError,
  }) {
    return ProfileLoaded(
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      localPreviewFile: clearLocalPreviewFile ? null : localPreviewFile ?? this.localPreviewFile,
      allAchievements: allAchievements ?? this.allAchievements,
      completedAchievementTitles: completedAchievementTitles ?? this.completedAchievementTitles,
      achievementsLoading: achievementsLoading ?? this.achievementsLoading,
      achievementsError: achievementsError,
    );
  }

  @override
  List<Object?> get props => [username, displayName, email, photoUrl, isUploadingImage, localPreviewFile, allAchievements, completedAchievementTitles, achievementsLoading, achievementsError];
}

class ProfileUpdateSuccess extends ProfileState {
  final String message;
  const ProfileUpdateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
