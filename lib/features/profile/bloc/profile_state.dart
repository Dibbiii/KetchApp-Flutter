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
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final bool isUploadingImage; //  Per gestire lo stato di caricamento/eliminazione dell'immagine
  final File? localPreviewFile; // Added for local preview

  const ProfileLoaded({
    this.displayName,
    this.email,
    this.photoUrl,
    this.isUploadingImage = false,
    this.localPreviewFile, // Added
  });

  ProfileLoaded copyWith({
    String? displayName,
    String? email,
    String? photoUrl,
    bool? isUploadingImage,
    File? localPreviewFile,
    bool clearLocalPreviewFile = false, // Helper to explicitly nullify
    // User? firebaseUser, // This was in your original code, ensure it's used if needed or remove
  }) {
    return ProfileLoaded(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      localPreviewFile: clearLocalPreviewFile ? null : localPreviewFile ?? this.localPreviewFile,
    );
  }

  @override
  List<Object?> get props => [displayName, email, photoUrl, isUploadingImage, localPreviewFile];
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
